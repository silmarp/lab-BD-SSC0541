/*
SCC0541 - Laboratorio de Base de Dados
Pratica 09 - PL/SQL - Procedimentos, Funcoes e Pacotes
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

set serveroutput on;

/* 1) Implemente uma funcao que calcule a distancia entre duas estrelas (pode ser distancia
Euclididana).
*/

/* Sera utilizada a distancia euclidiana dada por:
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

-- TESTES
-- Caso 1: Todos os dados validos
DECLARE
    v_estrela1 Estrela.Id_estrela%TYPE;
    v_estrela2 Estrela.Id_estrela%TYPE;
    v_distancia NUMBER;
BEGIN
    v_estrela1 := 'Alp Oct';
    v_estrela2 := '29Pi  And';
    v_distancia := calcula_distancia(v_estrela1, v_estrela2);
    dbms_output.put_line('A distancia entre as estrelas "' || v_estrela1 || '" e "' || v_estrela2 || '" eh ' || v_distancia);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Estrela nao encontrada');
END;

-- Caso 2: Estrela inexistente
DECLARE
    v_estrela1 Estrela.Id_estrela%TYPE;
    v_estrela2 Estrela.Id_estrela%TYPE;
    v_distancia NUMBER;
    
BEGIN
    v_estrela1 := 'Alp Oct';
    v_estrela2 := 'Teste';
    v_distancia := calcula_distancia(v_estrela1, v_estrela2);
    
    dbms_output.put_line('A distancia entre as estrelas "' || v_estrela1 || '" e "' || v_estrela2 || '" eh ' || v_distancia);
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('Estrela nao encontrada');
END;


/* 2) Implemente a seguinte funcionalidade relacionada ao usuario Lider de Faccao do Sistema
Sociedade Galatica (ver descricao do projeto final):
a. Gerenciamento: item 1.b (Remover faccao de Nacao)
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
		
		-- caso não caia no if continua
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
-- CPI dado NÃO é lider da facção
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
			dbms_output.put_line('O CPI recebido não é do lider de facção, ou faccção não existe operação não permitida');
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('Não há mais nações para Remover');	
END;

/* Resultado
O CPI recebido não é do lider de facção, ou faccção não existe operação não permitida
*/

SELECT * FROM NACAO_FACCAO nf WHERE nf.NACAO = 'Mordor' AND nf.FACCAO = 'Nazgul';

/*
Mordor	Nazgul 
*/

-- CPI dado é lider da facção
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
			dbms_output.put_line('O CPI recebido não é do lider de facção, ou faccção não existe operação não permitida');
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('Não há mais nações para Remover');	
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
	-- Facção não existe
	faccaoManager.remove_fac_nac(v_fac, v_nac, v_lider);
	EXCEPTION 
		WHEN faccaoManager.e_notLider THEN
			dbms_output.put_line('O CPI recebido não é do lider de facção, ou faccção não existe operação não permitida');
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('Não há mais nações para Remover');	
END;
/*
 O CPI recebido não é do lider de facção, ou faccção não existe operação não permitida
*/

-- não há mais o que deletar
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
			dbms_output.put_line('O CPI recebido não é do lider de facção, ou faccção não existe operação não permitida');
		WHEN NO_DATA_FOUND THEN
			dbms_output.put_line('Não há mais nações para Remover');	
END;
/*
Não há mais nações para Remover
*/

/* 3) Implemente a seguinte funcionalidade relacionada ao usuario Comandante do Sistema
Sociedade Galatica (ver descricao do projeto final):
a. Gerenciamento: item 3.a.ii (Criar nova federacao, com a propria nacao)
*/

CREATE OR REPLACE PACKAGE PacoteComandante AS
	e_notComandante EXCEPTION;
    e_atrib_notnull EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_atrib_notnull, -01400);
    PRAGMA EXCEPTION_INIT(e_notComandante, +100);

    FUNCTION isComandante (p_lider Lider.CPI%TYPE) RETURN Lider%ROWTYPE;
        
    PROCEDURE insertFederacao (
        p_lider Lider.CPI%TYPE,
        p_federacao_nome Federacao.Nome%TYPE,
        p_federacao_dt_fund Federacao.DATA_FUND%TYPE DEFAULT TO_DATE(SYSDATE, 'dd/mm/yyyy')
    );
END PacoteComandante;

/

