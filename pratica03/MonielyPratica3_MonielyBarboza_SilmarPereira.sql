/*
SCC0541 - Laboratório de Base de Dados
Prática 03 - SQL/DDL-DML
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*1) Remova todas as tabelas e re-crie a base de dados. Coloque no script de entrega da Prática 3 os
comandos para remoção (drop) e criação (create) das tabelas.
*/

DROP TABLE PARTICIPA;
DROP TABLE NACAO_FACCAO;
DROP TABLE FACCAO;
DROP TABLE LIDER;
DROP TABLE DOMINANCIA;
DROP TABLE NACAO;
DROP TABLE FEDERACAO;
DROP TABLE HABITACAO;
DROP TABLE COMUNIDADE;
DROP TABLE ESPECIE;
DROP TABLE ORBITA_PLANETA;
DROP TABLE ORBITA_ESTRELA;
DROP TABLE PLANETA;
DROP TABLE SISTEMA;
DROP TABLE ESTRELA;


CREATE TABLE ESTRELA (
    ID_CATALOGO VARCHAR(50) NOT NULL,
    NOME VARCHAR(50),
    CLASSIFICACAO VARCHAR(50),
    MASSA FLOAT,
    COORDENADAS_X FLOAT NOT NULL,
    COORDENADAS_Y FLOAT NOT NULL,
    COORDENADAS_Z FLOAT NOT NULL,
        CONSTRAINT PK_ESTRELA PRIMARY KEY (ID_CATALOGO),
        CONSTRAINT UNIQUE_ESTRELA UNIQUE (COORDENADAS_X, COORDENADAS_Y, COORDENADAS_Z)
);

CREATE TABLE SISTEMA (
    ESTRELA VARCHAR(50)  NOT NULL,
    NOME VARCHAR(50),
        CONSTRAINT PK_SISTEMA PRIMARY KEY (ESTRELA),
        CONSTRAINT FK_SISTEMA FOREIGN KEY (ESTRELA)
            REFERENCES ESTRELA(ID_CATALOGO)
            ON DELETE CASCADE
);

CREATE TABLE PLANETA (
    DESIGNACAO_ASTRONOMICA VARCHAR(50) NOT NULL,
    MASSA FLOAT,
    RAIO FLOAT,
    COMPOSICAO VARCHAR(50),
    CLASSIFICACAO VARCHAR(50),
        CONSTRAINT PK_PLANETA PRIMARY KEY (DESIGNACAO_ASTRONOMICA)
);

CREATE TABLE ORBITA_ESTRELA (
    ORBITANTE VARCHAR(50) NOT NULL,
    ORBITADA VARCHAR(50) NOT NULL,
    DISTANCIA_MIN FLOAT,
    DISTANCIA_MAX FLOAT,
    PERIODO FLOAT,
        CONSTRAINT PK_ORBITA_ESTRELA PRIMARY KEY (ORBITANTE, ORBITADA),
        CONSTRAINT FK_ORBITA_ESTRELA_ORBITANTE FOREIGN KEY (ORBITANTE)
            REFERENCES ESTRELA(ID_CATALOGO)
            ON DELETE CASCADE,
        CONSTRAINT FK_ORBITA_ESTRELA_ORBITADA FOREIGN KEY (ORBITADA)
            REFERENCES ESTRELA(ID_CATALOGO)
            ON DELETE CASCADE 
            /*não há orbita se não houver orbitante E orbitado*/
);

CREATE TABLE ORBITA_PLANETA (
    PLANETA VARCHAR(50) NOT NULL,
    ESTRELA VARCHAR(50) NOT NULL,
    DISTANCIA_MIN FLOAT,
    DISTANCIA_MAX FLOAT,
    PERIODO FLOAT,
        CONSTRAINT PK_ORBITA_PLANETA PRIMARY KEY (PLANETA, ESTRELA),
        CONSTRAINT FK_ORBITA_PLANETA_PLANETA FOREIGN KEY (PLANETA)
            REFERENCES PLANETA(DESIGNACAO_ASTRONOMICA)
            ON DELETE CASCADE,
        CONSTRAINT FK_ORBITA_PLANETA_ESTRELA FOREIGN KEY (ESTRELA)
            REFERENCES ESTRELA(ID_CATALOGO)
            ON DELETE CASCADE
);

