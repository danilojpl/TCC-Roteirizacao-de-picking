from src import queries as QR, grafo as GF,geneticAlgorithm
from utils.ConfigFile import *
import connection.Connect as Connect
from  igraph import *
from  igraph import plot
from utils.distancias import *
from utils.geraLotes import *
import csv

import chart_studio.plotly as py
from plotly.offline import plot
import plotly.graph_objs as go

config = ConfigFile().read()
baseServer = config.get('DATABASE', 'server')
database = config.get('DATABASE', 'database')
uid = config.get('DATABASE', 'uid')
pwd = config.get('DATABASE', 'pwd')

## Instance connection database
connection   = Connect.ConnectSQL(baseServer,database, uid, pwd)
instanceSQL = connection.getSession()

s = QR.Queries(instanceSQL)
cursor = s.locais()
# g = Graph()
i = 0
Edges=[]
weights=[]
cursor.close()
cursor = s.connections()

g = GF.Grafo(cursor)
grafo1,Edges = g .criaGrafo()

cursor.close()

maxVertice = s.ultimo_vertice()

# gerador = s.gerador_fila()

# geraFilaLotes(instanceSQL,gerador)

cursor_fila = s.fila()

with open('./distancia_valores.csv', mode='r') as infile:
    reader = csv.reader(infile)
    with open('./distancia_valores_new.csv', mode='w') as outfile:
        writer = csv.writer(outfile)
        mydict = {rows[0]:int(rows[1]) for rows in reader}

for vertices, vertice_locais, lote, map_verticesAux in s.analisa_duplicidade(cursor_fila, maxVertice, g):
    geneticAlgorithm.GA(grafo1,vertices, vertice_locais, lote, 20, mydict, map_verticesAux).executa()

# vertices, vertice_locais, lote = s.analisa_duplicidade(cursor_fila, maxVertice, g)

# salvar_distancias(grafo1)





# ga.executa()
# GA.executa(grafo1,vertices,vertice_locais, lote)

# instanceSQL.close()

#plotar grafo e salvar grafo em formato graphml
#g.plot_grafo(grafo1,Edges)
# grafo1.write_graphmlz("g.graphml")