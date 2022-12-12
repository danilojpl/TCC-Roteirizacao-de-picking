from src import queries as QR
import random

def geraFilaLotes(instanceSQL, gerador):
    cursor=instanceSQL.cursor()
    dados_gerador = {}
    i = 0
    while 1:
        row = gerador.fetchone()
        if not row:
            break
        else:
            dados_gerador[i] = [row.LOCAL, row.VERTICE]
        i = i+1
            
    num_lotes = 1000
    lote = 1
    produto = 1
    for i in range(num_lotes):
        num_produtos = random.randint(6,80)
        for j in range(num_produtos):
            dados_produto = random.choice(dados_gerador)
            cursor.execute("insert into LISTA_SEPARACAO(lote,produto, peso, local) values (?,?,NULL,?)",lote,'Produto'+str(produto),dados_produto[0])
            produto+=1
        lote+=1   
        produto = 1
    instanceSQL.commit()