/*
SCC0541 - Laboratorio de Base de Dados
Pratica 11 � Transacoes
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*
1) Nesse exerc�cio, s�o necess�rias duas conex�es do mesmo usu�rio em seu esquema,
chamadas aqui de SESS�O 1 e SESS�O 2. (O exerc�cio tamb�m pode ser feito com 2 usu�rios
diferentes: SESS�O 1 sendo dono do esquema, e SESS�O 2 o outro usu�rio, com permiss�o de
leitura nas tabelas do SESS�O 1).
Execute os passos abaixo utilizando os dois principais tipos de n�vel de isolamento dispon�veis no
Oracle (READ COMMITTED e SERIALIZABLE), analisando e explicando o que acontece em
cada caso. Os mesmos passos devem ser executados para os dois tipos de isolamento.
*/

-- USER1: a12563800
-- USER2: a12623950

-- Concedendo permissoes
GRANT SELECT ON PARTICIPA TO a12623950;
GRANT SELECT ON NACAO_FACCAO TO a12623950;
GRANT SELECT ON FACCAO TO a12623950;
GRANT SELECT ON LIDER TO a12623950;
GRANT SELECT ON DOMINANCIA TO a12623950;
GRANT SELECT ON NACAO TO a12623950;
GRANT SELECT ON FEDERACAO TO a12623950;
GRANT SELECT ON HABITACAO TO a12623950;
GRANT SELECT ON COMUNIDADE TO a12623950;
GRANT SELECT ON ORBITA_PLANETA TO a12623950;
GRANT SELECT ON ORBITA_ESTRELA TO a12623950;
GRANT SELECT ON SISTEMA TO a12623950;
GRANT SELECT ON ESTRELA TO a12623950;
GRANT SELECT ON ESPECIE TO a12623950;
GRANT SELECT ON PLANETA TO a12623950;

/* i. Abra uma conex�o para SESS�O 1 (m�quina 1); */


/* ii. Abra outra conex�o para SESS�O 2 (m�quina 2); */


/* iii. Na SESS�O 2, inicie uma transa��o com um dos n�veis de isolamento (OBS: inicie a transa��o
executando o comando SET TRANSACTION); */


/* iv. Na SESS�O 2, fa�a uma consulta que envolva jun��o e/ou agrupamento (em SQL) (OBS:
cuidado para n�o executar novamente o comando SET TRANSACTION � execute apenas o
comando de consulta); */


/* v. Na SESS�O 1, execute um comando DML que afete a resposta da consulta executada no item
anterior (OBS: n�o � necess�rio iniciar explicitamente uma transa��o � considere a transa��o
iniciada implicitamente com o n�vel de isolamento default). Execute a mesma consulta do item
anterior. O que aconteceu e por que? */

DELETE FROM ORBITA_PLANETA OP WHERE OP.ESTRELA = 'ESTRELA_TESTE1' AND OP.PLANETA = 'PLANETA_TESTE1';
DELETE FROM ORBITA_PLANETA OP WHERE OP.ESTRELA = 'ESTRELA_TESTE2' AND OP.PLANETA = 'PLANETA_TESTE2';

-- Consulta 
SELECT E.ID_ESTRELA, OP.PLANETA FROM ESTRELA E JOIN ORBITA_PLANETA OP
    ON E.ID_ESTRELA = OP.ESTRELA;
    
-- Comando DML: Inserir uma nova tupla no resultado
                                                                                                                                                                                                                                                                                                                                         
-- READ COMMITTED
INSERT INTO PLANETA (ID_ASTRO) VALUES('PLANETA_TESTE1');
INSERT INTO ESTRELA VALUES('ESTRELA_TESTE1', 'Estrela principal', 'Gigante branca', 10.5, -3, 1, 4);
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA) VALUES('PLANETA_TESTE1', 'ESTRELA_TESTE1');

/* RESULTADO
GA1	Gallifrey
ESTRELA_TESTE1	PLANETA_TESTE1
GA1	Skaro
SK20	Skaro

Observa-se que, o novo dado que acabou de ser inserido aparece no resultado da consulta da SESSAO1
*/

-- SERIALIZABLE
INSERT INTO PLANETA (ID_ASTRO) VALUES('PLANETA_TESTE2');
INSERT INTO ESTRELA VALUES('ESTRELA_TESTE2', 'Estrela principal', 'Gigante branca', 10.5, 1, 2, 3);
INSERT INTO ORBITA_PLANETA (PLANETA, ESTRELA) VALUES('PLANETA_TESTE2', 'ESTRELA_TESTE2');

