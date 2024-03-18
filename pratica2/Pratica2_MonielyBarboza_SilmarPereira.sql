/*
SCC0541 - Laboratório de Base de Dados
Prática 02 - SQL/DDL-DML
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/* 1) Insira (INSERT) pelo menos 2 tuplas em cada tabela, utilizando:
a. Função TO_DATE para formatação de datas;
b. Valores DEFAULT e NULL. */

/* Massa das estrelas em massas solares */
/* Massa dos planetas relativo a terra */

/* Insercoes na tabela ESTRELA */
INSERT INTO ESTRELA 
	VALUES ('GA1', 'Estrela principal', 'Gigante branca', 10.5, -3.03, 1.38, 4.94);

INSERT INTO ESTRELA 
	VALUES ('GA2', 'Estrela secundaria', 'ana vermelha', 0.25, -4.58, 5.8, 7.4);
	
INSERT INTO ESTRELA 
	VALUES ('SK20', 'D-5-GAMMA', 'ana vermelha', 0.1221, 3.03, -0.09, 3.16);

INSERT INTO ESTRELA
    VALUES ('ALF CMa','SIRIUS A', 'ana branca', 12.063, -16, 42, 58);

INSERT INTO ESTRELA 
    VALUES ('ALF CMa B','SIRIUS B', 'ana branca', 11.018, -58, 42, 16);


/* Insercoes na tabela PLANETA */
INSERT INTO PLANETA 
	VALUES ('Gallifrey', 1.75, 10.315, 'Oxigenio', 'Planeta rochoso');
	
INSERT INTO PLANETA 
	VALUES ('Skaro', 5.07, 15.315, 'Oxigenio', 'Planeta rochoso');
	
    
/* Insercoes na tabela SISTEMA */
INSERT INTO SISTEMA
	VALUES ('GA1', 'Sistema Gallifreiano');
	
INSERT INTO SISTEMA
	VALUES ('SK20', 'Sistema Skariano');


/* Insercoes na tabela ORBITA_ESTRELA */
INSERT INTO ORBITA_ESTRELA
	VALUES('GA1', 'GA2',
		57.2, 60.351, 57.36
	);
    
INSERT INTO ORBITA_ESTRELA 
	VALUES (
		'ALF CMa B', 'ALF CMa',
		8.56, 8.64, 50	
	);


/* Insercoes na tabela ORBITA_PLANETA */
INSERT INTO ORBITA_PLANETA 
	VALUES ('Gallifrey', 'GA1',
		278.447, 305.772, 675.354
	);
	
INSERT INTO ORBITA_PLANETA 
	VALUES ('Skaro', 'SK20',
		101.711, 115.421, 250.368
	);


/* Insercoes na tabela ESPECIE */
INSERT INTO ESPECIE 
	VALUES('Homo Tempus', /*Time Lords*/ 'Gallifrey', 'S');

INSERT INTO ESPECIE 
	VALUES('Kaleds Extermum' /*a.k.a Daleks*/, 'Skaro','S');


/* Insercoes na tabela COMUNIDADE */
/* Qantidade de habitantes em milhoes */
INSERT INTO COMUNIDADE
	VALUES(
		'Kaleds Extermum',
		'Kaledon',
		950
	);

INSERT INTO COMUNIDADE
	VALUES(
		'Kaleds Extermum',
		'Thals',
		845
	);

INSERT INTO COMUNIDADE (ESPECIE, NOME)
	VALUES(
		'Kaleds Extermum',
		'Skaro Remains'
	);

INSERT INTO COMUNIDADE
	VALUES(
		'Homo Tempus',
		'Arcadia',
		4750
	);

INSERT INTO COMUNIDADE (ESPECIE, NOME)
	VALUES(
		'Kaleds Extermum',
		'Kaledos'
	);

INSERT INTO COMUNIDADE (ESPECIE, NOME)
	VALUES(
		'Kaleds Extermum',
        'Restos de Skaro'
	);
 
 
/* Insercoes na tabela HABITACAO */
INSERT INTO HABITACAO
	VALUES(
		'Skaro', 'Kaleds Extermum', 'Kaledos',
		TO_DATE('07/11/1200', 'dd/mm/yyyy'),
		TO_DATE('14/12/3050', 'dd/mm/yyyy')
	);

