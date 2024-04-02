/*
SCC0541 - Laborat�rio de Base de Dados
Pr�tica 04 - �ndices
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/* 1) Preparando a base de dados....
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
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(NULL, NULL); */

EXEC DBMS_STATS.GATHER_SCHEMA_STATS(NULL, NULL);

/* 2) Considere as consultas abaixo:
select * from planeta
where classificacao = 'Dolores autem maxime fuga.';
select * from planeta where classificacao = 'Confirmed';
a) Execute as consultas, e depois analise os planos de execu��o gerados pelo otimizador para essas
consultas. */

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
 
   1 - filter("CLASSIFICACAO"='Confirmed') */ 
   
/*  Como em ambas as consultas � solicitada a mesma informa��o (planetas com uma determinada classifica��o) e n�o h� index para o atributo buscado, o processo realizado � o mesmo: percorrer toda tabela seleciionando as tuplas que satisfazem a condi��o solicitada */


/* b) Crie um �ndice que possa melhorar a performance dessas consultas. Explique o porqu� da
escolha do tipo de �ndice criado. */

create index idx_classificacao
on planeta (classificacao);

drop index idx_classificacao;

/*  Utilizou-se o �ndice B-tree, que � mais simples e comum.
A cardinalidade do atributo classifica��o � muito alta, n�o sendo vi�vel o uso de um bitmap index.
Al�m disso, n�o h� a computa��o de uma fun��o ou express�o, n�o fazendo sentido o uso de um Function-Based Index.
Por se tratar de consultas simples, n�o h� a necessidade de utilizar um Application Domain Index
Por esses motivos, optamos pelo B-Tree index */

/*  c) Execute novamente as consultas e analise os planos de execu��o. Inclua os plano no script da
pr�tica. Explique as principais diferen�as em rela��o aos planos gerados antes da cria��o do
�ndice. */

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
 
   1 - filter("CLASSIFICACAO"='Confirmed') */
        
    
/*  Ap�s a cria��o do �ndice, na primeira consulta o custo foi bem menor devido ao fato de ser 1 acesso � 1 tupla da tabela. Por isso, a opera��o realizada foi o acesso por �ndice.
Em contrapartida, na segunda consulta v�rias tuplas s�o acessadas, sendo assim, mesmo com a cria��o do �ndice, ele n�o � utilizado e o resultado permanece o mesmo de antes, pois o otimizador continua realizando a busca sequencial. */


/*  3) Considere as consultas abaixo:
select * from nacao where nome = 'Minus magni.';
select * from nacao where upper(nome) = 'MINUS MAGNI.';
a) Execute as consultas, e depois analise os planos de execu��o gerados pelo otimizador para essas
consultas. Explique a principal diferen�a entre eles e a raz�o dessa diferen�a */

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
 
   1 - filter(UPPER("NOME")='MINUS MAGNI.') */
   
/*  Houve uma diferen�a na opera��o realizada em cada opra��o e, por consequ�ncia no custo. Enquanto na consulta 1 ele utiliza o �ndice para acessar a tupla, na consulta 2 toda a tebala � percorrida.
Ambas as consultas retornam apenas 1 tupla como resultado. Entretanto, como na segunda consulta h� a fun��o 'upper', o otimizador entende que pode haver mais de 1 resultado poss�vel, pois o atrbuto deixa de ser uma unique, sendo assim, verifica-se toda a tabela. */


/*  b) Crie um �ndice que possa melhorar a performance da segunda consulta. Explique o porqu� da
escolha do tipo de �ndice criado. */

/* Como h� a fun��o upper na consulta 02, utilizaremos uma Function-Based Index para que o valor da fun��o seja calculado e utilizado como chave do index. */

create index idx_astro
on nacao (upper(nome));

drop index idx_astro;


/*  c) Execute novamente as consultas e analise os planos de execu��o. Inclua os planos no script da
pr�tica. Explique as principais diferen�as em rela��o aos planos gerados antes da cria��o do
�ndice. */

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
 
   2 - access(UPPER("NOME")='MINUS MAGNI.') */
   
/*  Com a cria��o do �ndice para upper(nome), o otimizador utilizou o �ndice ao realizar a busca. Houve uma pequena redu��o do custo e uso da CPU. Entretanto, a fun��o upper aplicada no nome ocasiona que o nome deixe de ser considerado como unique. Por esse motivo, o otimizador estima que podem haver muito mais linhas de resultado do que realmente h� (semanticamente, sabemos que h� apenas 1 tupla de resultado, pois nome � primary key da tabela)
Por isso, criaremos um unique index para upper(nome) */

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
 
   2 - access(UPPER("NOME")='MINUS MAGNI.') */
   
