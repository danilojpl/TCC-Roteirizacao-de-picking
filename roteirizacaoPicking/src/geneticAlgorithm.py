import random
from  igraph import *
import pygad
import copy
import time
import statistics
import csv
import os.path
from collections import Counter, defaultdict
import itertools

class GA:
    
    def __init__(self,g,rotaInicial, vertices_locais, lote, numPais, distancias,map_verticesAux):
        self.g = g
        self.rotaInicial = rotaInicial
        self.vertices_locais = vertices_locais
        self.lote =lote
        self.numPais = numPais
        self.distancias = distancias
        self.map_verticesAux = map_verticesAux
    
    # def fitness(self, individuo):
    #     distancias = []
    #     for i in range(len(individuo)):
    #         if(i+1<len(individuo)):
    #             distancias.append(self.g.get_shortest_paths(individuo[i],to=individuo[i+1], weights = self.g.es["weight"], output="epath"))
    #     if len(distancias[0][0]) > 0:
    #         distancia = 0
    #         for ei in distancias:
    #             for ej in ei[0]:
    #                 distancia += self.g.es[ej]["weight"]
    #         return -distancia
    #     else:
    #         print("Caminho inexistente")
    #         return -1

    def fitness(self, individuo):
        distancia = 0
        for i in range(len(individuo)):
            if(i+1<len(individuo)):
                if((str(individuo[i])+'_'+str(individuo[i+1])) in self.distancias):
                    distancia += self.distancias[str(individuo[i])+'_'+str(individuo[i+1])]
                elif((str(individuo[i+1])+'_'+str(individuo[i])) in self.distancias):
                    distancia += self.distancias[str(individuo[i+1])+'_'+str(individuo[i])]
                else:
                    if(individuo[i+1] in self.map_verticesAux):
                        if((str(self.map_verticesAux[individuo[i+1]])+'_'+str(individuo[i])) in self.distancias):
                            distancia += self.distancias[str(self.map_verticesAux[individuo[i+1]])+'_'+str(individuo[i])]
                        elif((str(individuo[i])+'_'+str(self.map_verticesAux[individuo[i+1]])) in self.distancias):
                            distancia += self.distancias[str(individuo[i])+'_'+str(self.map_verticesAux[individuo[i+1]])]
                        else:
                            distancia +=1
                            
                    elif(individuo[i] in self.map_verticesAux):
                        if((str(self.map_verticesAux[individuo[i]])+'_'+str(individuo[i+1])) in self.distancias):
                            distancia += self.distancias[str(self.map_verticesAux[individuo[i]])+'_'+str(individuo[i+1])]
                        elif((str(individuo[i+1])+'_'+str(self.map_verticesAux[individuo[i]])) in self.distancias):
                            distancia += self.distancias[str(individuo[i+1])+'_'+str(self.map_verticesAux[individuo[i]])]
                        else:
                            distancia +=1
                
        return -distancia
                
        #         distancias.append(self.g.get_shortest_paths(individuo[i],to=individuo[i+1], weights = self.g.es["weight"], output="epath"))
        # if len(distancias[0][0]) > 0:
        #     distancia = 0
        #     for ei in distancias:
        #         for ej in ei[0]:
        #             distancia += self.g.es[ej]["weight"]
        #     return -distancia
        # else:
        #     print("Caminho inexistente")
        #     return -1


    def selecao(self,populacao):
        nova_lista = sorted(populacao, key=self.fitness, reverse=True)
        return nova_lista[0:self.numPais]
    
    def eliminar_duplicatas(self, individuo):
        b = True
        valores = []
        for v in self.dominio[1]:
            for j in individuo:
                if(v==j):
                    b = False
                    break
            if(b):
                valores.append(v)
            else:
                b = True
        if len(valores) > 0:
           individuo = list(dict.fromkeys(individuo))
           for i in valores:
               f = individuo.pop()
               individuo.append(i)
               individuo.append(f)
        return individuo
    # def eliminar_duplicatas(self, part1, part2):
    #     result = False
    #     for i in part1:
    #         for j in part2:
    #             if i == j:
    #                 result = True
    #                 return result
    #     return False
        
        
    def crossover(self,populacao,tipo,n):
        novaPopulacao = []
        retornar = False
        if(tipo == 'M'):
            tamPopulacaoPais = len(populacao)-1
            keep_list = [random.randint(0,tamPopulacaoPais) for x in range(n)]
            
            while True:
                for i in self.combinations:
                    if(i[0] not in keep_list and i[1] not in keep_list):
                        corte = random.randint(0,self.tamIndiv-2)
                        filho1 = self.eliminar_duplicatas(populacao[i[0]][0:corte] + populacao[i[1]][corte:self.tamIndiv])
                        novaPopulacao.append(filho1)
                        filho2 = self.eliminar_duplicatas(populacao[i[1]][0:corte] + populacao[i[0]][corte:self.tamIndiv])
                        novaPopulacao.append(filho2)
                    if(len(novaPopulacao) == self.tamPopInicial or len(novaPopulacao) > self.tamPopInicial):
                        retornar = True
                        break
                if (retornar == True):
                    if(len(novaPopulacao) > self.tamPopInicial):
                        novaPopulacao.pop(len(novaPopulacao)-1)
                        break
                    else:
                        break

                    
        return novaPopulacao
                    
                    

    def mutacao(self, populacao, p):
        pop_mutada = []
        for individuo in populacao:
            d = random.randint(1,100)
            if(d<=p):
                localI = random.randint(1,self.tamIndiv-2)
                localJ = random.randint(1,self.tamIndiv-2)
                individuo[localI], individuo[localJ] = individuo[localJ], individuo[localI]
                pop_mutada.append(individuo)
            else:
                pop_mutada.append(individuo)
        return pop_mutada
                

    def geraPopulacao(self,rotaInicial):
        rota = []
        lista = copy.deepcopy(rotaInicial)

        for _ in range(len(rotaInicial)):
            aleatorio = random.choice(lista)
            rota.append(aleatorio)
            lista.remove(aleatorio)
        rota.append(2369)
        rota.insert(0,2370)
        return rota 

    def defineDominio(self,rotaInicial):
        dominio =[]
        rota = copy.deepcopy(rotaInicial)
        for _ in range(len(rota)):
            dominio.append(rota)
        dominio.append([2369])
        dominio.insert(0,[2370])
        return dominio
        
    def conv_vertice_rota(self,vertices):
        rota = []
        for i in range(len(vertices)):
            if(i+1<len(vertices)):
                rota.append(self.g.get_shortest_paths(vertices[i],to=vertices[i+1], weights = self.g.es["weight"], output="vpath"))
        return rota

    def local_estoque(self, vertices, vertices_locais):
        rota_locais = []
        for v in vertices:
            if(v in vertices_locais):
                rota_locais.append(vertices_locais[v])
        return rota_locais

    def stop(ga_instance):
        bf = ga_instance.best_solution()[1]
        if ga_instance.best_solution()[1] > -242:
            return "stop"


    def executa(self):
       # g = grafo
        populacaoMutada = []
        populacaoCrossover = []
        
        combinations = itertools.combinations(range(0,self.numPais),2)
        self.combinations = [i for i in combinations]
        # for i in combinations:
        #     print (i)
        # rotaInicial, vertices_locais = retornaRotaInicial(cursor)
        self.dominio = self.defineDominio(self.rotaInicial)
        self.tamPopInicial = len(self.combinations)
        
        
        populacao = [self.geraPopulacao(self.rotaInicial) for _ in range(0,self.tamPopInicial-1)]
        
        self.rotaInicial.append(2369)
        self.rotaInicial.insert(0,2370)
        
        self.tamIndiv = len(self.rotaInicial)
        
        populacao.append(self.rotaInicial)
        
        tbest_fitness = None
        stop =0
        stop_criterion = 200
        start = time.process_time()
        while True:
            populacao = self.selecao(populacao)
            populacao = self.crossover(populacao, 'M', 5)
            pop_mutada = [i for i in self.mutacao(populacao, 10)]
            populacao = pop_mutada
            new_tbest = self.fitness(self.selecao(populacao)[0])
            if(tbest_fitness == new_tbest):
                stop +=1
                if(stop == stop_criterion):
                    break
            else:
                tbest_fitness = self.fitness(self.selecao(populacao)[0])
                stop = 0
            
            # print(tbest_fitness)
        
        tbest_solution = self.selecao(populacao)[0]
        end = time.process_time()
        locais = self.local_estoque(tbest_solution,self.vertices_locais)
        print(tbest_fitness)
        # print("Tempo (segundos) para encontrar a melhor solução: ", end - start)
        melhor_rota = self.conv_vertice_rota(tbest_solution)
        print (melhor_rota)
        print(locais)
        
        print('\n\n')
        fitness_rotaInicial = self.fitness(self.rotaInicial)
        rota_inicial = self.conv_vertice_rota(self.rotaInicial)
        print (rota_inicial)
        print(fitness_rotaInicial)
        
        ganho = (fitness_rotaInicial*(-1) - tbest_fitness *(-1))/fitness_rotaInicial*(-1)*100
        
        print('Ganho:', ganho)
    
        # if(not os.path.exists('./resultados.csv')):
        #     with open('./resultados.csv', 'w', newline='', encoding='utf8') as csvfile:
        #         csv.writer(csvfile, delimiter = ',').writerow([self.lote,len(self.vertices_locais), fitness_rotaInicial*(-1),tbest_fitness *(-1), str(ganho)+'%', end - start])
        # else:
        #     with open('./resultados.csv', 'a+', newline='') as write_obj:
        #         csv_writer = csv.writer(write_obj)
        #         csv_writer.writerow([self.lote,len(self.vertices_locais), fitness_rotaInicial*(-1),tbest_fitness *(-1), str(ganho)+'%', end - start])


    
    # start = time.process_time()

    # ga_instance.run()

    # end = time.process_time()

    # ga_instance.plot_fitness()
    # solution, solution_fitness, solution_idx = ga_instance.best_solution()
    # print("Parametros da melhor solução: {solution}".format(solution=solution))
    # print("Valor de fitness da melhor solução: {solution_fitness}".format(solution_fitness=solution_fitness))
    # # print("Indice da melhor solução : {solution_idx}".format(solution_idx=solution_idx))

    # locais = local_estoque(solution, vertices_locais)
    # # print(locais)
    # # print("Tempo (segundos) para encontrar a melhor solução: ", end - start)
    # rota = conv_vertice_rota(solution)
    # print(rota)

    # #distancia media entre dois pontos, rota decerescente 
    # #distanciaM = distancia_media(rotaInicial)

    # rotaInicial_fitness = fitness_func(rotaInicial, None)
    # locais_rotaInicial = local_estoque(rotaInicial, vertices_locais)
    # rota_inicial = conv_vertice_rota(rotaInicial)

    # # print('\n\n')
    # # print("Valor de fitness da solução inicial: ",rotaInicial_fitness)
    # # print(locais_rotaInicial)
    # # print(rota_inicial)
    # ganho = (rotaInicial_fitness*(-1) - solution_fitness *(-1))/rotaInicial_fitness*(-1)*100
    
    # print("ganho: ",ganho)

       

    
