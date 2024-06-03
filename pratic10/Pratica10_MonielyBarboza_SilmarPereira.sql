/*
SCC0541 - Laboratorio de Base de Dados
Prática 10 – PL/SQL – Triggers
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*
1. Implemente triggers para consistencia das seguintes restricoes:
*/
-- a) Uma federação só pode existir se estiver associada a pelo menos 1 nação.  
/*
assumimos que toda inserção de uma nova federação irá ser adicionando juntamente sua primeira nação
na interface do projeto final, ao adicionar uma nova nação será possivel escolher entre federações existentes ou criar uma nova.
assim não teremos um trigger que afete insert.
*/
CREATE OR REPLACE TRIGGER fedExist
FOR DELETE OR UPDATE ON NACAO 
compound trigger
	TYPE t_tab_feds IS TABLE OF NUMBER INDEX BY FEDERACAO.nome%TYPE; 
	v_feds t_tab_feds;
	e_fedWithoutNations EXCEPTION;
BEFORE STATEMENT IS
BEGIN
	FOR fed IN (SELECT n.FEDERACAO, count(n.federacao) AS qtd FROM NACAO n WHERE n.federacao IS NOT NULL GROUP BY n.FEDERACAO) LOOP 
		v_feds(fed.federacao) := fed.qtd;
	END LOOP;
END BEFORE STATEMENT;

BEFORE EACH ROW IS
BEGIN
    
	IF UPDATING THEN 
		IF :OLD.federacao IS NOT null THEN
			v_feds(:OLD.federacao) := v_feds(:OLD.federacao) - 1;
		ELSIF :NEW.federacao IS NOT null THEN
			v_feds(:NEW.federacao) := v_feds(:NEW.federacao) + 1;
		END IF;
    ELSIF DELETING AND :OLD.federacao IS NOT null THEN 
   		v_feds(:OLD.federacao) := v_feds(:OLD.federacao) - 1;
    END IF;
END BEFORE EACH ROW;

AFTER STATEMENT IS
	v_fed federacao.nome%TYPE;
BEGIN
  v_fed := v_feds.FIRST;
  WHILE v_fed IS NOT NULL LOOP
  IF v_feds(v_fed) = 0 THEN
  	raise e_fedWithoutNations;
   	--DELETE FROM federacao WHERE nome = v_fed;
  END if;
    v_fed := v_feds.NEXT(v_fed);
  END LOOP;
END AFTER STATEMENT;
END fedExist;

-- Testes
INSERT INTO FEDERACAO f values('Old Imperium', TO_DATE('01/01/2020', 'dd/mm/yyyy'));

INSERT INTO NACAO n values('Cala', 0, 'Old Imperium');

UPDATE NACAO SET FEDERACAO = NULL WHERE nome = 'Cala';

DELETE FROM NACAO WHERE nome = 'Cala';

/* Resultado de ambos delete e update
SQL Error [6510] [65000]: ORA-06510: PL/SQL: unhandled user-defined exception
ORA-06512: at "A12623950.FEDEXIST", line 33
ORA-04088: error during execution of trigger 'A12623950.FEDEXIST'

Como se o delete ou o update forem efetivado a federação ficará sem naçoes é dado um erro
Esse erro será tratado na aplicação, ao ser desenvolvido o delete e update de nações
*/

-- b) O líder de uma facção deve estar associado a uma nação em que a facção está presente.  
CREATE OR REPLACE TRIGGER validLider
after INSERT OR UPDATE ON FACCAO 
FOR EACH ROW 
DECLARE 
	e_notPartOfFaction EXCEPTION;
	v_liderNac nacao.nome%TYPE;
	v_valid NUMBER;
BEGIN 
    IF INSERTING THEN 
    	-- Ao criar uma nova facção ja adicionamos a nação do lider como ela estando presente
    	SELECT n.nome INTO v_liderNac FROM NACAO n JOIN lider l ON n.nome = l.nacao WHERE l.CPI = :NEW.lider;
   		INSERT INTO NACAO_FACCAO values(v_liderNac, :NEW.NOME);
    ELSIF UPDATING THEN 
    	--se retornar 0 não está presente se retornar 1 está
   		SELECT count(*) INTO v_valid FROM NACAO_FACCAO nf JOIN LIDER l ON l.NACAO = nf.NACAO WHERE nf.FACCAO = :NEW.nome;
    	IF v_valid = 0 THEN
    		raise e_notPartOfFaction;
    	END IF;
   	END IF;
END validLider;

