/*
SCC0541 - Laboratorio de Base de Dados
Pratica 08 - PL/SQL Tipos e Colecoes
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/* Insercoes na tabela ESTRELA */
INSERT INTO ESTRELA VALUES ('GA1', 'Estrela principal', 'Gigante branca', 10.5, -3.03, 1.38, 4.94);
INSERT INTO ESTRELA VALUES ('GA2', 'Estrela secundaria', 'ana vermelha', 0.25, -4.58, 5.8, 7.4);
INSERT INTO ESTRELA VALUES ('SK20', 'D-5-GAMMA', 'ana vermelha', 0.1221, 3.03, -0.09, 3.16);
INSERT INTO ESTRELA VALUES ('ALF CMa','SIRIUS A', 'ana branca', 12.063, -16, 42, 58);
INSERT INTO ESTRELA VALUES ('ALF CMa B','SIRIUS B', 'ana branca', 11.018, -58, 42, 16);

/* Insercoes na tabela PLANETA */
INSERT INTO PLANETA VALUES ('Gallifrey', 1.75, 10.315, 'Planeta rochoso');
INSERT INTO PLANETA VALUES ('Skaro', 5.07, 15.315, 'Planeta rochoso');
	 
/* Insercoes na tabela SISTEMA */
INSERT INTO SISTEMA VALUES ('GA1', 'Sistema Gallifreiano');
INSERT INTO SISTEMA VALUES ('SK20', 'Sistema Skariano');

/* Insercoes na tabela ORBITA_ESTRELA */
INSERT INTO ORBITA_ESTRELA VALUES('GA1', 'GA2', 57.2, 60.351, 57.36);   
INSERT INTO ORBITA_ESTRELA VALUES ('ALF CMa B', 'ALF CMa', 8.56, 8.64, 50);

/* Insercoes na tabela ORBITA_PLANETA */
INSERT INTO ORBITA_PLANETA VALUES ('Gallifrey', 'GA1', 278.447, 305.772, 675.354);
INSERT INTO ORBITA_PLANETA VALUES ('Skaro', 'SK20', 101.711, 115.421, 250.368);

/* Insercoes na tabela ESPECIE */
INSERT INTO ESPECIE VALUES('Homo Tempus', /*Time Lords*/ 'Gallifrey', 'V');
INSERT INTO ESPECIE VALUES('Kaleds Extermum' /*a.k.a Daleks*/, 'Skaro','F');

/* Insercoes na tabela COMUNIDADE */
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Kaledon', 950);
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Thals', 845);
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Skaro Remains', 564);
INSERT INTO COMUNIDADE VALUES('Homo Tempus', 'Arcadia', 4750);
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Kaledos', 654);
INSERT INTO COMUNIDADE VALUES('Kaleds Extermum', 'Restos de Skaro', 879);
 
/* Insercoes na tabela HABITACAO */
INSERT INTO HABITACAO VALUES('Skaro', 'Kaleds Extermum', 'Kaledos',
    TO_DATE('07/11/1200', 'dd/mm/yyyy'), TO_DATE('14/12/3050', 'dd/mm/yyyy'));
INSERT INTO HABITACAO VALUES('Skaro', 'Kaleds Extermum', 'Thals',
    TO_DATE('01/05/0500', 'dd/mm/yyyy'), TO_DATE('14/12/3050', 'dd/mm/yyyy'));
INSERT INTO HABITACAO VALUES('Skaro', 'Kaleds Extermum', 'Restos de Skaro',
    TO_DATE('15/12/3050', 'dd/mm/yyyy'), NULL);
INSERT INTO HABITACAO VALUES('Gallifrey', 'Homo Tempus', 'Arcadia',
    TO_DATE('16/08/0200', 'dd/mm/yyyy'), TO_DATE('05/12/5325', 'dd/mm/yyyy'));

/* Insercoes na tabela FEDERACAO */
INSERT INTO FEDERACAO VALUES('Poder obscuro', TO_DATE('01/05/5000', 'dd/mm/yyyy'));
INSERT INTO FEDERACAO VALUES('Senhor do tempo', TO_DATE('25/02/4890', 'dd/mm/yyyy'));

/* Insercoes na tabela NACAO */
INSERT INTO NACAO (NOME, FEDERACAO) VALUES('Imperio Dalek', 'Poder obscuro');
INSERT INTO NACAO (NOME, FEDERACAO) VALUES('Gallyos', 'Senhor do tempo');
INSERT INTO NACAO (NOME, FEDERACAO) VALUES('Gallifrey', 'Senhor do tempo');

/* Insercoes na tabela DOMINANCIA */
INSERT INTO DOMINANCIA VALUES('Skaro', 'Imperio Dalek',
    TO_DATE('19/06/0025', 'dd/mm/yyyy'),TO_DATE('05/12/5325', 'dd/mm/yyyy'));
INSERT INTO DOMINANCIA VALUES('Gallifrey', 'Gallyos',
    TO_DATE('24/01/0001', 'dd/mm/yyyy'), TO_DATE('05/12/5325', 'dd/mm/yyyy'));