/* RESULTADO
GA1	Gallifrey
ESTRELA_TESTE1	PLANETA_TESTE1
ESTRELA_TESTE2	PLANETA_TESTE2
GA1	Skaro
SK20	Skaro

Observa-se que, o novo dado que acabou de ser inserido aparece no resultado da consulta da SESSAO1
*/

/* vi. Na SESS�O 2, execute novamente a mesma consulta. O que aconteceu e por que? */


/* vii. Na SESS�O 1, execute COMMIT para efetivar a transa��o; */
COMMIT;

/* viii. Na SESS�O 2, execute novamente a mesma consulta. O que aconteceu e por que? */


/* ix. Na SESS�O 2, execute COMMIT para efetivar a transa��o; */


/* x. Na SESS�O 2, execute novamente a mesma consulta. O que aconteceu e por que? */




/* 2)
a) Implemente um trigger para log de opera��es de DML para alguma tabela de sua escolha.
Crie uma tabela para armazenar os dados de log: usu�rio que realizou a opera��o, opera��o,
data/hora.
*/

DROP TABLE LogTabelaEstrela;

CREATE TABLE logTabelaEstrela (
    ID_USER VARCHAR(9) NOT NULL,
    OPERACAO CHAR NOT NULL,
    DATA_HORA TIMESTAMP (2) NOT NULL,
    
    CONSTRAINT PK_LOG_TABELA_ESTRELA PRIMARY KEY (ID_USER, OPERACAO, DATA_HORA)
);
COMMIT;

DROP TRIGGER LogEstrela;

CREATE OR REPLACE TRIGGER LogEstrela
    AFTER INSERT OR UPDATE OR DELETE ON Estrela
    /* n�vel de instru��o */
    DECLARE
    v_operacao CHAR;
    BEGIN
    /*usando predicados booleanos�*/
    IF INSERTING THEN v_operacao := 'I';
    ELSIF UPDATING THEN v_operacao := 'U';
    ELSIF DELETING THEN v_operacao := 'D';
    END IF;
    INSERT INTO logTabelaEstrela
    VALUES (USER, v_operacao, LOCALTIMESTAMP (2));
    
    --TODO: Exceptions
END LogEstrela;


DELETE FROM ESTRELA E WHERE E.ID_ESTRELA = 'ESTRELA_TESTE1';
DELETE FROM ESTRELA E WHERE E.ID_ESTRELA = 'ESTRELA_TESTE2';

INSERT INTO ESTRELA VALUES('ESTRELA_TESTE1', 'Estrela principal', 'Gigante branca', 10.5, -3, 1, 4);
INSERT INTO ESTRELA VALUES('ESTRELA_TESTE2', 'Estrela principal', 'Gigante branca', 10.5, 1, 2, 3);

UPDATE ESTRELA E SET E.NOME = 'Estrela Secundaria' WHERE E.ID_ESTRELA = 'ESTRELA_TESTE1';
UPDATE ESTRELA E SET E.NOME = 'Estrela Terciaria' WHERE E.ID_ESTRELA = 'ESTRELA_TESTE2';

/* b) Os triggers s�o executados dentro da mesma transa��o em que � executada a opera��o
instru��o de disparo e, portanto, as opera��es dentro do trigger s�o efetivadas (commit) ou
desfeitas (rollback) junto com as opera��es da transa��o em que est� a instru��o.
Implemente e teste esse cen�rio (i.e. teste commit e rollback da transa��o em que est�
a instru��o que dispara o trigger e explique o que acontece no log).
*/

/* c) Considere agora um cen�rio em que � interessante manter o log das informa��es de todas as
tentativas de execu��o de opera��es DML, mesmo que a opera��o em si n�o tenha sido
efetivada. Implemente e teste esse cen�rio (i.e. teste commit e rollback da transa��o
em que est� a instru��o que dispara o trigger e explique o que acontece no log). */

/* 3) Defina uma transa��o que dever� ser implementada no projeto final (OBS: N�o � necess�rio
implementar a transa��o para esta pr�tica):
a. Quais opera��es est�o inclu�das na transa��o (incluindo opera��es em triggers)?
Justifique.
b. Qual o n�vel de isolamento da trans��o? Justifique.
c. Ser� necess�rio utilizar savepoints e/ou transa��es aut�nomas? Justifique. */