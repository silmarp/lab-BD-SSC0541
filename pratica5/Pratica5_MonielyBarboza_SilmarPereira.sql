/*
SCC0541 - Laboratório de Base de Dados
Prática 05 - Views
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/* 1) Crie uma view não atualizável que armazene, para todas as facções progressistas, nome da facção e
CPI do líder. */

/* Insercoes na tabela LIDER */
INSERT INTO LIDER
	VALUES('123.543.908-12', 'Borusa', 'COMANDANTE', 'Non eius in.', 'Odio ex in');

/* Insercoes na tabela FACCAO */
INSERT INTO FACCAO (NOME, LIDER, IDEOLOGIA)
	VALUES('Senhor do tempo', '123.543.908-12', 'PROGRESSITA');
/* PS: Há um erro de digtação na criação do esquema. Está 'PROGRESSITA' ao inves de 'PROGRESSISTA' */

-- Criação da view
CREATE OR REPLACE VIEW VIEW_FACCAO AS
    SELECT NOME, LIDER
    FROM FACCAO
    WHERE IDEOLOGIA = 'PROGRESSITA'
    WITH READ ONLY;
    
/*  Note que, sem a cláusula 'WITH READ ONLY', está view seria atualizável.
    Por isso, inserimos essa cláusula, a fim de garanter que ela seja não atualizável
    Com isso, apenas oprações de seleção são possíveis. */
    
/* a) Usando a view, faça uma consulta que retorne o número de facções progressistas; */

SELECT COUNT(*) FROM VIEW_FACCAO;

/* b) Usando a view, teste uma operação de inserção. Explique o resultado. */

/* Nova insercao na tabela LIDER */
INSERT INTO LIDER
	VALUES('408.540.985-55', 'Davros', 'CIENTISTA', 'Facilis illo.', 'Illo fugit');

/* Tentativa de inserao utilizando a view_faccao */
INSERT INTO VIEW_FACCAO
    VALUES('Daleks', '408.540.985-55');

/* Ao tentar realizar essa inserção, o seguinte erro é exibido:

Erro a partir da linha : 34 no comando -
INSERT INTO VIEW_FACCAO
    VALUES('Daleks', '408.540.985-55')
Erro na Linha de Comandos : 34 Coluna : 1
Relatório de erros -
Erro de SQL: ORA-42399: não é possível efetuar uma operação de DML em uma view somente para leitura
42399.0000 - "cannot perform a DML operation on a read-only view"

Isso ocorre pois na criação da view incluímos a cláusula 'WITH READ ONLY', tornando-a não atualizável. */

/* Abaixo, criaremos a view sem a cláusula 'WITH READ ONLY' e tentaremos realizar uma operação de inserção: */

DELETE FROM FACCAO WHERE NOME = 'Daleks';

-- Criação da view atualizável
CREATE OR REPLACE VIEW VIEW_FACCAO AS
    SELECT NOME, LIDER
    FROM FACCAO
    WHERE IDEOLOGIA = 'PROGRESSITA';

/* Tentativa de inserao utilizando a view_faccao */
INSERT INTO VIEW_FACCAO
    VALUES('Daleks', '408.540.985-55');
    
/* Dessa forma, a view se torna atualizável e é possível executar a inserção. */


/* 2) Crie duas views atualizáveis que armazenem, para todas as facções tradicionalistas, nome da facção,
CPI do líder e a ideologia, da seguinte maneira:
a) A primeira view deve permitir a inserção de facções não tradicionalistas. Insira na view
facções tradicionalistas e não tradicionalistas (efetive com commit). Mostre o resultado na
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
		'Império Dalek',
		'Kaleds Extermum'
	);
INSERT INTO VW_TRADICIONALISTAS VALUES ('testInsert', '400.289.226-12', 'PROGRESSITA')

INSERT INTO LIDER
	VALUES(
		'430.289.226-12', 'liderInsert', 'CIENTISTA', 
		'Império Dalek',
		'Kaleds Extermum'
	);
INSERT INTO VW_TRADICIONALISTAS VALUES ('testInsert2', '430.289.226-12', 'TRADICIONALISTA');

COMMIT;

SELECT * FROM vw_tradicionalistas;
/* Resultado da view após inserções
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
testInsert2	430.289.226-12	TRADICIONALISTA 
*/
SELECT * FROM faccao;
/* Tabela inteira apos as inserções
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
testInsert	400.289.226-12	PROGRESSITA
testInsert2	430.289.226-12	TRADICIONALISTA
 
*/

DROP VIEW vw_tradicionalistas;

