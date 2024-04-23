/*
SCC0541 - Laboratorio de Base de Dados
Pratica 06 - Usuarios e Privilegios
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*  USER1: a12563800
    USER2: a12623950
    USER3: a10727952
*/

/* 1. Escolha uma tabela do esquema do USER1 e conceda permissao de leitura nessa tabela para o USER 2. Faca
duas variacoes:
a. sem GRANT OPTION; */

GRANT SELECT ON ESTRELA TO a12623950;

/* i. USER2 deve realizar uma consulta qualquer na tabela do USER1 para testar o privilÃ©gio; */

SELECT * FROM A12563800.ESTRELA e;
/* O USER2 obteve sucesso com a consulta e acessou os dados da tabela ESTRELA
    
/* ii. USER2 deve tentar realizar uma insercao na tabela do USER1 para testar o privilegio; */

INSERT INTO A12563800.ESTRELA
	VALUES ('Sarg250 M','Nika','HI772',651.684857458,17.421517,250.257428,-780.56308);

/* Ao tentar executar uma insercao, obtemos o seguinte erro:

SQL Error [1031] [42000]: ORA-01031: insufficient privileges

Isso ocorre pois o USER2 nÃ£o possui o privilegio necessario para executar uma insercao. */
    
/* iii. USER3 deve tentar realizar uma consulta qualquer na tabela do USER1 ; */
SELECT * FROM a12563800.ESTRELA;
/* Ao executar a consulta, recebemos a seguinte mensagem:
--TODO: colocar o erro
Isso ocorre pois USER3 naoo tem acesso a  tabela, ja que nao recebeu permissao para acessa-la. */

/* iv. USER1 deve revogar o privilegio de leitura do USER2; */

REVOKE SELECT ON ESTRELA FROM a12623950;

/* v. USER2 deve realizar uma consulta na tabela do USER1 para testar. */

SELECT * FROM A12563800.ESTRELA e ;

/* Ao realizar a consulta apos a revogacao, recebemos a seguinte mensagem:

SQL Error [942] [42000]: ORA-00942: table or view does not exist

Isso ocorre pois o acesso a  tabela ESTRELA do USER2 foi revogado. Logo, ele nao pode mais consulta-la.

/* b. com GRANT OPTION; */

GRANT SELECT ON ESTRELA TO a12623950
WITH GRANT OPTION;

/* i. USER2 deve realizar uma consulta na tabela do USER1 para testar o privilegio; */
    /* Tudo ok */
/* ii. USER2 deve conceder permissao de leitura na tabela do USER1 para o USER3 (sem GRANT
OPTION); */
GRANT SELECT ON A12563800.ESTRELA
	TO A10727952;

/* Tudo ok */

/* iii. USER3 deve realizar uma consulta na tabela do USER1 para testar o privilegio; */
SELECT * FROM a12563800.ESTRELA;
/* Tudo ok */

/* iv. USER1 deve revogar o privilegio de leitura do USER2; */

REVOKE SELECT ON ESTRELA FROM a12623950;

/* v. USER2 e USER3 devem tentar realizar uma consulta na tabela do USER1 para testar; */
/* Tabela nao existe para os 2.
Como o privilegio de leitura foi revogado para o USER2 e o USER3 recebeu acesso pelo USER2,
ambos perderam o acesso.


/* 2. Escolha uma tabela do esquema do USER1 e conceda permissao de leitura, e de inserao em apenas alguns
atributos da tabela para o USER 2, com GRANT OPTION: */


GRANT SELECT, INSERT (ID_ESTRELA, NOME, MASSA, X, Y, Z) ON ESTRELA TO a12623950
WITH GRANT OPTION;


/* a. USER2 deve inserir uma tupla na tabela do USER1 para testar o privilegio; */

INSERT INTO A12563800.ESTRELA (id_estrela,nome,massa,x,y,z)
	VALUES ('Sarg250 MA','Nika', 61.6844646585,117.44654654,2500.465456,1850.465465465);

