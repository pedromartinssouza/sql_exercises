TRUNCATE TABLE PRODUTOS CASCADE;
TRUNCATE TABLE VENDEDORES CASCADE;
TRUNCATE TABLE COMPRADORES CASCADE;
TRUNCATE TABLE VENDAS RESTART IDENTITY CASCADE;
TRUNCATE TABLE TRANSACOES RESTART IDENTITY CASCADE;

INSERT INTO PRODUTOS VALUES ('ARGILA', '11111111111111111111', '2020-01-01', 10.0, 1.0, 1.0, 1.0, 1.0, 1.0, 100.0);
INSERT INTO PRODUTOS VALUES ('CIMENT', '22222222222222222222', '2020-01-01', 20.0, 2.0, 2.0, 2.0, 2.0, 2.0, 100.0);
INSERT INTO PRODUTOS VALUES ('CONCRE', '33333333333333333333', '2020-01-01', 30.0, 3.0, 3.0, 3.0, 3.0, 3.0, 100.0);

INSERT INTO VENDEDORES VALUES ('IDCAR', '11111111111', 'Carlos', 'carlos@carlos.com');
INSERT INTO VENDEDORES VALUES ('IDLUI', '22222222222', 'Luis', 'luis@luis.com');
INSERT INTO VENDEDORES VALUES ('IDPED', '33333333333', 'Pedro', 'pedro@pedro.com');

INSERT INTO COMPRADORES VALUES ('GUST', '12345678901', 'Gustavo', '51111111111', 'Rua 1');
INSERT INTO COMPRADORES VALUES ('LORE', '23456789012', 'Lorenzo', '52222222222', 'Rua 2');
INSERT INTO COMPRADORES VALUES ('SORR', '34567890123', 'Sor', '53333333333', 'Rua 3');

INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-01-01', 'IDCAR', 'GUST'); /* VENDA 1 - CARLOS - GUSTAVO */
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-01-15', 'IDCAR', 'GUST'); /* VENDA 2 - CARLOS - GUSTAVO */
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-01-15', 'IDPED', 'SORR'); /* VENDA 3 - PEDRO - SOR      */
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-01-15', 'IDPED', 'LORE'); /* VENDA 4 - PEDRO - LORENZO  */
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2022-01-15', 'IDPED', 'SORR'); /* VENDA 5 - PEDRO - SOR      */

INSERT INTO TRANSACOES VALUES ('ARGILA', 1, 1); /* VENDA 1 - 1x ARGILA - TOTAL 10   */
INSERT INTO TRANSACOES VALUES ('CONCRE', 1, 4); /* VENDA 1 - 4x CONCRE - TOTAL 120  */
INSERT INTO TRANSACOES VALUES ('CONCRE', 2, 1); /* VENDA 2 - 1x CONCRE - TOTAL 30   */
INSERT INTO TRANSACOES VALUES ('CIMENT', 3, 1); /* VENDA 3 - 1x CIMENT - TOTAL 20   */
INSERT INTO TRANSACOES VALUES ('CIMENT', 4, 4); /* VENDA 4 - 4x CIMENT - TOTAL 80   */
INSERT INTO TRANSACOES VALUES ('ARGILA', 5, 3); /* VENDA 5 - 3x ARGILA - TOTAL 30   */


