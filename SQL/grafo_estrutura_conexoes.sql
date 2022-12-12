--ESTRUTURA DE TABELAS 
CREATE TABLE LISTA_SEPARACAO(
	LOTE INT,
	PRODUTO VARCHAR(255),
	PESO float,
	LOCAL VARCHAR(50)
)

SELECT*
FROM LISTA_SEPARACAO

CREATE TABLE PRJ_LOCAL_VERTICE(
	IDLOCAL INT,
	VERTICE INT
)


CREATE TABLE PRJ_LOCAL_COORDINATES(
	IDLOCAL INT,
	ZONA VARCHAR (2),
	COORD_X INT,
	COORD_Y  INT,
	COORD_Z INT,
)

CREATE TABLE PRJ_LOCAIS(
	VERTICE INT IDENTITY(1,1),
	ZONA VARCHAR (2),
	COORD_X INT,
	COORD_Y INT,
	COORD_Z INT,
	ORD_ZONA_X INT,
	ORD_ZONA_Y INT,
	ESCADA VARCHAR(1)
)

CREATE TABLE PRJ_LOCAL_CONNECTIONS(
	ID_CONNECTION INT IDENTITY(1,1),
	VERTICE1 INT ,
	VERTICE2 INT,
	WEIGHT INT
)

CREATE TABLE LOCAIS_ESTOQUE(
	IDLOCAL INT IDENTITY(1,1) ,
	LOCAL VARCHAR (255),
)



drop table  PRJ_LOCAL_VERTICE
drop table  PRJ_LOCAL_COORDINATES
drop table  PRJ_LOCAIS
drop table  PRJ_LOCAL_CONNECTIONS



--SELECT* FROM PRJ_LOCAL_COORDINATES

--LIGAÇÃO DOS LOCAIS DE ESTOQUE COM COORDENADAS 
INSERT INTO PRJ_LOCAL_COORDINATES
SELECT IDLOCAL 
,SUBSTRING(LOCAL, 3, 2)
,cast(substring(local,charindex('.', local, (charindex('.', local, 1))+1)+1, 2) as int)
,cast(substring(local,charindex('.', local, (charindex('.', local, 1))+charindex('.', local, (charindex('.', local, 1))+1))+1, 2) as int)
,cast(substring(local, 1, 1)as int)
FROM locais_estoque


--CRIAÇÃO DOS VERTICES PARA CONEXÃO
INSERT INTO PRJ_LOCAIS
SELECT distinct ZONA,coord_x, IIF(COORD_Y%2 = 1 and COORD_Y>1, COORD_Y/2+1,iif(COORD_Y = 1,1,COORD_Y/2)), coord_z, SUBSTRING(ZONA, 2,1), CASE WHEN SUBSTRING(ZONA, 1,1) = 'A' THEN 1 
WHEN SUBSTRING(ZONA, 1,1) ='B' THEN 2 WHEN SUBSTRING(ZONA, 1,1) ='C' THEN 3 WHEN SUBSTRING(ZONA, 1,1) ='D' THEN 4 END,'F'
FROM PRJ_LOCAL_COORDINATES
ORDER BY coord_z,ZONA,coord_x, coord_y--, coord_z


--TABELA PARA A RELAÇÃO DOS LOCAIS COM OS VERTICES 
insert into PRJ_LOCAL_VERTICE
select DISTINCT idlocal, VERTICE
from PRJ_LOCAIS PL 
INNER JOIN PRJ_LOCAL_COORDINATES PLC ON PLC.COORD_X = PL.COORD_X
										AND IIF(PLC.COORD_Y%2 = 1 and PLC.COORD_Y>1, PLC.COORD_Y/2+1
										, iif(PLC.COORD_Y = 1,1,PLC.COORD_Y/2)) = PL.COORD_Y
										AND PLC.COORD_Z = PL.COORD_Z
										AND PLC.ZONA = PL.ZONA

-----------------------------------------/CONEXÕES/--------------------------------------------------------------------------------------