INSERT INTO HABITACAO
	VALUES(
		'Skaro', 'Kaleds Extermum', 'Thals',
		TO_DATE('01/05/0500', 'dd/mm/yyyy'),
		TO_DATE('14/12/3050', 'dd/mm/yyyy') 
	);

INSERT INTO HABITACAO
	VALUES(
		'Skaro', 'Kaleds Extermum', 'Restos de Skaro', /*pós guerra civil dalek*/
		TO_DATE('15/12/3050', 'dd/mm/yyyy'),
		NULL
	);

INSERT INTO HABITACAO
	VALUES(
		'Gallifrey', 'Homo Tempus', 'Arcadia',
		TO_DATE('16/08/0200', 'dd/mm/yyyy'),
		TO_DATE('05/12/5325', 'dd/mm/yyyy') /*destruida na ultima grande guerra do tempo*/
	);


/* Insercoes na tabela FEDERACAO */
INSERT INTO FEDERACAO 
	VALUES(
		'Eixo dos poderes obscuros',
		TO_DATE('01/05/5000', 'dd/mm/yyyy'));

INSERT INTO FEDERACAO 
	VALUES(
		'Alianca dos senhores do tempo',
		TO_DATE('25/02/4890', 'dd/mm/yyyy'));


/* Insercoes na tabela NACAO */
INSERT INTO NACAO (NOME_NC, FEDERACAO)
	VALUES('Imperio Dalek', 'Eixo dos poderes obscuros');

INSERT INTO NACAO (NOME_NC, FEDERACAO)
	VALUES('Gallyos', 'Alianca dos senhores do tempo');

INSERT INTO NACAO (NOME_NC, FEDERACAO)
	VALUES('Gallifrey', 'Alianca dos senhores do tempo');


/* Insercoes na tabela DOMINANCIA */
INSERT INTO DOMINANCIA
	VALUES(
		'Imperio Dalek', 'Skaro',
		TO_DATE('19/06/0025', 'dd/mm/yyyy'),
		TO_DATE('05/12/5325', 'dd/mm/yyyy')/*fim da grande guerra do tempo*/
	);

INSERT INTO DOMINANCIA
	VALUES(
		'Gallyos',
		'Gallifrey',
		TO_DATE('24/01/0001', 'dd/mm/yyyy'),
		TO_DATE('05/12/5325', 'dd/mm/yyyy')/*fim da grande guerra do tempo*/
	);


/* Insercoes na tabela LIDER */
INSERT INTO LIDER
	VALUES(
		'408.540.985-55', 'Davros', 'CIENTISTA', 
		'Imperio Dalek',
		'Kaleds Extermum'
	);

INSERT INTO LIDER
	VALUES(
		'123.543.908.12', 'Borusa', 'Comandante', /*seu cargo eh presidente o que nao esta nas opcoes*/ 
		'Gallifrey',
		'Homo Tempus'
	);


/* Insercoes na tabela FACCAO */
INSERT INTO FACCAO (NOME_FC, LIDER_FC, IDEOLOGIA)
	VALUES(
		'Senhores do tempo',
		'123.543.908.12',
		'PROGRESSISTA'
	);

INSERT INTO FACCAO 
	VALUES(
		'Daleks',
		'408.540.985-55',
		'TOTALITARIA',
		2
	);

/* Insercoes na tabela NACAO_FACCAO */
INSERT INTO NACAO_FACCAO 
	VALUES(
        'Gallyos',
        'Senhores do tempo'
	);

INSERT INTO NACAO_FACCAO 
	VALUES(
        'Gallifrey',
        'Senhores do tempo'
	);


INSERT INTO NACAO_FACCAO 
	VALUES(
        'Imperio Dalek',
		'Daleks'
	);

/* Insercoes na tabela PARTICIPA */
INSERT INTO PARTICIPA
	VALUES(
		'Daleks',
		'Kaleds Extermum',
        'Kaledon'
	);

INSERT INTO PARTICIPA
	VALUES(
		'Senhores do tempo',
		'Kaleds Extermum',
        'Kaledon'
	);

INSERT INTO PARTICIPA
	VALUES(
		'Senhores do tempo',
		'Homo Tempus',
        'Arcadia'
	);


