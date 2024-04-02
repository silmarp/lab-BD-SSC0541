/*
SCC0541 - Laboratório de Base de Dados
Prática 04 - Índices
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/* 1) Preparando a base de dados....
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
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(NULL, NULL); */

EXEC DBMS_STATS.GATHER_SCHEMA_STATS(NULL, NULL);

/* 2) Considere as consultas abaixo:
select * from planeta
where classificacao = 'Dolores autem maxime fuga.';
select * from planeta where classificacao = 'Confirmed';
a) Execute as consultas, e depois analise os planos de execução gerados pelo otimizador para essas
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
   
/*  Como em ambas as consultas é solicitada a mesma informação (planetas com uma determinada classificação) e não há index para o atributo buscado, o processo realizado é o mesmo: percorrer toda tabela seleciionando as tuplas que satisfazem a condição solicitada */


/* b) Crie um índice que possa melhorar a performance dessas consultas. Explique o porquê da
escolha do tipo de índice criado. */

create index idx_classificacao
on planeta (classificacao);

drop index idx_classificacao;

/*  Utilizou-se o índice B-tree, que é mais simples e comum.
A cardinalidade do atributo classificação é muito alta, não sendo viável o uso de um bitmap index.
Além disso, não há a computação de uma função ou expressão, não fazendo sentido o uso de um Function-Based Index.
Por se tratar de consultas simples, não há a necessidade de utilizar um Application Domain Index
Por esses motivos, optamos pelo B-Tree index */

/*  c) Execute novamente as consultas e analise os planos de execução. Inclua os plano no script da
prática. Explique as principais diferenças em relação aos planos gerados antes da criação do
índice. */

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
 
   1 - filter("CLASSIFICACAO"='Confirmed') */
        
    
/*  Após a criação do índice, na primeira consulta o custo foi bem menor devido ao fato de ser 1 acesso à 1 tupla da tabela. Por isso, a operação realizada foi o acesso por índice.
Em contrapartida, na segunda consulta várias tuplas são acessadas, sendo assim, mesmo com a criação do índice, ele não é utilizado e o resultado permanece o mesmo de antes, pois o otimizador continua realizando a busca sequencial. */


/*  3) Considere as consultas abaixo:
select * from nacao where nome = 'Minus magni.';
select * from nacao where upper(nome) = 'MINUS MAGNI.';
a) Execute as consultas, e depois analise os planos de execução gerados pelo otimizador para essas
consultas. Explique a principal diferença entre eles e a razão dessa diferença */

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
   
/*  Houve uma diferença na operação realizada em cada opração e, por consequência no custo. Enquanto na consulta 1 ele utiliza o índice para acessar a tupla, na consulta 2 toda a tebala é percorrida.
Ambas as consultas retornam apenas 1 tupla como resultado. Entretanto, como na segunda consulta há a função 'upper', o otimizador entende que pode haver mais de 1 resultado possível, pois o atrbuto deixa de ser uma unique, sendo assim, verifica-se toda a tabela. */


/*  b) Crie um índice que possa melhorar a performance da segunda consulta. Explique o porquê da
escolha do tipo de índice criado. */

/* Como há a função upper na consulta 02, utilizaremos uma Function-Based Index para que o valor da função seja calculado e utilizado como chave do index. */

create index idx_astro
on nacao (upper(nome));

drop index idx_astro;


/*  c) Execute novamente as consultas e analise os planos de execução. Inclua os planos no script da
prática. Explique as principais diferenças em relação aos planos gerados antes da criação do
índice. */

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
 
   2 - access(UPPER("NOME")='MINUS MAGNI.') */
   
/*  Com a criação do índice para upper(nome), o otimizador utilizou o índice ao realizar a busca. Houve uma pequena redução do custo e uso da CPU. Entretanto, a função upper aplicada no nome ocasiona que o nome deixe de ser considerado como unique. Por esse motivo, o otimizador estima que podem haver muito mais linhas de resultado do que realmente há (semanticamente, sabemos que há apenas 1 tupla de resultado, pois nome é primary key da tabela)
Por isso, criaremos um unique index para upper(nome) */

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
 
   2 - access(UPPER("NOME")='MINUS MAGNI.') */
   