/* b) A segunda view não deve permitir facções diferentes de tradicionalistas. Faça testes como no
item anterior. */
CREATE VIEW vw_tradicionalistas AS
	SELECT NOME, LIDER, IDEOLOGIA FROM FACCAO WHERE IDEOLOGIA = 'TRADICIONALISTA'
WITH CHECK OPTION;

SELECT * FROM vw_tradicionalistas; 
/* Resultado da view antes das inserções
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
testInsert2	430.289.226-12	TRADICIONALISTA 
*/
INSERT INTO LIDER
	VALUES(
		'470.289.226-12', 'liderInsert', 'CIENTISTA', 
		'Império Dalek',
		'Kaleds Extermum'
	);
INSERT INTO VW_TRADICIONALISTAS VALUES ('testInsert3', '470.289.226-12', 'PROGRESSITA')
/*
SQL Error [1402] [44000]: ORA-01402: view WITH CHECK OPTION where-clause violation
Operação não permitida por conta do uso do check option
*/

INSERT INTO LIDER
	VALUES(
		'480.289.226-12', 'liderInsert', 'CIENTISTA', 
		'Império Dalek',
		'Kaleds Extermum'
	);
INSERT INTO VW_TRADICIONALISTAS VALUES ('testInsert4', '480.289.226-12', 'TRADICIONALISTA');
COMMIT;

SELECT * FROM VW_TRADICIONALISTAS;
/* resultado da view apos as inserções
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
testInsert2	430.289.226-12	TRADICIONALISTA
testInsert4	480.289.226-12	TRADICIONALISTA
*/
SELECT * FROM FACCAO;
/* resultado na tabela apos as inserções
tempo	123.543.908-12	TRADICIONALISTA
Daleks	408.540.985-55	TRADICIONALISTA
testInsert	400.289.226-12	PROGRESSITA
testInsert2	430.289.226-12	TRADICIONALISTA
testInsert4	480.289.226-12	TRADICIONALISTA

Notamos a inserção da tupla tradicionalista deu certo enquando a progressita deu errado
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
estrela, e id e classificação dos planetas que a orbitam. */

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

/* a) A view é atualizável? Faça testes e explique considerando a teoria e os resultados dos testes. */

-- Insercao de orbita: estrela nova e planeta existente
INSERT INTO view_orbita_planeta
    VALUES ('GA2', -4.58, 5.8, 7.4, Gallifrey, 'Planeta rochoso');
    
    -- Insercao de orbita: estrela existente e planeta novo
INSERT INTO view_orbita_planeta
    VALUES ('GA1', -3.03, 1.38, 4.94, Saturno, 'Planeta rochoso');

/*  Ao tentar executar as inserções acima, o seguinte erro é exibido:

Erro a partir da linha : 117 no comando -
INSERT INTO view_orbita_planeta
    VALUES ('GA2', -4.58, 5.8, 7.4, Gallifrey, 'Planeta rochoso')
Erro na Linha de Comandos : 118 Coluna : 37
Relatório de erros -
Erro de SQL: ORA-00984: coluna não permitida aqui
00984. 00000 -  "column not allowed here"
*Cause:    
*Action:

Erro a partir da linha : 121 no comando -
INSERT INTO view_orbita_planeta
    VALUES ('GA1', -3.03, 1.38, 4.94, Saturno, 'Planeta rochoso')
Erro na Linha de Comandos : 122 Coluna : 39
Relatório de erros -
Erro de SQL: ORA-00984: coluna não permitida aqui
00984. 00000 -  "column not allowed here"
*Cause:    
*Action: */

/*  Isso ocorre pois a view não é atualizável, uma vez que para cada tupla das tabelas base pode haver mais de 1 tupla correspondente na visão.
    Ou seja, não há preservação de chave.
    Por exemplo, podemos observar no resultado da consulta que a estrela 'GA1' e o planeta 'Skaro' aparecem 2 vezes, pois uma estrela pode ser orbitada por mais de 1 planeta e um planeta pode orbitar mais de 1 estrela. */

/* b) Usando a view, faça uma consulta que retorne a quantidade de planetas que orbita cada
estrela. */

SELECT ESTRELA, COUNT(*) AS QTD_PLANETAS FROM VIEW_ORBITA_PLANETA
GROUP BY(ESTRELA);


/* 4) Crie uma view que armazene, para cada lider: CPI, nome, cargo, sua nação e respectiva federação,
sua espécie e respectivo planeta de origem. */
/* a) A view é atualizável? Explique. */

