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

/* b) A segunda view não deve permitir facções diferentes de tradicionalistas. Faça testes como no
item anterior. */


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
/* b) Faça operações de inserção, atualização e remoção na view. Explique o efeito de cada
operação nas tabelas base. */
    
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
momento em que o refresh é realizado (ex: on commit). */