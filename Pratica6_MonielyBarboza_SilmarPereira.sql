/*
SCC0541 - Laborat�rio de Base de Dados
Pr�tica 05 - Usu�rios e Privil�gios
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*  USER1: a12563800
    USER2: a12623950
    USER3: a10727952
*/

/* 1. Escolha uma tabela do esquema do USER1 e conceda permiss�o de leitura nessa tabela para o USER 2. Fa�a
duas varia��es:
a. sem GRANT OPTION; */

GRANT SELECT ON ESTRELA TO a12623950;

/* i. USER2 deve realizar uma consulta qualquer na tabela do USER1 para testar o privil�gio; */
--TODO: colocar o comando select
/* O USER2 obteve sucesso com a consulta e acessou os dados da tabela ESTRELA
    
/* ii. USER2 deve tentar realizar uma inser��o na tabela do USER1 para testar o privil�gio; */
/* Ao tentar executar uma inser��o, obtemos o seguinte erro:
--TODO: Colocar o erro
Isso ocorre pois o USER2 n�o possui o privil�gio necess�rio para executar uma inser��o. */
    
/* iii. USER3 deve tentar realizar uma consulta qualquer na tabela do USER1 ; */
SELECT * FROM a12563800.ESTRELA;
/* Ao executar a consulta, recebemos a seguinte mensagem:
--TODO: colocar o erro
Isso ocorre pois USER3 n�o tem acesso � tabela, j� que n�o recebeu permiss�o para acess�-la. */

/* iv. USER1 deve revogar o privil�gio de leitura do USER2; */

REVOKE SELECT ON ESTRELA FROM a12623950;

/* v. USER2 deve realizar uma consulta na tabela do USER1 para testar. */
/* Ao realizar a consulta ap�s a revoga��o, recebemos a seguinte mensagem:
--TODO: colocar o erro
Isso ocorre pois o acesso � tabela ESTRELA do USER2 foi revogado. Logo, ele n�o pode mais consult�-la.

/* b. com GRANT OPTION; */

GRANT SELECT ON ESTRELA TO a12623950
WITH GRANT OPTION;

/* i. USER2 deve realizar uma consulta na tabela do USER1 para testar o privil�gio; */
    /* Tudo ok
/* ii. USER2 deve conceder permiss�o de leitura na tabela do USER1 para o USER3 (sem GRANT
OPTION); */
    /* Tudo ok
/* iii. USER3 deve realizar uma consulta na tabela do USER1 para testar o privil�gio; */
    SELECT * FROM a12563800.ESTRELA;
    /* Resultados:
    
    */

/* iv. USER1 deve revogar o privil�gio de leitura do USER2; */

REVOKE SELECT ON ESTRELA FROM a12623950;

/* v. USER2 e USER3 devem tentar realizar uma consulta na tabela do USER1 para testar; */
/* Tabela n�o existe pros 2. Explicar 


/* 2. Escolha uma tabela do esquema do USER1 e conceda permiss�o de leitura, e de inser��o em apenas alguns
atributos da tabela para o USER 2, com GRANT OPTION: */


GRANT SELECT, INSERT (ID_ESTRELA, NOME, MASSA, X, Y, Z) ON ESTRELA TO a12623950
WITH GRANT OPTION;


/* a. USER2 deve inserir uma tupla na tabela do USER1 para testar o privil�gio; */
/* 

/* b. USER1 e USER2 devem realizar uma consulta (select) na tabela para verificar a inser��o da
nova tupla:
i. as consultas devem ser feitas antes e depois de USER2 fazer um commit;
ii. explique o que acontece antes e depois do commit � h� diferen�a entre os resultados
mostrados para USER1 e os resultados mostrados para o USER2 antes do commit? E
depois do commit?
iii. como fica a tupla na tabela do USER1 em rela��o aos atributos para os quais n�o foi dada
permiss�o de inser��o? */

-- ANTES DO USER2 REALIZAR COMMIT
/* Consultas USER1: */
SELECT * FROM ESTRELA WHERE ID_ESTRELA = 'Sarg250 MA';
/* Resultados: N�o escontrado, pois a tupla ainda n�o foi inserida na tabela do USER1 */

-- DEPOIS DO USER2 REALIZAR COMMIT
SELECT * FROM ESTRELA WHERE ID_ESTRELA = 'Sarg250 MA';
/* Resultados: 
Sarg250 MA	Nika		61,6844646585	117,44654654	2500,465456	1850,465465465
Ap�s o commit, a tupla foi encontrada.
Isso ocorre pois antes de realizar o commit a tupla ainda n�o foi inserida na tabela do USER1 e, por isso, o USER1 n�o pode encontr�-la.
Al�m disso, nos atributos que USER2 n�o tinha permiss�o, foi inserido null.
*/

/* c. USER2 deve conceder a USER3 (sem GRANT OPTION) os mesmos privil�gios recebidos; */
/* d. Refa�a os testes dos itens a e b agora considerando os tr�s usu�rios. */
/* e. USER1 deve revogar os privil�gios do USER2. */

REVOKE SELECT, INSERT ON LIDER FROM a12623950;

