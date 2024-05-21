/*
SCC0541 - Laboratorio de Base de Dados
Pratica 09 - PL/SQL � Procedimentos, Funcoes e Pacotes
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

set serveroutput on;

/* 1) Implemente uma fun��o que calcule a dist�ncia entre duas estrelas (pode ser dist�ncia
Euclididana). */

/* Ser� utilizada a distancia euclidiana dada por:
distancia = sqrt ( (X2 - X1)^2 + (Y2 - Y1)^2 + (Z2 - Z1)^2 )
*/

CREATE OR REPLACE FUNCTION calcula_distancia (
    p_estrela1 Estrela.Id_estrela%TYPE,
    p_estrela2 Estrela.Id_estrela%TYPE
) RETURN NUMBER IS
    
    CURSOR c_estrelas IS
        SELECT E.X, E.Y, E.Z
        FROM ESTRELA E
        WHERE E.ID_ESTRELA = p_estrela1 OR E.ID_ESTRELA = p_estrela2;
        
    TYPE t_estrela IS RECORD (
        coord_X Estrela.X%TYPE,
        coord_Y Estrela.Y%TYPE,
        coord_Z Estrela.Z%TYPE
    );
    TYPE t_tab_estrelas IS TABLE OF t_estrela;
    v_estrelas t_tab_estrelas := t_tab_estrelas();
    
    v_diferenca_X NUMBER;
    v_diferenca_Y NUMBER;
    v_diferenca_Z NUMBER;
    v_distancia NUMBER;
    
BEGIN
    v_estrelas.extend(2);
    OPEN c_estrelas;
    FOR i IN 1..2 LOOP
        FETCH c_estrelas INTO v_estrelas(i).coord_X, v_estrelas(i).coord_Y, v_estrelas(i).coord_Z;
        IF c_estrelas%NOTFOUND THEN RAISE NO_DATA_FOUND; END IF;
    END LOOP;
    
    CLOSE c_estrelas;
    
    v_diferenca_X := v_estrelas(2).coord_X - v_estrelas(1).coord_X;
    v_diferenca_Y := v_estrelas(2).coord_Y - v_estrelas(1).coord_Y;
    v_diferenca_Z := v_estrelas(2).coord_Z - v_estrelas(1).coord_Z;
    
    v_distancia := sqrt( (v_diferenca_X)**2 + (v_diferenca_Y)**2 + (v_diferenca_Z)**2 );

RETURN v_distancia;

EXCEPTION
    WHEN NO_DATA_FOUND THEN RAISE NO_DATA_FOUND;
        
END calcula_distancia;

DECLARE
    v_estrela1 Estrela.Id_estrela%TYPE;
    v_estrela2 Estrela.Id_estrela%TYPE;
    v_distancia NUMBER;
    
BEGIN
    v_estrela1 := 'Alp Oct';
    v_estrela2 := '29Pi  And';
    v_distancia := calcula_distancia(v_estrela1, v_estrela2);
    
    dbms_output.put_line('A distancia entre as estrelas "' || v_estrela1 || '" e "' || v_estrela2 || '" � ' || v_distancia);
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('Estrela nao encontrada');
END;

/* Resultado:
    v_estrela1 := 'Alp Oct';
    v_estrela2 := '29Pi  And';
A distancia entre as estrelas "Alp Oct" e "29Pi  And" � 205,938950049332855677777975828942337846

    v_estrela1 := 'Teste';
    v_estrela2 := '29Pi  And';
Estrela nao encontrada
*/

/*2) 
Implemente! a! seguinte! funcionalidade! relacionada! ao! usu�rio! L�der) de) Fac��o! do! Sistema!
Sociedade!Gal�tica!(ver!descri��o!do!projeto!final):
a. Gerenciamento:!!item!1.b!!(Remover'fac��o'de'Na��o)
*/

-- Inserts para testar
INSERT INTO NACAO (NOME) values('Mordor');

INSERT INTO ESPECIE (NOME) values('maiar');

INSERT INTO LIDER VALUES('222.444.666-88', 'Saruman', 'OFICIAL', 'Mordor', 'maiar'); -- lider de outra faccao

INSERT INTO LIDER VALUES('999.666.333-12', 'Sauron', 'COMANDANTE', 'Mordor', 'maiar'); -- lider da faccao