/* 2) Faça as seguintes atualizações (UPDATE) na base de dados:

a. Escolha 1 tabela e faça uma atualização que sempre afetará no máximo 1 tupla,
independente do tamanho da tabela */ 
UPDATE ESPECIE SET INTELIGENTE = 'N'
    WHERE NOME_CIENTIFICO LIKE 'Homo Tempus';
    

/* b. Escolha 1 tabela e faça uma atualização que pode afetar 0 ou mais tuplas, atualizando mais
de 1 atributo de cada tupla. */
UPDATE ESTRELA SET CLASSIFICACAO = CONCAT('GG ', CLASSIFICACAO), NOME = CONCAT('GG ', NOME)
    WHERE MASSA > 10;

    
/* c. Escolha 1 tabela e faça uma atualização que coloque NULL em 1 atributo de todas as tuplas
da tabela.*/
UPDATE FACCAO SET IDEOLOGIA = NULL;


/* 3) Faça as seguintes remoções (DELETE) na base de dados:
a. Escolha 1 tabela que não seja referenciada por chave estrangeira e remova 1 ou mais tuplas. */
DELETE FROM PARTICIPA
    WHERE COM_ESPECIE = 'Kaleds Extermum' AND COM_NOME = 'Kaledon';


/* b. Escolha 1 tabela que seja referenciada por chave estrangeira e remova 1 tupla que não seja
referenciada por tuplas de outras tabelas. */
DELETE FROM COMUNIDADE
    WHERE ESPECIE = 'Kaleds Extermum' AND NOME = 'Skaro Remains';


/* c. Escolha 1 tabela que seja referenciada por chave estrangeira e remova 1 tupla que seja
referenciada por tuplas de outras tabelas com ação de ON DELETE. Explique o efeito da
remoção. 

- Deletar todas as facções cujo lider é da nação 'Gallifrey'
    Ao executar essa deleção, as tuplas das tabelas NACAO_FACCAO  e PARTICIPA que referenciam essa facção também serão deletados.
    Isso ocorre pois, ao deletar uma facção não faz sentido manter sua relação com a nação e com a comunidade.
    E esse atrbuto não poderia ser null nas tabelas que o referenciam, pois são NOT NULL nelas.
*/
DELETE FROM FACCAO WHERE
    LIDER_FC IN (SELECT CPI FROM LIDER WHERE NACAO = 'Gallifrey');


/* 4) Faça as seguintes alterações no esquema da base de dados (ALTER TABLE/DROP TABLE): */

/* a. Escolha uma tabela e insira um novo atributo, que poderá assumir valor nulo. O que
aconteceu nas tuplas já existentes na tabela?
    - Nas tuplas já existentes, o atributo foi adicionado e setado como NULL.
*/
ALTER TABLE ESTRELA ADD IDADE FLOAT;


/* b. Escolha uma tabela e insira um novo atributo, que terá valor default. O que aconteceu nas
tuplas já existentes na tabela? 
    - Nas tuplas já existentes, o atributo foi adicionado e setado com o valor definido como default.
*/
ALTER TABLE FACCAO ADD DT_INICIO DATE DEFAULT SYSDATE;


/* c. Escolha uma tabela e remova uma constraint. */
ALTER TABLE ESPECIE DROP CONSTRAINT IS_INTELIGENTE;


/* d. Escolha uma tabela e crie uma nova constraint do tipo check, de modo que os valores
já existentes na tabela não atendam à nova restrição (faça as inserções necessárias para
teste antes da criação da nova constraint). Pesquise o funcionamento do check no Oracle e
teste as possibilidades (dica: novalidate). Inclua os testes no script, tanto os de sucesso
quanto os de erro. */

/* ALTER TABLE ESPECIE ADD CONSTRAINT EH_INTELIGENTE CHECK(UPPER(INTELIGENTE) IN ('Y', 'N')); 
    Esse comando gera o erro abaixo, pois os dados existentes na tabela violam a constraint que está sendo adicionada e, por isso, ela não pode ser aicionada
    Relatório de erros -
    ORA-02293: não é possível validar (A12563800.EH_INTELIGENTE) - restrição de verificação violada
    02293. 00000 - "cannot validate (%s.%s) - check constraint violated"
    *Cause:    an alter table operation tried to validate a check constraint to
               populated table that had nocomplying values.
    *Action:   Obvious
*/