CREATE TABLE ESPECIE (
    NOME_CIENTIFICO VARCHAR(50) NOT NULL,
    PLANETA_ORIGEM VARCHAR(50) NOT NULL,
    INTELIGENTE CHAR(1) NOT NULL,
        CONSTRAINT PK_ESPECIE PRIMARY KEY (NOME_CIENTIFICO),
        CONSTRAINT IS_INTELIGENTE CHECK (UPPER(INTELIGENTE) IN ('S','N')),
        CONSTRAINT FK_ESPECIE FOREIGN KEY (PLANETA_ORIGEM)
            REFERENCES PLANETA(DESIGNACAO_ASTRONOMICA)
            ON DELETE CASCADE
);

/* Se uma Comunidade está sendo criada, deve existir pelo menos 1 Habitante */
CREATE TABLE COMUNIDADE (
    ESPECIE VARCHAR(50) NOT NULL,
    NOME VARCHAR(50) NOT NULL,
    QTD_HABITANTES INT DEFAULT 1,
        CONSTRAINT PK_COMUNIDADE PRIMARY KEY (ESPECIE, NOME),
        CONSTRAINT FK_COMUNIDADE FOREIGN KEY (ESPECIE)
            REFERENCES ESPECIE(NOME_CIENTIFICO)
            ON DELETE CASCADE
);

CREATE TABLE HABITACAO (
    PLANETA VARCHAR(50) NOT NULL,
    COM_ESPECIE VARCHAR(50) NOT NULL,
    COM_NOME VARCHAR(50) NOT NULL,
    DT_INICIO DATE NOT NULL,
    DT_FIM DATE,
        CONSTRAINT PK_HABITACAO PRIMARY KEY (PLANETA, COM_ESPECIE, COM_NOME, DT_INICIO),
        CONSTRAINT FK_HABITACAO_PLANETA FOREIGN KEY (PLANETA)
            REFERENCES PLANETA(DESIGNACAO_ASTRONOMICA)
            ON DELETE CASCADE, 
        CONSTRAINT FK_HABITACAO_ FOREIGN KEY (COM_ESPECIE, COM_NOME)
            REFERENCES COMUNIDADE(ESPECIE, NOME)
            ON DELETE CASCADE
);

CREATE TABLE FEDERACAO (
    NOME_FD VARCHAR(50) NOT NULL,
    DT_FUND DATE,
        CONSTRAINT PK_FEDERACAO PRIMARY KEY (NOME_FD)
);

/* Se uma Nação está sendo criada, ela deve existir em pelo menos 1 Planeta */
CREATE TABLE NACAO (
    NOME_NC VARCHAR(50) NOT NULL,
    QTD_PLANETAS INT DEFAULT 1,
    FEDERACAO VARCHAR(50),
        CONSTRAINT PK_NACAO PRIMARY KEY (NOME_NC),
        CONSTRAINT FK_NACAO FOREIGN KEY (FEDERACAO)
            REFERENCES FEDERACAO(NOME_FD)
            ON DELETE SET NULL
);

CREATE TABLE DOMINANCIA (
    NACAO VARCHAR(50) NOT NULL,
    PLANETA VARCHAR(50) NOT NULL,
    DT_INICIO DATE NOT NULL,
    DT_FIM DATE,
        CONSTRAINT PK_DOMINANCIA PRIMARY KEY (NACAO, PLANETA, DT_INICIO),
        CONSTRAINT FK_DOMINANCIA_NACAO FOREIGN KEY (NACAO)
            REFERENCES NACAO(NOME_NC)
            ON DELETE CASCADE, 
        CONSTRAINT FK_DOMINANCIA_PLANETA FOREIGN KEY (PLANETA)
            REFERENCES PLANETA(DESIGNACAO_ASTRONOMICA)
            ON DELETE CASCADE
);