INSERT INTO FACCAO values('Nazgul', '999.666.333-12', 'TOTALITARIA', 1);

INSERT INTO NACAO_FACCAO values('Mordor', 'Nazgul');

CREATE OR REPLACE PACKAGE faccaoManager AS 
	-- Pacote para o item 1 das funcionalidades de gerenciamento
	e_notLider EXCEPTION;

	FUNCTION isLider (p_faccao FACCAO.NOME%TYPE, p_lider LIDER.CPI%TYPE) RETURN char;

	PROCEDURE remove_fac_nac (
		p_faccao FACCAO.NOME%TYPE,
		p_nacao NACAO.NOME%TYPE,
		p_lider LIDER.CPI%TYPE
	);
END faccaoManager;

/

CREATE OR REPLACE PACKAGE BODY faccaoManager AS

	PROCEDURE remove_fac_nac (
		p_faccao FACCAO.NOME%TYPE,
		p_nacao NACAO.NOME%TYPE,
		p_lider LIDER.CPI%TYPE
	) IS
	v_isLider char;
	BEGIN
		v_isLider := isLider(p_faccao, p_lider);
		
		IF v_isLider = 'F' THEN
			raise e_notLider;
		END IF;
		
		-- caso n�o caia no if continua
		DELETE FROM NACAO_FACCAO nf WHERE nf.NACAO = p_nacao AND nf.FACCAO = p_faccao;
	
		IF NOT SQL%FOUND THEN
			RAISE NO_DATA_FOUND;
		END IF;
		
		UPDATE FACCAO SET QTD_NACOES = QTD_NACOES - 1;
	
		COMMIT;
	
	END remove_fac_nac;

	--

	FUNCTION isLider (p_faccao FACCAO.NOME%TYPE, p_lider LIDER.CPI%TYPE) RETURN char is
		v_isLider char;
		v_count NUMBER;
	BEGIN
		SELECT count(*) INTO v_count FROM FACCAO f WHERE f.nome = p_faccao AND  f.LIDER = p_lider;
		v_isLider := 'F';
		
		IF v_count > 0 THEN
			v_isLider := 'V';
		END IF;
		
		RETURN v_isLider;
	END isLider;
END faccaoManager;

-- Testes
-- CPI dado N�O � lider da fac��o
DECLARE 
	v_nac NACAO.NOME%TYPE;
	v_fac FACCAO.NOME%TYPE;
	v_lider LIDER.CPI%TYPE;
BEGIN
	v_fac := 'Nazgul';
	v_nac := 'Mordor';
	v_lider := '222.444.666-88';
	faccaoManager.remove_fac_nac(v_fac, v_nac, v_lider);

	EXCEPTION 
		WHEN faccaoManager.e_notLider THEN
			dbms_output.put_line('O CPI recebido n�o � do lider de fac��o, ou facc��o n�o existe opera��o n�o permitida');
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('N�o h� mais na��es para Remover');	
END;

/* Resultado
O CPI recebido n�o � do lider de fac��o, ou facc��o n�o existe opera��o n�o permitida
*/

SELECT * FROM NACAO_FACCAO nf WHERE nf.NACAO = 'Mordor' AND nf.FACCAO = 'Nazgul';

/*
Mordor	Nazgul 
*/

-- CPI dado � lider da fac��o
DECLARE 
	v_nac NACAO.NOME%TYPE;
	v_fac FACCAO.NOME%TYPE;
	v_lider LIDER.CPI%TYPE;
BEGIN
	v_fac := 'Nazgul';
	v_nac := 'Mordor';
	v_lider := '999.666.333-12';
	faccaoManager.remove_fac_nac(v_fac, v_nac, v_lider);

	EXCEPTION 
		WHEN faccaoManager.e_notLider THEN
			dbms_output.put_line('O CPI recebido n�o � do lider de fac��o, ou facc��o n�o existe opera��o n�o permitida');
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('N�o h� mais na��es para Remover');	
END;

SELECT * FROM NACAO_FACCAO nf WHERE nf.NACAO = 'Mordor' AND nf.FACCAO = 'Nazgul';
/* Reultado da consulta

*/

DECLARE 
	v_nac NACAO.NOME%TYPE;
	v_fac FACCAO.NOME%TYPE;
	v_lider LIDER.CPI%TYPE;