ALTER TABLE ESPECIE ADD CONSTRAINT EH_INTELIGENTE CHECK(UPPER(INTELIGENTE) IN ('Y', 'N')) ENABLE NOVALIDATE; 
/*  Com o comando acima, a constraint é adicionada e o comando ENABLE NOVALIDATE permite ativar a constarint sem validá-la nos dados já existentes.
    Assim, as novas inserções deverão obedecer à constraint, mas as tuplas já existentes não precisam ser alteradas ou descartadas */


/* e. Escolha uma ou mais tabelas faça as seguintes alterações nas restrições de atributo: */
/* i. Inserir valor DEFAULT para um atributo que não tenha; */
ALTER TABLE FEDERACAO MODIFY (DT_FUND DEFAULT SYSDATE);
/* para testar:
DELETE FROM FEDERACAO WHERE NOME_FD = 'Eixo dos poderes obscuros';
INSERT INTO FEDERACAO (NOME_FD) VALUES('Eixo dos poderes obscuros');
*/


/* ii. Remover uma restrição NOT NULL de um atributo obrigatório. */
ALTER TABLE LIDER MODIFY (CARGO NULL);


/* f. Escolha uma tabela que seja referenciada por chave estrangeira e: */
/* i. Usando a interface do SQL Developer, veja a estrutura da tabela escolhida e da tabela
que a referencia (double click no nome da tabela na hierarquia do lado esquerdo da tela
abre abas no lado direto com todas as informações): constraints, índices criados para
cada uma delas e dados inseridos. */
/* ii. Remova o(s) atributo(s) que define(m) a chave primária da tabela escolhida. Qual o efeito
disso na tabela escolhida e na tabela que a referencia (considerando constraints, índices
e dados)? */
/*
ALTER TABLE ESTRELA DROP COLUMN ID_CATALOGO;
    Com o comando acima, o seguinte erro eh exibido:
    Relatório de erros -
    ORA-12992: não é possível eliminar uma coluna-chave mãe
    12992. 00000 -  "cannot drop parent key column"
    *Cause:    An attempt was made to drop a parent key column.
    *Action:   Drop all constraints referencing the parent key column, or
               specify CASCADE CONSTRAINTS in statement.
*/
ALTER TABLE ESTRELA DROP COLUMN ID_CATALOGO CASCADE CONSTRAINTS;
/*  Com o comando acima, a coluna ID_CATALOGO (que eh a cheva primaria) é removida.
    Alem disso, na tabela ORBITA_ESTRELA (que a referencia) as constraints de chave estrangeira tambem foram removidas, mas os atributos continuam com os valores cadastrados e a restricao NOT NULL
*/


/* g. Escolha uma tabela que seja referenciada por chave estrangeira e:
i. Usando a interface do SQL Developer, veja a estrutura da tabela escolhida e da tabela
que a referencia: constraints, índices criados para cada uma delas e dados inseridos.
ii. Remova a tabela escolhida da base dados (a tabela deve ser removida com sucesso). Qual
o efeito disso na tabela que a referencia (considerando constraints, índices e dados)? */
/*
DROP TABLE PLANETA;
    Com o comando acima, o seguinte erro eh exibido:
    Relatório de erros -
    ORA-02449: chaves primárias/exclusivas na tabela referenciadas por chaves externas
    02449. 00000 -  "unique/primary keys in table referenced by foreign keys"
    *Cause:    An attempt was made to drop a table with unique or
               primary keys referenced by foreign keys in another table.
    *Action:   Before performing the above operations the table, drop the
               foreign key constraints in other tables. You can see what
               constraints are referencing a table by issuing the following
               command:
               SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = "tabnam";
*/
DROP TABLE PLANETA CASCADE CONSTRAINTS;
/*  Com o comando acima, a tabela PLANETA é removida.
    Alem disso, na tabela ORBITA_PLANETA (que a referencia) as constraints de chave estrangeira tambem foram removidas, mas os atributos continuam com os valores cadastrados e a restricao NOT NULL
*/
