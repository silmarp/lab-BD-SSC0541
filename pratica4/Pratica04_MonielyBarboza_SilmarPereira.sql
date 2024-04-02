/*
SCC0541 - Laboratório de Base de Dados
Prática 03 - SQL/DDL-DML
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*
1) Preparando a base de dados....
a) remova todas as tabelas criadas na Prática 3
Ø Dica: usando o comando abaixo, crie um script de remoção para todas as suas tabelas - o script
será o resultado da consulta
select 'drop table '||table_name||' cascade constraints;' from user_tables;
( || é um operador de concatenação de string )
b) crie novas tabelas executando o script esquema.sql (disponível no Tidia)
c) alimente a base com o script dados_novo.sql (disponível no Tidia)
d) como o seu esquema acabou de ser criado, ainda não há estatísticas coletadas para ele.
Portanto, qualquer plano de consulta será gerado sem o uso de estatísticas, considerando
apenas regras do otimizador e avaliações de custo. Execute o comando abaixo para
coletar as estatísticas que ajudam na otimização das consultas. Se o comando não for
executado explicitamente, as estatísticas são geradas automaticamente durante a noite
(quando o Oracle está configurado para isso).
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(NULL, NULL);
*/

EXEC DBMS_STATS.GATHER_SCHEMA_STATS(NULL, NULL);

/*
2) Considere as consultas abaixo:
select * from planeta
where classificacao = 'Dolores autem maxime fuga.';
select * from planeta where classificacao = 'Confirmed';
a) Execute as consultas, e depois analise os planos de execução gerados pelo otimizador para essas
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
   
   
Como em ambas as consultas é solicitada a mesma informação (planetas com uma determinada classificação) e não há index para o atributo buscado, o processo realizado é o mesmo: percorrer toda tabela seleciionando as tuplas que satisfazem a condição solicitada
*/


/*
b) Crie um índice que possa melhorar a performance dessas consultas. Explique o porquê da
escolha do tipo de índice criado.
*/

create index idx_classificacao
on planeta (classificacao);

drop index idx_classificacao;

-- TODO: explicar o pq da escolha desse tipo de indice


/*
c) Execute novamente as consultas e analise os planos de execução. Inclua os plano no script da
prática. Explique as principais diferenças em relação aos planos gerados antes da criação do
índice.
*/

/*  Resultados após a criação do índice:
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
        
    
Após a criação do índice, na primeira consulta o custo foi bem menor devido ao fato de ser 1 acesso à 1 tupla da tabela. Por isso, a operação realizada foi o acesso por índice.
Em contrapartida, na segunda consulta várias tuplas são acessadas, sendo assim, mesmo com a criação do índice, ele não é utilizado e o resultado permanece o mesmo de antes, pois o otimizador continua realizando a busca sequencial.
*/


/*
3) Considere as consultas abaixo:
select * from nacao where nome = 'Minus magni.';
select * from nacao where upper(nome) = 'MINUS MAGNI.';
a) Execute as consultas, e depois analise os planos de execução gerados pelo otimizador para essas
consultas. Explique a principal diferença entre eles e a razão dessa diferença
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
   
Houve uma diferença na operação realizada em cada opração e, por consequência no custo. Enquanto na consulta 1 ele utiliza o índice para acessar a tupla, na consulta 2 toda a tebala é percorrida.
Ambas as consultas retornam apenas 1 tupla como resultado. Entretanto, como na segunda consulta há a função 'upper', o otimizador entende que pode haver mais de 1 resultado possível, pois o atrbuto deixa de ser uma unique, sendo assim, verifica-se toda a tabela.   
        
*/


/*
b) Crie um índice que possa melhorar a performance da segunda consulta. Explique o porquê da
escolha do tipo de índice criado.

Como há a função upper na consulta 02, utilizaremos uma Function-Based Index para que o valor da função seja calculado e utilizado como chave do index.
*/

create index idx_astro
on nacao (upper(nome));

drop index idx_astro;


/*
c) Execute novamente as consultas e analise os planos de execução. Inclua os planos no script da
prática. Explique as principais diferenças em relação aos planos gerados antes da criação do
índice.
*/

/*  Resultado com a criação de um index para a função upper
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
   
Com a criação do índice para upper(nome), o otimizador utilizou o índice ao realizar a busca. Houve uma pequena redução do custo e uso da CPU. Entretanto, a função upper aplicada no nome ocasiona que o nome deixe de ser considerado como unique. Por esse motivo, o otimizador estima que podem haver muito mais linhas de resultado do que realmente há (semanticamente, sabemos que há apenas 1 tupla de resultado, pois nome é primary key da tabela)
Por isso, criaremos um unique index para upper(nome)
*/

create unique index idx_astro
on nacao (upper(nome));

/* Resultado com a criação de um index unique para a função upper
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
   
Com o unique index, ele executa um Unique Index Scan, ou seja, ele acessará apenas a tupla resultante e a estimativa fica adequada. Além disso, o custo é reduzido.
Apesar de na prática, nesse caso, não haver diferença entre a consulta com e sem o unique index, em outras situações isso pode levar ao otimizador escolher realizar uma busca sequencial, pois ele não saberia que nome é uma unique.
*/