-- TESTES
INSERT INTO NACAO n values('Cala', 0, NULL);

INSERT INTO LIDER values('551.398.886-11', 'Paul Atreides', 'COMANDANTE', 'Cala', 'Non eos qui');

INSERT INTO LIDER values('452.986.325-11', 'Dunkan Idaho', 'OFICIAL', 'Cala', 'Non eos qui');

INSERT INTO NACAO n values('Arrakeen', 0, NULL);

INSERT INTO LIDER VALUES('456.666.333-12', 'Vladimir', 'COMANDANTE', 'Arrakeen', 'Non eos qui');

-- insere nova faccao e adiciona nação facção com a nação do lider
INSERT INTO FACCAO values('Fremen', '551.398.886-11', 'TOTALITARIA', 0);

-- Funciona pois o novo lider é da mesma faccao que o anterior
UPDATE FACCAO SET lider = '452.986.325-11' WHERE nome = 'Fremen';

-- Falha, pois o novo lider é de uma nação a qual não faz parte da facção
UPDATE FACCAO SET lider = '456.666.333-12' WHERE nome = 'Fremen';

-- c) A quantidade de nações, na tabela Faccao dever estar sempre atualizada.  
CREATE OR REPLACE TRIGGER atualizaFacNacoes
after INSERT OR UPDATE OR DELETE ON nacao_faccao
FOR EACH ROW 
DECLARE 
BEGIN 
	IF INSERTING THEN 
		UPDATE faccao SET QTD_NACOES = QTD_NACOES + 1 WHERE nome = :NEW.faccao;

		
 	ELSIF UPDATING THEN 
 		-- remove 1 do qtd para a faccao que perdeu nação e adiciona 1 para a que ganhou
 		-- No caso em que o update não afeta federação, não faz nada
 		UPDATE faccao SET QTD_NACOES = QTD_NACOES + 1 WHERE nome = :NEW.faccao; 			
 		UPDATE faccao SET QTD_NACOES = QTD_NACOES - 1 WHERE nome = :OLD.faccao;
 	
 	ELSIF DELETING THEN
 		UPDATE faccao SET QTD_NACOES = QTD_NACOES - 1 WHERE nome = :NEW.faccao;
 	END IF;  
END atualizaFacNacoes;

-- TESTES
INSERT INTO NACAO n values('Cala', 0, NULL);

INSERT INTO NACAO n values('Arrakeen', 0, NULL);

INSERT INTO LIDER values('551.398.886-11', 'Paul Atreides', 'COMANDANTE', 'Cala', 'Non eos qui');

INSERT INTO FACCAO values('Fremen', '551.398.886-11', 'TOTALITARIA', 0)

INSERT INTO NACAO_FACCAO values('Cala', 'Fremen');

INSERT INTO NACAO_FACCAO values('Arrakeen', 'Fremen');

SELECT f.QTD_NACOES FROM FACCAO f WHERE f.NOME = 'Fremen';

/* Resultado
2
*/

DELETE FROM NACAO_FACCAO WHERE nacao = 'Cala';

INSERT INTO LIDER VALUES('456.666.333-12', 'Vladimir', 'COMANDANTE', 'Arrakeen', 'Non eos qui');

INSERT INTO FACCAO values('Harkonnen', '456.666.333-12', 'TOTALITARIA', 0);

UPDATE NACAO_FACCAO SET FACCAO = 'Harkonnen' WHERE NACAO = 'Arrakeen';

SELECT f.QTD_NACOES FROM FACCAO f WHERE f.NOME = 'Fremen';

/* Resultado
0
*/

-- d) Na tabela Nacao, o atributo qtd_planetas deve considerar somente dominâncias atuais.  
CREATE OR REPLACE TRIGGER updateAddQTDPlaneta
AFTER INSERT OR UPDATE ON DOMINANCIA 
FOR EACH ROW 
WHEN (
		-- Para insert e update se dominancia for de não atual para atual
		(NEW.data_ini <= current_date  AND ( NEW.data_fim > current_date OR NEW.data_fim is NULL ))
		
		OR
		-- Caso a nação mude E a dominancia ainda seja atual
		(OLD.NACAO != NEW.NACAO and NEW.data_ini <= current_date  AND ( NEW.data_fim > current_date  OR NEW.data_fim is NULL ))
	)
DECLARE 
BEGIN 
	UPDATE NACAO SET QTD_PLANETAS = QTD_PLANETAS + 1 WHERE nome = :NEW.NACAO;
