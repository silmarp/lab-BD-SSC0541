/*
SCC0541 - Laborat�rio de Base de Dados
Pr�tica 03 - SQL/DDL-DML
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*
1) Preparando a base de dados....
a) remova todas as tabelas criadas na Pr�tica 3
� Dica: usando o comando abaixo, crie um script de remo��o para todas as suas tabelas - o script
ser� o resultado da consulta
select 'drop table '||table_name||' cascade constraints;' from user_tables;
( || � um operador de concatena��o de string )
b) crie novas tabelas executando o script esquema.sql (dispon�vel no Tidia)
c) alimente a base com o script dados_novo.sql (dispon�vel no Tidia)
d) como o seu esquema acabou de ser criado, ainda n�o h� estat�sticas coletadas para ele.
Portanto, qualquer plano de consulta ser� gerado sem o uso de estat�sticas, considerando
apenas regras do otimizador e avalia��es de custo. Execute o comando abaixo para
coletar as estat�sticas que ajudam na otimiza��o das consultas. Se o comando n�o for
executado explicitamente, as estat�sticas s�o geradas automaticamente durante a noite
(quando o Oracle est� configurado para isso).
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(NULL, NULL);
*/

EXEC DBMS_STATS.GATHER_SCHEMA_STATS(NULL, NULL);

/*
2) Considere as consultas abaixo:
select * from planeta
where classificacao = 'Dolores autem maxime fuga.';
select * from planeta where classificacao = 'Confirmed';
a) Execute as consultas, e depois analise os planos de execu��o gerados pelo otimizador para essas
consultas.
*/

select * from planeta
    where classificacao = 'Dolores autem maxime fuga.';
    
select * from planeta
    where classificacao = 'Confirmed';

delete from plan_table;

-- Plano de Consulta: Consulta 01
explain plan set statement_id = 'teste1' for
    select * from planeta
        where classificacao = 'Dolores autem maxime fuga.';    
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());


-- Plano de Consulta: Consulta 02
explain plan set statement_id = 'teste1' for
    select * from planeta
        where classificacao = 'Confirmed';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*  Resultados:

Plano de Consulta: Consulta 01
Plan hash value: 2930980072
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |     1 |    59 |   137   (1)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PLANETA |     1 |    59 |   137   (1)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("CLASSIFICACAO"='Dolores autem maxime fuga.')
   
   
Plano de Consulta: Consulta 02
Plan hash value: 2930980072
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  5190 |   299K|   137   (1)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PLANETA |  5190 |   299K|   137   (1)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("CLASSIFICACAO"='Confirmed')
   
   
Como em ambas as consultas � solicitada a mesma informa��o (planetas com uma determinada classifica��o) e n�o h� index para o atributo buscado, o processo realizado � o mesmo: percorrer toda tabela seleciionando as tuplas que satisfazem a condi��o solicitada
*/


/*
b) Crie um �ndice que possa melhorar a performance dessas consultas. Explique o porqu� da
escolha do tipo de �ndice criado.
*/

create index idx_classificacao
on planeta (classificacao);

drop index idx_classificacao;

-- TODO: explicar o pq da escolha desse tipo de indice


/*
c) Execute novamente as consultas e analise os planos de execu��o. Inclua os plano no script da
pr�tica. Explique as principais diferen�as em rela��o aos planos gerados antes da cria��o do
�ndice.
*/

/*  Resultados ap�s a cria��o do �ndice:
Plano de Consulta: Consulta 01

Plan hash value: 1267387943
 
---------------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |                   |     1 |    59 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| PLANETA           |     1 |    59 |     2   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN                  | IDX_CLASSIFICACAO |     1 |       |     1   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("CLASSIFICACAO"='Dolores autem maxime fuga.')
   
   
Plano de Consulta: Consulta 02

Plan hash value: 2930980072
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  5190 |   299K|   137   (1)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PLANETA |  5190 |   299K|   137   (1)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("CLASSIFICACAO"='Confirmed')
        
    
Ap�s a cria��o do �ndice, na primeira consulta o custo foi bem menor devido ao fato de ser 1 acesso � 1 tupla da tabela. Por isso, a opera��o realizada foi o acesso por �ndice.
Em contrapartida, na segunda consulta v�rias tuplas s�o acessadas, sendo assim, mesmo com a cria��o do �ndice, ele n�o � utilizado e o resultado permanece o mesmo de antes, pois o otimizador continua realizando a busca sequencial.
*/


/*
3) Considere as consultas abaixo:
select * from nacao where nome = 'Minus magni.';
select * from nacao where upper(nome) = 'MINUS MAGNI.';
a) Execute as consultas, e depois analise os planos de execu��o gerados pelo otimizador para essas
consultas. Explique a principal diferen�a entre eles e a raz�o dessa diferen�a
*/

select * from nacao where nome = 'Minus magni.';
select * from nacao where upper(nome) = 'MINUS MAGNI.';