/* Insercoes na tabela LIDER */
INSERT INTO LIDER VALUES('408.540.985-55', 'Davros', 'CIENTISTA', 'Imperio Dalek', 'Kaleds Extermum');
INSERT INTO LIDER VALUES('123.543.908-12', 'Borusa', 'COMANDANTE', 'Gallifrey', 'Homo Tempus');

/* Insercoes na tabela FACCAO */
INSERT INTO FACCAO (NOME, LIDER, IDEOLOGIA) VALUES('Senhor do tempo', '123.543.908-12', 'PROGRESSITA');
INSERT INTO FACCAO VALUES('Daleks', '408.540.985-55', 'TOTALITARIA', 2);

/* Insercoes na tabela NACAO_FACCAO */
INSERT INTO NACAO_FACCAO VALUES('Gallyos', 'Senhor do tempo');
INSERT INTO NACAO_FACCAO VALUES('Gallifrey', 'Senhor do tempo');
INSERT INTO NACAO_FACCAO VALUES('Imperio Dalek','Daleks');

/* Insercoes na tabela PARTICIPA */
INSERT INTO PARTICIPA VALUES('Daleks', 'Kaleds Extermum', 'Kaledon');
INSERT INTO PARTICIPA VALUES('Senhor do tempo', 'Kaleds Extermum', 'Kaledon');
INSERT INTO PARTICIPA VALUES('Senhor do tempo', 'Homo Tempus', 'Arcadia');


-- PL/SQL
/* 1) Implemente um programa PL/SQL que, dada uma facção (entrada de usuário), selecione as
comunidades que habitam planetas dominados por nações onde a facção está presente
(NacaoFaccao), mas que ainda não participam da facção (Participa). Cadastre essas
comunidades como novas participantes da facção. Para este exercício:
a. pesquise CURSOR FOR LOOP (tipos: Explícito e SQL) e escolha um deles para usar. Use
coleção Nested Table. As tuplas resultantes da consulta por comunidades devem ser
atribuídas uma a uma à coleção, isto é, sem usar BULK COLLECT.
b. Pesquise FORALL e use para o cadastro das comunidades como novas participantes da
facção. Pesquise e explique se há diferença de performance entre usar FORALL com a
coleção ou percorrer a coleção com FOR LOOP para realizar as inserções.
*/

DECLARE 
	v_input_faccao VARCHAR(15);

	v_acumulador NUMBER;
	
	TYPE t_comunidade IS RECORD (
		nome COMUNIDADE.NOME%TYPE,
		especie COMUNIDADE.ESPECIE%TYPE
	);
	TYPE t_comunidades IS TABLE OF t_comunidade;
	
	v_comunidades t_comunidades := t_comunidades();

BEGIN 
	v_input_faccao := 'Daleks';

	v_acumulador := 1;

	FOR comunidade IN (
		SELECT * FROM 
		(
			-- Seleciona comunidades que estão em planetas de uma determinada faccao 
			SELECT c.ESPECIE, c.NOME FROM COMUNIDADE c JOIN HABITACAO h ON c.NOME = h.COMUNIDADE AND c.ESPECIE = h.ESPECIE WHERE planeta IN (
				SELECT d.PLANETA 
					FROM FACCAO fac JOIN  NACAO_FACCAO nf on nf.FACCAO = fac.NOME 
					JOIN NACAO n ON nf.NACAO = n.NOME 
					JOIN DOMINANCIA d ON n.NOME = d.NACAO WHERE nf.FACCAO = v_input_faccao)
		) 
		MINUS 
		(
			-- seleciona as comunidades que participam da faccao
			SELECT c.ESPECIE, c.NOME  FROM 
				COMUNIDADE c JOIN PARTICIPA p on c.NOME = p.COMUNIDADE AND c.ESPECIE = p.ESPECIE 
				WHERE p.FACCAO = v_input_faccao
		)
	)
	LOOP
		v_comunidades.extend(1);
		
		v_comunidades(v_acumulador).nome := comunidade.nome;
		v_comunidades(v_acumulador).especie := comunidade.especie;
		
		dbms_output.put_line('Comunidade '|| v_comunidades(v_acumulador).nome || ' adicionada a facção');
	
		v_acumulador := v_acumulador + 1;
	END LOOP;

	IF v_comunidades IS EMPTY THEN
		RAISE NO_DATA_FOUND;
	END IF;
	
	FORALL i IN indices of v_comunidades
		INSERT INTO PARTICIPA VALUES (v_input_faccao, v_comunidades(i).especie, v_comunidades(i).nome);
	
	COMMIT;
	
	-- No caso do ex1, como é bem conciso, a exception que pode acontecer é a NO_DATA_FOUND
	EXCEPTION
        WHEN NO_DATA_FOUND
            THEN dbms_output.put_line('Não foram encontradas comunidades');
        WHEN OTHERS  
       		THEN dbms_output.put_line('Erro nro:  ' || SQLCODE  
                            || '. Mensagem: ' || SQLERRM );
END;