/*

4) Considere as consultas abaixo:
select * from planeta where massa between 0.1 and 10;
select * from planeta where massa between 0.1 and 3000;
a) Execute as consultas, e depois analise os planos de execução gerados pelo otimizador para essas
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
b) Crie um índice que possa melhorar a performance dessas consultas. Explique o porquê da
escolha do tipo de índice criado.
*/

create index idx_massa
on planeta (massa);

drop index idx_massa;



/*
c) Execute novamente as consultas e analise os planos de execução. Inclua os planos no script da
prática. Explique os resultados.
*/

/*  Resultado com a criação de um index para o atributo massa
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

A artir de certo ponto, mesmo existindo um índice para o atributo massa, torna-se mais eficiente realizar o acesso sequencial do que por índice, pois o acesso sequencial obtém um bloco de dados em um único acesso ao disco.
Apesar disso, com a criação do índice as estimativas de linhas e bytes mudou.
*/

/*
5) Considere as consultas abaixo:
select * from especie where inteligente = 'V';
select * from especie where inteligente = 'F';
a) Execute as consultas, e depois analise os planos de execução gerados pelo otimizador para essas
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
|   0 | SELECT STATEMENT  |         | 24940 |   706K|    70   (3)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESPECIE | 24940 |   706K|    70   (3)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("INTELIGENTE"='V')
   
Resultado: Consulta 02
Plan hash value: 139595281
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         | 25054 |   709K|    70   (3)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESPECIE | 25054 |   709K|    70   (3)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("INTELIGENTE"='F')
*/


/*
b) Crie um índice bitmap para a tabela de espécies.
*/

create bitmap index idx_inteligente
    on especie(inteligente);

drop index idx_inteligente;


/*
c) Discuta vantagem(ns) e desvantagem(ns) da criação do índice. Use os planos de consulta gerados
após a criação do índice para embasar sua resposta

Resultado após a criação do índice: Consulta 01
Plan hash value: 139595281
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         | 24940 |   706K|    70   (3)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESPECIE | 24940 |   706K|    70   (3)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("INTELIGENTE"='V')
   
Resultado após a criação do índice: Consulta 02
Plan hash value: 139595281
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         | 25054 |   709K|    70   (3)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESPECIE | 25054 |   709K|    70   (3)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("INTELIGENTE"='F')

*/

/*
6) Considere as consultas abaixo:
select * from estrela where classificacao = 'M3' and massa < 1;
a) Crie um índice de chave composta que possa melhorar a performance da consulta. Analise os
planos de consulta antes e depois da criação do índice para ter certeza do ganho de
performance.
*/

select * from estrela where classificacao = 'M3' and massa < 1;

-- Plano de Consulta: Consulta 01
explain plan set statement_id = 'teste1' for
    select * from estrela where classificacao = 'M3' and massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*  Resultados antes da criação do índice
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

/*   Resultados depois da criação do índice:
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
b) Execute as consultas abaixo, e analise os planos de execução gerados pelo otimizador. Em
qual(ai) dela(s) o índice é utilizado e em qual(is) não é. Explique a razão em cada caso.
select * from estrela where classificacao = 'M3' or massa < 1;
select * from estrela where classificacao = 'M3';
select * from estrela where massa < 1;
*/

-- Consulta 01
select * from estrela where classificacao = 'M3' or massa < 1;

-- Plano de Consulta:
explain plan set statement_id = 'teste1' for
    select * from estrela where classificacao = 'M3' or massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/* 
-- Antes da criação do índice
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  3134 |   140K|    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |  3134 |   140K|    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<1 OR "CLASSIFICACAO"='M3')
   
   
-- Depois da criação do índice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  3134 |   140K|    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |  3134 |   140K|    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<1 OR "CLASSIFICACAO"='M3')
*/

-- Consulta 02
select * from estrela where classificacao = 'M3';

-- Plano de Consulta: Consulta 02
explain plan set statement_id = 'teste1' for
    select * from estrela where classificacao = 'M3';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());
/*
-- Antes da criação do índice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |   125 |  5750 |    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |   125 |  5750 |    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("CLASSIFICACAO"='M3')
   
-- Depois da criação do índice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |   125 |  5750 |    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |   125 |  5750 |    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("CLASSIFICACAO"='M3')
*/

-- Consulta 03
select * from estrela where massa < 1;

-- Plano de Consulta: Consulta 03
explain plan set statement_id = 'teste1' for
    select * from estrela where massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());
/*
--  Antes da criação do índice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  3067 |   137K|    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |  3067 |   137K|    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<1)

-- Depois da criação do índice:
Plan hash value: 1653849300
 
-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |  3067 |   137K|    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |  3067 |   137K|    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------
 
Predicate Information (identified by operation id):
---------------------------------------------------
 
   1 - filter("MASSA"<1)
*/

-- SILMAR --
/*
7) Crie um índice que melhore a performance da consulta abaixo. Apresente os planos de execução
antes e depois do índice e explique porque sua solução funciona (qual foi sua linha de raciocínio?).
select classificacao, count(*) from estrela
group by classificacao;
8) Pesquise sobre bitmap join index. Elabore uma consulta com junção que possa se beneficiar desse
tipo de índice e explique o porquê. Crie o índice e analise os planos de consulta antes e depois.
OBS: se for usar alguma tabela que está vazia, faça as devidas inserções para teste.
*/