-- Plano de Consulta: Consulta 01
explain plan set statement_id = 'teste1' for
    select * from nacao where nome = 'Minus magni.';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());


-- Plano de Consulta: Consulta 02
explain plan set statement_id = 'teste1' for
    select * from nacao where upper(nome) = 'MINUS MAGNI.';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*  Resultados:
Plano de Consulta: Consulta 01
    
Plan hash value: 718961691
 
----------------------------------------------------------------------------------------
| Id  | Operation                   | Name     | Rows  | Bytes | Cost (%CPU)| Time     |
----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |          |     1 |    30 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| NACAO    |     1 |    30 |     2   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | PK_NACAO |     1 |       |     1   (0)| 00:00:01 |
----------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("NOME"='Minus magni.')
   
Plano de Consulta: Consulta 02

Plan hash value: 2698598799
 
---------------------------------------------------------------------------
| Id  | Operation         | Name  | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |       |   498 | 14940 |    69   (2)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| NACAO |   498 | 14940 |    69   (2)| 00:00:01 |
---------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter(UPPER("NOME")='MINUS MAGNI.')
   
Houve uma diferen�a na opera��o realizada em cada opra��o e, por consequ�ncia no custo. Enquanto na consulta 1 ele utiliza o �ndice para acessar a tupla, na consulta 2 toda a tebala � percorrida.
Ambas as consultas retornam apenas 1 tupla como resultado. Entretanto, como na segunda consulta h� a fun��o 'upper', o otimizador entende que pode haver mais de 1 resultado poss�vel, pois o atrbuto deixa de ser uma unique, sendo assim, verifica-se toda a tabela.   
        
*/


/*
b) Crie um �ndice que possa melhorar a performance da segunda consulta. Explique o porqu� da
escolha do tipo de �ndice criado.

Como h� a fun��o upper na consulta 02, utilizaremos uma Function-Based Index para que o valor da fun��o seja calculado e utilizado como chave do index.
*/

create index idx_astro
on nacao (upper(nome));

drop index idx_astro;


/*
c) Execute novamente as consultas e analise os planos de execu��o. Inclua os planos no script da
pr�tica. Explique as principais diferen�as em rela��o aos planos gerados antes da cria��o do
�ndice.
*/

/*  Resultado com a cria��o de um index para a fun��o upper
Plan hash value: 1990771718
 
-------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |           |   498 | 14940 |    67   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID BATCHED| NACAO     |   498 | 14940 |    67   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN                  | IDX_ASTRO |   199 |       |     1   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access(UPPER("NOME")='MINUS MAGNI.')
   
Com a cria��o do �ndice para upper(nome), o otimizador utilizou o �ndice ao realizar a busca. Houve uma pequena redu��o do custo e uso da CPU. Entretanto, a fun��o upper aplicada no nome ocasiona que o nome deixe de ser considerado como unique. Por esse motivo, o otimizador estima que podem haver muito mais linhas de resultado do que realmente h� (semanticamente, sabemos que h� apenas 1 tupla de resultado, pois nome � primary key da tabela)
Por isso, criaremos um unique index para upper(nome)
*/

create unique index idx_astro
on nacao (upper(nome));

/* Resultado com a cria��o de um index unique para a fun��o upper
Plan hash value: 1113848651
 
-----------------------------------------------------------------------------------------
| Id  | Operation                   | Name      | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |           |     1 |    30 |     2   (0)| 00:00:01 |
|   1 |  TABLE ACCESS BY INDEX ROWID| NACAO     |     1 |    30 |     2   (0)| 00:00:01 |
|*  2 |   INDEX UNIQUE SCAN         | IDX_ASTRO |     1 |       |     1   (0)| 00:00:01 |
-----------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access(UPPER("NOME")='MINUS MAGNI.')
   
Com o unique index, ele executa um Unique Index Scan, ou seja, ele acessar� apenas a tupla resultante e a estimativa fica adequada. Al�m disso, o custo � reduzido.
Apesar de na pr�tica, nesse caso, n�o haver diferen�a entre a consulta com e sem o unique index, em outras situa��es isso pode levar ao otimizador escolher realizar uma busca sequencial, pois ele n�o saberia que nome � uma unique.
*/


/*

4) Considere as consultas abaixo:
select * from planeta where massa between 0.1 and 10;
select * from planeta where massa between 0.1 and 3000;
a) Execute as consultas, e depois analise os planos de execu��o gerados pelo otimizador para essas
consultas.
*/

select * from planeta where massa between 0.1 and 10;
select * from planeta where massa between 0.1 and 3000;

-- Plano de Consulta: Consulta 01
explain plan set statement_id = 'teste1' for
    select * from planeta where massa between 0.1 and 10;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());


-- Plano de Consulta: Consulta 02
explain plan set statement_id = 'teste1' for
    select * from planeta where massa between 0.1 and 3000;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/* Resultado: Consulta 01

Plan hash value: 2930980072
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |     6 |   354 |   137   (1)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PLANETA |     6 |   354 |   137   (1)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<=10 AND "MASSA">=0.1)
*/