-- CONNECTION OF MAX LOCATIONS
INSERT INTO PRJ_LOCAL_CONNECTIONS 
SELECT v1.VERTICE, v2.VERTICE, 2 FROM(
select p1.zona as 'z1', p1.COORD_X as 'CX_1', max(p1.COORD_Y) AS 'MAX_COORDY_V1', p1.COORD_Z as 'CZ_1', p2.zona 'z2', p2.COORD_X  as 'CX_2', max(p2.COORD_Y)AS 'MAX_COORDY_V2', p2.COORD_Z as 'CZ_2'
from PRJ_LOCAIS p1
inner join PRJ_LOCAIS p2 on p2.VERTICE <> p1.VERTICE
							and p2.COORD_X % 2 = 0
							AND (p2.COORD_X = p1.COORD_X+1
							or p1.COORD_X = p2.COORD_X +1)
							and (p2.ZONA = p1.ZONA AND p2.COORD_Z = p1.COORD_Z)
where p1.COORD_X %2 <>0
group by  p1.COORD_X, p1.COORD_Z,  p2.COORD_X,p2.COORD_Z,p1.zona,p2.zona
) T
inner join PRJ_LOCAIS v1 ON v1.COORD_Z = t.CZ_1
						and v1.COORD_X = t.CX_1
						and v1.COORD_Y = t.MAX_COORDY_V1
						and v1.ZONA = t.z1
inner join PRJ_LOCAIS v2 on v2.COORD_Z = T.CZ_2
							and v2.COORD_X = t.CX_2
							and v2.COORD_Y = t.MAX_COORDY_V2
							and v2.ZONA = t.z2



-- CONNECTION OF MIN LOCATIONS
INSERT INTO PRJ_LOCAL_CONNECTIONS 
SELECT v1.VERTICE, v2.VERTICE, 2 FROM(
select p1.zona as 'z1', p1.COORD_X as 'CX_1', min(p1.COORD_Y) AS 'MAX_COORDY_V1', p1.COORD_Z as 'CZ_1', p2.zona 'z2', p2.COORD_X  as 'CX_2', min(p2.COORD_Y)AS 'MAX_COORDY_V2', p2.COORD_Z as 'CZ_2'
from PRJ_LOCAIS p1
inner join PRJ_LOCAIS p2 on p2.VERTICE <> p1.VERTICE
							and p2.COORD_X % 2 = 0
							AND (p2.COORD_X = p1.COORD_X+1
							or p1.COORD_X = p2.COORD_X +1)
							and (p2.ZONA = p1.ZONA AND p2.COORD_Z = p1.COORD_Z)
where p1.COORD_X %2 <>0
group by  p1.COORD_X, p1.COORD_Z,  p2.COORD_X,p2.COORD_Z,p1.zona,p2.zona
) T
inner join PRJ_LOCAIS v1 ON v1.COORD_Z = t.CZ_1
						and v1.COORD_X = t.CX_1
						and v1.COORD_Y = t.MAX_COORDY_V1
						and v1.ZONA = t.z1
inner join PRJ_LOCAIS v2 on v2.COORD_Z = T.CZ_2
							and v2.COORD_X = t.CX_2
							and v2.COORD_Y = t.MAX_COORDY_V2
							and v2.ZONA = t.z2


--connection of zones

SELECT*
FROM PRJ_LOCAL_CONNECTIONS

--max 
insert into PRJ_LOCAL_CONNECTIONS
SELECT V1.VERTICE, V2.VERTICE,3 FROM(
select p1.zona as 'z1', p1.COORD_X as 'CX_1', max(p1.COORD_Y) AS 'MAX_COORDY_V1', p1.COORD_Z as 'CZ_1',  p2.zona as 'z2', p2.COORD_X as 'CX_2', max(p2.COORD_Y) AS 'MAX_COORDY_V2', p2.COORD_Z as 'CZ_2'
from PRJ_LOCAIS p1
inner join PRJ_LOCAIS p2 on p2.VERTICE <> p1.VERTICE
							and p1.COORD_X = (select max(COORD_X) from PRJ_LOCAIS p where p.zona = p1.zona)
							AND p2.ORD_ZONA_X =  p1.ORD_ZONA_X+1 
								and SUBSTRING(p1.ZONA, 1,1) = SUBSTRING(p2.ZONA, 1,1)
							AND p2.COORD_Z = p1.COORD_Z
where p2.COORD_X  = (select MIN(COORD_X) from PRJ_LOCAIS p where p.zona = p1.zona)
group by  p1.COORD_X, p1.COORD_Z,  p2.COORD_X,p2.COORD_Z,p1.zona,p2.zona)T
inner join PRJ_LOCAIS v1 ON v1.COORD_Z = t.CZ_1
						and v1.COORD_X = t.CX_1
						and v1.COORD_Y = t.MAX_COORDY_V1
						and v1.ZONA = t.z1
