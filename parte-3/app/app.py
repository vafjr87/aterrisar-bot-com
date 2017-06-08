#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pymysql

db = pymysql.connect(host='virgiliofernandes.me', user='', password='', database='')
cursor = db.cursor()
cursor.execute("SHOW TABLES")
data = cursor.fetchall()
print(data)
db.close()