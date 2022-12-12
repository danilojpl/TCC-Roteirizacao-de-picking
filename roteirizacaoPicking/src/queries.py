from collections import defaultdict
from email.policy import default
from utils.ConfigFile import *
import connection.Connect as Connect
class Queries:
    def __init__(self, instance):
        self.instanceSQL = instance


    def test(self):
        cursor=self.instanceSQL.cursor()
        cursor.execute("SELECT top 10 descricao1 as produto from produtos")
        while 1:
            row = cursor.fetchone()
            if not row:
                break
            print(row.produto)
        cursor.close()
        self.instanceSQL.close()

    def locais(self):
        cursor=self.instanceSQL.cursor()
        cursor.execute("SELECT distinct VERTICE from PRJ_LOCAIS ")
        return cursor

    def connections(self):
        cursor=self.instanceSQL.cursor()
        cursor.execute("SELECT vertice1,vertice2, weight from PRJ_LOCAL_CONNECTIONS")
        return cursor

    def fila(self):
        cursor=self.instanceSQL.cursor()
        cursor.execute("SELECT LS.lote, LS.local, LS.produto, LS.peso, LV.vertice "
                    "FROM LISTA_SEPARACAO LS  "
                    "INNER JOIN locais_estoque LE ON LE.LOCAL = LS.LOCAL "
                    "INNER JOIN PRJ_LOCAL_VERTICE LV ON LV.IDLOCAL = LE.IDLOCAL "
                    "order by LS.lote, LS.LOCAL DESC "
                    )           
        return cursor
    
    def gerador_fila(self):
       cursor=self.instanceSQL.cursor() 
       cursor.execute(" SELECT le.LOCAL, plv.VERTICE "
                    "from PRJ_LOCAL_VERTICE plv "
                    "inner join LOCAIS_ESTOQUE le on le.IDLOCAL = plv.IDLOCAL "
            )           
       return cursor
    
    def ultimo_vertice(self):
        cursor=self.instanceSQL.cursor()
        cursor.execute("SELECT MAX(VERTICE) AS 'vertice' FROM PRJ_LOCAIS")
        row = cursor.fetchone()
        return row.vertice 

    def analisa_duplicidade(self, cursor_fila, maxVertice, grafo):
        maxVertice +=1
        vertices = []
        locais = [[]]
        end = []
        lotes =[]
        lotes_vertices = [[]]
        lote = None
        map_verticesAux = {}
        i = -1

        while 1:
            row = cursor_fila.fetchone()
            if not row:
                break
            if(row.lote != lote):
                lote = row.lote
                lotes.append(lote)
                i+=1
                if(i > 0):
                    lotes_vertices.append([row.vertice])
                    locais.append([row.local])
                else:
                    lotes_vertices[i] = [row.vertice]
                    locais[i] = [row.local]
            else:
                lotes_vertices[i].append(row.vertice)
                locais[i].append(row.local)
        j = 0
        for rota_lote in lotes_vertices:
            for i in range(len(rota_lote)):
                vertices.append(rota_lote[i])
                end.append(locais[j][i])
            
            keys = defaultdict(list)
            for key, value in enumerate(vertices):
                keys[value].append(key)
            
            for value in keys:
                if len(keys[value]) > 1:
                    for i in range(1,len(keys[value])):
                        vertices[keys[value][i]] = maxVertice
                        grafo.copiar_conexoes(vertices[keys[value][0]], maxVertice)
                        map_verticesAux[maxVertice] = vertices[keys[value][0]]
                        maxVertice +=1

            vertice_locais = {}
            for i in range(len(vertices)):
                vertice_locais[vertices[i]] = end[i]
            
            yield vertices, vertice_locais, lotes[j], map_verticesAux
            vertices.clear()
            end.clear()
            j+=1