inner join PRJ_LOCAIS v2 on v2.COORD_Z = T.CZ_2
							and v2.COORD_X = t.CX_2
							and v2.COORD_Y = t.MAX_COORDY_V2
							and v2.ZONA = t.z2



--min
insert into PRJ_LOCAL_CONNECTIONS
SELECT V1.VERTICE, V2.VERTICE,3 FROM(
select p1.zona as 'z1', p1.COORD_X as 'CX_1', min(p1.COORD_Y) AS 'MIN_COORDY_V1', p1.COORD_Z as 'CZ_1',  p2.zona as 'z2', p2.COORD_X as 'CX_2', min(p2.COORD_Y) AS 'MIN_COORDY_V2', p2.COORD_Z as 'CZ_2'
from PRJ_LOCAIS p1
inner join PRJ_LOCAIS p2 on p2.VERTICE <> p1.VERTICE
							and p1.COORD_X = (select max(COORD_X) from PRJ_LOCAIS p where p.zona = p1.zona)
							AND p2.ORD_ZONA_X =  p1.ORD_ZONA_X+1 
								and SUBSTRING(p1.ZONA, 1,1) = SUBSTRING(p2.ZONA, 1,1)
							AND p2.COORD_Z = p1.COORD_Z
where p2.COORD_X  = (select MIN(COORD_X) from PRJ_LOCAIS p where p.zona = p1.zona)
group by  p1.COORD_X, p1.COORD_Z,  p2.COORD_X,p2.COORD_Z,p1.zona,p2.zona)T
inner join PRJ_LOCAIS v1 ON v1.COORD_Z = t.CZ_1
						and v1.COORD_X = t.CX_1
						and v1.COORD_Y = t.MIN_COORDY_V1
						and v1.ZONA = t.z1
inner join PRJ_LOCAIS v2 on v2.COORD_Z = T.CZ_2
							and v2.COORD_X = t.CX_2
							and v2.COORD_Y = t.MIN_COORDY_V2
							and v2.ZONA = t.z2



INSERT INTO PRJ_LOCAL_CONNECTIONS
SELECT V1.VERTICE, V2.VERTICE,3 FROM(
select p1.zona as 'z1', p1.COORD_X as 'CX_1', MAX(p1.COORD_Y) AS 'MAX_COORDY_V1'
, p1.COORD_Z as 'CZ_1', p2.zona as 'z2', p2.COORD_X as 'CX_2', MIN(p2.COORD_Y) AS 'MIN_COORDY_V2', p2.COORD_Z as 'CZ_2'
from PRJ_LOCAIS p1
INNER JOIN PRJ_LOCAIS p2 ON P2.ORD_ZONA_Y = p1.ORD_ZONA_Y +1
							AND P2.COORD_X = P1.COORD_X
							AND SUBSTRING(P2.ZONA, 2,1) = SUBSTRING(P1.ZONA, 2,1)
							AND p2.COORD_Z = p1.COORD_Z
Group by P1.ZONA,  P1.COORD_X,P2.ZONA,  P2.COORD_X, p1.COORD_Z, p2.COORD_Z) T
inner join PRJ_LOCAIS v1 ON v1.COORD_Z = t.CZ_1
						and v1.COORD_X = t.CX_1
						and v1.COORD_Y = t.MAX_COORDY_V1
						and v1.ZONA = t.z1
inner join PRJ_LOCAIS v2 on v2.COORD_Z = T.CZ_2
							and v2.COORD_X = t.CX_2
							and v2.COORD_Y = t.MIN_COORDY_V2
							and v2.ZONA = t.z2


