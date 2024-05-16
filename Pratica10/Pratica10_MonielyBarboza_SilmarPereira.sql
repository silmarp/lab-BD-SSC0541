/*
1. Implemente triggers para consistência das seguintes restrições:  
*/

-- a) Uma federação só pode existir se estiver associada a pelo menos 1 nação.  

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


-- b) O líder de uma facção deve estar associado a uma nação em que a facção está presente.  
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



-- c) A quantidade de nações, na tabela Faccao dever estar sempre atualizada.  
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

-- d) Na tabela Nacao, o atributo qtd_planetas deve considerar somente dominâncias atuais.  

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
-- 2
CREATE OR REPLACE VIEW view_lider_faccao
(LIDER, FACCAO, NACOES, PLANETAS, COM_ESPECIE, COM_NOME, PARTICIPA) AS
    SELECT F.LIDER, F.NOME, NF.NACAO, D.PLANETA, H.ESPECIE, H.COMUNIDADE, P.FACCAO 
        FROM NACAO_FACCAO NF JOIN FACCAO F
        ON NF.FACCAO = F.NOME
            LEFT JOIN DOMINANCIA D
            ON D.NACAO = NF.NACAO
                LEFT JOIN HABITACAO H
                ON H.PLANETA = D.PLANETA
                    LEFT JOIN PARTICIPA P
                    ON P.ESPECIE = H.ESPECIE AND P.COMUNIDADE = H.COMUNIDADE
        WHERE F.LIDER = '123.543.908-12' AND D.DATA_FIM >= TO_DATE(SYSDATE) OR D.DATA_FIM IS NULL;
    
SELECT * FROM view_lider_faccao;


CREATE OR REPLACE TRIGGER insert_participa
INSTEAD OF INSERT ON view_lider_faccao
FOR EACH ROW
    
BEGIN

    INSERT INTO PARTICIPA (FACCAO, ESPECIE, COMUNIDADE) VALUES (FACCAO, :new.Especie, :new.Comunidade);
    
END insert_update_participa;
