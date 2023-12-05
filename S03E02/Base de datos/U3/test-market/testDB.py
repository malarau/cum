import os, oracledb

connection = oracledb.connect(user="sys", password='demodb', dsn="localhost/XE", mode=oracledb.SYSDBA)

cursor = connection.cursor()


for row in cursor.execute("select * from productos"):
    print(row)