CREATE VIEW vw_lider_nacao_especie as
    SELECT l.cpi, l.nome, l.cargo, l.NACAO, l.especie, n.FEDERACAO, e.PLANETA_OR
        FROM lider l JOIN NACAO n ON l.NACAO = n.NOME
        JOIN ESPECIE e  ON l.ESPECIE = e.NOME;
/*
É parcialmente atualizavel, apenas a tabela lider pode ser atualizada por conta 
da preservação de chave, pois essa é a unica que para cada tupla da tabela base
há apenas 1 correspondente na view, afinal nação e especie podem ser as mesmas 
da de outros lideres 
*/

/* b) Faça operações de inserção, atualização e remoção na view. Explique o efeito de cada
operação nas tabelas base. */
INSERT INTO vw_lider_nacao_especie
	VALUES ('123.456.789-00', 'Bruce', 'CIENTISTA', 'Gallyos', 'Homo Tempus', 'tempo', 'Gallifrey');

/*
SQL Error [1776] [42000]: ORA-01776: cannot modify more than one base table through a join view

O resultado dessa inserção é o erro apresentado acima, que ocorre pois estamos 
tentando inserir valores na tabela editavel lider, por ter preservação de 
chave entretanto também tentamos inserir valores nas tabelas de espécie e
nação, que nesse caso são não editaveis 
*/

INSERT INTO vw_lider_nacao_especie (CPI, NOME, CARGO, NACAO, ESPECIE)
	VALUES ('123.456.789-00', 'Bruce', 'CIENTISTA', 'Gallyos', 'Homo Tempus');

SELECT * FROM vw_lider_nacao_especie;
/*
408.540.985-55	Davros	CIENTISTA 	Império Dalek	Kaleds Extermum	obscuros	Skaro
123.543.908-12	Borusa	OFICIAL   	Gallyos	Homo    Tempus	        tempo	    Gallifrey
123.456.789-00	Bruce   CIENTISTA 	Gallyos	Homo    Tempus	        tempo	    Gallifrey

Como podemos ver na query acima, essa inserção funciona, pois apesar de ser 
semelhante a feita anteriormente ela não possui valores de federação e planeta
de origem assim, não tenta inserir nada em tabelas que não são editaveis.
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
as tabelas de espécia ou nação, que como já mencionadas são não editaveis e portanto
não podemos fazer updates.
*/

UPDATE VW_LIDER_NACAO_ESPECIE 
	SET CARGO = 'COMANDANTE',NOME = 'Alfred'
	WHERE CPI = '123.456.789-00';

SELECT * FROM vw_lider_nacao_especie WHERE CPI='123.456.789-00';

/*
123.456.789-00	Alfred	COMANDANTE	Gallyos	Homo Tempus	tempo	Gallifrey

Diferentemente dos outros updates feitos, esse altera apenas dados da tabela lider
que é editavel, portanto é bem sucedida, como podemos ver no resultado da consulta.
*/

DELETE FROM VW_LIDER_NACAO_ESPECIE WHERE CPI='123.456.789-00' AND PLANETA_OR = 'Gallifrey' and FEDERACAO='tempo';

SELECT * FROM vw_lider_nacao_especie;
/*
408.540.985-55	Davros	CIENTISTA 	Império Dalek	Kaleds Extermum	obscuros	Skaro
123.543.908-12	Borusa	OFICIAL   	Gallyos			Homo Tempus		tempo		Gallifrey

Como podemos ver pela consulta, apesar de usarmos dados de tabelas não atualizaveis
o delete foi bem sucedido, isso decorre do comportamento do delete, que realiza a 
operação na tabela com preservação de chave, independentemente se usamos ou não
dados de tabelas não atualizaveis para fazermos a query.
*/
    
/* 5) Crie uma view que armazene, para cada facção: nome da facção, CPI e nome do lider, e ideologia. */

-- Criação da view
CREATE OR REPLACE VIEW VIEW_FACCAO_IDEOLOGIA (FACCAO, LIDER_CPI, LIDER_NOME, IDEOLOGIA) AS
    SELECT F.NOME, F.LIDER, L.NOME, F.IDEOLOGIA
    FROM FACCAO F JOIN LIDER L
    ON F.LIDER = L.CPI;
    
SELECT * FROM VIEW_FACCAO_IDEOLOGIA;

/* a) A view é atualizável? Explique. */

/*  Sim, a view_faccao_ideologia é atualizável, pois para cada tupla das tabelas base há 1 tupla correspondente na visão.
    Isso ocorre devido à semantica e relacionamento entre as tabelas faccao e lider, já que cada faccao deve ter um único líder e um líder pode participar apenas de 1 faccao.
    Sendo assim, apesar de a view conter junções, ela é atualizável. */
      
