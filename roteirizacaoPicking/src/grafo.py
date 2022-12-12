from src import queries 
from utils.ConfigFile import *
import connection.Connect as Connect
from  igraph import *
from  igraph import plot
import numpy as np

import chart_studio.plotly as py
from plotly.offline import plot
import plotly.graph_objs as go

class Grafo:
    def __init__(self, cursor):
        self.cursor = cursor
        self.Edges=[]
        self.weights=[]
        self.grafo = None
    
    def criaGrafo(self): 
        while 1:
            row = self.cursor.fetchone()
            if not row:
                break
            self.Edges.append((row.vertice1, row.vertice2))
            self.weights.append(row.weight)
        self.grafo = Graph(self.Edges, directed = False)
        self.grafo.es['weight'] = self.weights
        self.cursor.close
        return self.grafo, self.Edges
    
    def copiar_conexoes(self, vertice_original, vertice_copia):     
        aresta = None

        #adicionar novo vertice auxiliar
        self.grafo.add_vertex()

        #copia as conexões do vertice original
        for ed in self.grafo.es[self.grafo.incident(vertice_original)]:
            if(ed.target != vertice_original):
                aresta = self.grafo.add_edge(vertice_copia, ed.target)
            else:
                aresta = self.grafo.add_edge(vertice_copia, ed.source)
            self.grafo.es[aresta.index]['weight'] = ed["weight"]

        #cria uma conexao entre o vertice original e a copia
        aresta = self.grafo.add_edge(vertice_copia, vertice_original)
        self.grafo.es[aresta.index]['weight'] = 0


    def plot_grafo(self, grafo, Edges):
        layout = grafo.layout("fr3d")

        n = grafo.vcount()

        Xn=[]
        Yn=[]
        Zn=[]

        for k in range(n):
            Xn+=[layout[k][0]]
            Yn+=[layout[k][1]]
            Zn+=[layout[k][2]]

        Xe=[]
        Ye=[]
        Ze=[]

        for e in Edges:
            Xe+=[layout[e[0]][0],layout[e[1]][0],None]# x-coordinates of edge ends
            Ye+=[layout[e[0]][1],layout[e[1]][1],None]
            Ze+=[layout[e[0]][2],layout[e[1]][2],None]

        trace1=go.Scatter3d(x=Xe, y=Ye, z=Ze, mode='lines', line=dict(color='rgb(125,125,125)', width=1),hoverinfo='none')

        trace2=go.Scatter3d(x=Xn, y=Yn, z=Zn, mode='markers', name='actors', 
                        marker=dict(symbol='circle', size=6, colorscale='Viridis', 
                            line=dict(color='rgb(50,50,50)', width=0.5)), hoverinfo='text')

        axis=dict(showbackground=False, showline=False, zeroline=False, showgrid=False, showticklabels=False, title='')

        layout = go.Layout(
                width=1000,
                height=1000,
                showlegend=False,
                scene=dict(
                    xaxis=dict(axis),
                    yaxis=dict(axis),
                    zaxis=dict(axis),
                ))

        data=[trace1, trace2]

        fig=go.Figure(data=data, layout=layout)

        plot(fig, filename='Grafo')