CREATE TABLE LIDER (
    CPI VARCHAR(50) NOT NULL,
    NOME VARCHAR(50),
    CARGO VARCHAR(50) NOT NULL,
    NACAO VARCHAR(50) NOT NULL,
    ESPECIE VARCHAR(50) NOT NULL,
        CONSTRAINT PK_LIDER PRIMARY KEY (CPI),
        CONSTRAINT CARGO_POSSIVEL CHECK (UPPER(CARGO) IN ('COMANDANTE','OFICIAL', 'CIENTISTA')),
        CONSTRAINT FK_LIDER_NACAO FOREIGN KEY (NACAO)
            REFERENCES NACAO(NOME_NC)
            ON DELETE CASCADE,
        CONSTRAINT FK_LIDER_ESPECIE FOREIGN KEY (ESPECIE)
            REFERENCES ESPECIE(NOME_CIENTIFICO)
            ON DELETE CASCADE
);

/* Se uma Faccção está sendo criada, ela deve existir em pelo menos 1 Nação */
CREATE TABLE FACCAO(
    NOME_FC VARCHAR(50) NOT NULL,
    LIDER_FC VARCHAR(50) NOT NULL,
    IDEOLOGIA VARCHAR(50),
    QTD_NACOES INT DEFAULT 1,
        CONSTRAINT PK_FACCAO PRIMARY KEY (NOME_FC),
        CONSTRAINT UNIQUE_FACCAO UNIQUE (LIDER_FC),
        CONSTRAINT IDEOLOGIA_POSSIVEL CHECK (UPPER(IDEOLOGIA) IN ('PROGRESSISTA','TRADICIONALISTA', 'TOTALITARIA', NULL)),
        CONSTRAINT FK_FACCAO FOREIGN KEY (LIDER_FC)
            REFERENCES LIDER(CPI)
            ON DELETE CASCADE
);


CREATE TABLE NACAO_FACCAO (
    NACAO VARCHAR(50) NOT NULL,
    FACCAO VARCHAR(50) NOT NULL,
        CONSTRAINT PK_NACAO_FACCAO PRIMARY KEY (NACAO, FACCAO),
        CONSTRAINT FK_NACAO_FACCAO_NACAO FOREIGN KEY (NACAO)
            REFERENCES NACAO(NOME_NC)
            ON DELETE CASCADE,
        CONSTRAINT FK_NACAO_FACCAO_FACCAO FOREIGN KEY (FACCAO)
            REFERENCES FACCAO(NOME_FC)
            ON DELETE CASCADE
);

CREATE TABLE PARTICIPA (
    FACCAO VARCHAR(50) NOT NULL,
    COM_ESPECIE VARCHAR(50) NOT NULL,
    COM_NOME VARCHAR(50) NOT NULL,
        CONSTRAINT PK_PARTICIPA PRIMARY KEY (FACCAO, COM_ESPECIE, COM_NOME),
        CONSTRAINT FK_PARTICIPA_FACCAO FOREIGN KEY (FACCAO)
            REFERENCES FACCAO(NOME_FC)
            ON DELETE CASCADE,
        CONSTRAINT FK_PARTICIPA_COM_ESPECIE_COM_NOME FOREIGN KEY (COM_ESPECIE, COM_NOME)
            REFERENCES COMUNIDADE(ESPECIE, NOME)
            ON DELETE CASCADE
);


/*
2) Re-insira os dados (podem ser os mesmos inserts realizados no início da Prática 2). Coloque no script
de entrega da Prática 3 os comandos para inserção dos dados.
*/
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

/*
3) Para as consultas a seguir, elabore casos de teste e insira os dados necessários para testar os casos.
A eficiência da consulta será considerada na correção. Coloque no script de entrega da Prática 3: os
comandos de inserção dos dados de teste de cada consulta, o comando da consulta e os
comentários que julgar relevantes para a correção. */

/* a. Selecione, para cada facção, seu nome, ideologia, nome do líder, espécie do líder e nação do
líder. */