BEGIN
	v_fac := 'Fellowship';
	v_nac := 'Mordor';
	v_lider := '999.666.333-12';
	-- Fac��o n�o existe
	faccaoManager.remove_fac_nac(v_fac, v_nac, v_lider);
	EXCEPTION 
		WHEN faccaoManager.e_notLider THEN
			dbms_output.put_line('O CPI recebido n�o � do lider de fac��o, ou facc��o n�o existe opera��o n�o permitida');
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('N�o h� mais na��es para Remover');	
END;
/*
 O CPI recebido n�o � do lider de fac��o, ou facc��o n�o existe opera��o n�o permitida
*/

-- n�o h� mais o que deletar
DECLARE 
	v_nac NACAO.NOME%TYPE;
	v_fac FACCAO.NOME%TYPE;
	v_lider LIDER.CPI%TYPE;
BEGIN
	v_fac := 'Nazgul';
	v_nac := 'Mordor';
	v_lider := '999.666.333-12';
	faccaoManager.remove_fac_nac(v_fac, v_nac, v_lider);
	EXCEPTION 
		WHEN faccaoManager.e_notLider THEN
			dbms_output.put_line('O CPI recebido n�o � do lider de fac��o, ou facc��o n�o existe opera��o n�o permitida');
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('N�o h� mais na��es para Remover');	
END;
/*
N�o h� mais na��es para Remover
*/
/* 3) Implemente a seguinte funcionalidade relacionada ao usu�rio Comandante do Sistema
Sociedade Gal�tica (ver descri��o do projeto final):
a. Gerenciamento: item 3.a.ii (Criar nova federa��o, com a pr�pria na��o)
*/

/*
Comandante � de uma nacao
Ele vai inserir uma nova federacao
Essa nova federacao passa a ser e federacao da nacao
Sea nacao j� tem federacao, update
Sen�o insert
*/

CREATE OR REPLACE PACKAGE PacoteComandante AS
    PROCEDURE insere_federacao (
        p_nacao Nacao.Nome%TYPE,
        p_federacao Federacao.Nome%TYPE,
        p_data_fundacao Federacao.Data_fund%TYPE DEFAULT TO_DATE(SYSDATE, 'dd/mm/yyyy')
    );
END PacoteComandante;

CREATE OR REPLACE PACKAGE BODY PacoteComandante AS 
    PROCEDURE insere_federacao (
        p_nacao Nacao.Nome%TYPE,
        p_federacao Federacao.Nome%TYPE,
        p_data_fundacao Federacao.Data_fund%TYPE DEFAULT TO_DATE(SYSDATE, 'dd/mm/yyyy')
    ) IS
        
        CURSOR c_federacao IS SELECT * FROM FEDERACAO F WHERE F.NOME = p_federacao;
        v_federacao Federacao%ROWTYPE;
         
        BEGIN
            OPEN c_federacao;
            IF c_federacao%FOUND THEN
                UPDATE NACAO SET FEDERACAO = p_federacao WHERE NOME = p_nacao;
            ELSE   
                INSERT INTO FEDERACAO VALUES (p_federacao, p_data_fundacao);
                UPDATE NACAO SET FEDERACAO = p_federacao WHERE NOME = p_nacao;                
            END IF;
    END insere_federacao;
END PacoteComandante;

/*
CREATE OR REPLACE PROCEDURE insere_federacao (
    p_nacao Nacao.Nome%TYPE,
    p_federacao Federacao.Nome%TYPE,
    p_data_fundacao Federacao.Data_fund%TYPE DEFAULT TO_DATE(SYSDATE, 'dd/mm/yyyy')
) IS
    CURSOR c_federacao IS SELECT * FROM FEDERACAO F WHERE F.NOME = p_federacao;
    v_federacao Federacao%ROWTYPE;
    
BEGIN
    OPEN c_federacao;
    IF c_federacao%FOUND THEN
        UPDATE NACAO SET FEDERACAO = p_federacao WHERE NOME = p_nacao;
    ELSE   
        INSERT INTO FEDERACAO VALUES (p_federacao, p_data_fundacao);
        UPDATE NACAO SET FEDERACAO = p_federacao WHERE NOME = p_nacao;
        
    END IF;
END insere_federacao;
*/

DECLARE
    v_nacao Nacao.Nome%TYPE;
    v_federacao Federacao.Nome%TYPE;
    