CREATE OR REPLACE PACKAGE BODY PacoteComandante AS

    FUNCTION isComandante (
        p_lider Lider.CPI%TYPE
    ) RETURN Lider%ROWTYPE IS
        v_lider Lider%ROWTYPE;
        BEGIN 
            v_lider := NULL;
            SELECT * INTO v_lider FROM Lider L WHERE L.CPI = p_lider AND L.CARGO = 'COMANDANTE';
            IF SQL%NOTFOUND THEN RAISE e_notComandante;
            END IF;
            dbms_output.put_line('LIDER: ' || v_lider.CPI || ', Nome: ' || v_lider.NOME || ', Cargo: ' || v_lider.CARGO || ', Nacao: ' || v_lider.NACAO || ', Especie: ' || v_lider.ESPECIE);
        RETURN v_lider;  
        EXCEPTION
            WHEN PacoteComandante.e_notComandante THEN
                dbms_output.put_line('CPI informado nao corresponde a um comandante');
    END isComandante;
    
    PROCEDURE insertFederacao (
        p_lider Lider.CPI%TYPE,
        p_federacao_nome Federacao.Nome%TYPE,
        p_federacao_dt_fund Federacao.DATA_FUND%TYPE DEFAULT TO_DATE(SYSDATE, 'dd/mm/yyyy')
    ) IS
        v_lider Lider%ROWTYPE;
        v_federacao Federacao%ROWTYPE;
        v_nacao Nacao%ROWTYPE;
        BEGIN
            v_lider := isComandante(p_lider);    
            INSERT INTO FEDERACAO VALUES (p_federacao_nome, p_federacao_dt_fund);
            UPDATE NACAO N SET FEDERACAO = p_federacao_nome WHERE N.NOME = v_lider.nacao;
            COMMIT;

            SELECT * INTO v_federacao FROM FEDERACAO F WHERE F.NOME = p_federacao_nome;
            SELECT * INTO v_nacao FROM NACAO N WHERE N.NOME = v_lider.nacao;
            dbms_output.put_line('FEDERACAO: ' || v_federacao.nome || ', Data_Fund: ' || v_federacao.data_fund);
            dbms_output.put_line('NACAO: ' || v_nacao.nome || ', Qtd_planetas: ' || v_nacao.qtd_planetas || ', Federacao: ' || v_nacao.federacao);
        EXCEPTION
            WHEN e_atrib_notnull THEN
                dbms_output.put_line('Valor obrigatorio nao fornecido');
            WHEN VALUE_ERROR THEN
                dbms_output.put_line('Erro de atribuicao. Verifique os dados fornecidos');
            WHEN DUP_VAL_ON_INDEX THEN
                dbms_output.put_line('Federacao ja existente');
    END insertFederacao;
    
END PacoteComandante;

-- TESTES
DELETE FROM FEDERACAO F WHERE F.NOME = '3.a.ii';

-- Caso 1: Todos os dados válidos
DECLARE
    v_liderCPI Lider.CPI%TYPE;
    v_federacao_nome Federacao.NOME%TYPE;
    v_federacao_dt_fund Federacao.DATA_FUND%TYPE;
    
BEGIN
    v_liderCPI := '123.543.908-12'; -- Eh comandante
    v_federacao_nome := '3.a.ii';
    v_federacao_dt_fund := TO_DATE('01/01/2001', 'dd/mm/yyyy');
    PacoteComandante.insertFederacao(v_liderCPI, v_federacao_nome, v_federacao_dt_fund);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Ocorreu um erro. Operacao cancelada');
END;

-- Caso 2: CPI informado não é de um comandante
DECLARE
    v_liderCPI Lider.CPI%TYPE;
    v_federacao_nome Federacao.NOME%TYPE;
    v_federacao_dt_fund Federacao.DATA_FUND%TYPE;
    
BEGIN
        v_liderCPI := '408.540.985-55'; -- Nao eh comandante
        v_federacao_nome := '3.a.ii';
        v_federacao_dt_fund := TO_DATE('01/01/2001', 'dd/mm/yyyy');
        PacoteComandante.insertFederacao(v_liderCPI, v_federacao_nome, v_federacao_dt_fund);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Ocorreu um erro. Operacao cancelada');
END;

-- Caso 3: Dados faltantes
DECLARE
    v_liderCPI Lider.CPI%TYPE;
    v_federacao_nome Federacao.NOME%TYPE;
    v_federacao_dt_fund Federacao.DATA_FUND%TYPE;
    
BEGIN
    v_liderCPI := '123.543.908-12';
    v_federacao_nome := ''; -- Federacao.NOME eh NOT NULL
    v_federacao_dt_fund := TO_DATE('01/01/2001', 'dd/mm/yyyy');
    PacoteComandante.insertFederacao(v_liderCPI, v_federacao_nome, v_federacao_dt_fund);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Ocorreu um erro. Operacao cancelada');
END;

