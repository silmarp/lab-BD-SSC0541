/* 1) Crie uma view n�o atualiz�vel que armazene, para todas as fac��es progressistas, nome da fac��o e
CPI do l�der. */

/* Insercoes na tabela LIDER */
INSERT INTO LIDER
	VALUES('123.543.908-12', 'Borusa', 'COMANDANTE', 'Non eius in.', 'Odio ex in');

/* Insercoes na tabela FACCAO */
INSERT INTO FACCAO (NOME, LIDER, IDEOLOGIA)
	VALUES('Senhor do tempo', '123.543.908-12', 'PROGRESSITA');
/* PS: H� um erro de digta��o na cria��o do esquema. Est� 'PROGRESSITA' ao inves de 'PROGRESSISTA' */

-- Cria��o da view
CREATE OR REPLACE VIEW VIEW_FACCAO AS
    SELECT NOME, LIDER
    FROM FACCAO
    WHERE IDEOLOGIA = 'PROGRESSITA'
    WITH READ ONLY;
    
/*  Note que, sem a cl�usula 'WITH READ ONLY', est� view seria atualiz�vel.
    Por isso, inserimos essa cl�usula, a fim de garanter que ela seja n�o atualiz�vel
    Com isso, apenas opra��es de sele��o s�o poss�veis. */
    
/* a) Usando a view, fa�a uma consulta que retorne o n�mero de fac��es progressistas; */

SELECT COUNT(*) FROM VIEW_FACCAO;

/* b) Usando a view, teste uma opera��o de inser��o. Explique o resultado. */

/* Nova insercao na tabela LIDER */
INSERT INTO LIDER
	VALUES('408.540.985-55', 'Davros', 'CIENTISTA', 'Facilis illo.', 'Illo fugit');

/* Tentativa de inserao utilizando a view_faccao */
INSERT INTO VIEW_FACCAO
    VALUES('Daleks', '408.540.985-55');

/* Ao tentar realizar essa inser��o, o seguinte erro � exibido:

Erro a partir da linha : 34 no comando -
INSERT INTO VIEW_FACCAO
    VALUES('Daleks', '408.540.985-55')
Erro na Linha de Comandos : 34 Coluna : 1
Relat�rio de erros -
Erro de SQL: ORA-42399: n�o � poss�vel efetuar uma opera��o de DML em uma view somente para leitura
42399.0000 - "cannot perform a DML operation on a read-only view"

Isso ocorre pois na cria��o da view inclu�mos a cl�usula 'WITH READ ONLY', tornando-a n�o atualiz�vel. */

/* Abaixo, criaremos a view sem a cl�usula 'WITH READ ONLY' e tentaremos realizar uma opera��o de inser��o: */

DELETE FROM FACCAO WHERE NOME = 'Daleks';

-- Cria��o da view atualiz�vel
CREATE OR REPLACE VIEW VIEW_FACCAO AS
    SELECT NOME, LIDER
    FROM FACCAO
    WHERE IDEOLOGIA = 'PROGRESSITA';

/* Tentativa de inserao utilizando a view_faccao */
INSERT INTO VIEW_FACCAO
    VALUES('Daleks', '408.540.985-55');
    
/* Dessa forma, a view se torna atualiz�vel e � poss�vel executar a inser��o. */


/* 2) Crie duas views atualiz�veis que armazenem, para todas as fac��es tradicionalistas, nome da fac��o,
CPI do l�der e a ideologia, da seguinte maneira:
a) A primeira view deve permitir a inser��o de fac��es n�o tradicionalistas. Insira na view
fac��es tradicionalistas e n�o tradicionalistas (efetive com commit). Mostre o resultado na
view e na tabela base. */

CREATE VIEW vw_tradicionalistas AS
	SELECT NOME, LIDER, IDEOLOGIA FROM FACCAO WHERE IDEOLOGIA = 'TRADICIONALISTA';

SELECT * FROM vw_tradicionalistas; 
/* resultados da view
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
*/

INSERT INTO LIDER
	VALUES(
		'400.289.226-12', 'liderInsert', 'CIENTISTA', 
		'Imp�rio Dalek',
		'Kaleds Extermum'
	);
INSERT INTO VW_TRADICIONALISTAS VALUES ('testInsert', '400.289.226-12', 'PROGRESSITA')