END updateAddQTDPlaneta;


CREATE OR REPLACE TRIGGER updateSubtractQTDPlaneta
AFTER UPDATE OR DELETE ON DOMINANCIA 
FOR EACH ROW 
WHEN (
		-- Para delete e update caso a dominancia vá de atual para não atual
		(OLD.data_ini <= CURRENT_DATE AND (OLD.data_fim >= CURRENT_DATE OR OLD.data_fim is NULL))
		
		OR 
		
		-- Caso a nacao mude e a dominancia antiga era atual
		(OLD.NACAO != NEW.NACAO OR OLD.data_ini <= CURRENT_DATE AND (OLD.data_fim >= CURRENT_DATE OR OLD.data_fim is NULL))
	)
DECLARE 
BEGIN 
 	UPDATE NACAO SET QTD_PLANETAS = QTD_PLANETAS - 1 WHERE nome = :OLD.nacao;
END updateSubtractQTDPlaneta;

-- TESTES
INSERT INTO NACAO n values('Arrakeen', 0, NULL);

INSERT INTO PLANETA p values('Arrakis', 463.514, 4535.897, NULL);

INSERT INTO PLANETA p values('Caladan', 463.514, 4535.897, NULL);

INSERT INTO PLANETA p values('Giedi', 463.514, 4535.897, NULL);

-- Dominancia atual
INSERT INTO DOMINANCIA d values('Arrakis', 'Arrakeen', TO_DATE('01/01/1999', 'dd/mm/yyyy'), NULL);

-- Dominancia passada
INSERT INTO DOMINANCIA d values('Giedi', 'Arrakeen', TO_DATE('01/01/1300', 'dd/mm/yyyy'), TO_DATE('01/01/1800', 'dd/mm/yyyy'));

-- Dominancia futura
INSERT INTO DOMINANCIA d values('Caladan', 'Arrakeen', TO_DATE('01/01/2950', 'dd/mm/yyyy'), TO_DATE('01/01/3099', 'dd/mm/yyyy'));

SELECT n.QTD_PLANETAS  FROM NACAO n WHERE n.NOME = 'Arrakeen';
/* Resultado
1
*/

UPDATE DOMINANCIA SET DATA_INI = TO_DATE('01/01/2020', 'dd/mm/yyyy') WHERE PLANETA = 'Caladan' AND NACAO = 'Arrakeen';

SELECT n.QTD_PLANETAS  FROM NACAO n WHERE n.NOME = 'Arrakeen';
/* Resultado
2
*/

UPDATE DOMINANCIA SET DATA_FIM  = TO_DATE('01/01/2020', 'dd/mm/yyyy') WHERE PLANETA = 'Arrakis' AND NACAO = 'Arrakeen';

SELECT n.QTD_PLANETAS  FROM NACAO n WHERE n.NOME = 'Arrakeen';
/* Resultado
1
*/

DELETE FROM DOMINANCIA WHERE PLANETA = 'Caladan' AND NACAO = 'Arrakeen';

SELECT n.QTD_PLANETAS  FROM NACAO n WHERE n.NOME = 'Arrakeen';
/* Resultado
0
*/

/*
2. Usando view e trigger instead-of implemente a funcionalidade (de Gerenciamento) a.iii do Lider
de Faccao: Credenciar comunidades novas (Participa), que habitem planetas dominados por
nacoes onde a faccao esta presente/credenciada. Devem ser atendidos os seguintes requisitos:
    
    - o lider deve visualizar: as nacoes em que sua faccao esta presente, os planetas
    dominados (dominacao atual) por cada uma dessas nacoes, as comunidades que habitam
    cada um desses planetas, e a indicacao se cada uma dessas comunidades esta ou nao
    credenciada a faccao da qual e lider;
    
    - deve ser criada somente 1 view, e tanto a visualizacao de informacoes do item anterior
    quanto o credenciamento de uma comunidade (em Participa) devem ser feitos
    exclusivamente por meio da view.
*/

set serveroutput on;

-- Criando View
CREATE OR REPLACE VIEW view_lider_faccao
(LIDER, FACCAO, NACAO, PLANETA, COM_ESPECIE, COM_NOME, PARTICIPA) AS
    SELECT F.LIDER, F.NOME, NF.NACAO, D.PLANETA, H.ESPECIE, H.COMUNIDADE, P.FACCAO 
    FROM NACAO_FACCAO NF JOIN FACCAO F
    ON NF.FACCAO = F.NOME
        LEFT JOIN DOMINANCIA D
        ON D.NACAO = NF.NACAO
            LEFT JOIN HABITACAO H
            ON H.PLANETA = D.PLANETA
                LEFT JOIN PARTICIPA P
                ON P.ESPECIE = H.ESPECIE AND P.COMUNIDADE = H.COMUNIDADE
    WHERE D.DATA_FIM >= TO_DATE(SYSDATE) OR D.DATA_FIM IS NULL;
    