/* 2) Implemente um programa PL/SQL que selecione e imprima, para cada planeta, informações
como: nação dominante atual (se houver), datas de início e fim da última dominação (se houver),
quantidades de comunidades, de espécies, de habitantes, e de facções presentes, facção majoritária
(se houver) , e quantidade de espécies que tiveram origem no planeta. Para este exercício, use BULK
COLLECT.
*/

-- Para cada planeta, selecione a nação dominante atual (se houver), datas de início e fim da última dominação (se houver)
SELECT P.ID_ASTRO AS PLANETA, D.NACAO AS NACAO_DOMINANTE, MAX(D.DATA_INI) AS INICIO_ULTIMA_DOMINACAO, MAX(D.DATA_FIM) AS FIM_ULTIMA_DOMINACAO
FROM PLANETA P JOIN DOMINANCIA D
    ON P.ID_ASTRO = D.PLANETA
GROUP BY P.ID_ASTRO, D.NACAO, D.DATA_INI, D.DATA_FIM;

-- Para cada planeta, selecione as quantidades de comunidades, de espécies, de habitantes
SELECT P.ID_ASTRO, COUNT(*) AS QTD_COMUNIDADES, COUNT(DISTINCT H.ESPECIE) AS QTD_ESPECIES, SUM(C.QTD_HABITANTES) AS QTD_HABITANTES
FROM PLANETA P JOIN HABITACAO H
ON P.ID_ASTRO = H.PLANETA
JOIN COMUNIDADE C 
ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
GROUP BY P.ID_ASTRO, H.ESPECIE;

-- Para cada planeta, selecione faccoes presentes, faccao majoritaria
SELECT P.ID_ASTRO, P.FACCAO AS FACCAO
FROM PLANETA P JOIN HABITACAO H
ON P.ID_ASTRO = H.PLANETA
JOIN PARTICIPA P
ON H.ESPECIE = P.ESPECIE AND H.COMUNIDADE = P.COMUNIDADE;

-- Para cada planeta, selecione a quantidade de especies que tiveram origem no planeta
SELECT P.ID_ASTRO, COUNT(*) AS QTD_ESPECIES_ORIGINADAS
FROM PLANETA P JOIN ESPECIE E
ON P.ID_ASTRO = E.PLANETA_OR
GROUP BY P.ID_ASTRO;

DECLARE
    TYPE t_planeta IS RECORD (
        planeta planeta.id_astro%type,
        nacao_dominante dominancia.nacao%type,
        dt_ini_dominacao dominancia.data_ini%type,
        dt_fim_dominacao dominancia.data_fim%type,
        qtd_comunidades INTEGER,
        qtd_especies INTEGER,
        qtd_habitantes INTEGER,
        qtd_faccoes INTEGER,
        faccao_majoritaria participa.faccao%type,
        qtd_especies_originadas INTEGER
    );
    
    TYPE t_tab_planetas IS TABLE OF t_planeta;
    
    v_planetas t_tab_planetas := t_tab_planetas();
    
BEGIN
    SELECT P.ID_ASTRO AS PLANETA, D.NACAO AS NACAO_DOMINANTE, MAX(D.DATA_INI) AS INICIO_ULTIMA_DOMINACAO, MAX(D.DATA_FIM) AS FIM_ULTIMA_DOMINACAO
    BULK COLLECT INTO v_planetas
    FROM PLANETA P LEFT JOIN DOMINANCIA D
        ON P.ID_ASTRO = D.PLANETA
    GROUP BY P.ID_ASTRO, D.NACAO, D.DATA_INI, D.DATA_FIM;
    
     -- Consulta para habitacao
    FOR i IN 1..v_planetas.COUNT LOOP
        SELECT COUNT(*) AS QTD_COMUNIDADES, COUNT(DISTINCT H.ESPECIE) AS QTD_ESPECIES, SUM(C.QTD_HABITANTES) AS QTD_HABITANTES
        INTO v_planetas(i).qtd_comunidades, v_planetas(i).qtd_especies, v_planetas(i).qtd_habitantes
        FROM HABITACAO H JOIN COMUNIDADE C 
        ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
        WHERE H.PLANETA = v_planetas(i).planeta;
    END LOOP;

    -- Consulta para faccao
    FOR i IN 1..v_planetas.COUNT LOOP
        SELECT COUNT(*) INTO v_planetas(i).qtd_faccoes
        FROM HABITACAO H JOIN PARTICIPA P
        ON H.ESPECIE = P.ESPECIE AND H.COMUNIDADE = P.COMUNIDADE
        WHERE H.PLANETA = v_planetas(i).planeta;
    END LOOP;
    
    -- Consulta para especies originadas
    FOR i IN 1..v_planetas.COUNT LOOP
        SELECT COUNT(*) INTO v_planetas(i).qtd_especies_originadas
        FROM ESPECIE E
        WHERE E.PLANETA_OR = v_planetas(i).planeta;
    END LOOP;
    
    FOR i IN 1..v_planetas.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Planeta: ' || v_planetas(i).planeta);
    END LOOP;
END;