/* b. USER1 e USER2 devem realizar uma consulta (select) na tabela para verificar a insercao da
nova tupla:
i. as consultas devem ser feitas antes e depois de USER2 fazer um commit;
ii. explique o que acontece antes e depois do commit - ha diferenca entre os resultados
mostrados para USER1 e os resultados mostrados para o USER2 antes do commit? E
depois do commit?
iii. como fica a tupla na tabela do USER1 em relacao aos atributos para os quais nao foi dada
permissao de insercao? */

-- ANTES DO USER2 REALIZAR COMMIT
/* Consultas USER1: */
SELECT * FROM ESTRELA WHERE ID_ESTRELA = 'Sarg250 MA';
/* Resultados: Nao escontrado, pois a tupla ainda nao foi inserida na tabela do USER1 */

/* Consulta do user2: */
SELECT * FROM A12563800.ESTRELA WHERE ID_ESTRELA = 'Sarg250 MA'; 
/*
Sarg250 MA	Nika		61.6844646585	117.44654654	2500.465456	1850.465465465 

O resultado foi encontrado mesmo nao tendo feito o commit ainda.
Isso ocorre pois a transacao esta sendo realizada pelo USER2, que pode acessar suas proprias alteracoes antes do commit
Entretando, so serao possiveis de acessar por outro usuario apos a efetivacaoo da transacao.
*/

COMMIT;

-- DEPOIS DO USER2 REALIZAR COMMIT
SELECT * FROM ESTRELA WHERE ID_ESTRELA = 'Sarg250 MA';
/* Resultados para ambos os usuarios: 
Sarg250 MA	Nika		61,6844646585	117,44654654	2500,465456	1850,465465465

Apos o commit, a tupla foi encontrada.
Isso ocorre pois antes de realizar o commit a tupla ainda nao foi inserida na tabela do USER1 e, por isso, o USER1 nao pode encontra-la.
Alem disso, nos atributos em que USER2 nao tinha permissao, foi inserido null.
*/

/* c. USER2 deve conceder a USER3 (sem GRANT OPTION) os mesmos privilegios recebidos; */
GRANT SELECT, INSERT (ID_ESTRELA, NOME, MASSA, X, Y, Z) ON A12563800.ESTRELA
	TO A10727952;
/* d. Refaca os testes dos itens a e b agora considerando os tres usuarios. */
/* e. USER1 deve revogar os privilegios do USER2. */

REVOKE SELECT, INSERT ON LIDER FROM a12623950;

/* 3. Considere o seguinte cenario: USER2 precisa criar em seu proprio esquema uma tabela nova que armazenara
curiosidades a respeito de comunidades que estejam cadastradas na tabela Comunidade do USER1. A tabela
do USER2 deve guardar, portanto, especie e nome da comunidade, e um texto com as curiosidades a respeito
dela. As seguintes restricoes devem ser atendidas para essa tabela (do USER2):
i. a comunidade inserida nessa tabela deve ser uma comunidade cadastrada na tabela Comunidade
do USER1;
ii. todas as comunidades nessa tabela devem obrigatoriamente ter curiosidades armazenadas (mas
nem todas as comunidades do USER1 precisam estar na tabela de curiosidades do USER2).
Implemente e teste esse cenÃ¡rio: */

/* a) conceda os privilegios necessarios; */

GRANT SELECT, REFERENCES(NOME, ESPECIE) ON COMUNIDADE TO a12623950;

/* b) crie a tabela de curiosidades no esquema do USER2, de modo a atender as restriçoes acima; */

CREATE TABLE COMUNIDADE_CURIOSIDADE(
	COMUNIDADE VARCHAR2(15),
	ESPECIE  VARCHAR2(15),
	CURIOSIDADE  VARCHAR2(500) NOT NULL,
	CONSTRAINT PK_COMUNIDADE_CURIOSIDADE PRIMARY KEY (COMUNIDADE, ESPECIE),
	CONSTRAINT FK_CC_COMUNIDADE FOREIGN KEY (COMUNIDADE, ESPECIE) REFERENCES A12563800.COMUNIDADE(NOME, ESPECIE) ON DELETE CASCADE
);