DO $$
    DECLARE
        V_QUANTIDADE_REGISTROS INTEGER;

        V_NOME CHAR(100);
        V_VALOR_TOTAL REAL;
        V_QUANTIDADE_VENDIDA INTEGER;

    BEGIN
        RAISE NOTICE 'TESTE 1 - TESTANDO VIEW VENDAS_MENSAIS';

        BEGIN
            SELECT COUNT(*) INTO V_QUANTIDADE_REGISTROS FROM VENDAS_MENSAIS;
            IF V_QUANTIDADE_REGISTROS = 3 THEN
                RAISE NOTICE 'OK - TESTE 1A - QUANTIDADE DE REGISTROS';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 1A - QUANTIDADE DE REGISTROS';
            END IF;
        END;
        BEGIN
            SELECT VALOR_TOTAL INTO V_VALOR_TOTAL FROM VENDAS_MENSAIS WHERE VENDEDOR = 'IDCAR';
            IF V_VALOR_TOTAL = 160.0 THEN
                RAISE NOTICE 'OK - TESTE 1B - VENDA IDCAR';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 1B - VENDA IDCAR';
            END IF;
        END;
        BEGIN
            SELECT NOME, QUANTIDADE_VENDIDA, VALOR_TOTAL INTO V_NOME, V_QUANTIDADE_VENDIDA, V_VALOR_TOTAL
            FROM VENDAS_MENSAIS WHERE VENDEDOR = 'IDPED' AND MES = '2022-01';
        
            IF V_VALOR_TOTAL = 30.0 AND V_QUANTIDADE_VENDIDA = 3 AND V_NOME = 'Pedro' THEN
                RAISE NOTICE 'OK - TESTE 1C - VENDA IDPED 2022-01';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 1C - SOMA VENDAS IDPED';
            END IF;
        END;
        BEGIN
            SELECT NOME, QUANTIDADE_VENDIDA, VALOR_TOTAL INTO V_NOME, V_QUANTIDADE_VENDIDA, V_VALOR_TOTAL
            FROM VENDAS_MENSAIS WHERE VENDEDOR = 'IDCAR' AND MES = '2020-01';
        
            IF V_VALOR_TOTAL = 160.0 AND V_QUANTIDADE_VENDIDA = 6 AND V_NOME = 'Carlos' THEN
                RAISE NOTICE 'OK - TESTE 1D - VENDA IDCAR 2020-01';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 1D - SOMA VENDAS IDCAR';
            END IF;
        END;
        BEGIN
            SELECT NOME, QUANTIDADE_VENDIDA, VALOR_TOTAL INTO V_NOME, V_QUANTIDADE_VENDIDA, V_VALOR_TOTAL
            FROM VENDAS_MENSAIS WHERE VENDEDOR = 'IDPED' AND MES = '2020-01';
        
            IF V_VALOR_TOTAL = 100.0 AND V_QUANTIDADE_VENDIDA = 5 AND V_NOME = 'Pedro' THEN
                RAISE NOTICE 'OK - TESTE 1E - VENDA IDPED 2020-01';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 1E - SOMA VENDAS IDPED';
            END IF;
        END;
    END;
$$;

DO $$
    DECLARE
        V_QUANTIDADE_REGISTROS INTEGER;

        V_VALOR_TOTAL REAL;
        V_PRODUTOS TEXT;
        V_NOME_VENDEDOR CHAR(100);
        V_NOME_COMPRADOR CHAR(100);

    BEGIN
        RAISE NOTICE 'TESTE 2 - TESTANDO VIEW VENDAS_SUMARIZADAS';

        BEGIN
            SELECT COUNT(*) INTO V_QUANTIDADE_REGISTROS FROM VENDAS_SUMARIZADAS;
            IF V_QUANTIDADE_REGISTROS = 5 THEN
                RAISE NOTICE 'OK - TESTE 2A - QUANTIDADE DE REGISTROS';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 2A - QUANTIDADE DE REGISTROS';
            END IF;
        END;
        BEGIN
            SELECT VALOR_TOTAL, PRODUTOS, NOME_VENDEDOR, NOME_COMPRADOR 
            INTO V_VALOR_TOTAL, V_PRODUTOS, V_NOME_VENDEDOR, V_NOME_COMPRADOR 
            FROM VENDAS_SUMARIZADAS WHERE ID_VENDA = 1;

            IF V_VALOR_TOTAL = 130.0 AND V_PRODUTOS = 'ARGILA,CONCRE' AND V_NOME_VENDEDOR = 'Carlos' AND V_NOME_COMPRADOR = 'Gustavo' THEN
                RAISE NOTICE 'OK - TESTE 2B - VENDA 1';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 2B - VENDA 1';
            END IF;
        END;
        BEGIN
            DELETE FROM TRANSACOES WHERE ID_VENDA = 1 AND ID_PRODUTO = 'ARGILA';
            SELECT VALOR_TOTAL, PRODUTOS, NOME_VENDEDOR, NOME_COMPRADOR 
            INTO V_VALOR_TOTAL, V_PRODUTOS, V_NOME_VENDEDOR, V_NOME_COMPRADOR 
            FROM VENDAS_SUMARIZADAS WHERE ID_VENDA = 1;

            IF V_VALOR_TOTAL = 120.0 AND V_PRODUTOS = 'CONCRE' AND V_NOME_VENDEDOR = 'Carlos' AND V_NOME_COMPRADOR = 'Gustavo' THEN
                RAISE NOTICE 'OK - TESTE 2C - VENDA 1 SEM ARGILA';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 2C - VENDA 1 SEM ARGILA';
            END IF;
        END;
        BEGIN
            SELECT VALOR_TOTAL, PRODUTOS, NOME_VENDEDOR, NOME_COMPRADOR 
            INTO V_VALOR_TOTAL, V_PRODUTOS, V_NOME_VENDEDOR, V_NOME_COMPRADOR 
            FROM VENDAS_SUMARIZADAS WHERE ID_VENDA = 2;

            IF V_VALOR_TOTAL = 30.0 AND V_PRODUTOS = 'CONCRE' AND V_NOME_VENDEDOR = 'Carlos' AND V_NOME_COMPRADOR = 'Gustavo' THEN
                RAISE NOTICE 'OK - TESTE 2D - VENDA 2';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 2D - VENDA 2';
            END IF;
        END;
        BEGIN
            SELECT VALOR_TOTAL, PRODUTOS, NOME_VENDEDOR, NOME_COMPRADOR 
            INTO V_VALOR_TOTAL, V_PRODUTOS, V_NOME_VENDEDOR, V_NOME_COMPRADOR 
            FROM VENDAS_SUMARIZADAS WHERE ID_VENDA = 3;

            IF V_VALOR_TOTAL = 20.0 AND V_PRODUTOS = 'CIMENT' AND V_NOME_VENDEDOR = 'Pedro' AND V_NOME_COMPRADOR = 'Sor' THEN
                RAISE NOTICE 'OK - TESTE 2E - VENDA 3';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 2E - VENDA 3';
            END IF;
        END;
        BEGIN
            SELECT VALOR_TOTAL, PRODUTOS, NOME_VENDEDOR, NOME_COMPRADOR 
            INTO V_VALOR_TOTAL, V_PRODUTOS, V_NOME_VENDEDOR, V_NOME_COMPRADOR 
            FROM VENDAS_SUMARIZADAS WHERE ID_VENDA = 4;

            IF V_VALOR_TOTAL = 80.0 AND V_PRODUTOS = 'CIMENT' AND V_NOME_VENDEDOR = 'Pedro' AND V_NOME_COMPRADOR = 'Lorenzo' THEN
                RAISE NOTICE 'OK - TESTE 2F - VENDA 4';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 2F - VENDA 4';
            END IF;
        END;
        BEGIN
            SELECT VALOR_TOTAL, PRODUTOS, NOME_VENDEDOR, NOME_COMPRADOR 
            INTO V_VALOR_TOTAL, V_PRODUTOS, V_NOME_VENDEDOR, V_NOME_COMPRADOR 
            FROM VENDAS_SUMARIZADAS WHERE ID_VENDA = 5;

            IF V_VALOR_TOTAL = 30.0 AND V_PRODUTOS = 'ARGILA' AND V_NOME_VENDEDOR = 'Pedro' AND V_NOME_COMPRADOR = 'Sor' THEN
                RAISE NOTICE 'OK - TESTE 2G - VENDA 5';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 2G - VENDA 5';
            END IF;
        END;
    END;