/* b) Faça operações de inserção, atualização e remoção na view. Explique o efeito de cada
operação nas tabelas base. */

/* Tentativa de insercao utilizando a view_faccao_ideologia */
INSERT INTO VIEW_FACCAO_IDEOLOGIA (FACCAO, LIDER_CPI)
    VALUES('Daleks', '408.540.985-55');
/* Obtemos sucesso nessa inserção, a nova faccao 'Daleks' é inserida na tabela base Faccao e esse valor passa a aparecer nos resultados de seleção da view. */

/* Tentativa de update utilizando a view_faccao_ideologia */
UPDATE VIEW_FACCAO_IDEOLOGIA
    SET IDEOLOGIA = 'PROGRESSITA'
    WHERE FACCAO = 'Daleks';

UPDATE VIEW_FACCAO_IDEOLOGIA
    SET LIDER_NOME = 'Devros'
    WHERE FACCAO = 'Daleks';
/*  Também obtemos sucesso nos 2 updates acima.
    Note que, no primeiro, atualizamos uma tupla da tabela Faccao, sendo o atributo ideologia da faccao 'Daleks' que recebeu o valor 'PROGRESSITA'.
    Já no segundo update, atualizamos uma tupla da tabela Lider, trocando o nome do líder da faccao 'Daleks', que era 'Davros' para 'Devros'.
    Em ambos obtivemos sucesso e os valores foram atualizados nas tabelas base, justamente graças a preservação de chave. */
  
DELETE FROM VIEW_FACCAO_IDEOLOGIA
WHERE LIDER_NOME = 'Devros';
/*  Novamente, obtemos sucesso e a faccao cujo nome do lider é 'Devros' (faccao 'Daleks') foi excluída da tabela Faccao.
    Entretanto, o líder 'Devros' contia na tabela Lider. */
    
/* 6) Crie pelo menos 1 visão materializada de cada tipo principal: com junção, com agregação, e
aninhada. Para a criação das visões, pesquise e use diferentes parâmetros de: momento em que a
visão é efetivamente populada (ex: build immediate), tipo de refresh (ex: refresh fast) e
momento em que o refresh é realizado (ex: on commit).

Usando build immediate que irá popular a view no momento de sua criação,
opção de refresh force que tenta um refresh fast se houver log, se não faz um
refresh complete e refresh on demand em uma view com junções  
*/
CREATE MATERIALIZED VIEW VW_LIDER_ESPECIE  
	BUILD IMMEDIATE 
	REFRESH FORCE ON DEMAND AS 
		SELECT E.NOME, E.PLANETA_OR, P.CLASSIFICACAO AS PLANETA_TIPO, OP.ESTRELA AS ESTRELA_ORBITADA 
			FROM ESPECIE E  JOIN PLANETA P
			ON E.PLANETA_OR = P.ID_ASTRO
			JOIN ORBITA_PLANETA OP 
			ON OP.PLANETA = E.PLANETA_OR;

-- DROP MATERIALIZED VIEW VW_LIDER_ESPECIE;

/*
Agora em uma consulta com agregação usando Build immediate, refresh fast on commit,
importante notar que para a possibilitar o uso do refresh fast necessitamos criar um
log da tabela e atributos que usaremos e esse log será usado para pupular a view, ademais
como usamos refresh on commit, a view terá refresh toda vez que for commitado uma alteração
nas tabelas usadas.
*/

CREATE MATERIALIZED VIEW log ON ESPECIE WITH ROWID (NOME, PLANETA_OR) INCLUDING NEW VALUES;
-- DROP MATERIALIZED VIEW log ON especie;
CREATE MATERIALIZED VIEW vw_planeta_qtdEspecie
refresh fast ON COMMIT as
SELECT e.PLANETA_OR, count(*) 
	FROM ESPECIE e GROUP BY PLANETA_OR;

-- DROP VIEW VW_PLANETA_QTDESPECIE;

/*
Na consulta aninhada de planetas ainda dominados, porem sem vida inteligente usamos Build 
defered, que fará a view ser populada no proximo refresh, com refresh complete, ou seja
a query é refeita e refresh on demand. 
*/
CREATE MATERIALIZED VIEW vw_orbita
BUILD DEFERRED 
refresh complete ON DEMAND AS 
SELECT p.ID_ASTRO FROM PLANETA p WHERE p.ID_ASTRO IN
	(SELECT D.PLANETA FROM DOMINANCIA D WHERE DATA_FIM IS NULL)
	MINUS 
	(SELECT e.PLANETA_OR FROM ESPECIE e WHERE e.INTELIGENTE = 'F');