/*  Com o unique index, ele executa um Unique Index Scan, ou seja, ele acessar� apenas a tupla resultante e a estimativa fica adequada. Al�m disso, o custo � reduzido.
Apesar de na pr�tica, nesse caso, n�o haver diferen�a entre a consulta com e sem o unique index, em outras situa��es isso pode levar ao otimizador escolher realizar uma busca sequencial, pois ele n�o saberia que nome � uma unique. */


/* 4) Considere as consultas abaixo:
select * from planeta where massa between 0.1 and 10;
select * from planeta where massa between 0.1 and 3000;
a) Execute as consultas, e depois analise os planos de execu��o gerados pelo otimizador para essas
consultas. */

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
 
   1 - filter("MASSA"<=10 AND "MASSA">=0.1) */

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
 
   1 - filter("MASSA"<=3000 AND "MASSA">=0.1) */


/*  b) Crie um �ndice que possa melhorar a performance dessas consultas. Explique o porqu� da
escolha do tipo de �ndice criado. */

create index idx_massa
on planeta (massa);

drop index idx_massa;

/*  c) Execute novamente as consultas e analise os planos de execu��o. Inclua os planos no script da
pr�tica. Explique os resultados. */

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
 
   1 - filter("MASSA"<=3000 AND "MASSA">=0.1) */

/*  A artir de certo ponto, mesmo existindo um �ndice para o atributo massa, torna-se mais eficiente realizar o acesso sequencial do que por �ndice, pois o acesso sequencial obt�m um bloco de dados em um �nico acesso ao disco.
Apesar disso, com a cria��o do �ndice as estimativas de linhas e bytes mudou. */

/*  5) Considere as consultas abaixo:
select * from especie where inteligente = 'V';
select * from especie where inteligente = 'F';
a) Execute as consultas, e depois analise os planos de execu��o gerados pelo otimizador para essas
consultas. */

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
|   0 | SELECT STATEMENT  |         | 24940 |   706K|    70   (3)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESPECIE | 24940 |   706K|    70   (3)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("INTELIGENTE"='V') */

   
/* Resultado: Consulta 02
Plan hash value: 139595281
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         | 25054 |   709K|    70   (3)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESPECIE | 25054 |   709K|    70   (3)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("INTELIGENTE"='F') */

/* b) Crie um �ndice bitmap para a tabela de esp�cies. */

create bitmap index idx_inteligente
    on especie(inteligente);

drop index idx_inteligente;


/* c) Discuta vantagem(ns) e desvantagem(ns) da cria��o do �ndice. Use os planos de consulta gerados
ap�s a cria��o do �ndice para embasar sua resposta */

/* A cria��o de um �ndice bitmap possibilita uma mehoria no desempenho das consultas que filtram dados com base em colunas que possuem um n�mero limitado de valores distintos, como booleanos ou valores discretos.
Outra vantagem consiste na redu��o dos acessos ao disco e da sobrecarga da CPU, j� que �ndices bitmap geralmente s�o mais eficientes em termos de CPU do que outras formas de �ndices.

Em contrapartida, � importante considerar que o �ndice bitmap pode consumir mais espa�o de armazenamento, especiealmente em tabelas grandes ou colunas com v�rios valores distintos.
Al�m disso, h� o custo de overhead de atualiza��o que ocorrer� em todas as opera��es de inser��o, atualiza��o e exclus�o da tabela.

Para o caso das consultas acima, podemos observar que o n�mero de tuplas recuperadas em cada uma dessas consultas equivale a aproximadamente metade da quantidade total de tuplas da tabela.
Sendo assim, para o otimizador � mais vantajoso realizar o acesso sequencial, uma vez que um grande bloco de dados ser� recuperado. */

-- Plano de Consulta: Usando o �ndice bitmap
explain plan set statement_id = 'teste1' for
    SELECT COUNT(*) FROM especie WHERE inteligente = 'V';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/* Em contrapartida, em uma busca como a acima, o otimizador far� uso do �ndice bitmap, pois n�o ser� necess�rio recuperar um grande volume de dados, apenas contar a quantidade de tuplas correspondentes. */


/* 6) Considere as consultas abaixo:
select * from estrela where classificacao = 'M3' and massa < 1;
a) Crie um �ndice de chave composta que possa melhorar a performance da consulta. Analise os
planos de consulta antes e depois da cria��o do �ndice para ter certeza do ganho de
performance. */

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
 
   1 - filter("CLASSIFICACAO"='M3' AND "MASSA"<1) */

