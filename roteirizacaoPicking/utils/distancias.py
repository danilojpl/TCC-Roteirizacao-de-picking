import itertools
import os.path
import csv


def salvar_distancias(g):
    nodes = g.vs.indices
    combinacoes = []
    distancia = 0
    
    for subset in itertools.combinations(nodes, 2):
        combinacoes.append(subset)
    
    for c in combinacoes: 
        caminho = g.get_shortest_paths(c[0],to=c[1], weights = g.es["weight"], output="epath")   
        if len(caminho[0]) > 0:
            distancia = 0
            for ei in caminho[0]:
                distancia += g.es[ei]["weight"]
                    
            if(not os.path.exists('./distancias.csv')):
                with open('./distancias.csv', 'w', newline='', encoding='utf8') as csvfile:
                    csv.writer(csvfile, delimiter = ',').writerow([str(c[0])+'_'+str(c[1]),distancia])
            else:
                with open('./distancias.csv', 'a+', newline='') as write_obj:
                    csv_writer = csv.writer(write_obj)
                    csv_writer.writerow([str(c[0])+'_'+str(c[1]),distancia])