$$;

DO $$
    DECLARE
        V_QUANTIDADE_REGISTROS INTEGER;

        V_QUANTIDADE_DISPONIVEL REAL;
    
    BEGIN
        RAISE NOTICE 'TESTE 3 - TESTANDO VIEW ESTOQUE_DISPONIVEL';

        BEGIN
            SELECT COUNT(*) INTO V_QUANTIDADE_REGISTROS FROM ESTOQUE_DISPONIVEL;
            IF V_QUANTIDADE_REGISTROS = 3 THEN
                RAISE NOTICE 'OK - TESTE 3A - QUANTIDADE DE REGISTROS';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 3A - QUANTIDADE DE REGISTROS';
            END IF;
        END;
        BEGIN
            SELECT QUANTIDADE_DISPONIVEL INTO V_QUANTIDADE_DISPONIVEL FROM ESTOQUE_DISPONIVEL WHERE ID_PRODUTO = 'ARGILA';
            IF V_QUANTIDADE_DISPONIVEL = 97.0 THEN
                RAISE NOTICE 'OK - TESTE 3B - QUANTIDADE DISPONIVEL ARGILA';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 3B - QUANTIDADE DISPONIVEL ARGILA';
            END IF;
        END;
        BEGIN
            SELECT QUANTIDADE_DISPONIVEL INTO V_QUANTIDADE_DISPONIVEL FROM ESTOQUE_DISPONIVEL WHERE ID_PRODUTO = 'CIMENT';
            IF V_QUANTIDADE_DISPONIVEL = 95.0 THEN
                RAISE NOTICE 'OK - TESTE 3C - QUANTIDADE DISPONIVEL CIMENT';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 3C - QUANTIDADE DISPONIVEL CIMENT';
            END IF;
        END;
        BEGIN
            SELECT QUANTIDADE_DISPONIVEL INTO V_QUANTIDADE_DISPONIVEL FROM ESTOQUE_DISPONIVEL WHERE ID_PRODUTO = 'CONCRE';
            IF V_QUANTIDADE_DISPONIVEL = 95.0 THEN
                RAISE NOTICE 'OK - TESTE 3D - QUANTIDADE DISPONIVEL CONCRE';
            ELSE
                RAISE EXCEPTION 'FAIL - TESTE 3D - QUANTIDADE DISPONIVEL CONCRE';
            END IF;
        END;
    END;
$$;