-- Cria��o do �ndice:
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
 
   1 - filter("CLASSIFICACAO"='M3' AND "MASSA"<1) */
/* Podemos observar que, mesmo com a cria��o do �ndice, o otimizador continua varrendo toda a tabela. Isso ocorre pois ele precisar� recuparar uma grande quantidade de dados, n�o sendo vantajoso o uso do �ndice.
Entretanto, em buscas em que o objetivo seja recuperar os dados de algum atrbuto que est� indexado, o otimizador far� uso do �ndice, como no exemplo abaixo: */

select massa from estrela where classificacao = 'M3' and massa < 1;

-- Plano de Consulta: Consulta 01
explain plan set statement_id = 'teste1' for
    select massa from estrela where classificacao = 'M3' and massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*
Plan hash value: 3833001942
 
--------------------------------------------------------------------------------------------
| Id  | Operation        | Name                    | Rows  | Bytes | Cost (%CPU)| Time     |
--------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT |                         |    58 |   928 |     2   (0)| 00:00:01 |
|*  1 |  INDEX RANGE SCAN| IDX_CLASSIFICACAO_MASSA |    58 |   928 |     2   (0)| 00:00:01 |
--------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - access("CLASSIFICACAO"='M3' AND "MASSA"<1) */
   
/* b) Execute as consultas abaixo, e analise os planos de execu��o gerados pelo otimizador. Em
qual(ai) dela(s) o �ndice � utilizado e em qual(is) n�o �. Explique a raz�o em cada caso.
select * from estrela where classificacao = 'M3' or massa < 1;
select * from estrela where classificacao = 'M3';
select * from estrela where massa < 1; */

-- Consulta 01
select * from estrela where classificacao = 'M3' or massa < 1;

-- Plano de Consulta:
explain plan set statement_id = 'teste1' for
    select * from estrela where classificacao = 'M3' or massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*  Resultado antes da cria��o do �ndice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  3134 |   140K|    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |  3134 |   140K|    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<1 OR "CLASSIFICACAO"='M3') */
   
/* Resultado depois da cria��o do �ndice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  3134 |   140K|    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |  3134 |   140K|    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<1 OR "CLASSIFICACAO"='M3') */
   
/* Nessa consulta, o otimizador realiza uma busca sequencial, pois ser� nececss�rio recuperar um grande volume de dados.
Sendo assim, o �ndice criado n�o � utilizado. */

-- Consulta 02
select * from estrela where classificacao = 'M3';

-- Plano de Consulta:
explain plan set statement_id = 'teste1' for
    select * from estrela where classificacao = 'M3';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/* Resultado antes da cria��o do �ndice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |   125 |  5750 |    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |   125 |  5750 |    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("CLASSIFICACAO"='M3') */

/* Resultado depois da cria��o do �ndice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |   125 |  5750 |    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |   125 |  5750 |    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("CLASSIFICACAO"='M3') */

/* Semelhantemente � consulta anterior, o otimizador realiza uma busca sequencial, pois ser� nececss�rio recuperar um grande volume de dados.
Sendo assim, o �ndice criado n�o � utilizado. */

-- Consulta 03
select * from estrela where massa < 1;

-- Plano de Consulta:
explain plan set statement_id = 'teste1' for
    select * from estrela where massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*  Resultado antes da cria��o do �ndice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  3067 |   137K|    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |  3067 |   137K|    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<1) */
   
/* Resultado depois da cria��o do �ndice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  3067 |   137K|    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |  3067 |   137K|    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<1) */

/* Semelhantemente �s consultas anteriores, o otimizador realiza uma busca sequencial, pois ser� nececss�rio recuperar um grande volume de dados.
Sendo assim, o �ndice criado n�o � utilizado. */


/* 7) Crie um �ndice que melhore a performance da consulta abaixo. Apresente os planos de execu��o
antes e depois do �ndice e explique porque sua solu��o funciona (qual foi sua linha de racioc�nio?).
select classificacao, count(*) from estrela
group by classificacao; */

-- Consulta --
select classificacao, count(*) from estrela
group by classificacao;

explain plan set statement_id = 'teste1' for
    select classificacao, count(*) from estrela
	group by classificacao;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*
Resultados antes da cria��o do indice:

------------------------------------------------------------------------------
| Id  | Operation          | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |         |  1235 |  6175 |    16   (7)| 00:00:01 |
|   1 |  HASH GROUP BY     |         |  1235 |  6175 |    16   (7)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| ESTRELA |  6586 | 32930 |    15   (0)| 00:00:01 |
------------------------------------------------------------------------------
*/

-- Cria��o do indice --