-- Teste: Inserção de um líder que não lidera nenhuma facção
INSERT INTO LIDER
VALUES ('111.222.333-44', 'Rassilon', 'Comandante', 'Gallifrey', 'Homo Tempus');

SELECT F.NOME_FC, F.IDEOLOGIA, L.NOME AS LIDER, L.ESPECIE, L.NACAO
FROM FACCAO F, LIDER L
WHERE F.LIDER_FC = L.CPI;


/* b. Selecione, para cada líder da sociedade galáctica, seu CPI, seu nome, nação a que pertence,
sua espécie e o planeta de origem dela, e se o líder for responsável por liderar alguma facção,
selecione também o nome da facção. */
/* TODO: inserir testes para quando o lider não lidera faccao */

SELECT L.CPI, L.NOME, L.NACAO, L.ESPECIE, E.PLANETA_ORIGEM AS ESPECIE_ORIGEM, F.NOME_FC AS FACCAO
FROM LIDER L JOIN ESPECIE E
ON L.ESPECIE = E.NOME_CIENTIFICO 
    LEFT JOIN FACCAO F
    ON L.CPI = F.LIDER_FC;


/* c. Para cada estrela orbitada por outra(s), selecione seu nome e sua classificação, e o nome e a
classificação da(s) estrela(s) que a orbita(m). */

-- Teste: Estrela orbitada por múltiplas estrelas
INSERT INTO ESTRELA 
    VALUES ('ALF CMa C','SIRIUS C', 'ana branca', 11.018, 16, -58, 42);
    
INSERT INTO ORBITA_ESTRELA 
	VALUES ('ALF CMa C', 'ALF CMa', 8.56, 8.64, 50);
   
 
SELECT E1.NOME AS ORBITADA_NOME, E1.CLASSIFICACAO AS ORBITADA_CLASSIFICACAO,
        E2.NOME AS ORBITANTE_NOME, E2.CLASSIFICACAO AS ORBITANTE_CLASSIFICACAO
FROM ORBITA_ESTRELA OE, ESTRELA E1, ESTRELA E2
WHERE OE.ORBITADA = E1.ID_CATALOGO AND OE.ORBITANTE = E2.ID_CATALOGO;


/* d. Para cada planeta habitado momento atual, selecione a quantidade de comunidades com
espécies inteligentes que possuem atualmente (ou seja, a consulta não considera habitações
do passado). Lembre-se de considerar que um planeta habitado no momento atual pode não
ter espécies inteligentes, mas precisa aparecer na resposta com contagem zero. */

--Testes:
-- Planeta habitado sem espécies inteligentes: Mercurio - Cogumelo
-- Planeta habitado com comunidades do passado de especies inteligentes (que não devem ser contadas): Terra - Dinossauro 
-- Planeta não habitado: Venus


INSERT INTO PLANETA (DESIGNACAO_ASTRONOMICA) VALUES ('Mercurio');  
INSERT INTO PLANETA (DESIGNACAO_ASTRONOMICA) VALUES ('Terra');
INSERT INTO PLANETA (DESIGNACAO_ASTRONOMICA) VALUES ('Venus');
    
INSERT INTO ESPECIE VALUES('Homo Sapiens', 'Terra', 'N');
INSERT INTO ESPECIE VALUES('V-Rex', 'Terra', 'S');
INSERT INTO ESPECIE VALUES('Agaricus arvensis', 'Mercurio', 'N');

INSERT INTO COMUNIDADE (ESPECIE, NOME) VALUES('Homo Sapiens', 'Humano');
INSERT INTO COMUNIDADE (ESPECIE, NOME) VALUES('V-Rex', 'Dinossauro');
INSERT INTO COMUNIDADE (ESPECIE, NOME) VALUES('Agaricus arvensis', 'Cogumelo');
    
INSERT INTO HABITACAO (PLANETA, COM_ESPECIE, COM_NOME, DT_INICIO)
    VALUES('Terra', 'Homo Sapiens', 'Humano', TO_DATE('07/11/2010', 'dd/mm/yyyy'));
