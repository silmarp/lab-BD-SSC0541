/*
SCC0541 - Laboratório de Base de Dados
Prática 05 - Usuários e Privilégios
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*  USER1: a12563800
    USER2: a12623950
    USER3: a10727952
*/

/* 1. Escolha uma tabela do esquema do USER1 e conceda permissão de leitura nessa tabela para o USER 2. Faça
duas variações:
a. sem GRANT OPTION; */

GRANT SELECT ON ESTRELA TO a12623950;

/* i. USER2 deve realizar uma consulta qualquer na tabela do USER1 para testar o privilégio; */

SELECT * FROM A12563800.ESTRELA e;
/* O USER2 obteve sucesso com a consulta e acessou os dados da tabela ESTRELA
    
/* ii. USER2 deve tentar realizar uma inserção na tabela do USER1 para testar o privilégio; */

INSERT INTO A12563800.ESTRELA
	VALUES ('Sarg250 M','Nika','HI772',651.684857458,17.421517,250.257428,-780.56308);

/* Ao tentar executar uma inserção, obtemos o seguinte erro:

SQL Error [1031] [42000]: ORA-01031: insufficient privileges

Isso ocorre pois o USER2 não possui o privilégio necessário para executar uma inserção. */
    
/* iii. USER3 deve tentar realizar uma consulta qualquer na tabela do USER1 ; */
SELECT * FROM a12563800.ESTRELA;
/* Ao executar a consulta, recebemos a seguinte mensagem:
--TODO: colocar o erro
Isso ocorre pois USER3 não tem acesso à tabela, já que não recebeu permissão para acessá-la. */

/* iv. USER1 deve revogar o privilégio de leitura do USER2; */

REVOKE SELECT ON ESTRELA FROM a12623950;

/* v. USER2 deve realizar uma consulta na tabela do USER1 para testar. */

SELECT * FROM A12563800.ESTRELA e ;

/* Ao realizar a consulta após a revogação, recebemos a seguinte mensagem:

SQL Error [942] [42000]: ORA-00942: table or view does not exist

Isso ocorre pois o acesso à tabela ESTRELA do USER2 foi revogado. Logo, ele não pode mais consultá-la.

/* b. com GRANT OPTION; */

GRANT SELECT ON ESTRELA TO a12623950
WITH GRANT OPTION;

/* i. USER2 deve realizar uma consulta na tabela do USER1 para testar o privilégio; */
    /* Tudo ok */
/* ii. USER2 deve conceder permissão de leitura na tabela do USER1 para o USER3 (sem GRANT
OPTION); */
GRANT SELECT ON A12563800.ESTRELA
	TO A10727952;

/* Tudo ok */

/* iii. USER3 deve realizar uma consulta na tabela do USER1 para testar o privilégio; */
    SELECT * FROM a12563800.ESTRELA;
    /* Resultados:
     Tudo ok 
    */

/* iv. USER1 deve revogar o privilégio de leitura do USER2; */

REVOKE SELECT ON ESTRELA FROM a12623950;

/* v. USER2 e USER3 devem tentar realizar uma consulta na tabela do USER1 para testar; */
/* Tabela não existe pros 2. Explicar 


/* 2. Escolha uma tabela do esquema do USER1 e conceda permissão de leitura, e de inserção em apenas alguns
atributos da tabela para o USER 2, com GRANT OPTION: */


GRANT SELECT, INSERT (ID_ESTRELA, NOME, MASSA, X, Y, Z) ON ESTRELA TO a12623950
WITH GRANT OPTION;


/* a. USER2 deve inserir uma tupla na tabela do USER1 para testar o privilégio; */

INSERT INTO A12563800.ESTRELA (id_estrela,nome,massa,x,y,z)
	VALUES ('Sarg250 MA','Nika', 61.6844646585,117.44654654,2500.465456,1850.465465465);

/* b. USER1 e USER2 devem realizar uma consulta (select) na tabela para verificar a inserção da
nova tupla:
i. as consultas devem ser feitas antes e depois de USER2 fazer um commit;
ii. explique o que acontece antes e depois do commit – há diferença entre os resultados
mostrados para USER1 e os resultados mostrados para o USER2 antes do commit? E
depois do commit?
iii. como fica a tupla na tabela do USER1 em relação aos atributos para os quais não foi dada
permissão de inserção? */

