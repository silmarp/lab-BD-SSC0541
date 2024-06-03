/*
SCC0541 - Laboratorio de Base de Dados
Pratica 11 - Transacoes
Moniely Silva Barboza - 12563800
Silmar Pereira da Silva Junior - 12623950
*/

/*
1) Nesse exercicio, sao necessarias duas conexoes do mesmo usuario em seu esquema,
chamadas aqui de SESSAO 1 e SESSAO 2. (O exercicio tambem pode ser feito com 2 usuarios
diferentes: SESSAO 1 sendo dono do esquema, e SESSAO 2 o outro usuario, com permissao de
leitura nas tabelas do SESSAO 1).
Execute os passos abaixo utilizando os dois principais tipos de nivel de isolamento disponiveis no
Oracle (READ COMMITTED e SERIALIZABLE), analisando e explicando o que acontece em
cada caso. Os mesmos passos devem ser executados para os dois tipos de isolamento.
*/

-- USER1: a12563800
-- USER2: a12623950

-- Concedendo permissoes

-- TODO: Testar esse script depois
SET PAGESIZE 0
SET LINESIZE 100
SET FEEDBACK OFF
SPOOL grant_permissions.sql

SELECT 'GRANT SELECT ON ' || table_name || ' TO a12623950;'
FROM all_tables
WHERE owner = 'a12563800';

SPOOL OFF

@grant_permissions.sql

-- TODO: Se der certo o script, apagar esses debaixo

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

/* i. Abra uma conexao para SESSAO 1 (maquina 1); */


/* ii. Abra outra conexao para SESSAO 2 (maquina 2); */


/* iii. Na SESSAO 2, inicie uma transacao com um dos niveis de isolamento (OBS: inicie a transacao
executando o comando SET TRANSACTION); */


/* iv. Na SESSAO 2, faca uma consulta que envolva juncao e/ou agrupamento (em SQL) (OBS:
cuidado para nao executar novamente o comando SET TRANSACTION ? execute apenas o
comando de consulta); */


/* v. Na SESSAO 1, execute um comando DML que afete a resposta da consulta executada no item
anterior (OBS: nao e necessario iniciar explicitamente uma transacao ? considere a transacao
iniciada implicitamente com o nivel de isolamento default). Execute a mesma consulta do item
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

/* vi. Na SESSAO 2, execute novamente a mesma consulta. O que aconteceu e por que? */


/* vii. Na SESSAO 1, execute COMMIT para efetivar a transacao; */
COMMIT;

/* viii. Na SESSAO 2, execute novamente a mesma consulta. O que aconteceu e por que? */


/* ix. Na SESSAO 2, execute COMMIT para efetivar a transacao; */


/* x. Na SESSAO 2, execute novamente a mesma consulta. O que aconteceu e por que? */




/* 2)
a) Implemente um trigger para log de operacoes de DML para alguma tabela de sua escolha.
Crie uma tabela para armazenar os dados de log: usuario que realizou a operacao, operacao,
data/hora.
*/

set serveroutput on;

--Criacao da tabela de logs
/* OBS: Considerando que eh possivel que um mesmo usuario execute 2 operacoes iguais
no mesmo momento (como 2 inserts/updates/delestes, em sequencia), utilizar apenas os atributos 
da tabela como chave primaria estava causando erros de duplicacao de chave.
Por esse motivo, foi criado um id sintetico para o log)
*/

DROP TABLE LogTabelaEstrela;

CREATE TABLE logTabelaEstrela (
    ID_LOG VARCHAR(20),
    ID_USER VARCHAR(9) NOT NULL,
    OPERACAO CHAR NOT NULL,
    DATA_HORA DATE NOT NULL,
    
    CONSTRAINT PK_LOG_TABELA_ESTRELA PRIMARY KEY (ID_LOG)
);


DROP SEQUENCE log_seq;
CREATE SEQUENCE log_seq START WITH 1 INCREMENT BY 1;

-- Criacao do Trigger

DROP TRIGGER LogEstrela;

CREATE OR REPLACE TRIGGER LogEstrela
    AFTER INSERT OR UPDATE OR DELETE ON Estrela
    DECLARE
        v_operacao CHAR;
        v_id_log VARCHAR(20);
    BEGIN
        IF INSERTING THEN v_operacao := 'I';
        ELSIF UPDATING THEN v_operacao := 'U';
        ELSIF DELETING THEN v_operacao := 'D';
        END IF;
        v_id_log := TO_CHAR(log_seq.NEXTVAL, 'FM0000000000');
        INSERT INTO logTabelaEstrela
            VALUES (v_id_log, USER, v_operacao, SYSDATE);
END LogEstrela;