INSERT INTO LIDER
	VALUES(
		'430.289.226-12', 'liderInsert', 'CIENTISTA', 
		'Imp�rio Dalek',
		'Kaleds Extermum'
	);
INSERT INTO VW_TRADICIONALISTAS VALUES ('testInsert2', '430.289.226-12', 'TRADICIONALISTA');

COMMIT;

SELECT * FROM vw_tradicionalistas;
/* Resultado da view ap�s inser��es
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
testInsert2	430.289.226-12	TRADICIONALISTA 
*/
SELECT * FROM faccao;
/* Tabela inteira apos as inser��es
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
testInsert	400.289.226-12	PROGRESSITA
testInsert2	430.289.226-12	TRADICIONALISTA
 
*/

DROP VIEW vw_tradicionalistas;

/* b) A segunda view n�o deve permitir fac��es diferentes de tradicionalistas. Fa�a testes como no
item anterior. */
CREATE VIEW vw_tradicionalistas AS
	SELECT NOME, LIDER, IDEOLOGIA FROM FACCAO WHERE IDEOLOGIA = 'TRADICIONALISTA'
WITH CHECK OPTION;

SELECT * FROM vw_tradicionalistas; 
/* Resultado da view antes das inser��es
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
testInsert2	430.289.226-12	TRADICIONALISTA 
*/
INSERT INTO LIDER
	VALUES(
		'470.289.226-12', 'liderInsert', 'CIENTISTA', 
		'Imp�rio Dalek',
		'Kaleds Extermum'
	);
INSERT INTO VW_TRADICIONALISTAS VALUES ('testInsert3', '470.289.226-12', 'PROGRESSITA')
/*
SQL Error [1402] [44000]: ORA-01402: view WITH CHECK OPTION where-clause violation
Opera��o n�o permitida por conta do uso do check option
*/

INSERT INTO LIDER
	VALUES(
		'480.289.226-12', 'liderInsert', 'CIENTISTA', 
		'Imp�rio Dalek',
		'Kaleds Extermum'
	);
INSERT INTO VW_TRADICIONALISTAS VALUES ('testInsert4', '480.289.226-12', 'TRADICIONALISTA');
COMMIT;

SELECT * FROM VW_TRADICIONALISTAS;
/* resultado da view apos as inser��es
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
testInsert2	430.289.226-12	TRADICIONALISTA
testInsert4	480.289.226-12	TRADICIONALISTA
*/
SELECT * FROM FACCAO;
/* resultado na tabela apos as inser��es
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
testInsert	400.289.226-12	PROGRESSITA
testInsert2	430.289.226-12	TRADICIONALISTA
testInsert4	480.289.226-12	TRADICIONALISTA

Notamos a inser��o da tupla tradicionalista deu certo enquando a progressita deu errado
*/
DROP VIEW vw_tradicionalistas;

DELETE FROM FACCAO WHERE nome = 'testInsert';
DELETE FROM FACCAO WHERE nome = 'testInsert2';
DELETE FROM lider WHERE cpi = '400.289.226-12';
DELETE FROM lider WHERE cpi = '430.289.226-12';

--DELETE FROM FACCAO WHERE nome = 'testeInsert'; not needed
DELETE FROM FACCAO WHERE nome = 'testInsert4';
DELETE FROM lider WHERE cpi = '470.289.226-12';
DELETE FROM lider WHERE cpi = '480.289.226-12';

COMMIT;

/* 3) Crie uma view que armazene, para cada estrela orbitada por planeta, nome e coordenadas da
estrela, e id e classifica��o dos planetas que a orbitam. */

/* Insercoes na tabela ESTRELA */
INSERT INTO ESTRELA 
	VALUES ('GA1', 'Estrela principal', 'Gigante branca', 10.5, -3.03, 1.38, 4.94);

INSERT INTO ESTRELA 
	VALUES ('SK20', 'D-5-GAMMA', 'ana vermelha', 0.1221, 3.03, -0.09, 3.16);

/* Insercoes na tabela PLANETA */
INSERT INTO PLANETA 
	VALUES ('Gallifrey', 1.75, 10.315, 'Planeta rochoso');
	
INSERT INTO PLANETA 
	VALUES ('Skaro', 5.07, 15.315, 'Planeta rochoso');

