/*
SCC0541 - LaboratÃ³rio de Base de Dados
PrÃ¡tica 07 - PL/SQL
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*
1. Implemente um programa PL/SQL que selecione e imprima nome e id das estrelas que possuem o
maior nÃºmero de estrelas em sua Ã³rbita (pode haver mais de uma estrela com o mesmo â€œmaior
nÃºmeroâ€� de estrelas orbitantes). Imprima tambÃ©m o valor desse â€œmaior nÃºmeroâ€�.
OBS: use cursor explÃ­cito, e procure maximizar o que Ã© feito na consulta associada ao cursor e
minimizar o que Ã© feito em processamento PL.
*/

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

	dbms_output.put_line('Quantidade maxima de orbitantes ÃƒÂ©: ' || v_mais_orbitados.QTD);	
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
			dbms_output.put_line('NÃƒÂ£o foram encontrados registros de orbita');
END;

/*
2. Implemente um programa PL/SQL que remova da base de dados todas as federaÃ§Ãµes que nÃ£o
possuem nenhuma naÃ§Ã£o associada. Imprima a quantidade de federaÃ§Ãµes removidas.
OBS: use cursor implÃ­cito. FaÃ§a a remoÃ§Ã£o usando um Ãºnico comando DELETE.
*/

/* Insercoes na tabela FEDERACAO */
INSERT INTO FEDERACAO 
	VALUES('Seldus', TO_DATE('01/05/5000', 'dd/mm/yyyy'));

INSERT INTO FEDERACAO 
	VALUES('Molcleans', TO_DATE('25/02/4890', 'dd/mm/yyyy'));

BEGIN
    DELETE FROM FEDERACAO F WHERE F.NOME IN (
        SELECT F.NOME FROM FEDERACAO F WHERE F.NOME NOT IN
            (SELECT N.FEDERACAO FROM NACAO N)
    );
    IF SQL%FOUND
        THEN dbms_output.put_line(SQL%ROWCOUNT || ' federacoes removidas');
    ELSE
        RAISE NO_DATA_FOUND;
    END IF;
    COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND
            THEN dbms_output.put_line('Todas as federaÃƒÂ§ÃƒÂµes estÃƒÂ£o associadas');
END;

/*
3. Implemente um programa PL/SQL que, dado um planeta e uma comunidade (entradas de usuÃ¡rio),
inclua a comunidade como habitante do planeta por um perÃ­odo de:
â€¢ 100 anos a partir da data atual se a comunidade possuir 1000 habitantes ou menos;
â€¢ 50 anos a partir da data atual se a comunidade possuir mais de 1000 habitantes;
Imprima as informaÃ§Ãµes referentes Ã  espÃ©cie da comunidade (nome, planeta de origem e se Ã©
inteligente ou nÃ£o), e o perÃ­odo (datas) de habitaÃ§Ã£o cadastrado.
*/

-- TODO impresÃƒÂ£o das ultimas informaÃƒÂ§ÃƒÂµes
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
			-- habitaÃƒÂ§ÃƒÂ£o de 50 anos
			INSERT INTO HABITACAO values(v_planeta, v_especie, v_comunidade, current_date, add_months(current_date, 600));
		ELSE
			-- habitaÃƒÂ§ÃƒÂ£o de 100 anos
			INSERT INTO HABITACAO values(v_planeta, v_especie, v_comunidade, current_date, add_months(current_date, 1200));
	end IF;

	COMMIT;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN  
			dbms_output.put_line('NÃƒÂ£o foi possivel encotrar a comunidade');
		WHEN e_planeta_invalido THEN
			dbms_output.put_line('O planeta ' || v_planeta || ' ÃƒÂ© invalido e/ou nÃƒÂ£o existe');
		WHEN OTHERS  
       		THEN dbms_output.put_line('Erro nro:  ' || SQLCODE  
                            || '. Mensagem: ' || SQLERRM );
END;

/*
4. Implemente um programa PL/SQL que, dada uma classificaÃ§Ã£o de estrela (entrada de usuÃ¡rio), e
considerando todas as estrelas dessa classificaÃ§Ã£o que sejam orbitadas por planetas, remova o
planeta da Ã³rbita da estrela se a distÃ¢ncia mÃ­nima entre eles for superior a um valor tambÃ©m
fornecido como entrada de usuÃ¡rio. Imprima o nÃºmero total de Ã³rbitas removidas.
OBS: use cursor explicito com SELECT ... FOR UPDATE.
*/
INSERT INTO ORBITA_PLANETA VALUES ('Skaro', 'GJ 4273', 110.711, 162.421, 250.368);
INSERT INTO ORBITA_PLANETA VALUES ('Skaro', 'Gl 203', 210.711, 371.421, 250.368);
INSERT INTO ORBITA_PLANETA VALUES ('Skaro', 'GJ 4019B', 157.711, 193.421, 250.368);

DECLARE 
    v_classificacao ESTRELA.CLASSIFICACAO%TYPE;
    v_dist_min ORBITA_PLANETA.DIST_MIN%TYPE;
    v_deletados INTEGER;
    
    CURSOR C_ORBITA_PLANETA IS 
        SELECT OP.ESTRELA, OP.PLANETA, E.CLASSIFICACAO, OP.DIST_MIN
        FROM ESTRELA E JOIN ORBITA_PLANETA OP
        ON E.ID_ESTRELA = OP.ESTRELA
    FOR UPDATE;
    
    v_resultado c_orbita_planeta%ROWTYPE;
    
BEGIN
    v_classificacao := 'M5';
    v_dist_min := 100;
    v_deletados := 0;
    OPEN c_orbita_planeta;
    
    LOOP
        FETCH c_orbita_planeta INTO v_resultado;
        EXIT WHEN c_orbita_planeta%NOTFOUND;
        IF v_resultado.classificacao = v_classificacao AND v_resultado.dist_min > v_dist_min
            THEN DELETE FROM ORBITA_PLANETA WHERE CURRENT OF c_orbita_planeta;
                v_deletados := v_deletados + 1;
            END IF;
        END LOOP;
        IF v_deletados = 0
           THEN RAISE NO_DATA_FOUND;
        ELSE dbms_output.put_line(v_deletados || ' orbitas removidas');
        END IF;
    
        CLOSE c_orbita_planeta;
        COMMIT;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                dbms_output.put_line('Nenhuma órbita com estrelas da classificacao ' || v_classificacao
                    || ' e distância mínima maior que ' || v_dist_min
                    || ' foi encontrada');
    END;    