/*  Com o unique index, ele executa um Unique Index Scan, ou seja, ele acessará apenas a tupla resultante e a estimativa fica adequada. Além disso, o custo é reduzido.
Apesar de na prática, nesse caso, não haver diferença entre a consulta com e sem o unique index, em outras situações isso pode levar ao otimizador escolher realizar uma busca sequencial, pois ele não saberia que nome é uma unique. */


/* 4) Considere as consultas abaixo:
select * from planeta where massa between 0.1 and 10;
select * from planeta where massa between 0.1 and 3000;
a) Execute as consultas, e depois analise os planos de execução gerados pelo otimizador para essas
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


/*  b) Crie um índice que possa melhorar a performance dessas consultas. Explique o porquê da
escolha do tipo de índice criado. */

create index idx_massa
on planeta (massa);

drop index idx_massa;

/*  c) Execute novamente as consultas e analise os planos de execução. Inclua os planos no script da
prática. Explique os resultados. */

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
 
   1 - filter("MASSA"<=3000 AND "MASSA">=0.1) */

/*  A artir de certo ponto, mesmo existindo um índice para o atributo massa, torna-se mais eficiente realizar o acesso sequencial do que por índice, pois o acesso sequencial obtém um bloco de dados em um único acesso ao disco.
Apesar disso, com a criação do índice as estimativas de linhas e bytes mudou. */

/*  5) Considere as consultas abaixo:
select * from especie where inteligente = 'V';
select * from especie where inteligente = 'F';
a) Execute as consultas, e depois analise os planos de execução gerados pelo otimizador para essas
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

/* b) Crie um índice bitmap para a tabela de espécies. */

create bitmap index idx_inteligente
    on especie(inteligente);

drop index idx_inteligente;


/* c) Discuta vantagem(ns) e desvantagem(ns) da criação do índice. Use os planos de consulta gerados
após a criação do índice para embasar sua resposta */

/* A criação de um índice bitmap possibilita uma mehoria no desempenho das consultas que filtram dados com base em colunas que possuem um número limitado de valores distintos, como booleanos ou valores discretos.
Outra vantagem consiste na redução dos acessos ao disco e da sobrecarga da CPU, já que índices bitmap geralmente são mais eficientes em termos de CPU do que outras formas de índices.

Em contrapartida, é importante considerar que o índice bitmap pode consumir mais espaço de armazenamento, especiealmente em tabelas grandes ou colunas com vários valores distintos.
Além disso, há o custo de overhead de atualização que ocorrerá em todas as operações de inserção, atualização e exclusão da tabela.

Para o caso das consultas acima, podemos observar que o número de tuplas recuperadas em cada uma dessas consultas equivale a aproximadamente metade da quantidade total de tuplas da tabela.
Sendo assim, para o otimizador é mais vantajoso realizar o acesso sequencial, uma vez que um grande bloco de dados será recuperado. */

-- Plano de Consulta: Usando o índice bitmap
explain plan set statement_id = 'teste1' for
    SELECT COUNT(*) FROM especie WHERE inteligente = 'V';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/* Em contrapartida, em uma busca como a acima, o otimizador fará uso do índice bitmap, pois não será necessário recuperar um grande volume de dados, apenas contar a quantidade de tuplas correspondentes. */


/* 6) Considere as consultas abaixo:
select * from estrela where classificacao = 'M3' and massa < 1;
a) Crie um índice de chave composta que possa melhorar a performance da consulta. Analise os
planos de consulta antes e depois da criação do índice para ter certeza do ganho de
performance. */

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
 
   1 - filter("CLASSIFICACAO"='M3' AND "MASSA"<1) */

-- Criação do índice:
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
 
   1 - filter("CLASSIFICACAO"='M3' AND "MASSA"<1) */
/* Podemos observar que, mesmo com a criação do índice, o otimizador continua varrendo toda a tabela. Isso ocorre pois ele precisará recuparar uma grande quantidade de dados, não sendo vantajoso o uso do índice.
Entretanto, em buscas em que o objetivo seja recuperar os dados de algum atrbuto que está indexado, o otimizador fará uso do índice, como no exemplo abaixo: */

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
   
/* b) Execute as consultas abaixo, e analise os planos de execução gerados pelo otimizador. Em
qual(ai) dela(s) o índice é utilizado e em qual(is) não é. Explique a razão em cada caso.
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

/*  Resultado antes da criação do índice:
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
   
/* Resultado depois da criação do índice:
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
   
/* Nessa consulta, o otimizador realiza uma busca sequencial, pois será nececssário recuperar um grande volume de dados.
Sendo assim, o índice criado não é utilizado. */