--CONEXAO CORREDORES 
INSERT INTO PRJ_LOCAL_CONNECTIONS
SELECT VERTICE1, VERTICE2,1 FROM(
select DISTINCT P1.VERTICE AS 'VERTICE1',P1.COORD_X AS 'X1',P1.COORD_Y AS 'Y1',P1.COORD_Z AS 'Z1',P2.VERTICE AS 'VERTICE2'
,P2.COORD_X AS 'X2',P2.COORD_Y AS 'Y2',P2.COORD_Z AS 'Z2'
FROM PRJ_LOCAIS P1
INNER JOIN PRJ_LOCAIS P2 ON P2.COORD_X = P1.COORD_X
							AND P2.COORD_Z = P1.COORD_Z
							AND P2.COORD_Y = P1.COORD_Y+1
							AND P2.ZONA = P1.ZONA)T

--CONEXAO ENTRE ANDARES 
INSERT INTO PRJ_LOCAL_CONNECTIONS
SELECT v1.VERTICE, v2.VERTICE,4 FROM (
SELECT p1.zona as 'ZONA1', p1.COORD_X as 'COORD_X1', min(p1.COORD_Y) as 'COORD_y1', p1.COORD_Z as 'COORD_z1',
p2.zona as 'ZONA2', p2.COORD_X as 'COORD_X2', max(p2.COORD_Y) as 'COORD_y2', p2.COORD_Z as 'COORD_z2'
from PRJ_LOCAIS p1
inner join PRJ_LOCAIS p2 on (p2.COORD_X = p1.COORD_X or p2.COORD_X = p1.COORD_X+1 or p2.COORD_X = p1.COORD_X-1)
							and p2.ZONA = p1.zona
							and p2.COORD_Y > p1.COORD_Y
							and p2.COORD_Z = p1.COORD_Z+1
							and p2.escada = 'T'
where p1.ESCADA = 'T'
GROUP BY p1.COORD_Z,p1.zona, p1.COORD_X , p2.COORD_Z,p2.zona, p2.COORD_X ) T
inner join PRJ_LOCAIS v1 ON v1.COORD_Z = t.COORD_z1
						and v1.COORD_X = t.COORD_X1
						and v1.COORD_Y = t.COORD_y1
						and v1.ZONA = t.ZONA1
inner join PRJ_LOCAIS v2 on v2.COORD_Z = T.COORD_z2
							and v2.COORD_X = t.COORD_X2
							and v2.COORD_Y = t.COORD_y2
							and v2.ZONA = t.ZONA2
--where v1.vertice = 1137
--or v2.vertice = 1137
--order by p1.COORD_Z,p1.zona, p1.COORD_X 


---------------------------------------/LISTA SEPARAÇÃO/--------------------------------------------

--INSERT INTO LISTA_SEPARACAO
--select DISTINCT prefaturamento, concat(p.cod_produto, c.cod_cor, pr.tamanho) as 'SKU',p.peso, max(le.local)
--from produto_prefat pr 
--inner join produtos p on p.produto = pr.produto
--inner join cores c on c.cor = pr.cor
--INNER JOIN estoques_locais el on el.produto = p.produto
--								and el.cor = c.cor
--								and el.tamanho = pr.tamanho
--inner join LOCAIS_ESTOQUE LE ON LE.IDLOCAL = EL.IDLOCAL
--where prefaturamento in (4696009
--,4696126
--,4696242
--,4698092
--,4698111
--,4698262
--,4698265
--,4698311
--,4698345
--,4698423)
--and EL.FILIAL = 140 
--AND LE.BLOQUEADO = 'F' 
--AND LE.VIRTUAL = 'F' 
--AND LE.TIPO_LOCAL <> '01'
--group by prefaturamento,p.cod_produto, c.cod_cor, pr.tamanho, p.peso

delete from LISTA_SEPARACAO

--Itens espalhados pelas zonas
--INSERT INTO LISTA_SEPARACAO
--select DISTINCT concat(p.cod_produto, c.cod_cor, pr.tamanho) as 'SKU',p.peso, max(le.local)
--from produto_prefat pr 
--inner join produtos p on p.produto = pr.produto
--inner join cores c on c.cor = pr.cor
--INNER JOIN estoques_locais el on el.produto = p.produto
--								and el.cor = c.cor
--								and el.tamanho = pr.tamanho
--inner join LOCAIS_ESTOQUE LE ON LE.IDLOCAL = EL.IDLOCAL
--where prefaturamento in (4696009
--,4696242
--,4698092
--,4698265
--,4698345
--,4698423)
--and EL.FILIAL = 140 
--AND LE.BLOQUEADO = 'F' 
--AND LE.VIRTUAL = 'F' 
--AND LE.TIPO_LOCAL <> '01'
--and cod_produto <> '50701345'
--and cod_produto <> '50400638'
--group by prefaturamento,p.cod_produto, c.cod_cor, pr.tamanho, p.peso