SELECT * FROM view_lider_faccao;

-- Criando Trigger
CREATE OR REPLACE TRIGGER insert_participa
INSTEAD OF INSERT OR UPDATE OR DELETE ON view_lider_faccao
FOR EACH ROW
    
BEGIN
    IF INSERTING THEN 
        INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES (:new.FACCAO, :new.COM_ESPECIE, :new.COM_NOME);
    ELSIF DELETING THEN
        DELETE FROM PARTICIPA P WHERE P.FACCAO = :old.FACCAO AND P.ESPECIE = :old.COM_ESPECIE AND P.COMUNIDADE = :old.COM_NOME;
    END IF;
END insert_participa;

-- Criando Pacote para Lider de Faccao
/* OBS: A procedure delete_comunidade foi criada apenas para facilitar os
        testes e nao necessariamente sera uma uma funcionalidade permitida para esse usuario
*/
CREATE OR REPLACE PACKAGE Package_LiderFaccao AS
    TYPE t_comunidades IS TABLE OF view_lider_faccao%ROWTYPE;
    PROCEDURE view_comunidades (p_lider IN Lider.CPI%TYPE);
    PROCEDURE print_comunidades (p_comunidades IN t_comunidades);
    PROCEDURE insert_comunidade (p_lider IN Lider.CPI%TYPE, p_faccao IN Faccao.Nome%TYPE, p_com_especie IN Comunidade.Especie%TYPE, p_com_nome IN Comunidade.Nome%TYPE);
    PROCEDURE delete_comunidade (p_lider IN Lider.CPI%TYPE, p_faccao IN Faccao.Nome%TYPE, p_com_especie IN Comunidade.Especie%TYPE, p_com_nome IN Comunidade.Nome%TYPE);
END Package_LiderFaccao;
/
CREATE OR REPLACE PACKAGE BODY Package_LiderFaccao AS
    PROCEDURE view_comunidades (p_lider IN Lider.CPI%TYPE) AS
        v_comunidades t_comunidades := t_comunidades();
        BEGIN
            SELECT * BULK COLLECT INTO v_comunidades FROM VIEW_LIDER_FACCAO VW_LF WHERE VW_LF.LIDER = p_lider;
            print_comunidades(v_comunidades);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Nao foram encontradas informacos sobre o lider' || p_lider || CHR(10));
        END view_comunidades;
    
    PROCEDURE print_comunidades (p_comunidades IN t_comunidades) AS
        BEGIN
            DBMS_OUTPUT.PUT_LINE('LIDER: ' || p_comunidades(1).LIDER);
            DBMS_OUTPUT.PUT_LINE('FACCAO: ' || p_comunidades(1).FACCAO);
            FOR i IN 1 .. p_comunidades.COUNT LOOP
                DBMS_OUTPUT.PUT_LINE('NACAO: ' ||  p_comunidades(i).NACAO
                    || ', PLANETA: ' || p_comunidades(i).PLANETA
                    || ', COM. ESPECIE: ' || p_comunidades(i).COM_ESPECIE
                    || ', COM. NOME: ' || p_comunidades(i).COM_NOME
                    || ', PARTICIPAM DA FACCAO: ' || p_comunidades(i).PARTICIPA);
            END LOOP;
        END print_comunidades;
        
    PROCEDURE insert_comunidade (
        p_lider IN Lider.CPI%TYPE,
        p_faccao IN Faccao.Nome%TYPE, 
        p_com_especie IN Comunidade.Especie%TYPE,
        p_com_nome IN Comunidade.Nome%TYPE
    ) AS
        v_valida NUMBER;
    BEGIN
        SELECT 1 INTO v_valida 
            FROM view_lider_faccao
            WHERE LIDER = p_lider AND COM_ESPECIE = p_com_especie AND COM_NOME = p_com_nome
            FETCH FIRST 1 ROWS ONLY;
        INSERT INTO view_lider_faccao (FACCAO, COM_ESPECIE, COM_NOME)
            VALUES (p_faccao, p_com_especie, p_com_nome);
        COMMIT;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(CHR(10) || 'A comunidade [' || p_com_nome || '] da especie [' || p_com_especie 
                || '] nao habita planetas dominados por nacoes onde a faccao [' || p_faccao || ']' || ' esta presente/credenciada' || CHR(10));
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE(CHR(10) || 'A comunidade [' || p_com_nome || '] da especie [' || p_com_especie || '] ja participa da faccao [' || p_faccao || ']' || CHR(10));
    END insert_comunidade;
    
    PROCEDURE delete_comunidade (
        p_lider IN Lider.CPI%TYPE,
        p_faccao IN Faccao.Nome%TYPE, 
        p_com_especie IN Comunidade.Especie%TYPE,
        p_com_nome IN Comunidade.Nome%TYPE
    ) AS
        v_valida NUMBER;
    BEGIN
        SELECT 1 INTO v_valida 
            FROM view_lider_faccao
            WHERE PARTICIPA = p_faccao
            FETCH FIRST 1 ROWS ONLY;
        DELETE FROM view_lider_faccao WHERE
            FACCAO = p_faccao AND
            COM_ESPECIE = p_com_especie AND
            COM_NOME = p_com_nome;      
        COMMIT;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(CHR(10) || 'A comunidade [' || p_com_nome || '] da especie [' || p_com_especie || '] nao participa da faccao [' || p_faccao || ']' || CHR(10));
    END delete_comunidade;
    
