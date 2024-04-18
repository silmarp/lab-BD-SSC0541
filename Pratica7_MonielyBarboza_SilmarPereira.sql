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

       
