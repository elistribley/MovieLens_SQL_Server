import os
import sys
import argparse
import signal
import pymssql as sql

def handler(signum, frame):
    print("exiting...")
    if "conn" in globals():
        conn.close()
    sys.exit()

signal.signal(signal.SIGINT, handler)


parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("-S", "--server", type=str, required=True, help="SQL Server instance name\
    \nNOTE: if you use name like COMPUTE_NAME/SQLSERVER and fail, try with COMPUTER_NAME only")
parser.add_argument("-U", "--user", type=str, required=True, help="User name used to login the server")
parser.add_argument("-P", "--passward", type=str, required=True, help="login passward")
parser.add_argument("-D", "--database", type=str, required=True, help="database name to connect to")
parser.add_argument("-k1", "--k1", type=int, default=3, help="top-k1 users'info used for recommendation")
parser.add_argument("-k2", "--k2", type=int, default=10, help="top-k2 movies of a user ranking is used")

def main():
    args = parser.parse_args()
    server = args.server
    user = args.user
    passwd = args.passward
    database = args.database
    global conn
    conn = sql.connect(server, user, passwd, database, port="1433")
    # cursor
    cursor = conn.cursor()

    # NOTE: all tables below use ***sequence number*** instead of id
    # import user-moive matrix
    cursor.execute("SELECT * FROM dbo.UserMovieMatrix_seq")
    # NOTE: UserMovieMatrix is ordered by 1. UserSeq 2. MovieSeq
    row = cursor.fetchone()
    user_movie = []
    idx = 0
    while row:
        if row[0] == idx:
            user_movie[-1].append(list(row[1:]))
        else:
            user_movie.append([])
            user_movie[-1].append(list(row[1:]))
            idx = row[0]
        row = cursor.fetchone()

    # import user-user matrix
    cursor.execute("SELECT * FROM dbo.UserUserMatrix_seq")
    # NOTE: UserUserMatrix is ordered by 1. UserID1 2. UserID2
    row = cursor.fetchone()
    user_user = []
    idx = 0
    while row:
        if row[0] == idx:
            user_user[-1].append(list(row[1:]))
        else:
            user_user.append([])
            user_user[-1].append(list(row[1:]))
            idx = row[0]
        row = cursor.fetchone()

    # sort the user-movie matrix in terms of ranking
    user_movie = [sorted(one_user, key=lambda x:x[-1], reverse=True) for one_user in user_movie]
    # sort the user-user matrix in terms of similarity
    user_user = [sorted(one_user, key=lambda x:x[-1], reverse=True) for one_user in user_user]

    # find top-k1 similar users of a user
    k1 = args.k1
    uu_topk1 = []
    for one_user in user_user:
        # avoid overflow
        num = len(one_user)
        topk1 = map(lambda x:x[0], one_user[:min(k1, num)])
        uu_topk1.append(topk1)

    # find top-k2 ranked movies of any user
    k2 = args.k2
    um_topk2 = []
    for one_user in user_movie:
        # avoid overflow
        num = len(one_user)
        topk2 = map(lambda x:x[0], one_user[:min(k2, num)])
        um_topk2.append(topk2)
    
    # recommend
    # use the union of top-k2 ranked movies of all top-k1 similar users of a user
    # and minus those user has seen
    u_reco = []
    for idx, topk1 in enumerate(uu_topk1):
        # use set for uniqueness
        union = set()
        for u in topk1:
            # NOTE: the index starts from 0
            topk2 = um_topk2[u-1]
            union = union | set(topk2)
        
        # find all movies user has seen
        m_seen = map(lambda x:x[0], user_movie[idx])
        # minus from union
        union = union - set(m_seen)
        u_reco.append(list(union))

    # create table and insert into database
    cursor.execute(
        "IF OBJECT_ID('dbo.UserRecoMovie', 'U') IS NOT NULL \
         DROP TABLE dbo.UserRecoMovie"
    )
    cursor.execute(
        "CREATE TABLE dbo.UserRecoMovie \
        (USeq INT NOT NULL, \
        MSeq INT NOT NULL, \
        PRIMARY KEY (USeq, MSeq));"
    )
    # insert into table one row per time
    for idx, one_user in enumerate(u_reco):
        # NOTE: id = idx + 1
        for mseq in one_user:
            cursor.execute("INSERT INTO dbo.UserRecoMovie VALUES (%d, %d)", (idx+1, mseq))
    
    # do commit
    conn.commit()
    conn.close()

if __name__ == "__main__":
    main()