END Package_LiderFaccao;

        DELETE FROM view_lider_faccao WHERE
            FACCAO = 'Daleks' AND
            COM_ESPECIE = 'Kaleds Extermum' AND
            COM_NOME = 'Kaledos';
            
-- Testando as funcionalidades
DECLARE
    v_lider Lider.CPI%TYPE;
    v_faccao Faccao.Nome%TYPE;
    v_comunidade_especie Comunidade.Especie%TYPE;
    v_comunidade_nome Comunidade.Nome%TYPE;
BEGIN
-- Caso 1: Lider de faccao inserir comunidades novas (Participa), que habitem planetas dominados por nações onde a facção está presente/credenciada
    v_lider := '408.540.985-55';
    v_comunidade_especie := 'Kaleds Extermum';
    v_comunidade_nome := 'Kaledos';
    SELECT F.NOME INTO v_faccao FROM FACCAO F WHERE F.LIDER = v_lider;
    
    -- Caso ja esteja em participa, deleta (facilitar testes)
    Package_LiderFaccao.delete_comunidade(v_lider, v_faccao, v_comunidade_especie, v_comunidade_nome);

    Package_LiderFaccao.view_comunidades(v_lider);
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Caso 1' || CHR(10));
    Package_LiderFaccao.insert_comunidade(v_lider, v_faccao, v_comunidade_especie, v_comunidade_nome);
    Package_LiderFaccao.view_comunidades(v_lider);

-- Caso 2: Lider de faccao inserir comunidades novas (Participa), que NAO habitem planetas dominados por nações onde a facção está presente/credenciada
    v_lider := '408.540.985-55';
    v_comunidade_especie := 'Kaleds Extermum';
    v_comunidade_nome := 'Restos de Skaro';
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Caso 2' || CHR(10));
    
    Package_LiderFaccao.insert_comunidade(v_lider, v_faccao, v_comunidade_especie, v_comunidade_nome);
    Package_LiderFaccao.view_comunidades(v_lider);
    
-- Caso 3: Lider de faccao inserir comunidades ja cadastradas, que habitem planetas dominados por nações onde a facção está presente/credenciada
    v_lider := '408.540.985-55';
    v_comunidade_especie := 'Kaleds Extermum';
    v_comunidade_nome := 'Kaledos';
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Caso 3' || CHR(10));
    
    Package_LiderFaccao.insert_comunidade(v_lider, v_faccao, v_comunidade_especie, v_comunidade_nome);
    Package_LiderFaccao.view_comunidades(v_lider);

-- Caso 4: Lider de faccao inexistente
    v_lider := '408.540.985-50';
    v_comunidade_especie := 'Kaleds Extermum';
    v_comunidade_nome := 'Kaledos';
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Caso 4' || CHR(10));
    
    SELECT F.NOME INTO v_faccao FROM FACCAO F WHERE F.LIDER = v_lider;
    Package_LiderFaccao.insert_comunidade(v_lider, v_faccao, v_comunidade_especie, v_comunidade_nome);
    Package_LiderFaccao.view_comunidades(v_lider);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Lider não encontrado' || CHR(10));
END;