/*  Resultado: Consulta 02

Plan hash value: 2930980072
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  1580 | 93220 |   137   (1)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PLANETA |  1580 | 93220 |   137   (1)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<=3000 AND "MASSA">=0.1)
*/


/*
b) Crie um �ndice que possa melhorar a performance dessas consultas. Explique o porqu� da
escolha do tipo de �ndice criado.
*/

create index idx_massa
on planeta (massa);

drop index idx_massa;



/*
c) Execute novamente as consultas e analise os planos de execu��o. Inclua os planos no script da
pr�tica. Explique os resultados.
*/

/*  Resultado com a cria��o de um index para o atributo massa
Resultado: Consulta 01
Plan hash value: 2930980072
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  1599 | 94341 |   137   (1)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PLANETA |  1599 | 94341 |   137   (1)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<=10 AND "MASSA">=0.1)
   
   
Resultado: Consulta 02
Plan hash value: 2930980072
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  3352 |   193K|   137   (1)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| PLANETA |  3352 |   193K|   137   (1)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<=3000 AND "MASSA">=0.1)

A artir de certo ponto, mesmo existindo um �ndice para o atributo massa, torna-se mais eficiente realizar o acesso sequencial do que por �ndice, pois o acesso sequencial obt�m um bloco de dados em um �nico acesso ao disco.
Apesar disso, com a cria��o do �ndice as estimativas de linhas e bytes mudou.
*/

/*
5) Considere as consultas abaixo:
select * from especie where inteligente = 'V';
select * from especie where inteligente = 'F';
a) Execute as consultas, e depois analise os planos de execu��o gerados pelo otimizador para essas
consultas.
*/

select * from especie where inteligente = 'V';
select * from especie where inteligente = 'F';

-- Plano de Consulta: Consulta 01
explain plan set statement_id = 'teste1' for
    select * from especie where inteligente = 'V';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());


-- Plano de Consulta: Consulta 02
explain plan set statement_id = 'teste1' for
    select * from especie where inteligente = 'F';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/* Resultado: Consulta 01
Plan hash value: 139595281
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         | 24997 |   707K|    70   (3)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESPECIE | 24997 |   707K|    70   (3)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("INTELIGENTE"='V')
   
Resultado: Consulta 02
Plan hash value: 139595281
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         | 24997 |   707K|    70   (3)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESPECIE | 24997 |   707K|    70   (3)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("INTELIGENTE"='F')

*/


/*
b) Crie um �ndice bitmap para a tabela de esp�cies.
*/

create bitmap index idx_inteligente
    on especie(inteligente);

drop index idx_inteligente;


/*
c) Discuta vantagem(ns) e desvantagem(ns) da cria��o do �ndice. Use os planos de consulta gerados
ap�s a cria��o do �ndice para embasar sua resposta
*/

/*
6) Considere as consultas abaixo:
select * from estrela where classificacao = 'M3' and massa < 1;
a) Crie um �ndice de chave composta que possa melhorar a performance da consulta. Analise os
planos de consulta antes e depois da cria��o do �ndice para ter certeza do ganho de
performance.
*/

select * from estrela where classificacao = 'M3' and massa < 1;

-- Plano de Consulta: Consulta 01
explain plan set statement_id = 'teste1' for
    select * from estrela where classificacao = 'M3' and massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*  Resultados antes da cria��o do �ndice
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |    58 |  2668 |    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |    58 |  2668 |    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("CLASSIFICACAO"='M3' AND "MASSA"<1)
*/

create index idx_classificacao_massa
    on estrela(classificacao, massa);

drop index idx_classificacao_massa;

/*   Resultados depois da cria��o do �ndice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |    58 |  2668 |    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |    58 |  2668 |    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("CLASSIFICACAO"='M3' AND "MASSA"<1)  
*/

/*
b) Execute as consultas abaixo, e analise os planos de execu��o gerados pelo otimizador. Em
qual(ai) dela(s) o �ndice � utilizado e em qual(is) n�o �. Explique a raz�o em cada caso.
select * from estrela where classificacao = 'M3' or massa < 1;
select * from estrela where classificacao = 'M3';
select * from estrela where massa < 1;
*/

-- SILMAR --
/*
7) Crie um �ndice que melhore a performance da consulta abaixo. Apresente os planos de execu��o
antes e depois do �ndice e explique porque sua solu��o funciona (qual foi sua linha de racioc�nio?).
select classificacao, count(*) from estrela
group by classificacao;
8) Pesquise sobre bitmap join index. Elabore uma consulta com jun��o que possa se beneficiar desse
tipo de �ndice e explique o porqu�. Crie o �ndice e analise os planos de consulta antes e depois.
OBS: se for usar alguma tabela que est� vazia, fa�a as devidas inser��es para teste.
*/