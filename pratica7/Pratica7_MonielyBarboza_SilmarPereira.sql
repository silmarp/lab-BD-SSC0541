/* 1. */
DECLARE
	CURSOR c_mais_orbitados IS  SELECT e.ID_ESTRELA, e.NOME, count(*) as QTD
		FROM ORBITA_ESTRELA oe JOIN ESTRELA e ON oe.ORBITADA = e.ID_ESTRELA 
		GROUP BY e.ID_ESTRELA, e.NOME  
		HAVING count(*) = (SELECT max(count(*)) FROM ORBITA_ESTRELA GROUP BY ORBITADA);

	v_mais_orbitados c_mais_orbitados%ROWTYPE;
BEGIN
	OPEN c_mais_orbitados;
	FETCH c_mais_orbitados INTO v_mais_orbitados;	
	
	IF NOT c_mais_orbitados%FOUND THEN RAISE NO_DATA_FOUND; END if;

	dbms_output.put_line('Quantidade maxima de orbitantes é: ' || v_mais_orbitados.QTD);	
	dbms_output.put_line('Estrela id: ' || v_mais_orbitados.ID_ESTRELA
		|| ';  Estrela Nome: ' || v_mais_orbitados.NOME);

	LOOP
		FETCH c_mais_orbitados INTO v_mais_orbitados;
		EXIT WHEN c_mais_orbitados%NOTFOUND;
		dbms_output.put_line('Estrela id: ' || v_mais_orbitados.ID_ESTRELA
			|| ';  Estrela Nome: ' || v_mais_orbitados.NOME);
	end LOOP;

	CLOSE c_mais_orbitados;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN  
			dbms_output.put_line('Não foram encontrados registros de orbita');
END;

/* 2. Implemente um programa PL/SQL que remova da base de dados todas as federações que não
possuem nenhuma nação associada. Imprima a quantidade de federações removidas.
OBS: use cursor implícito. Faça a remoção usando um único comando DELETE. */

BEGIN
    DELETE FROM FEDERACAO F WHERE F.NOME IN (
        SELECT F.NOME FROM FEDERACAO F WHERE F.NOME NOT IN
            (SELECT N.FEDERACAO FROM NACAO N)
        );
    IF SQL%FOUND
    THEN dbms_output.put_line(SQL%ROWCOUNT || ' federacoes removidas');
    ELSE RAISE NO_DATA_FOUND;
    END IF;
    COMMIT;
    EXCEPTION
    WHEN NO_DATA_FOUND
        THEN dbms_output.put_line('Todas as federações estão associadas');
END;

INSERT INTO FEDERACAO VALUES('P7_TESTE1', '17/04/2024');
INSERT INTO FEDERACAO VALUES('P7_TESTE2', '17/04/2024');
INSERT INTO FEDERACAO VALUES('P7_TESTE3', '17/04/2024');
INSERT INTO FEDERACAO VALUES('P7_TESTE4', '17/04/2024');


/*
3. Implemente um programa PL/SQL que, dado um planeta e uma comunidade (entradas de usuário), 
inclua a comunidade como habitante do planeta por um período de:  
• 100 anos a partir da data atual se a comunidade possuir 1000 habitantes ou menos;  
• 50 anos a partir da data atual se a comunidade possuir mais de 1000 habitantes;  
Imprima  as  informações  referentes  à  espécie  da  comunidade  (nome,  planeta  de  origem  e  se  é 
inteligente ou não), e o período (datas) de habitação cadastrado.  
*/

-- TODO impresão das ultimas informações
DECLARE
	v_planeta PLANETA.ID_ASTRO%TYPE;
	v_comunidade COMUNIDADE.NOME%TYPE;
	v_especie COMUNIDADE.ESPECIE%TYPE;
	v_habitantes COMUNIDADE.QTD_HABITANTES%TYPE;

	e_planeta_invalido EXCEPTION;
	pragma EXCEPTION_INIT(e_planeta_invalido, -2291);
BEGIN
    -- entradas do usuario
	v_planeta := 'Laborum nihil.';
	v_comunidade := 'Thals';
	v_especie := 'Kaleds Extermum';

	SELECT QTD_HABITANTES INTO v_habitantes 
		FROM COMUNIDADE c WHERE c.NOME = v_comunidade AND c.ESPECIE = v_especie;
	
	IF v_habitantes > 1000 then
			-- habitação de 50 anos
			INSERT INTO HABITACAO values(v_planeta, v_especie, v_comunidade, current_date, add_months(current_date, 600));
		ELSE
			-- habitação de 100 anos
			INSERT INTO HABITACAO values(v_planeta, v_especie, v_comunidade, current_date, add_months(current_date, 1200));
	end IF;

	COMMIT;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN  
			dbms_output.put_line('Não foi possivel encotrar a comunidade');
		WHEN e_planeta_invalido THEN
			dbms_output.put_line('O planeta ' || v_planeta || ' é invalido e/ou não existe');
		WHEN OTHERS  
       		THEN dbms_output.put_line('Erro nro:  ' || SQLCODE  
                            || '. Mensagem: ' || SQLERRM );
END;
