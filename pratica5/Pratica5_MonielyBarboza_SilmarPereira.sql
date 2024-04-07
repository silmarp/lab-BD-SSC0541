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

/* b) A segunda view n�o deve permitir fac��es diferentes de tradicionalistas. Fa�a testes como no
item anterior. */


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
/* b) Fa�a opera��es de inser��o, atualiza��o e remo��o na view. Explique o efeito de cada
opera��o nas tabelas base. */
    
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