BEGIN
    v_nacao := 'Facilis illo.';
    v_federacao := 'Nova';
    PacoteComandante.insere_federacao(v_nacao, v_federacao);

    dbms_output.put_line('Federacao ' || v_federacao || ' associada � nacao ' || v_nacao);
END;

/*4) Implemente as seguines funcionalidades relacionadas ao usu�rio Cientista do Sistema Sociedade 
Gal�tica (ver descri��o do projeto final):  
*/
--a. Gerenciamento:  item 4.a (CRUD de estrelas) 
CREATE OR REPLACE PACKAGE starManager AS 
	e_idInvalido EXCEPTION;
	
	e_coordsInvalidas EXCEPTION;

	PROCEDURE createStar (
		p_id ESTRELA.ID_ESTRELA%TYPE,
		p_name ESTRELA.NOME%TYPE,
		p_class ESTRELA.CLASSIFICACAO%TYPE,
		p_massa ESTRELA.MASSA%TYPE,
		p_x ESTRELA.X%TYPE,
		p_y ESTRELA.Y%TYPE,
		p_z ESTRELA.Z%TYPE
	);

	FUNCTION readStar (p_id ESTRELA.ID_ESTRELA%TYPE) RETURN SYS_REFCURSOR;

	PROCEDURE updateStar (
		p_idPK ESTRELA.ID_ESTRELA%TYPE,
		p_name ESTRELA.NOME%TYPE,
		p_class ESTRELA.CLASSIFICACAO%TYPE,
		p_massa ESTRELA.MASSA%TYPE,
		p_x ESTRELA.X%TYPE,
		p_y ESTRELA.Y%TYPE,
		p_z ESTRELA.Z%TYPE
	);


	PROCEDURE deleteStar (
		p_idPK ESTRELA.ID_ESTRELA%TYPE
	);
	
END starManager;

/

CREATE OR REPLACE PACKAGE BODY starManager AS
	PROCEDURE createStar (
		p_id ESTRELA.ID_ESTRELA%TYPE,
		p_name ESTRELA.NOME%TYPE,
		p_class ESTRELA.CLASSIFICACAO%TYPE,
		p_massa ESTRELA.MASSA%TYPE,
		p_x ESTRELA.X%TYPE,
		p_y ESTRELA.Y%TYPE,
		p_z ESTRELA.Z%TYPE
	) IS
	BEGIN
		IF p_id IS null THEN
			raise e_idInvalido;
		ELSIF p_x IS NULL OR p_y IS NULL OR p_z IS null THEN 
			raise e_coordsInvalidas;
		END IF;
		
		INSERT INTO ESTRELA VALUES (p_id, p_name, p_class, p_massa, p_x, p_y, p_z);
	
		COMMIT;
	END createStar;

	FUNCTION readStar (p_id ESTRELA.ID_ESTRELA%TYPE) RETURN SYS_REFCURSOR AS
		c_star SYS_REFCURSOR;
	BEGIN
		OPEN c_star FOR
		SELECT * FROM ESTRELA e
			WHERE e.ID_ESTRELA = p_id;
		
		RETURN c_star;
	END readStar;

/*
A aplica��o ira exibir ao usuario todas as informa��es da estrela, o usuario poder�
modificar qualquer uma exeto o ID, ao chamar por um update ser� recebida todas as informa��es
da estrela, alteradas por usuario ou n�o alteradas, e o update ser� feito

Em caso de n�o haver mudan�a a ser feira, a aplica��o ser� responsavel por n�o chamar a fun��o
*/
	PROCEDURE updateStar (
		p_idPK ESTRELA.ID_ESTRELA%TYPE,
		p_name ESTRELA.NOME%TYPE,
		p_class ESTRELA.CLASSIFICACAO%TYPE,
		p_massa ESTRELA.MASSA%TYPE,
		p_x ESTRELA.X%TYPE,
		p_y ESTRELA.Y%TYPE,
		p_z ESTRELA.Z%TYPE
	) IS
	BEGIN
		UPDATE ESTRELA e SET e.NOME = p_name, e.CLASSIFICACAO  = p_class,
			e.MASSA = p_massa, e.X  = p_x,
			e.Y  = p_y, e.Z = p_z 
			WHERE e.ID_ESTRELA = p_idPK; 
		
		COMMIT;
	END updateStar;


	PROCEDURE deleteStar (
		p_idPK ESTRELA.ID_ESTRELA%TYPE
	)IS
	BEGIN
		DELETE FROM ESTRELA e WHERE e.ID_ESTRELA = p_idPK;
	
		IF NOT SQL%FOUND THEN
			RAISE NO_DATA_FOUND;
		END IF;
	
	COMMIT;
		
	END deleteStar;