CREATE index idx_classificacao_id
    on estrela(classificacao, id_estrela);

drop index idx_classificacao_id;

/*
Resultados ap�s a cria��o do indice:

-------------------------------------------------------------------------------------------
| Id  | Operation             | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |                   |  1235 |  6175 |     9  (12)| 00:00:01 |
|   1 |  HASH GROUP BY        |                   |  1235 |  6175 |     9  (12)| 00:00:01 |
|   2 |   INDEX FAST FULL SCAN| IDX_CLASSIFICACAO |  6586 | 32930 |     8   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

Com rela��o ao porque essa solu��o funciona, a consulta em quest�o exige apenas um
atributo (classifica��o) e ler� todas as tuplas pois ira contar todas ap�s serem agrupadas.
Assim, a melhor op��o para melhorar o desempenho com o uso de indice ser� um Fast Full Index Scan
com a classifica��o da estrela indexada.

Entretanto se indexarmos apenas a classifica��o, o Fast Full Index Scan n�o ir� ocorrer pois
o atriburo indexado pode ser NULL, e ter ao menos um atributo NOT NULL � uma exigencia desse tipo
de scan, para resolver tal problema basta indexar junto a classifica��o um atributo que cumpra o
requisito, no caso o que est� sendo usado o ID_ESTRELA.

Assim, com o uso do indice ao inves de um table access temos como resultado uma diminui��o no custo
de aproximadamente 44%, mesmo que haja uma maior ultiliza��o da CPU
*/

/* 8) Pesquise sobre bitmap join index. Elabore uma consulta com jun��o que possa se beneficiar desse
tipo de �ndice e explique o porqu�. Crie o �ndice e analise os planos de consulta antes e depois.
OBS: se for usar alguma tabela que est� vazia, fa�a as devidas inser��es para teste. */

/* Suponhamos que seja comum consultar o n�mero de esp�cies cujo planeta de origem � de determinada classifica��o.
Uma consulta desse tipo pode ser: */

SELECT COUNT(*) 
FROM   especie, planeta 
WHERE  especie.planeta_or = planeta.id_astro 
AND    planeta.classificacao = 'Confirmed';

explain plan set statement_id = 'teste1' for
    SELECT COUNT(*) 
    FROM   especie, planeta 
    WHERE  especie.planeta_or = planeta.id_astro 
    AND    planeta.classificacao = 'Confirmed';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/* Para essa consulta, � gerado o seguinte plano de consulta:
Plan hash value: 86740029
 
-------------------------------------------------------------------------------
| Id  | Operation           | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------
|   0 | SELECT STATEMENT    |         |     1 |    61 |   207   (2)| 00:00:01 |
|   1 |  SORT AGGREGATE     |         |     1 |    61 |            |          |
|*  2 |   HASH JOIN         |         |  7865 |   468K|   207   (2)| 00:00:01 |
|*  3 |    TABLE ACCESS FULL| PLANETA |  5190 |   238K|   137   (1)| 00:00:01 |
|   4 |    TABLE ACCESS FULL| ESPECIE | 49994 |   683K|    69   (2)| 00:00:01 |
-------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   2 - access("ESPECIE"."PLANETA_OR"="PLANETA"."ID_ASTRO")
   3 - filter("PLANETA"."CLASSIFICACAO"='Confirmed') */

/* Note que, para localizar as linhas correspondentes, � realizada uma varredura nas tabelas.
A fim de minimizar o custo dessa busca, pode-se criar um bitmap join index. Dessa froma, ser� poss�vel recuperar os dados a partir do �ndice: */

CREATE BITMAP INDEX idx_especie
ON     especie (planeta.classificacao) 
FROM   especie, planeta
WHERE  especie.planeta_or = planeta.id_astro;

drop index idx_especie;

/* Ap�s a cria��o do �ndice, temos o plano de consulta abaixo:
Plan hash value: 1605055779
 
-------------------------------------------------------------------------------------------
| Id  | Operation                   | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |             |     1 |    14 |    23   (0)| 00:00:01 |
|   1 |  SORT AGGREGATE             |             |     1 |    14 |            |          |
|   2 |   BITMAP CONVERSION COUNT   |             |     2 |    28 |    23   (0)| 00:00:01 |
|*  3 |    BITMAP INDEX SINGLE VALUE| IDX_ESPECIE |       |       |            |          |
-------------------------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   3 - access("ESPECIE"."SYS_NC00004$"='Confirmed') */

/* Podemos observar que, com o �ndice, houve uma grande redu��o nos custos, estimativas de linhas e bytes.
Sendo assim, a busca se tornou muito mais eficiente. */
