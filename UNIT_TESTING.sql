TRUNCATE TABLE PRODUTOS CASCADE;
TRUNCATE TABLE VENDEDORES CASCADE;
TRUNCATE TABLE COMPRADORES CASCADE;
TRUNCATE TABLE VENDAS CASCADE;
TRUNCATE TABLE TRANSACOES CASCADE;

INSERT INTO PRODUTOS VALUES ('ARGILA', '11111111111111111111', '2020-01-01', 10.0, 1.0, 1.0, 1.0, 1.0, 1.0, 100.0);
INSERT INTO PRODUTOS VALUES ('CIMENT', '22222222222222222222', '2020-01-01', 20.0, 2.0, 2.0, 2.0, 2.0, 2.0, 100.0);
INSERT INTO PRODUTOS VALUES ('CONCRE', '33333333333333333333', '2020-01-01', 30.0, 3.0, 3.0, 3.0, 3.0, 3.0, 100.0);

INSERT INTO VENDEDORES VALUES ('IDCAR', '11111111111', 'Carlos', 'carlos@carlos.com');
INSERT INTO VENDEDORES VALUES ('IDLUI', '22222222222', 'Luis', 'luis@luis.com');
INSERT INTO VENDEDORES VALUES ('IDPED', '33333333333', 'Pedro', 'pedro@pedro.com');

INSERT INTO COMPRADORES VALUES ('GUST', '12345678901', 'Gustavo', '51111111111', 'Rua 1');
INSERT INTO COMPRADORES VALUES ('LORE', '23456789012', 'Lorenzo', '52222222222', 'Rua 2');
INSERT INTO COMPRADORES VALUES ('SORR', '34567890123', 'Sor', '53333333333', 'Rua 3');

INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-01-01', 'IDCAR', 'GUST');

SELECT * FROM TRANSACOES;

INSERT INTO TRANSACOES VALUES ('ARGILA', 1, 1); /* VENDA 1 - 1x ARGILA - TOTAL 10 */
INSERT INTO TRANSACOES VALUES ('CONCRE', 1, 4); /* VENDA 1 - 4x CONCRE - TOTAL 120 */

SELECT * FROM VENDAS_MENSAIS;
SELECT * FROM VENDAS_SUMARIZADAS;
SELECT * FROM ESTOQUE_DISPONIVEL;