/* 3. Considere o seguinte cen�rio: USER2 precisa criar em seu pr�prio esquema uma tabela nova que armazenar�
curiosidades a respeito de comunidades que estejam cadastradas na tabela Comunidade do USER1. A tabela
do USER2 deve guardar, portanto, esp�cie e nome da comunidade, e um texto com as curiosidades a respeito
dela. As seguintes restri��es devem ser atendidas para essa tabela (do USER2):
i. a comunidade inserida nessa tabela deve ser uma comunidade cadastrada na tabela Comunidade
do USER1;
ii. todas as comunidades nessa tabela devem obrigatoriamente ter curiosidades armazenadas (mas
nem todas as comunidades do USER1 precisam estar na tabela de curiosidades do USER2).
Implemente e teste esse cen�rio: */

/* a) conceda os privil�gios necess�rios; */

GRANT SELECT, REFERENCES(NOME, ESPECIE) ON COMUNIDADE TO a12623950;

/* b) crie a tabela de curiosidades no esquema do USER2, de modo a atender as restri��es acima; */
/* c) fa�a inser��es na tabela de curiosidades � teste inclusive inser��o de curiosidades para comunidades
que n�o existem na tabela de Comunidades do USER1; */
/* d) remova da tabela de comunidades do USER1 uma comunidade para a qual exista curiosidade
cadastrada na tabela de curiosidades do USER2. Explique o que acontece. */

/* Insercoes na tabela COMUNIDADE */
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Kaledon', 950);
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Thals', 845);
INSERT INTO COMUNIDADE VALUES('Homo Tempus', 'Arcadia', 4750);
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Skaro Remains', 785);

DELETE FROM COMUNIDADE WHERE ESPECIE = 'Kaleds Extermum' AND NOME = 'Kaledon';


/* Quando o USER1 deleta uma comunidade que possui curiosidades, a tupla que referencia essa comunidade na tabela curiosidades � tamb�m � exclu�da.
Isso ocorre pois, na cria��o do esquema da tabela curiosidades, foi inclu�da a cl�usula ON DELETE CASCADE

/* 4. No esquema do USER2, crie um novo �ndice (B-Tree ou Bitmap) sobre uma tabela do esquema do USER1. Crie
um �ndice que provavelmente n�o ser� utilizado no plano de consulta por quest�es de efici�ncia. Pode ser
usado um �ndice criado na Pr�tica 4. Implemente o seguinte cen�rio: */
/* a. conceda os privil�gios necess�rios; */

GRANT SELECT, INDEX ON ENTRELA TO a12623950;

/* b. crie o novo �ndice no esquema do USER2; */
/* c. fa�a, em USER2, uma consulta na tabela do USER1 e analise o plano de execu��o. */
/* d. fa�a a mesma consulta em USER1 e analise o plano de execu��o. */
/* e. em USER2, �force� o uso de �ndices nas consultas usando:
ALTER SESSION SET OPTIMIZER_MODE = FIRST_ROWS;
(pesquise o funcionamento do comando acima no manual de SQL Tuning Guide:
https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/influencing-the-
optimizer.html#GUID-FD82C6F7-C338-41E3-8AE1-F8ADFB882ECF) */
/* f. refa�a a consulta em USER2, e analise o plano de consulta. Explique a mudan�a. Houve ganho no
desempenho da consulta? */
/* g. refa�a a consulta em USER1, e analise o plano de consulta. Houve alguma mudan�a? Por que? */


/* 5. Considere ent�o o seguinte cen�rio:
� o usu�rio USER2 precisa criar, em seu pr�prio esquema, uma vis�o com tabelas base que est�o no
esquema do USER1. A vis�o deve ser:
    - vis�o com jun��o
    - atualiz�vel
    - possibilidade de opera��es de leitura, inser��o, remo��o e atualiza��o
� o usu�rio USER 1 deve conceder todos os privil�gios necess�rios para o USER2.
� o usu�rio USER2 deve conceder, para o USER3, acesso de leitura na vis�o criada em seu esquema
(somente leitura e somente na vis�o!). */
/* a) Implemente o cen�rio acima: considere que todos os usu�rios j� t�m privil�gio de cria��o de vis�es
nos pr�prios esquemas (cada um em seu esquema). Inclua na resposta tudo o que for feito: atribui��o
de permiss�es necess�rias (apenas as necess�rias!), qual usu�rio concede cada permiss�o, cria��o da
vis�o, etc. */

GRANT SELECT, INSERT, DELETE, UPDATE ON ESTRELA TO a12623950;

/* b) Teste as opera��es e permiss�es: verifique se USER2 e USER3 conseguem fazer todas as opera��es de
acesso � vis�o, conforme especificado no cen�rio. Teste se USER3 consegue fazer opera��es de escrita
na vis�o. Verifique tamb�m o acesso direto de USER2 e USER3 �s tabelas base do USER1. */
/* c) USER1 deve revogar todas as permiss�es de acesso a suas tabelas concedidas ao USER2. Teste se
USER2 e USER3 ainda t�m acesso � vis�o. */

REVOKE SELECT, INSERT, DELETE, UPDATE ON ESTRELA FROM a12623950;