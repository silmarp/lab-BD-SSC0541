/*
SCC0541 - Laborat�rio de Base de Dados
Pr�tica 01 - SQL/DML
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

CREATE TABLE ESTRELA (
    ID_CATALOGO VARCHAR(10) NOT NULL,
    NOME VARCHAR(15),
    CLASSIFICACAO VARCHAR(15),
    MASSA FLOAT,
    COORDENADAS_X FLOAT NOT NULL,
    COORDENADAS_Y FLOAT NOT NULL,
    COORDENADAS_Z FLOAT NOT NULL,
        CONSTRAINT PK_ESTRELA PRIMARY KEY (ID_CATALOGO),
        CONSTRAINT UNIQUE_ESTRELA UNIQUE (COORDENADAS_X, COORDENADAS_Y, COORDENADAS_Z)
);

CREATE TABLE SISTEMA (
    ESTRELA VARCHAR(10)  NOT NULL,
    NOME VARCHAR(15),
        CONSTRAINT PK_SISTEMA PRIMARY KEY (ESTRELA),
        CONSTRAINT FK_SISTEMA FOREIGN KEY (ESTRELA)
            REFERENCES ESTRELA(ID_CATALOGO)
            ON DELETE CASCADE
);

CREATE TABLE PLANETA (
    DESIGNACAO_ASTRONOMICA VARCHAR(15) NOT NULL,
    MASSA FLOAT,
    RAIO FLOAT,
    COMPOSICAO VARCHAR(20),
    CLASSIFICACAO VARCHAR(20),
        CONSTRAINT PK_PLANETA PRIMARY KEY (DESIGNACAO_ASTRONOMICA)
);

CREATE TABLE ORBITA_ESTRELA (
    ORBITANTE VARCHAR(10) NOT NULL,
    ORBITADA VARCHAR(10) NOT NULL,
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
            /*n�o h� orbita se n�o houver orbitante E orbitado*/
);

CREATE TABLE ORBITA_PLANETA (
    PLANETA VARCHAR(10) NOT NULL,
    ESTRELA VARCHAR(10) NOT NULL,
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
    NOME_CIENTIFICO VARCHAR(15) NOT NULL,
    PLANETA_ORIGEM VARCHAR(15) NOT NULL,
    INTELIGENTE CHAR(1) NOT NULL,
        CONSTRAINT PK_ESPECIE PRIMARY KEY (NOME_CIENTIFICO),
        CONSTRAINT IS_INTELIGENTE CHECK (UPPER(INTELIGENTE) IN ('S','N')),
        CONSTRAINT FK_ESPECIE FOREIGN KEY (PLANETA_ORIGEM)
            REFERENCES PLANETA(DESIGNACAO_ASTRONOMICA)
            ON DELETE CASCADE
);

CREATE TABLE COMUNIDADE (
    ESPECIE VARCHAR(15) NOT NULL,
    NOME VARCHAR(15) NOT NULL,
    QTD_HABITANTES INT,
        CONSTRAINT PK_COMUNIDADE PRIMARY KEY (ESPECIE, NOME),
        CONSTRAINT FK_COMUNIDADE FOREIGN KEY (ESPECIE)
            REFERENCES ESPECIE(NOME_CIENTIFICO)
            ON DELETE CASCADE
);

CREATE TABLE HABITACAO (
    PLANETA VARCHAR(15) NOT NULL,
    COM_ESPECIE VARCHAR(15) NOT NULL,
    COM_NOME VARCHAR(15) NOT NULL,
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
    NOME_FD VARCHAR(15) NOT NULL,
    DT_FUND DATE,
        CONSTRAINT PK_FEDERACAO PRIMARY KEY (NOME_FD)
);

CREATE TABLE NACAO (
    NOME_NC VARCHAR(15) NOT NULL,
    QTD_PLANETAS INT,
    FEDERACAO VARCHAR(15),
        CONSTRAINT PK_NACAO PRIMARY KEY (NOME_NC),
        CONSTRAINT FK_NACAO FOREIGN KEY (FEDERACAO)
            REFERENCES FEDERACAO(NOME_FD)
            ON DELETE SET NULL
);

CREATE TABLE DOMINANCIA (
    NACAO VARCHAR(15) NOT NULL,
    PLANETA VARCHAR(15) NOT NULL,
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
    CPI VARCHAR(15) NOT NULL,
    NOME VARCHAR(15),
    CARGO VARCHAR(15) NOT NULL,
    NACAO VARCHAR(15) NOT NULL,
    ESPECIE VARCHAR(15) NOT NULL,
        CONSTRAINT PK_LIDER PRIMARY KEY (CPI),
        CONSTRAINT CARGO_POSSIVEL CHECK (UPPER(CARGO) IN ('COMANDANTE','OFICIAL', 'CIENTISTA')),
        CONSTRAINT FK_LIDER_NACAO FOREIGN KEY (NACAO)
            REFERENCES NACAO(NOME_NC)
            ON DELETE CASCADE,
        CONSTRAINT FK_LIDER_ESPECIE FOREIGN KEY (ESPECIE)
            REFERENCES ESPECIE(NOME_CIENTIFICO)
            ON DELETE CASCADE
);

CREATE TABLE FACCAO(
    NOME_FC VARCHAR(15) NOT NULL,
    LIDER_FC VARCHAR(15) NOT NULL,
    IDEOLOGIA VARCHAR(15),
    QTD_NACOES INT,
        CONSTRAINT PK_FACCAO PRIMARY KEY (NOME_FC),
        CONSTRAINT UNIQUE_FACCAO UNIQUE (LIDER_FC),
        CONSTRAINT IDEOLOGIA_POSSIVEL CHECK (UPPER(IDEOLOGIA) IN ('PROGRESSISTA','TRADICIONALISTA', 'TOTALITARIA', NULL)),
        CONSTRAINT FK_FACCAO FOREIGN KEY (LIDER_FC)
            REFERENCES LIDER(CPI)
            ON DELETE CASCADE
);


CREATE TABLE NACAO_FACCAO (
    NACAO VARCHAR(15) NOT NULL,
    FACCAO VARCHAR(15) NOT NULL,
        CONSTRAINT PK_NACAO_FACCAO PRIMARY KEY (NACAO, FACCAO),
        CONSTRAINT FK_NACAO_FACCAO_NACAO FOREIGN KEY (NACAO)
            REFERENCES NACAO(NOME_NC)
            ON DELETE CASCADE,
        CONSTRAINT FK_NACAO_FACCAO_FACCAO FOREIGN KEY (FACCAO)
            REFERENCES FACCAO(NOME_FC)
            ON DELETE CASCADE
);

CREATE TABLE PARTICIPA (
    FACCAO VARCHAR(15) NOT NULL,
    COM_ESPECIE VARCHAR(15) NOT NULL,
    COM_NOME VARCHAR(15) NOT NULL,
        CONSTRAINT PK_PARTICIPA PRIMARY KEY (FACCAO, COM_ESPECIE, COM_NOME),
        CONSTRAINT FK_PARTICIPA_FACCAO FOREIGN KEY (FACCAO)
            REFERENCES FACCAO(NOME_FC)
            ON DELETE CASCADE,
        CONSTRAINT FK_PARTICIPA_COM_ESPECIE_COM_NOME FOREIGN KEY (COM_ESPECIE, COM_NOME)
            REFERENCES COMUNIDADE(ESPECIE, NOME)
            ON DELETE CASCADE
);