/* Insercoes na tabela ORBITA_PLANETA */
INSERT INTO ORBITA_PLANETA 
	VALUES ('Gallifrey', 'GA1', 278.447, 305.772, 675.354);
	
INSERT INTO ORBITA_PLANETA 
	VALUES ('Skaro', 'GA1', 101.711, 115.421, 250.368);

INSERT INTO ORBITA_PLANETA 
	VALUES ('Skaro', 'SK20', 101.711, 115.421, 250.368);

-- Criacao da view            
CREATE OR REPLACE VIEW VIEW_ORBITA_PLANETA (ESTRELA, E_COORD_X, E_COORD_Y, E_COORD_Z, PLANETA, P_CLASSIFICACAO) AS
    SELECT OP.ESTRELA, E.X, E.Y, E.Z, OP.PLANETA, P.CLASSIFICACAO
    FROM ESTRELA E JOIN ORBITA_PLANETA OP
        ON E.ID_ESTRELA = OP.ESTRELA
        JOIN PLANETA P
            ON OP.PLANETA = P.ID_ASTRO;
            
SELECT * FROM VIEW_ORBITA_PLANETA;

/* a) A view � atualiz�vel? Fa�a testes e explique considerando a teoria e os resultados dos testes. */

-- Insercao de orbita: estrela nova e planeta existente
INSERT INTO view_orbita_planeta
    VALUES ('GA2', -4.58, 5.8, 7.4, Gallifrey, 'Planeta rochoso');
    
    -- Insercao de orbita: estrela existente e planeta novo
INSERT INTO view_orbita_planeta
    VALUES ('GA1', -3.03, 1.38, 4.94, Saturno, 'Planeta rochoso');

/*  Ao tentar executar as inser��es acima, o seguinte erro � exibido:

Erro a partir da linha : 117 no comando -
INSERT INTO view_orbita_planeta
    VALUES ('GA2', -4.58, 5.8, 7.4, Gallifrey, 'Planeta rochoso')
Erro na Linha de Comandos : 118 Coluna : 37
Relat�rio de erros -
Erro de SQL: ORA-00984: coluna n�o permitida aqui
00984. 00000 -  "column not allowed here"
*Cause:    
*Action:

Erro a partir da linha : 121 no comando -
INSERT INTO view_orbita_planeta
    VALUES ('GA1', -3.03, 1.38, 4.94, Saturno, 'Planeta rochoso')
Erro na Linha de Comandos : 122 Coluna : 39
Relat�rio de erros -
Erro de SQL: ORA-00984: coluna n�o permitida aqui
00984. 00000 -  "column not allowed here"
*Cause:    
*Action: */

/*  Isso ocorre pois a view n�o � atualiz�vel, uma vez que para cada tupla das tabelas base pode haver mais de 1 tupla correspondente na vis�o.
    Ou seja, n�o h� preserva��o de chave.
    Por exemplo, podemos observar no resultado da consulta que a estrela 'GA1' e o planeta 'Skaro' aparecem 2 vezes, pois uma estrela pode ser orbitada por mais de 1 planeta e um planeta pode orbitar mais de 1 estrela. */

/* b) Usando a view, fa�a uma consulta que retorne a quantidade de planetas que orbita cada
estrela. */

SELECT ESTRELA, COUNT(*) AS QTD_PLANETAS FROM VIEW_ORBITA_PLANETA
GROUP BY(ESTRELA);


/* 4) Crie uma view que armazene, para cada lider: CPI, nome, cargo, sua na��o e respectiva federa��o,
sua esp�cie e respectivo planeta de origem. */
/* a) A view � atualiz�vel? Explique. */

CREATE VIEW vw_lider_nacao_especie as
	SELECT l.cpi, l.nome, l.cargo, l.NACAO, n.FEDERACAO, l.especie, e.PLANETA_OR  
	FROM lider l, NACAO n, ESPECIE e  
	WHERE l.NACAO = n.NOME AND l.ESPECIE = e.NOME; 
/*
� parcialmente atualizavel, apenas a tabela lider pode ser atualizada por conta 
da preserva��o de chave, pois essa � a unica que para cada tupla da tabela base
h� apenas 1 correspondente na view, afinal na��o e especie podem ser as mesmas 
da de outros lideres 
*/