-- Consulta 02
select * from estrela where classificacao = 'M3';

-- Plano de Consulta:
explain plan set statement_id = 'teste1' for
    select * from estrela where classificacao = 'M3';
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/* Resultado antes da criação do índice:
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

/* Resultado depois da criação do índice:
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

/* Semelhantemente à consulta anterior, o otimizador realiza uma busca sequencial, pois será nececssário recuperar um grande volume de dados.
Sendo assim, o índice criado não é utilizado. */

-- Consulta 03
select * from estrela where massa < 1;

-- Plano de Consulta:
explain plan set statement_id = 'teste1' for
    select * from estrela where massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*  Resultado antes da criação do índice:
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
   
/* Resultado depois da criação do índice:
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

/* Semelhantemente às consultas anteriores, o otimizador realiza uma busca sequencial, pois será nececssário recuperar um grande volume de dados.
Sendo assim, o índice criado não é utilizado. */


/* 7) Crie um índice que melhore a performance da consulta abaixo. Apresente os planos de execução
antes e depois do índice e explique porque sua solução funciona (qual foi sua linha de raciocínio?).
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
Resultados antes da criação do indice:

------------------------------------------------------------------------------
| Id  | Operation          | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------
|   0 | SELECT STATEMENT   |         |  1235 |  6175 |    16   (7)| 00:00:01 |
|   1 |  HASH GROUP BY     |         |  1235 |  6175 |    16   (7)| 00:00:01 |
|   2 |   TABLE ACCESS FULL| ESTRELA |  6586 | 32930 |    15   (0)| 00:00:01 |
------------------------------------------------------------------------------
*/

-- Criação do indice --

CREATE index idx_classificacao_id
    on estrela(classificacao, id_estrela);

drop index idx_classificacao_id;

/*
Resultados após a criação do indice:

-------------------------------------------------------------------------------------------
| Id  | Operation             | Name              | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT      |                   |  1235 |  6175 |     9  (12)| 00:00:01 |
|   1 |  HASH GROUP BY        |                   |  1235 |  6175 |     9  (12)| 00:00:01 |
|   2 |   INDEX FAST FULL SCAN| IDX_CLASSIFICACAO |  6586 | 32930 |     8   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

Com relação ao porque essa solução funciona, a consulta em questão exige apenas um
atributo (classificação) e lerá todas as tuplas pois ira contar todas após serem agrupadas.
Assim, a melhor opção para melhorar o desempenho com o uso de indice será um Fast Full Index Scan
com a classificação da estrela indexada.

Entretanto se indexarmos apenas a classificação, o Fast Full Index Scan não irá ocorrer pois
o atriburo indexado pode ser NULL, e ter ao menos um atributo NOT NULL é uma exigencia desse tipo
de scan, para resolver tal problema basta indexar junto a classificação um atributo que cumpra o
requisito, no caso o que está sendo usado o ID_ESTRELA.

Assim, com o uso do indice ao inves de um table access temos como resultado uma diminuição no custo
de aproximadamente 44%, mesmo que haja uma maior ultilização da CPU
*/

/* 8) Pesquise sobre bitmap join index. Elabore uma consulta com junção que possa se beneficiar desse
tipo de índice e explique o porquê. Crie o índice e analise os planos de consulta antes e depois.
OBS: se for usar alguma tabela que está vazia, faça as devidas inserções para teste. */

/* Suponhamos que seja comum consultar o número de espécies cujo planeta de origem é de determinada classificação.
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

/* Para essa consulta, é gerado o seguinte plano de consulta:
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

/* Note que, para localizar as linhas correspondentes, é realizada uma varredura nas tabelas.
A fim de minimizar o custo dessa busca, pode-se criar um bitmap join index. Dessa froma, será possível recuperar os dados a partir do índice: */

CREATE BITMAP INDEX idx_especie
ON     especie (planeta.classificacao) 
FROM   especie, planeta
WHERE  especie.planeta_or = planeta.id_astro;

drop index idx_especie;

/* Após a criação do índice, temos o plano de consulta abaixo:
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

/* Podemos observar que, com o índice, houve uma grande redução nos custos, estimativas de linhas e bytes.
Sendo assim, a busca se tornou muito mais eficiente. */
