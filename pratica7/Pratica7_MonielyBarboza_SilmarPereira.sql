/*
SCC0541 - Laboratorio de Base de Dados
Pratica 07 - PL/SQL
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/* Habilita saida */
set serveroutput on;

/*
1. Implemente um programa PL/SQL que selecione e imprima nome e id das estrelas que possuem o
maior numero de estrelas em sua orbita (pode haver mais de uma estrela com o mesmo maior
numero de estrelas orbitantes). Imprima tambem o valor desse maior numero.
OBS: use cursor explicito, e procure maximizar o que e feito na consulta associada ao cursor e
minimizar o que e feito em processamento PL.
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

	dbms_output.put_line('Quantidade maxima de orbitantes: ' || v_mais_orbitados.QTD);	
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
			dbms_output.put_line('Nao foram encontrados registros de orbita');
END;

/*
2. Implemente um programa PL/SQL que remova da base de dados todas as federacoes que nao
possuem nenhuma nacao associada. Imprima a quantidade de federacoes removidas.
OBS: use cursor implicito. Faca a remocao usando um unico comando DELETE.
*/

/* Insercoes na tabela FEDERACAO */
INSERT INTO FEDERACAO VALUES('Seldus', TO_DATE('01/05/5000', 'dd/mm/yyyy'));
INSERT INTO FEDERACAO VALUES('Molcleans', TO_DATE('25/02/4890', 'dd/mm/yyyy'));

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
            THEN dbms_output.put_line('Todas as federacoes estao associadas');
END;

/*
3. Implemente um programa PL/SQL que, dado um planeta e uma comunidade (entradas de usuario),
inclua a comunidade como habitante do planeta por um periodo de:
? 100 anos a partir da data atual se a comunidade possuir 1000 habitantes ou menos;
? 50 anos a partir da data atual se a comunidade possuir mais de 1000 habitantes;
Imprima as informacoes referentes a especie da comunidade (nome, planeta de origem e se e
inteligente ou nao), e o periodo (datas) de habitacao cadastrado.
*/

DECLARE
	v_planeta PLANETA.ID_ASTRO%TYPE;
	v_comunidade COMUNIDADE.NOME%TYPE;
	v_especie COMUNIDADE.ESPECIE%TYPE;
	v_habitantes COMUNIDADE.QTD_HABITANTES%TYPE;
	
	v_intel ESPECIE.INTELIGENTE%TYPE;
	v_origem ESPECIE.PLANETA_OR%TYPE;

	v_date DATE;
	v_date_end DATE;

	e_planeta_invalido EXCEPTION;
	pragma EXCEPTION_INIT(e_planeta_invalido, -2291);
BEGIN
	--input planeta
	v_planeta := 'Laborum nihil.';
	--input comunidade
	v_comunidade := 'Thals';
	v_especie := 'Kaleds Extermum';

	-- data atual
	v_date := current_date;

	SELECT QTD_HABITANTES INTO v_habitantes 
		FROM COMUNIDADE c WHERE c.NOME = v_comunidade AND c.ESPECIE = v_especie;
	
	IF v_habitantes > 1000 then
			-- habitação de 50 anos
			v_date_end := add_months(v_date, 600);
			INSERT INTO HABITACAO values(v_planeta, v_especie, v_comunidade, v_date, v_date_end);
		ELSE
			-- habitação de 100 anos
			v_date_end := add_months(v_date, 1200);
			INSERT INTO HABITACAO values(v_planeta, v_especie, v_comunidade, v_date, v_date_end);
	end IF;

	COMMIT;

	SELECT e.INTELIGENTE, e.PLANETA_OR INTO v_intel, v_origem
		FROM ESPECIE e WHERE e.NOME = v_especie;
	
	dbms_output.put_line('Especie: ' || v_especie ||
	' de origem no planeta: ' || v_origem ||
	', presença de inteligencia: ' || v_intel ||
	' teve habitação cadastrada com inicio em: ' || TO_CHAR(v_date, 'DD-MM-YYYY') || 
	' e fim em: ' || TO_CHAR(v_date_end, 'DD-MM-YYYY'));	
	

	EXCEPTION
		WHEN NO_DATA_FOUND THEN  
			dbms_output.put_line('Não foi possivel encotrar a comunidade');
		WHEN e_planeta_invalido THEN
			dbms_output.put_line('O planeta ' || v_planeta || ' é invalido e/ou não existe');
		WHEN OTHERS  
       		THEN dbms_output.put_line('Erro nro:  ' || SQLCODE  
                            || '. Mensagem: ' || SQLERRM );
END;

/*
4. Implemente um programa PL/SQL que, dada uma classificação de estrela (entrada de usuário), e
considerando todas as estrelas dessa classificação que sejam orbitadas por planetas, remova o
planeta da órbita da estrela se a distância mínima entre eles for superior a um valor também
fornecido como entrada de usuário. Imprima o número total de órbitas removidas.
OBS: use cursor explicito com SELECT ... FOR UPDATE.
*/

/* Para esse exercício, consideraremos a classificacao = 'M5' e a distância mínima = 100
Esses valores seriam fornecidos pelo usuário. Entretanto, em PL/SQL não temos comandos de entrada */

/* Insercoes na tabela ORBITA_PLANETA*/
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
                dbms_output.put_line('Nenhuma orbita com estrelas da classificacao ' || v_classificacao
                    || ' e distancia maxima maior que ' || v_dist_min
                    || ' foi encontrada');
END;    