/* b) Fa�a opera��es de inser��o, atualiza��o e remo��o na view. Explique o efeito de cada
opera��o nas tabelas base. */
INSERT INTO vw_lider_nacao_especie
	VALUES ('123.456.789-00', 'Sec', 'CIENTISTA', 'Gallyos', 'Homo Tempus', 'tempo', 'Gallifrey');

/*
SQL Error [1776] [42000]: ORA-01776: cannot modify more than one base table through a join view

O resultado dessa inser��o � o erro apresentado acima, que ocorre pois estamos 
tentando inserir valores na tabela lider (editavel) entretanto tamb�m tentamos
inserir valores nas tabelas de esp�cie e na��o, que nesse caso s�o n�o editaveis 
*/

INSERT INTO vw_lider_nacao_especie (CPI, NOME, CARGO, NACAO, ESPECIE)
	VALUES ('123.456.789-00', 'Sec', 'CIENTISTA', 'Gallyos', 'Homo Tempus');

SELECT * FROM vw_lider_nacao_especie;
/*
408.540.985-55	Davros	CIENTISTA 	Imp�rio Dalek	Kaleds Extermum	obscuros	Skaro
123.543.908-12	Borusa	OFICIAL   	Gallyos	Homo    Tempus	        tempo	    Gallifrey
123.456.789-00	Sec	    CIENTISTA 	Gallyos	Homo    Tempus	        tempo	    Gallifrey

Como podemos ver na query acima, apesar da inser��o ser semelhante a feita anteriormente
apenas sem os valores de federa��o e planeta de origem dessa vez n�o obtemos nenhum erro
e o valor inserido aparece na tabela. ao se fazer uma consulta.
*/

UPDATE VW_LIDER_NACAO_ESPECIE 
	SET CARGO = 'COMANDANTE',NOME = 'Alfred', PLANETA_OR = 'Skaro'
	WHERE CPI = '123.456.789-00';

UPDATE VW_LIDER_NACAO_ESPECIE 
	SET CARGO = 'COMANDANTE',NOME = 'Alfred', FEDERACAO = 'obscuros'
	WHERE CPI = '123.456.789-00';

/*
SQL Error [1776] [42000]: ORA-01776: cannot modify more than one base table through a join view

Para ambos os updates observamos o erro acima, que acontece ao tentarmos modificar algo referente
as tabelas de esp�cia ou na��o, que como j� mencionadas s�o n�o editaveis nesse caso em quest�o   
*/

UPDATE VW_LIDER_NACAO_ESPECIE 
	SET CARGO = 'COMANDANTE',NOME = 'Alfred'
	WHERE CPI = '123.456.789-00';

SELECT * FROM vw_lider_nacao_especie WHERE CPI='123.456.789-00';

/*
123.456.789-00	Alfred	COMANDANTE	Gallyos	Homo Tempus	tempo	Gallifrey

Diferentemente dos outros updates feitos, esse altera apenas dados da tabela lider
que � editavel, portanto � bem sucedida, como podemos ver no resultado da consulta.
*/

DELETE FROM VW_LIDER_NACAO_ESPECIE WHERE CPI='123.456.789-00' AND PLANETA_OR = 'Gallifrey' and FEDERACAO='tempo';

SELECT * FROM vw_lider_nacao_especie;
/*
408.540.985-55	Davros	CIENTISTA 	Imp�rio Dalek	Kaleds Extermum	obscuros	Skaro
123.543.908-12	Borusa	OFICIAL   	Gallyos			Homo Tempus		tempo		Gallifrey

Como podemos ver pela consulta, apesar de usarmos dados de tabelas n�o atualizaveis
o delete foi bem sucedido, isso decorre do comportamento do delete, que realiza a 
opera��o na tabela com preserva��o de chave, independentemente se usamos ou n�o
dados de tabelas n�o atualizaveis.
*/
    
/* 5) Crie uma view que armazene, para cada fac��o: nome da fac��o, CPI e nome do lider, e ideologia. */

-- Cria��o da view
CREATE OR REPLACE VIEW VIEW_FACCAO_IDEOLOGIA (FACCAO, LIDER_CPI, LIDER_NOME, IDEOLOGIA) AS
    SELECT F.NOME, F.LIDER, L.NOME, F.IDEOLOGIA
    FROM FACCAO F JOIN LIDER L
    ON F.LIDER = L.CPI;
    