-- ANTES DO USER2 REALIZAR COMMIT
/* Consultas USER1: */
SELECT * FROM ESTRELA WHERE ID_ESTRELA = 'Sarg250 MA';
/* Resultados: Não escontrado, pois a tupla ainda não foi inserida na tabela do USER1 */

/* Consulta do user2: */
SELECT * FROM A12563800.ESTRELA WHERE ID_ESTRELA = 'Sarg250 MA'; 
/*
Sarg250 MA	Nika		61.6844646585	117.44654654	2500.465456	1850.465465465 

O resultado foi encontrado mesmo não tendo feito o commit ainda, isso ocorre pois a transação está sendo realizada pelo USER2, que pode acessar suas alterações antes do commit, entretando só serão possiveis de acessar por outro usuario após a efetivação da transação.
*/

COMMIT;

-- DEPOIS DO USER2 REALIZAR COMMIT
SELECT * FROM ESTRELA WHERE ID_ESTRELA = 'Sarg250 MA';
/* Resultados para ambos os usuarios: 
Sarg250 MA	Nika		61,6844646585	117,44654654	2500,465456	1850,465465465
Após o commit, a tupla foi encontrada.
Isso ocorre pois antes de realizar o commit a tupla ainda não foi inserida na tabela do USER1 e, por isso, o USER1 não pode encontrá-la.
Além disso, nos atributos que USER2 não tinha permissão, foi inserido null.
*/

/* c. USER2 deve conceder a USER3 (sem GRANT OPTION) os mesmos privilégios recebidos; */
GRANT SELECT, INSERT (ID_ESTRELA, NOME, MASSA, X, Y, Z) ON A12563800.ESTRELA
	TO A10727952;
/* d. Refaça os testes dos itens a e b agora considerando os três usuários. */
/* e. USER1 deve revogar os privilégios do USER2. */

REVOKE SELECT, INSERT ON LIDER FROM a12623950;

/* 3. Considere o seguinte cenário: USER2 precisa criar em seu próprio esquema uma tabela nova que armazenará
curiosidades a respeito de comunidades que estejam cadastradas na tabela Comunidade do USER1. A tabela
do USER2 deve guardar, portanto, espécie e nome da comunidade, e um texto com as curiosidades a respeito
dela. As seguintes restrições devem ser atendidas para essa tabela (do USER2):
i. a comunidade inserida nessa tabela deve ser uma comunidade cadastrada na tabela Comunidade
do USER1;
ii. todas as comunidades nessa tabela devem obrigatoriamente ter curiosidades armazenadas (mas
nem todas as comunidades do USER1 precisam estar na tabela de curiosidades do USER2).
Implemente e teste esse cenário: */

/* a) conceda os privilégios necessários; */

GRANT SELECT, REFERENCES(NOME, ESPECIE) ON COMUNIDADE TO a12623950;

/* b) crie a tabela de curiosidades no esquema do USER2, de modo a atender as restrições acima; */

CREATE TABLE COMUNIDADE_CURIOSIDADE(
	COMUNIDADE VARCHAR2(15),
	ESPECIE  VARCHAR2(15),
	CURIOSIDADE  VARCHAR2(500) NOT NULL,
	CONSTRAINT PK_COMUNIDADE_CURIOSIDADE PRIMARY KEY (COMUNIDADE, ESPECIE),
	CONSTRAINT FK_CC_COMUNIDADE FOREIGN KEY (COMUNIDADE, ESPECIE) REFERENCES A12563800.COMUNIDADE(NOME, ESPECIE) ON DELETE CASCADE
);

/* c) faça inserções na tabela de curiosidades – teste inclusive inserção de curiosidades para comunidades
que não existem na tabela de Comunidades do USER1; */

INSERT INTO COMUNIDADE_CURIOSIDADE (ESPECIE, COMUNIDADE, CURIOSIDADE)
	VALUES ('Kaleds Extermum', 'Kaledon', 'A super cool curiosity about this community');

INSERT INTO COMUNIDADE_CURIOSIDADE (ESPECIE, COMUNIDADE, CURIOSIDADE)
	VALUES ('Kaleds Extermum', 'Thals', 'Another super cool curiosity about this community');

INSERT INTO COMUNIDADE_CURIOSIDADE (ESPECIE, COMUNIDADE, CURIOSIDADE)
	VALUES ('Homo Tempus', 'Arcadia', 'An even cooler curiosity about this one');

