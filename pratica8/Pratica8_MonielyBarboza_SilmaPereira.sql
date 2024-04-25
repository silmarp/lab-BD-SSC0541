/*
SCC0541 - Laboratorio de Base de Dados
Pratica 08 - PL/SQL – Registros e Coleções - Tipos Armazenados
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

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
	VALUES ('Gallifrey', 1.75, 10.315, 'Planeta rochoso');
	
INSERT INTO PLANETA 
	VALUES ('Skaro', 5.07, 15.315, 'Planeta rochoso');
	
    
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
	VALUES('Homo Tempus', /*Time Lords*/ 'Gallifrey', 'V');

INSERT INTO ESPECIE 
	VALUES('Kaleds Extermum' /*a.k.a Daleks*/, 'Skaro','F');


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

INSERT INTO COMUNIDADE
	VALUES(
		'Kaleds Extermum',
		'Skaro Remains',
        564
	);

INSERT INTO COMUNIDADE
	VALUES(
		'Homo Tempus',
		'Arcadia',
		4750
	);

INSERT INTO COMUNIDADE
	VALUES(
		'Kaleds Extermum',
		'Kaledos',
        654
	);

INSERT INTO COMUNIDADE
	VALUES(
		'Kaleds Extermum',
        'Restos de Skaro',
        879
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
		'Poder obscuro',
		TO_DATE('01/05/5000', 'dd/mm/yyyy'));

INSERT INTO FEDERACAO 
	VALUES(
		'Senhor do tempo',
		TO_DATE('25/02/4890', 'dd/mm/yyyy'));

/* Insercoes na tabela NACAO */
INSERT INTO NACAO (NOME, FEDERACAO)
	VALUES('Imperio Dalek', 'Poder obscuro');

INSERT INTO NACAO (NOME, FEDERACAO)
	VALUES('Gallyos', 'Senhor do tempo');

INSERT INTO NACAO (NOME, FEDERACAO)
	VALUES('Gallifrey', 'Senhor do tempo');


/* Insercoes na tabela DOMINANCIA */
INSERT INTO DOMINANCIA
	VALUES(
		'Skaro', 'Imperio Dalek',
		TO_DATE('19/06/0025', 'dd/mm/yyyy'),
		TO_DATE('05/12/5325', 'dd/mm/yyyy')/*fim da grande guerra do tempo*/
	);

INSERT INTO DOMINANCIA
	VALUES(
		'Gallifrey',
        'Gallyos',
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
		'123.543.908-12', 'Borusa', 'COMANDANTE', /*seu cargo eh presidente o que nao esta nas opcoes*/ 
		'Gallifrey',
		'Homo Tempus'
	);


/* Insercoes na tabela FACCAO */
INSERT INTO FACCAO (NOME, LIDER, IDEOLOGIA)
	VALUES(
		'Senhor do tempo',
		'123.543.908-12',
		'PROGRESSITA'
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
        'Senhor do tempo'
	);

INSERT INTO NACAO_FACCAO 
	VALUES(
        'Gallifrey',
        'Senhor do tempo'
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
		'Senhor do tempo',
		'Kaleds Extermum',
        'Kaledon'
	);

INSERT INTO PARTICIPA
	VALUES(
		'Senhor do tempo',
		'Homo Tempus',
        'Arcadia'
	);