--SELECT LS.PRODUTO, LS.PESO, LV.VERTICE, LS.LOCAL
--FROM LISTA_SEPARACAO LS 
--INNER JOIN locais_estoque LE ON LE.LOCAL = LS.LOCAL
--INNER JOIN PRJ_LOCAL_VERTICE LV ON LV.IDLOCAL = LE.IDLOCAL
--order by LS.LOCAL DESC


select*
from amr_regras_lotes

select *
from amr_lotes_separacao als
inner join lotes_separacao ls on ls.LOTE_SEPARACAO = als.LOTE_SEPARACAO
where regra_lote = 2
and ls.QTDE_PEDIDOS >=5

select*
from lotes_separacao_itens
where lote_Separacao  = 573813


--itens na mesma zona 
INSERT INTO LISTA_SEPARACAO
select DISTINCT concat(p.cod_produto, c.cod_cor, pr.tamanho) as 'SKU',p.peso, max(le.local)
from produto_prefat pr 
inner join produtos p on p.produto = pr.produto
inner join cores c on c.cor = pr.cor
INNER JOIN estoques_locais el on el.produto = p.produto
								and el.cor = c.cor
								and el.tamanho = pr.tamanho
inner join LOCAIS_ESTOQUE LE ON LE.IDLOCAL = EL.IDLOCAL
where prefaturamento in (4689006
,4689069
,4689056
,4689099
,4688980
,4689072
,4689082)
and EL.FILIAL = 140 
AND LE.BLOQUEADO = 'F' 
AND LE.VIRTUAL = 'F' 
AND LE.TIPO_LOCAL <> '01'
and le.local like('%1.D1%')
AND concat(p.cod_produto, c.cod_cor, pr.tamanho) <> '400007513010U'
group by prefaturamento,p.cod_produto, c.cod_cor, pr.tamanho, p.peso



SELECT LS.PRODUTO, LS.PESO, LV.VERTICE, LS.LOCAL
FROM LISTA_SEPARACAO LS 
INNER JOIN locais_estoque LE ON LE.LOCAL = LS.LOCAL
INNER JOIN PRJ_LOCAL_VERTICE LV ON LV.IDLOCAL = LE.IDLOCAL
order by LS.LOCAL DESC





--Testes Algoritmo

--353 

--329 -> 2321. 1575.  285. 2028. 1509.  580. 1335. 1866. 1269. 2073.  367.  648. 1155. 2320.

--325 -> 2321. 1155.  648. 2073. 1335.  580. 1509.  285. 2028.  367. 1269. 1866. 1575. 2320.

--309 -> 2321. 1575. 1509.  580. 1335. 1866. 1269.  648. 2073.  367. 2028.  285. 1155. 2320.

--317 -> 2321. 1155.  648. 2073.  367. 2028.  285. 1509.  580. 1335. 1269. 1866. 1575. 2320.

--320 -> 2321. 1575. 1155.  285. 1509. 1335.  580. 2028.  367. 2073. 1269. 1866. 648. 2320.

--307 -> 
--['3.A1.08.08.06.02', '2.C2.02.02.02.01', '2.C2.03.23.03.01', '2.C2.04.18.03.01', '1.B2.05.30.05.01', '1.D2.07.30.01.01', '1.D1.07.06.03.02', '1.C1.05.17.02.01', '2.C1.02.18.03.02', '2.C1.03.23.04.02', '1.C1.04.08.03.01', '1.B1.08.17.05.02']