INSERT INTO COMUNIDADE_CURIOSIDADE (ESPECIE, COMUNIDADE, CURIOSIDADE)
	VALUES ('Homo Denisovan', 'Eurasia', 'Fun fact, this community does not exist on USER1 tables');

/*
No caso de inserções que ultilizem uma comunidade que não existe na tabela original obtemos o seguinte erro:

SQL Error [2291] [23000]: ORA-02291: integrity constraint (A12623950.FK_CC_COMUNIDADE) violated - parent key not found

Que ocorre pois mesmo ultilizando comunidades de outro usuario como foreign key as regras de integridade ainda valem.
*/

/* d) remova da tabela de comunidades do USER1 uma comunidade para a qual exista curiosidade
cadastrada na tabela de curiosidades do USER2. Explique o que acontece. */

/* Insercoes na tabela COMUNIDADE */
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Kaledon', 950);
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Thals', 845);
INSERT INTO COMUNIDADE VALUES('Homo Tempus', 'Arcadia', 4750);
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Skaro Remains', 785);

DELETE FROM COMUNIDADE WHERE ESPECIE = 'Kaleds Extermum' AND NOME = 'Kaledon';


/* Quando o USER1 deleta uma comunidade que possui curiosidades, a tupla que referencia essa comunidade na tabela curiosidades é também é excluída.
Isso ocorre pois, na criação do esquema da tabela curiosidades, foi incluída a cláusula ON DELETE CASCADE

/* 4. No esquema do USER2, crie um novo índice (B-Tree ou Bitmap) sobre uma tabela do esquema do USER1. Crie
um índice que provavelmente não será utilizado no plano de consulta por questões de eficiência. Pode ser
usado um índice criado na Prática 4. Implemente o seguinte cenário: */
/* a. conceda os privilégios necessários; */

GRANT SELECT, INDEX ON ENTRELA TO a12623950;

/* b. crie o novo índice no esquema do USER2; */
/* c. faça, em USER2, uma consulta na tabela do USER1 e analise o plano de execução. */
/* d. faça a mesma consulta em USER1 e analise o plano de execução. */
/* e. em USER2, “force” o uso de índices nas consultas usando:
ALTER SESSION SET OPTIMIZER_MODE = FIRST_ROWS;
(pesquise o funcionamento do comando acima no manual de SQL Tuning Guide:
https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/influencing-the-
optimizer.html#GUID-FD82C6F7-C338-41E3-8AE1-F8ADFB882ECF) */
/* f. refaça a consulta em USER2, e analise o plano de consulta. Explique a mudança. Houve ganho no
desempenho da consulta? */
/* g. refaça a consulta em USER1, e analise o plano de consulta. Houve alguma mudança? Por que? */


/* 5. Considere então o seguinte cenário:
• o usuário USER2 precisa criar, em seu próprio esquema, uma visão com tabelas base que estão no
esquema do USER1. A visão deve ser:
    - visão com junção
    - atualizável
    - possibilidade de operações de leitura, inserção, remoção e atualização
• o usuário USER 1 deve conceder todos os privilégios necessários para o USER2.
• o usuário USER2 deve conceder, para o USER3, acesso de leitura na visão criada em seu esquema
(somente leitura e somente na visão!). */
/* a) Implemente o cenário acima: considere que todos os usuários já têm privilégio de criação de visões
nos próprios esquemas (cada um em seu esquema). Inclua na resposta tudo o que for feito: atribuição
de permissões necessárias (apenas as necessárias!), qual usuário concede cada permissão, criação da
visão, etc. */

GRANT SELECT, INSERT, DELETE, UPDATE ON ESTRELA TO a12623950;

/* b) Teste as operações e permissões: verifique se USER2 e USER3 conseguem fazer todas as operações de
acesso à visão, conforme especificado no cenário. Teste se USER3 consegue fazer operações de escrita
na visão. Verifique também o acesso direto de USER2 e USER3 às tabelas base do USER1. */
/* c) USER1 deve revogar todas as permissões de acesso a suas tabelas concedidas ao USER2. Teste se
USER2 e USER3 ainda têm acesso à visão. */

REVOKE SELECT, INSERT, DELETE, UPDATE ON ESTRELA FROM a12623950;