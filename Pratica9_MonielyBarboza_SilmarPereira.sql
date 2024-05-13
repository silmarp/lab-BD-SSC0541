/*
SCC0541 - Laboratorio de Base de Dados
Pratica 09 - PL/SQL – Procedimentos, Funcoes e Pacotes
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

set serveroutput on;

/* 1) Implemente uma função que calcule a distância entre duas estrelas (pode ser distância
Euclididana). */

/* Será utilizada a distancia euclidiana dada por:
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
    
    dbms_output.put_line('A distancia entre as estrelas "' || v_estrela1 || '" e "' || v_estrela2 || '" é ' || v_distancia);
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('Estrela nao encontrada');
END;

/* Resultado:
    v_estrela1 := 'Alp Oct';
    v_estrela2 := '29Pi  And';
A distancia entre as estrelas "Alp Oct" e "29Pi  And" é 205,938950049332855677777975828942337846

    v_estrela1 := 'Teste';
    v_estrela2 := '29Pi  And';
Estrela nao encontrada
*/


/*2) 
Implemente! a! seguinte! funcionalidade! relacionada! ao! usuário! Líder) de) Facção! do! Sistema!
Sociedade!Galática!(ver!descrição!do!projeto!final):
a. Gerenciamento:!!item!1.b!!(Remover'facção'de'Nação)
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

/* 3) Implemente a seguinte funcionalidade relacionada ao usuário Comandante do Sistema
Sociedade Galática (ver descrição do projeto final):
a. Gerenciamento: item 3.a.ii (Criar nova federação, com a própria nação)
*/

/*
Comandante é de uma nacao
Ele vai inserir uma nova federacao
Essa nova federacao passa a ser e federacao da nacao
Sea nacao já tem federacao, update
Senão insert
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

    dbms_output.put_line('Federacao ' || v_federacao || ' associada à nacao ' || v_nacao);
END;