--Tempo (segundos) para encontrar a solução:  103.59375
--[[[2321, 1271, 1342, 1137, 1288, 180, 1299, 1059, 739, 2016, 882, 491, 1088, 1662, 8, 263, 1457, 521, 1575]]
--, [[1575, 771, 790, 848, 79, 121, 1437, 827, 1089, 717, 1516, 1159, 1322, 1082, 789, 746, 1913, 1708, 92, 193, 2225, 1957, 1743, 604, 548, 1238, 817, 956, 1034, 1850, 1544, 308, 2184, 1941, 2099, 2188, 1008, 1509]]
--, [[1509, 1008, 1991, 1967, 437, 141, 158, 851, 884, 2171, 676, 1686, 1335]]
--, [[1335, 1107, 1213, 1199, 1636, 1602, 580]]
--, [[580, 1739, 2077, 228, 206, 425, 387, 540, 2188, 2099, 748, 449, 462, 1070, 2288, 300, 285]]
--, [[285, 300, 2288, 1070, 1827, 348, 316, 273, 1072, 1009, 733, 2019, 1403, 1489, 1280, 2232, 2170, 2070, 823, 773, 528, 460, 1676, 1378, 1349, 2147, 1834, 1568, 1678, 1379, 1111, 276, 2028]]
--, [[2028, 683, 415, 80, 304, 71, 165, 209, 957, 749, 724, 518, 201, 2048, 1804, 1928, 448, 251, 39, 1317, 197, 2063, 1960, 1914, 412, 367]]
--, [[367, 30, 885, 930, 555, 21, 102, 408, 474, 2073]]
--, [[2073, 474, 2030, 629, 1503, 1587, 1926, 2106, 2045, 1269]], [[1269, 2045, 2106, 1926, 1587, 1503, 1866]], [[1866, 1503, 629, 2295, 1133, 1556, 1472, 1946, 611, 648]], 
--[[648, 1023, 1043, 1132, 2068, 1218, 835, 1418, 1164, 168, 333, 357, 1958, 2006, 19, 169, 1155]]
--, [[1155, 1417, 1554, 691, 721, 1050, 1293, 1596, 1553, 1781, 2058, 2311, 268, 1530, 1717, 1780, 2282, 2310, 267, 1249, 113, 1683, 1421, 1528, 1748, 1137, 1342, 1271, 2320]]]

----------------------------------------/Definição do local de Início/------------------------------------------------------------------------
--2320 -> vertice inicio_fim

--INSERE VERTICE DE INICIO
insert into PRJ_LOCAIS(ZONA,COORD_X, COORD_Y, COORD_Z, ORD_ZONA_X, ORD_ZONA_Y, ESCADA) 
values('A1', 1,1,1,1,0,'F')


INSERT INTO PRJ_LOCAL_CONNECTIONS
SELECT P1.VERTICE, P2.VERTICE, IIF(P2.ZONA = P1.ZONA, P2.COORD_X*2-2, P2.COORD_X*2 + 17)
FROM PRJ_LOCAIS P1
INNER JOIN PRJ_LOCAIS P2 ON P2.ZONA IN ('A1', 'A2')
						AND P2.COORD_Y = P1.COORD_Y
						AND P2.COORD_Z = P1.COORD_Z
						AND P2.VERTICE <> P1.VERTICE
WHERE P1.VERTICE = 2370

select*
from PRJ_LOCAIS
--order by vertice desc
where vertice = 319
1394
select*
from PRJ_LOCAL_CONNECTIONS
where vertice1 = 1394
or vertice2 = 1394

delete from PRJ_LOCAL_CONNECTIONS where vertice1 =2320  or vertice2 = 2320





---------------------------------------/TESTES/------------------------------------------------------------------------------------------------

select *
from locais_estoque
WHERE EHPAI = 'F'
AND FILIAL = 140
AND SALDO = 1
AND VIRTUAL = 'F'
AND BLOQUEADO = 'F'
and nivel = 4
and tipo_local = 2
ORDER BY LOCAL

SELECT top 1 IDLOCAL,
cast(substring(local,charindex('.', local, (charindex('.', local, 1))+1)+1, 2) as int)
,cast(substring(local,charindex('.', local, (charindex('.', local, 1))+charindex('.', local, (charindex('.', local, 1))+1))+1, 2) as int)
,cast(substring(local, 1, 1)as int)
FROM locais_estoque
WHERE EHPAI = 'F'
AND FILIAL = 140
AND SALDO = 1
AND VIRTUAL = 'F'
AND BLOQUEADO = 'F'
and nivel = 4
and tipo_local = 2
ORDER BY LOCAL