/* b) Os triggers sao executados dentro da mesma transacao em que e executada a operacao
instrucao de disparo e, portanto, as operacoes dentro do trigger sao efetivadas (commit) ou
desfeitas (rollback) junto com as operacoes da transacao em que esta a instrucao.
Implemente e teste esse cenario (i.e. teste commit e rollback da transacao em que esta
a instrucao que dispara o trigger e explique o que acontece no log).
*/

/* Ate este momento, a transacao esta com nivel de isolamento padrao (Read Commited).
Ou seja, caso haja rollback da instrucao de disparo, tambem havera rollback na tabela de logs.
*/

BEGIN
    DELETE FROM ESTRELA E WHERE E.ID_ESTRELA = 'ESTRELA_TESTE1';
    INSERT INTO ESTRELA VALUES('ESTRELA_TESTE1', 'Estrela principal', 'Gigante branca', 10.5, -3, 1, 4);
    UPDATE ESTRELA E SET E.NOME = 'Estrela Secundaria' WHERE E.ID_ESTRELA = 'ESTRELA_TESTE1';
    COMMIT;
    
    DELETE FROM ESTRELA E WHERE E.ID_ESTRELA = 'ESTRELA_TESTE2';
    INSERT INTO ESTRELA VALUES('ESTRELA_TESTE2', 'Estrela principal', 'Gigante branca', 10.5, 1, 2, 3);
    UPDATE ESTRELA E SET E.NOME = 'Estrela Terciaria' WHERE E.ID_ESTRELA = 'ESTRELA_TESTE2';
    ROLLBACK;
END;

/* Executando o bloco PL/SQL acima, temos 6 instrucoes de disparo:
em 3 delas foi executado commit e nas outras 3 foi executado rollback.
Sendo assim, na tabela de logs, temos apenas 3 operacoes registradas (as em que foi executado o commit).
*/

/* c) Considere agora um cenario em que e interessante manter o log das informacoes de todas as
tentativas de execucao de operacoes DML, mesmo que a operacao em si nao tenha sido
efetivada. Implemente e teste esse cenario (i.e. teste commit e rollback da transacao
em que esta a instrucao que dispara o trigger e explique o que acontece no log).
*/


-- Criacao do Trigger Autonomo
CREATE OR REPLACE TRIGGER LogEstrela
    AFTER INSERT OR UPDATE OR DELETE ON Estrela
    DECLARE
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_operacao CHAR;
        v_id_log VARCHAR(20);
    BEGIN
        IF INSERTING THEN v_operacao := 'I';
        ELSIF UPDATING THEN v_operacao := 'U';
        ELSIF DELETING THEN v_operacao := 'D';
        END IF;
        v_id_log := TO_CHAR(log_seq.NEXTVAL, 'FM0000000000');
        INSERT INTO logTabelaEstrela
            VALUES (v_id_log, USER, v_operacao, SYSDATE);
        COMMIT;
END LogEstrela;

/* Para este exercicio, alteramos o trigger para que ele seja uma transacao autonoma.
Alem disso, a estrela 'ESTRELA_TESTE1' ja foi inserida no item anterior.
Sendo assim, ao fim do bloco PL/SQL abaixo, se nao tivessemos o ROLLBACK,
essa estrela deveria ter sido deletada. Contudo, testaremos este cenario.
*/

BEGIN
    DELETE FROM ESTRELA E WHERE E.ID_ESTRELA = 'ESTRELA_TESTE1';    
    ROLLBACK;
END;

/* Como temos o ROLLBACK ao fim do bloco, a estrela permanece na tabela Estrela.
Entretanto, a operacao de delete foi registrada na tabela de logs, ja que e o 
registro do log eh uma transacao autonoma. */


/* 3) Defina uma transacao que devera ser implementada no projeto final (OBS: Nao e necessario
implementar a transacao para esta pratica):   
    Uma das funcionalidades do sistema relacionadas ao Lider de Faccao consiste em:
    1. Lider de faccao:
        a. Gerenciar aspectos da propria faccao da qual e lider:
            i. Alterar nome da faccao
    Entretanto, e importante observar que o nome da faccao e um atributo que esta
    presente como chave estrangeira em outras tabelas que sao utilizadas em diversas
    funcionalidades do sistema.
    Sendo assim, ao alterar o nome da faccao, a tabela deve estar bloqueada ate a conclusao da transacao.
    Por isso, sera definida uma transacao para essa funcionalidade.
*/

/* a. Quais operacoes estao incluidas na transacao (incluindo operacoes em triggers)?
Justifique.
    Nessa transacao, esta inclusa a operacao de Update na tabela Faccao. 
*/

/* b. Qual o nivel de isolamento da transcao? Justifique.
    Seu nivel de isolamento sera Serializable, permitindo que a transacao mantenha
    bloqueio de todos os objetos que precisa ler e/ou escrever ate terminar.
*/

/* c. Sera necessario utilizar savepoints e/ou transacoes autonomas? Justifique. 
    Nao serao necessarios savepoints nem transacoes autonomas.
*/