SELECT * FROM VIEW_FACCAO_IDEOLOGIA;

/* a) A view � atualiz�vel? Explique. */

/*  Sim, a view_faccao_ideologia � atualiz�vel, pois para cada tupla das tabelas base h� 1 tupla correspondente na vis�o.
    Isso ocorre devido � semantica e relacionamento entre as tabelas faccao e lider, j� que cada faccao deve ter um �nico l�der e um l�der pode participar apenas de 1 faccao.
    Sendo assim, apesar de a view conter jun��es, ela � atualiz�vel. */
      
/* b) Fa�a opera��es de inser��o, atualiza��o e remo��o na view. Explique o efeito de cada
opera��o nas tabelas base. */

/* Tentativa de insercao utilizando a view_faccao_ideologia */
INSERT INTO VIEW_FACCAO_IDEOLOGIA (FACCAO, LIDER_CPI)
    VALUES('Daleks', '408.540.985-55');
/* Obtemos sucesso nessa inser��o, a nova faccao 'Daleks' � inserida na tabela base Faccao e esse valor passa a aparecer nos resultados de sele��o da view. */

/* Tentativa de update utilizando a view_faccao_ideologia */
UPDATE VIEW_FACCAO_IDEOLOGIA
    SET IDEOLOGIA = 'PROGRESSITA'
    WHERE FACCAO = 'Daleks';

UPDATE VIEW_FACCAO_IDEOLOGIA
    SET LIDER_NOME = 'Devros'
    WHERE FACCAO = 'Daleks';
/*  Tamb�m obtemos sucesso nos 2 updates acima.
    Note que, no primeiro, atualizamos uma tupla da tabela Faccao, sendo o atributo ideologia da faccao 'Daleks' que recebeu o valor 'PROGRESSITA'.
    J� no segundo update, atualizamos uma tupla da tabela Lider, trocando o nome do l�der da faccao 'Daleks', que era 'Davros' para 'Devros'.
    Em ambos obtivemos sucesso e os valores foram atualizados nas tabelas base, justamente gra�as a preserva��o de chave. */
  
DELETE FROM VIEW_FACCAO_IDEOLOGIA
WHERE LIDER_NOME = 'Devros';
/*  Novamente, obtemos sucesso e a faccao cujo nome do lider � 'Devros' (faccao 'Daleks') foi exclu�da da tabela Faccao.
    Entretanto, o l�der 'Devros' contia na tabela Lider. */
    
/* 6) Crie pelo menos 1 vis�o materializada de cada tipo principal: com jun��o, com agrega��o, e
aninhada. Para a cria��o das vis�es, pesquise e use diferentes par�metros de: momento em que a
vis�o � efetivamente populada (ex: build immediate), tipo de refresh (ex: refresh fast) e
momento em que o refresh � realizado (ex: on commit). */
CREATE MATERIALIZED VIEW VW_LIDER_ESPECIE  
	BUILD IMMEDIATE AS 
	SELECT L.CPI, L.NOME, L.NACAO, L.ESPECIE, E.PLANETA_OR AS ESPECIE_ORIGEM, F.NOME AS FACCAO
	FROM LIDER L JOIN ESPECIE E
	ON L.ESPECIE = E.NOME 
    	LEFT JOIN FACCAO F
    	ON L.CPI = F.LIDER;
    
DROP MATERIALIZED VIEW VW_LIDER_ESPECIE;

CREATE MATERIALIZED VIEW log ON ESPECIE WITH ROWID (NOME, PLANETA_OR) INCLUDING NEW VALUES;
-- DROP MATERIALIZED VIEW log ON especie;
CREATE MATERIALIZED VIEW vw_planeta_qtdEspecie
refresh fast ON COMMIT as
SELECT e.PLANETA_OR, count(*) 
	FROM ESPECIE e GROUP BY PLANETA_OR;

-- DROP VIEW VW_PLANETA_QTDESPECIE;
CREATE MATERIALIZED VIEW vw_orbita
BUILD DEFERRED refresh complete ON DEMAND AS 
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
        WHERE OP.ESTRELA = E.ID_ESTRELA)
	)
    AND E.ID_ESTRELA  != 'ALF CMa C';





