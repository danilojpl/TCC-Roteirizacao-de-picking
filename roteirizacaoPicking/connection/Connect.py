import pyodbc


class ConnectSQL:
    def __init__(self, server, database, uid, pwd):
        self.server = server
        self.database = database
        self.uid = uid
        self.pwd = pwd
        
    # connection string 
    def getSession(self):
        connection = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+self.server+';DATABASE='+self.database+';Trusted_Connection=yes')
        return connection

# cursor=connection.cursor()
# cursor.execute("SELECT top 10 descricao1 as produto from produtos")
# while 1:
#     row = cursor.fetchone()
#     if not row:
#         break
#     print(row.produto)
# cursor.close()
# connection.close()