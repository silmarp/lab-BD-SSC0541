/*
SCC0541 - Laboratorio de Base de Dados
Pratica 11 – Transacoes
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*
1) Nesse exercício, são necessárias duas conexões do mesmo usuário em seu esquema,
chamadas aqui de SESSÃO 1 e SESSÃO 2. (O exercício também pode ser feito com 2 usuários
diferentes: SESSÃO 1 sendo dono do esquema, e SESSÃO 2 o outro usuário, com permissão de
leitura nas tabelas do SESSÃO 1).
Execute os passos abaixo utilizando os dois principais tipos de nível de isolamento disponíveis no
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

/* i. Abra uma conexão para SESSÃO 1 (máquina 1); */


/* ii. Abra outra conexão para SESSÃO 2 (máquina 2); */


/* iii. Na SESSÃO 2, inicie uma transação com um dos níveis de isolamento (OBS: inicie a transação
executando o comando SET TRANSACTION); */


/* iv. Na SESSÃO 2, faça uma consulta que envolva junção e/ou agrupamento (em SQL) (OBS:
cuidado para não executar novamente o comando SET TRANSACTION – execute apenas o
comando de consulta); */


/* v. Na SESSÃO 1, execute um comando DML que afete a resposta da consulta executada no item
anterior (OBS: não é necessário iniciar explicitamente uma transação – considere a transação
iniciada implicitamente com o nível de isolamento default). Execute a mesma consulta do item
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

/* vi. Na SESSÃO 2, execute novamente a mesma consulta. O que aconteceu e por que? */


/* vii. Na SESSÃO 1, execute COMMIT para efetivar a transação; */
COMMIT;

/* viii. Na SESSÃO 2, execute novamente a mesma consulta. O que aconteceu e por que? */


/* ix. Na SESSÃO 2, execute COMMIT para efetivar a transação; */


/* x. Na SESSÃO 2, execute novamente a mesma consulta. O que aconteceu e por que? */




/* 2)
a) Implemente um trigger para log de operações de DML para alguma tabela de sua escolha.
Crie uma tabela para armazenar os dados de log: usuário que realizou a operação, operação,
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
    /* nível de instrução */
    DECLARE
    v_operacao CHAR;
    BEGIN
    /*usando predicados booleanos…*/
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

/* b) Os triggers são executados dentro da mesma transação em que é executada a operação
instrução de disparo e, portanto, as operações dentro do trigger são efetivadas (commit) ou
desfeitas (rollback) junto com as operações da transação em que está a instrução.
Implemente e teste esse cenário (i.e. teste commit e rollback da transação em que está
a instrução que dispara o trigger e explique o que acontece no log).
*/

/* c) Considere agora um cenário em que é interessante manter o log das informações de todas as
tentativas de execução de operações DML, mesmo que a operação em si não tenha sido
efetivada. Implemente e teste esse cenário (i.e. teste commit e rollback da transação
em que está a instrução que dispara o trigger e explique o que acontece no log). */

/* 3) Defina uma transação que deverá ser implementada no projeto final (OBS: Não é necessário
implementar a transação para esta prática):
a. Quais operações estão incluídas na transação (incluindo operações em triggers)?
Justifique.
b. Qual o nível de isolamento da transção? Justifique.
c. Será necessário utilizar savepoints e/ou transações autônomas? Justifique. */