INSERT INTO HABITACAO
	VALUES('Terra', 'V-Rex', 'Dinossauro', TO_DATE('01/01/0001', 'dd/mm/yyyy'), TO_DATE('01/01/0009', 'dd/mm/yyyy'));
INSERT INTO HABITACAO (PLANETA, COM_ESPECIE, COM_NOME, DT_INICIO)
	VALUES('Mercurio', 'Agaricus arvensis', 'Cogumelo', TO_DATE('04/11/2010', 'dd/mm/yyyy'));
    
SELECT H.PLANETA, COUNT(E.INTELIGENTE) AS QNT_COM_INTELIGENTES_ATUALMENTE
FROM PLANETA P JOIN HABITACAO H
ON P.DESIGNACAO_ASTRONOMICA = H.PLANETA
    LEFT JOIN ESPECIE E
    ON H.COM_ESPECIE = E.NOME_CIENTIFICO AND E.INTELIGENTE = 'S'
WHERE DT_FIM IS NULL OR DT_FIM > TO_DATE(SYSDATE, 'dd/mm/yyyy')
GROUP BY H.PLANETA;

/* e. Para cada planeta habitado, selecione a quantidade de comunidades existentes para cada
uma das espécies que o habitam. */

-- Testes: Planeta com mais de 1 especie
INSERT INTO HABITACAO (PLANETA, COM_ESPECIE, COM_NOME, DT_INICIO)
	VALUES('Terra', 'Agaricus arvensis', 'Cogumelo', TO_DATE('04/11/2010', 'dd/mm/yyyy'));

SELECT H.PLANETA, E.NOME_CIENTIFICO AS ESPECIE, COUNT(H.COM_NOME) AS QTD_COMUNIDADES
FROM PLANETA P JOIN HABITACAO H
ON P.DESIGNACAO_ASTRONOMICA = H.PLANETA
    RIGHT JOIN ESPECIE E
    ON H.COM_ESPECIE = E.NOME_CIENTIFICO
WHERE DT_FIM IS NULL OR DT_FIM > TO_DATE(SYSDATE, 'dd/mm/yyyy')
GROUP BY H.PLANETA, E.NOME_CIENTIFICO;

/* f. Escolha na sua base de dados 1 estrela orbitada por pelo menos 2 planetas. Selecione nome
e classificação das estrelas que são orbitadas por todos os planetas que orbitam a estrela
escolhida. */

-- Testes: Inserção de 1 estrela orbitada por pelo menos 2 planetas
INSERT INTO ORBITA_PLANETA VALUES ('Gallifrey', 'ALF CMa C', 278.447, 305.772, 675.354);
INSERT INTO ORBITA_PLANETA VALUES ('Skaro', 'ALF CMa C', 278.447, 305.772, 675.354);

-- Testes: Inserção de 2 estrelas orbitadas pelos mesmos planetas da estrela acima
INSERT INTO ORBITA_PLANETA VALUES ('Gallifrey', 'ALF CMa', 278.447, 305.772, 675.354);
INSERT INTO ORBITA_PLANETA VALUES ('Skaro', 'ALF CMa', 278.447, 305.772, 675.354);

INSERT INTO ORBITA_PLANETA VALUES ('Gallifrey', 'ALF CMa B', 278.447, 305.772, 675.354);
INSERT INTO ORBITA_PLANETA VALUES ('Skaro', 'ALF CMa B', 278.447, 305.772, 675.354);


SELECT DISTINCT E.NOME, E.CLASSIFICACAO
FROM ESTRELA E, PLANETA P
WHERE NOT EXISTS  (
    (   SELECT OP.PLANETA
        FROM ORBITA_PLANETA OP
        WHERE OP.ESTRELA = 'ALF CMa C'
    )
    MINUS
    (   SELECT OP.PLANETA
        FROM ORBITA_PLANETA OP
        WHERE OP.ESTRELA = E.ID_CATALOGO)
	)
    AND E.ID_CATALOGO != 'ALF CMa C';
