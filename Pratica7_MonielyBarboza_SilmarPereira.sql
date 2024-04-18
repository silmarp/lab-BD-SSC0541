/* 2. Implemente um programa PL/SQL que remova da base de dados todas as federa��es que n�o
possuem nenhuma na��o associada. Imprima a quantidade de federa��es removidas.
OBS: use cursor impl�cito. Fa�a a remo��o usando um �nico comando DELETE. */

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
        THEN dbms_output.put_line('Todas as federa��es est�o associadas');
END;

INSERT INTO FEDERACAO VALUES('P7_TESTE1', '17/04/2024');
INSERT INTO FEDERACAO VALUES('P7_TESTE2', '17/04/2024');
INSERT INTO FEDERACAO VALUES('P7_TESTE3', '17/04/2024');
INSERT INTO FEDERACAO VALUES('P7_TESTE4', '17/04/2024');

       