/* c) faca insercoes na tabela de curiosidades - teste inclusive insercao de curiosidades para comunidades
que nao existem na tabela de Comunidades do USER1; */

INSERT INTO COMUNIDADE_CURIOSIDADE (ESPECIE, COMUNIDADE, CURIOSIDADE)
	VALUES ('Kaleds Extermum', 'Kaledon', 'A super cool curiosity about this community');

INSERT INTO COMUNIDADE_CURIOSIDADE (ESPECIE, COMUNIDADE, CURIOSIDADE)
	VALUES ('Kaleds Extermum', 'Thals', 'Another super cool curiosity about this community');

INSERT INTO COMUNIDADE_CURIOSIDADE (ESPECIE, COMUNIDADE, CURIOSIDADE)
	VALUES ('Homo Tempus', 'Arcadia', 'An even cooler curiosity about this one');

INSERT INTO COMUNIDADE_CURIOSIDADE (ESPECIE, COMUNIDADE, CURIOSIDADE)
	VALUES ('Homo Denisovan', 'Eurasia', 'Fun fact, this community does not exist on USER1 tables');

/*
No caso de insercoes que ultilizem uma comunidade que nao existe na tabela original obtemos o seguinte erro:

SQL Error [2291] [23000]: ORA-02291: integrity constraint (A12623950.FK_CC_COMUNIDADE) violated - parent key not found

Que ocorre pois, mesmo ultilizando comunidades de outro usuario como foreign key, as regras de integridade ainda valem.
*/

/* d) remova da tabela de comunidades do USER1 uma comunidade para a qual exista curiosidade
cadastrada na tabela de curiosidades do USER2. Explique o que acontece. */

/* Insercoes na tabela COMUNIDADE */
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Kaledon', 950);
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Thals', 845);
INSERT INTO COMUNIDADE VALUES('Homo Tempus', 'Arcadia', 4750);
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Skaro Remains', 785);

DELETE FROM COMUNIDADE WHERE ESPECIE = 'Kaleds Extermum' AND NOME = 'Kaledon';


/* Quando o USER1 deleta uma comunidade que possui curiosidades, a tupla que referencia essa comunidade na tabela curiosidades tambem eh excluida.
Isso ocorre pois, na criacao do esquema da tabela curiosidades, foi incluida a clausula ON DELETE CASCADE

/* 4. No esquema do USER2, crie um novo indices  (B-Tree ou Bitmap) sobre uma tabela do esquema do USER1. Crie
um indices  que provavelmente nao sera utilizado no plano de consulta por questoes de eficiencia. Pode ser
usado um indices criado na Pratica 4. Implemente o seguinte cenario: */
/* a. conceda os privilegios necessarios; */

GRANT SELECT, INDEX ON ESTRELA TO a12623950;
REVOKE SELECT, INDEX ON ESTRELA FROM a12623950;


/* b. crie o novo indices no esquema do USER2; */

-- Criacao do índice:
create index idx_classificacao_massa
    on al12563800.estrela(classificacao, massa);

drop index idx_classificacao_massa;

/* c. faca, em USER2, uma consulta na tabela do USER1 e analise o plano de execucao. */
select massa from estrela where classificacao = 'M3' and massa < 1;

-- Plano de Consulta: Consulta 01
explain plan set statement_id = 'teste1' for
    select massa from estrela where classificacao = 'M3' and massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*
Plan hash value: 1653849300

-----------------------------------------------------------------------------
| Id  | Operation         | Name    | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------
|   0 | SELECT STATEMENT  |         |     1 |    16 |    15   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS FULL| ESTRELA |     1 |    16 |    15   (0)| 00:00:01 |
-----------------------------------------------------------------------------

Como podemos observar o indice criado não foi ultilizado pela consulta, seguindo o que
foi pedido na descrição da atividade 4. Isso decorre do grande volume de dados que precisa 
ser recuperado e que o otimizador acha mais vantajoso fazer um acesso total.
*/