END starManager;

-- Cria estrela valida
DECLARE 
	v_id ESTRELA.ID_ESTRELA%TYPE;
	v_nome ESTRELA.NOME%TYPE;
	v_class ESTRELA.CLASSIFICACAO%TYPE;
	v_mass ESTRELA.MASSA%TYPE;
	v_x ESTRELA.X%TYPE;
	v_y ESTRELA.Y%TYPE;
	v_z ESTRELA.Z%TYPE;
BEGIN
	v_id := 'C-ar3';
	v_nome := 'Canopus';
	v_class := 'P7';
	v_mass := 5.6454;
	v_x := 5423;
	v_y := 532.6566;
	v_z := 9768.1756;

	starManager.createStar(v_id, v_nome, v_class, v_mass, v_x, v_y, v_z);

	EXCEPTION 
		WHEN starManager.e_idInvalido THEN
			dbms_output.put_line('H� problemas no id recebido');
		WHEN starManager.e_coordsInvalidas THEN
			dbms_output.put_line('H� problemas nas coordenadas recebidas');
		WHEN OTHERS THEN  
			dbms_output.put_line('Erro nro:  ' || SQLCODE  
      	                     	|| '. Mensagem: ' || SQLERRM );
END;

SELECT * FROM estrela WHERE ID_ESTRELA = 'C-ar3';
/*
C-ar3	Canopus	P7	5.6454	5423	532.6566	9768.1756 
*/

-- Tenta criar estrela invalida
DECLARE 
	v_id ESTRELA.ID_ESTRELA%TYPE;
	v_nome ESTRELA.NOME%TYPE;
	v_class ESTRELA.CLASSIFICACAO%TYPE;
	v_mass ESTRELA.MASSA%TYPE;
	v_x ESTRELA.X%TYPE;
	v_y ESTRELA.Y%TYPE;
	v_z ESTRELA.Z%TYPE;
BEGIN
	v_id := 'C-ar3';
	v_nome := 'Canopus';
	v_class := 'P7';
	v_z := 9768.1756;

	starManager.createStar(v_id, v_nome, v_class, v_mass, v_x, v_y, v_z);
	
	EXCEPTION 
		WHEN starManager.e_idInvalido THEN
			dbms_output.put_line('H� problemas no id recebido');
		WHEN starManager.e_coordsInvalidas THEN
			dbms_output.put_line('H� problemas nas coordenadas recebidas');
		WHEN OTHERS THEN  
			dbms_output.put_line('Erro nro:  ' || SQLCODE  
      	                     	|| '. Mensagem: ' || SQLERRM );
END;

/*
H� problemas nas coordenadas recebidas
*/

-- L� estrela
DECLARE 
	c_star SYS_REFCURSOR;
	v_id ESTRELA.ID_ESTRELA%TYPE;

	v_nome ESTRELA.NOME%TYPE;
	v_class ESTRELA.CLASSIFICACAO%TYPE;
	v_mass ESTRELA.MASSA%TYPE;
	v_x ESTRELA.X%TYPE;
	v_y ESTRELA.Y%TYPE;
	v_z ESTRELA.Z%TYPE;
BEGIN
	v_id := 'C-ar3';
	c_star := starManager.readStar(v_id);
	FETCH c_star INTO
		v_id,
		v_nome,
		v_class,
		v_mass,
		v_x,
		v_y,
		v_z;

	CLOSE c_star;
	
	dbms_output.put_line('ID: '|| v_id || ' Nome: ' || v_nome || 
		' Classe: ' || v_class || ' Massa: '|| v_mass);
	

	EXCEPTION 
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('N�o foi possivel encontrar a estrela em quest�o');
		WHEN OTHERS THEN  
			dbms_output.put_line('Erro nro:  ' || SQLCODE  
      	                     	|| '. Mensagem: ' || SQLERRM );
END;

/*
ID: C-ar3 Nome: Canopus Classe: P7 Massa: 5.6454
*/

