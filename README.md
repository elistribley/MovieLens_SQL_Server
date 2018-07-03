# MovieLens_SQL_Server
processing MovieLens dataset using SQL Server 

carry out some queries and do further optimization

implement a simple recommendation algorithm using python

## file description
**basic data importing and formatting: in branch master**

- func.sql: create database and spilt function
- ready.sql: import data from csv file and convert to proper format  
- matrix.sql: produce the Incidence Matrices of User-Movie & User-User

**basic queries: in branch hzj**

- query.sql: 4 simple queries
- query5.sql: one more complex query

**query optimization: in branch yg**

- optimize/*.sql: do optimization for different queries with all kinds of technique

**recommendation algorithm: in branch master**

- recommend.py: import & export data between sql and python, then produce recommendation for every User  