/* d. faca a mesma consulta em USER1 e analise o plano de execucao. */
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
 
   1 - access("CLASSIFICACAO"='M3' AND "MASSA"<1)

*/


/* e. em USER2, force o uso de indices nas consultas usando:
ALTER SESSION SET OPTIMIZER_MODE = FIRST_ROWS;
(pesquise o funcionamento do comando acima no manual de SQL Tuning Guide:
https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/influencing-the-
optimizer.html#GUID-FD82C6F7-C338-41E3-8AE1-F8ADFB882ECF) */

/* f. refaca a consulta em USER2, e analise o plano de consulta. Explique a mudanca. Houve ganho no
desempenho da consulta? */
select massa from estrela where classificacao = 'M3' and massa < 1;

-- Plano de Consulta: Consulta 01
explain plan set statement_id = 'teste1' for
    select massa from estrela where classificacao = 'M3' and massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*
Plan hash value: 2236474767
 
------------------------------------------------------------------------------------------------------------
| Id  | Operation                           | Name                 | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                    |                      |     1 |    16 |    86   (0)| 00:00:01 |
|*  1 |  TABLE ACCESS BY INDEX ROWID BATCHED| ESTRELA              |     1 |    16 |    86   (0)| 00:00:01 |
|*  2 |   INDEX RANGE SCAN                  | IDX_CLASSIFICACAO_ID |   125 |       |     2   (0)| 00:00:01 |
------------------------------------------------------------------------------------------------------------

Como podemos ver, desta vez foi usado o indice para a consulta, entretando, com relação ao desempenho
houve queda pois o custo para executar essa consulta aumentou. Logo, podemos concluir que o acesso total
a tabela, mesmo não usando o indice, ainda assim é mais performatico.
*/

/* g. refaca a consulta em USER1, e analise o plano de consulta. Houve alguma mudanca? Por que? */
select massa from estrela where classificacao = 'M3' and massa < 1;

-- Plano de Consulta: Consulta 01
explain plan set statement_id = 'teste1' for
    select massa from estrela where classificacao = 'M3' and massa < 1;
SELECT plan_table_output
FROM TABLE(dbms_xplan.display());

/*
*/

/* 5. Considere entao o seguinte cenario:
- o usuario USER2 precisa criar, em seu proprio esquema, uma visao com tabelas base que estao no
esquema do USER1. A visao deve ser:
    - visao com juncao
    - atualizavel
    - possibilidade de operacoes de leitura, insercao, remocao e atualizacao
- o usuario USER 1 deve conceder todos os privilegios necessarios para o USER2.
- o usuario USER2 deve conceder, para o USER3, acesso de leitura na visao criada em seu esquema
(somente leitura e somente na visao!). */

/* a) Implemente o cenario acima: considere que todos os usuarios ja tem privilegio de criacao de visoes
nos proprios esquemas (cada um em seu esquema). Inclua na resposta tudo o que for feito: atribuicao
de permissoes necessarias (apenas as necessarias!), qual usuario concede cada permissao, criacao da
visao, etc. */

GRANT SELECT, INSERT, DELETE, UPDATE ON FACCAO TO a12623950
WITH GRANT OPTION;

GRANT SELECT, INSERT, DELETE, UPDATE ON LIDER TO a12623950
WITH GRANT OPTION;


/* b) Teste as operacoes e permissoes: verifique se USER2 e USER3 conseguem fazer todas as operacoes de
acesso a visao, conforme especificado no cenario. Teste se USER3 consegue fazer operacoes de escrita
na visao. Verifique tambem o acesso direto de USER2 e USER3 as tabelas base do USER1. */

/* c) USER1 deve revogar todas as permissoes de acesso a suas tabelas concedidas ao USER2. Teste se
USER2 e USER3 ainda tem acesso a  visao. */

REVOKE SELECT, INSERT, DELETE, UPDATE ON FACCAO FROM a12623950;
REVOKE SELECT, INSERT, DELETE, UPDATE ON LIDER FROM a12623950;
