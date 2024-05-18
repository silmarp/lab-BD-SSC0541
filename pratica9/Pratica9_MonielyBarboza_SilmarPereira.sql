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
		
		DELETE FROM NACAO_FACCAO nf WHERE nf.NACAO = p_nacao AND nf.FACCAO = p_faccao;
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
a. Gerenciamento: item 4.a (CRUD de estrelas)
b. Relatorios: item 4.a (Informacoes de Estrelas, Planetas e Sistemas)
*/
