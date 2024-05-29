/*
SCC0541 - Laboratorio de Base de Dados
Prática 10 – PL/SQL – Triggers
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*
1. Implemente triggers para consistencia das seguintes restricoes:
*/

-- a) Uma federacao so pode existir se estiver associada a pelo menos 1 nacao.

CREATE OR REPLACE TRIGGER fedExist
-- assumimos que toda inserção de uma federação irá ser adicionando juntamente com uma nação
-- assim o trigger será after delete
AFTER DELETE ON NACAO
-- considerar update também 
FOR EACH ROW
DECLARE 
	v_countNaccao number;
BEGIN
	SELECT count(*) INTO v_countNaccao FROM NACAO n  WHERE n.FEDERACAO = :OLD.FEDERACAO;
	
	IF v_countNaccao = 0 THEN
		-- Se não tem 1 ou mais naçoes na federação devemos exclui-lá ?
		-- Outra alternativa seria não permitir a exclusão da nação usando o before delete on
		DELETE FROM FEDERACAO f WHERE f.NOME = :OLD.FEDERACAO;
	END IF;
	
	EXCEPTION
END fedExist;


-- b) O lider de uma faccao deve estar associado a uma nacao em que a faccao esta presente.
CREATE OR REPLACE TRIGGER validLider
BEFORE INSERT OR UPDATE ON FACCAO 
FOR EACH ROW 
DECLARE 
	e_notPartOfFaction EXCEPTION;
	v_countLider NUMBER;
BEGIN 
	SELECT count(*) INTO v_countLider FROM LIDER l JOIN NACAO n ON l.NACAO = n.NOME AND n.nome IN (SELECT nf.NACAO FROM NACAO_FACCAO nf WHERE nf.FACCAO = :NEW.NOME );
	
	IF v_countLider = 0 then
		raise e_notPartOfFaction;
	end IF;
	
END validLider;



-- c) A quantidade de nacoes, na tabela Faccao dever estar sempre atualizada.
CREATE OR REPLACE TRIGGER atualizaFacNacoes
BEFORE INSERT OR UPDATE OR DELETE ON NACAO 
FOR EACH ROW 
DECLARE 
BEGIN 
	IF INSERTING THEN 
		UPDATE faccao SET QTD_NACOES = QTD_NACOES + 1 WHERE nome = :NEW.FEDERACAO;
 
 	ELSIF UPDATING THEN 
 		-- remove 1 do qtd para a faccao que perdeu nação e adiciona 1 para a que ganhou
 		-- no fim da na mesma se a alteração não for na federação, entretanto seria um despercicio de processamento ? 
 		UPDATE faccao SET QTD_NACOES = QTD_NACOES - 1 WHERE nome = :OLD.FEDERACAO;
 		UPDATE faccao SET QTD_NACOES = QTD_NACOES + 1 WHERE nome = :NEW.FEDERACAO;
 
 	ELSIF DELETING THEN
 		UPDATE faccao SET QTD_NACOES = QTD_NACOES - 1 WHERE nome = :NEW.FEDERACAO;;    
 END IF;  

END atualizaFacNacoes;

-- d) Na tabela Nacao, o atributo qtd_planetas deve considerar somente dominancias atuais.

-- maybe fazer 2 triggers (ou até 3, um para cada um) um para inserção e deleção e outro para update para resolver o problema do if
CREATE OR REPLACE TRIGGER validQTDPlanetas
BEFORE INSERT OR UPDATE OR DELETE ON DOMINANCIA 
FOR EACH ROW 

WHEN (
		-- Para insert e update se o novo valor for atual então procegue
		(NEW.data_ini <= CURRENT_DATE AND (NEW.data_fim >= CURRENT_DATE OR NEW.data_fim = NULL) ) 
	OR 
		-- Para delete e update se o valor antigo for atual procegue
		(OLD.data_ini <= CURRENT_DATE AND (OLD.data_fim >= CURRENT_DATE OR OLD.data_fim = NULL)) 
	)
DECLARE 
BEGIN 
	IF INSERTING THEN 
		UPDATE faccao SET QTD_PLANETAS = QTD_PLANETAS + 1 WHERE nome = :NEW.nacao;
 
 	ELSIF UPDATING THEN 
 		-- Mesmo problema do de cima com relação a performance
 		-- e se o update for de um atual para um não atual ??
 		-- e o oposto de um não atual para um atual ??
 		-- em ambos um será atualizado corretamente e o outro não (deveriamos adicionar um if aqui também ?)
 		UPDATE NACAO  SET QTD_PLANETAS = QTD_PLANETAS - 1 WHERE nome = :OLD.nacao;
 		UPDATE faccao SET QTD_PLANETAS = QTD_PLANETAS + 1 WHERE nome = :NEW.nacao;
 
 	ELSIF DELETING THEN
 		UPDATE faccao SET QTD_PLANETAS = QTD_PLANETAS - 1 WHERE nome = :NEW.nacao;;    
 END IF;  

END atualizaFacNacoes;



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