--testa update
DECLARE 
	v_id ESTRELA.ID_ESTRELA%TYPE;
	v_nome ESTRELA.NOME%TYPE;
	v_class ESTRELA.CLASSIFICACAO%TYPE;
	v_mass ESTRELA.MASSA%TYPE;
	v_x ESTRELA.X%TYPE;
	v_y ESTRELA.Y%TYPE;
	v_z ESTRELA.Z%TYPE;
BEGIN
	v_id := 'C-ar3';
	-- Mudamos o nome
	v_nome := 'Arakis';
	v_class := 'P7';
	v_mass := 5.6454;
	v_x := 5423;
	v_y := 532.6566;
	v_z := 9768.1756;
	
	starManager.updateStar(v_id, v_nome, v_class, v_mass, v_x, v_y, v_z);
END;

SELECT nome FROM estrela WHERE ID_ESTRELA = 'C-ar3';
/*
Arakis
*/

DECLARE
	v_id ESTRELA.ID_ESTRELA%TYPE;

BEGIN
	v_id := 'C-ar3';
	starManager.deleteStar(v_id);
	EXCEPTION 
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('N�o h� o que deletar');
		WHEN OTHERS THEN  
			dbms_output.put_line('Erro nro:  ' || SQLCODE  
      	                     	|| '. Mensagem: ' || SQLERRM );
END;

SELECT * FROM estrela WHERE ID_ESTRELA = 'C-ar3';

/*Resultado

*/

DECLARE
	v_id ESTRELA.ID_ESTRELA%TYPE;

BEGIN
	v_id := 'C-ar3543';
	starManager.deleteStar(v_id);
	EXCEPTION 
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('N�o h� o que deletar');
		WHEN OTHERS THEN  
			dbms_output.put_line('Erro nro:  ' || SQLCODE  
      	                     	|| '. Mensagem: ' || SQLERRM );
END;
/*
N�o h� o que deletar
*/

--b. Relat�rios: item 4.a (Informa��es de Estrelas, Planetas e Sistemas) 
CREATE OR REPLACE PACKAGE scienceReport AS 
	FUNCTION systemReport() RETURN SYS_REFCURSOR;
	FUNCTION planetReport() RETURN SYS_REFCURSOR;
	FUNCTION starReport() RETURN SYS_REFCURSOR;
END scienceReport;

/

CREATE OR REPLACE PACKAGE BODY scienceReport AS

/*
Report contem estrela principal do sistema, estrelas que orbitam a principal, e planetas que orbitam ou
a principal ou alguma das estrelas orbitantes. 
*/
FUNCTION systemReport() RETURN SYS_REFCURSOR AS
	c_report SYS_REFCURSOR;
BEGIN 
	OPEN c_report FOR
	SELECT s.ESTRELA, s.nome, oe.ORBITANTE, op.PLANETA 
		FROM SISTEMA s LEFT JOIN ORBITA_ESTRELA oe ON s.ESTRELA = oe.ORBITADA 
		LEFT JOIN ORBITA_PLANETA op ON op.ESTRELA = s.ESTRELA OR op.ESTRELA = oe.ORBITANTE;
		
	RETURN c_report;
END systemReport();

/*
 Contem cada planeta e suas informa��es, e a estrela que o orbita se orbitar
 Caso n�o orbite nenhuma estrela na aplica��o ser� dito que � um planeta errante
 */
FUNCTION planetReport() RETURN SYS_REFCURSOR AS
	c_report SYS_REFCURSOR;
BEGIN 
	OPEN c_report FOR
		SELECT p.ID_ASTRO, p.MASSA, p.RAIO, p.CLASSIFICACAO FROM PLANETA p LEFT JOIN ORBITA_PLANETA op ON op.PLANETA = p.ID_ASTRO;
		
	RETURN c_report;
END planetReport();


/*
 Contem informa��es de cada estrela, e se tem planetas que a orbitam 
*/
FUNCTION starReport() RETURN SYS_REFCURSOR AS
	c_report SYS_REFCURSOR;
BEGIN 
	OPEN c_report FOR
		SELECT e.ID_ESTRELA, e.NOME, e.CLASSIFICACAO, e.MASSA, e.X, e.Y, e.Z, op.PLANETA
			FROM ESTRELA e LEFT JOIN ORBITA_PLANETA op ON e.ID_ESTRELA  = op.ESTRELA; 
		
	RETURN c_report;
END starReport();

END scienceReport;