-- Caso 4: Inserir federação existente
DECLARE
    v_liderCPI Lider.CPI%TYPE;
    v_federacao_nome Federacao.NOME%TYPE;
    v_federacao_dt_fund Federacao.DATA_FUND%TYPE;
    
BEGIN
    v_liderCPI := '123.543.908-12';
    v_federacao_nome := '3.a.ii';
    v_federacao_dt_fund := TO_DATE('01/01/2001', 'dd/mm/yyyy');
    PacoteComandante.insertFederacao(v_liderCPI, v_federacao_nome, v_federacao_dt_fund);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Ocorreu um erro. Operacao cancelada');
END;


/* 4) Implemente as seguines funcionalidades relacionadas ao usuario Cientista do Sistema Sociedade
Galatica (ver descricao do projeto final):
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
A aplicação ira exibir ao usuario todas as informações da estrela, o usuario poderá
modificar qualquer uma exeto o ID, ao chamar por um update será recebida todas as informações
da estrela, alteradas por usuario ou não alteradas, e o update será feito

Em caso de não haver mudança a ser feira, a aplicação será responsavel por não chamar a função
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
			dbms_output.put_line('Há problemas no id recebido');
		WHEN starManager.e_coordsInvalidas THEN
			dbms_output.put_line('Há problemas nas coordenadas recebidas');
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
			dbms_output.put_line('Há problemas no id recebido');
		WHEN starManager.e_coordsInvalidas THEN
			dbms_output.put_line('Há problemas nas coordenadas recebidas');
		WHEN OTHERS THEN  
			dbms_output.put_line('Erro nro:  ' || SQLCODE  
      	                     	|| '. Mensagem: ' || SQLERRM );
END;

/*
Há problemas nas coordenadas recebidas
*/

-- Lê estrela
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
			dbms_output.put_line('Não foi possivel encontrar a estrela em questão');
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
			dbms_output.put_line('Não há o que deletar');
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
			dbms_output.put_line('Não há o que deletar');
		WHEN OTHERS THEN  
			dbms_output.put_line('Erro nro:  ' || SQLCODE  
      	                     	|| '. Mensagem: ' || SQLERRM );
END;
/*
Não há o que deletar
*/

--b. Relatórios: item 4.a (Informações de Estrelas, Planetas e Sistemas) 
CREATE OR REPLACE PACKAGE scienceReport AS 
	FUNCTION systemReport RETURN SYS_REFCURSOR;
	FUNCTION planetReport RETURN SYS_REFCURSOR;
	FUNCTION starReport RETURN SYS_REFCURSOR;
END scienceReport;

/

CREATE OR REPLACE PACKAGE BODY scienceReport AS

/*
Report contem estrela principal do sistema, estrelas que orbitam a principal, e planetas que orbitam ou
a principal ou alguma das estrelas orbitantes. 
*/
FUNCTION systemReport RETURN SYS_REFCURSOR AS
	c_report SYS_REFCURSOR;
BEGIN 
	OPEN c_report FOR
	SELECT s.ESTRELA, s.nome, oe.ORBITANTE, op.PLANETA 
		FROM SISTEMA s LEFT JOIN ORBITA_ESTRELA oe ON s.ESTRELA = oe.ORBITADA 
		LEFT JOIN ORBITA_PLANETA op ON op.ESTRELA = s.ESTRELA OR op.ESTRELA = oe.ORBITANTE;
		
	RETURN c_report;
END systemReport;

/*
 Contem cada planeta e suas informações, e a estrela que o orbita se orbitar
 Caso não orbite nenhuma estrela na aplicação será dito que é um planeta errante
 */
FUNCTION planetReport RETURN SYS_REFCURSOR AS
	c_report SYS_REFCURSOR;
BEGIN 
	OPEN c_report FOR
		SELECT p.ID_ASTRO, p.MASSA, p.RAIO, p.CLASSIFICACAO FROM PLANETA p LEFT JOIN ORBITA_PLANETA op ON op.PLANETA = p.ID_ASTRO;
		
	RETURN c_report;
END planetReport;


/*
 Contem informações de cada estrela, e se tem planetas que a orbitam 
*/
FUNCTION starReport RETURN SYS_REFCURSOR AS
	c_report SYS_REFCURSOR;
BEGIN 
	OPEN c_report FOR
		SELECT e.ID_ESTRELA, e.NOME, e.CLASSIFICACAO, e.MASSA, e.X, e.Y, e.Z, op.PLANETA
			FROM ESTRELA e LEFT JOIN ORBITA_PLANETA op ON e.ID_ESTRELA  = op.ESTRELA; 
		
	RETURN c_report;
END starReport;

END scienceReport;
