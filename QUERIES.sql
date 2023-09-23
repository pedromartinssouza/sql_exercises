DROP VIEW IF EXISTS VENDAS_MENSAIS;
DROP VIEW IF EXISTS VENDAS_SUMARIZADAS;
DROP VIEW IF EXISTS ESTOQUE_DISPONIVEL;
DROP TABLE IF EXISTS TRANSACOES;
DROP TABLE IF EXISTS VENDAS;
DROP TABLE IF EXISTS PRODUTOS;
DROP TABLE IF EXISTS VENDEDORES;
DROP TABLE IF EXISTS COMPRADORES;

--#region CREATE_TABLES

CREATE TABLE PRODUTOS (
    ID_PRODUTO CHAR(20) NOT NULL,
    CODIGO_DE_BARRAS CHAR(20) NOT NULL,
    DATA_FABRICACAO DATE NOT NULL,
    CUSTO_UNITARIO REAL NOT NULL DEFAULT 0.0 CHECK (CUSTO_UNITARIO >= 0.0),
    MASSA REAL CHECK (MASSA >= 0.0),
    VOLUME REAL CHECK (VOLUME >= 0.0),
    LARGURA REAL CHECK (LARGURA >= 0.0),
    ALTURA REAL CHECK (ALTURA >= 0.0),
    COMPRIMENTO REAL CHECK (COMPRIMENTO >= 0.0),
    QUANTIDADE_INICIAL REAL NOT NULL CHECK (QUANTIDADE_INICIAL >= 0.0),
    PRIMARY KEY (ID_PRODUTO)
);

CREATE TABLE VENDEDORES (
    ID_VENDEDOR CHAR(8) NOT NULL,
    CPF CHAR(11) NOT NULL,
    NOME CHAR(100) NOT NULL,
    EMAIL CHAR(100) NOT NULL,
    PRIMARY KEY (ID_VENDEDOR)
);

CREATE TABLE COMPRADORES (
    ID_COMPRADOR CHAR(8) NOT NULL,
    CPF CHAR(11) NOT NULL,
    NOME CHAR(100) NOT NULL,
    TELEFONE CHAR(13),
    ENDERECO CHAR(100),
    PRIMARY KEY (ID_COMPRADOR)
);

CREATE TABLE VENDAS (
    ID_VENDA SERIAL NOT NULL, 
    DATA_VENDA DATE NOT NULL CHECK (DATA_VENDA <= CURRENT_DATE),
    ID_VENDEDOR CHAR(8) NOT NULL,
    ID_COMPRADOR CHAR(8) NOT NULL,
    PRIMARY KEY (ID_VENDA),
    FOREIGN KEY (ID_VENDEDOR) REFERENCES VENDEDORES(ID_VENDEDOR),
    FOREIGN KEY (ID_COMPRADOR) REFERENCES COMPRADORES(ID_COMPRADOR)
);
CREATE INDEX IDX_VENDA ON VENDAS (DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR);

CREATE TABLE TRANSACOES (
    ID_PRODUTO CHAR(20) NOT NULL,
    ID_VENDA INTEGER NOT NULL,
    QUANTIDADE INTEGER NOT NULL CHECK (QUANTIDADE > 0),
    PRIMARY KEY (ID_VENDA, ID_PRODUTO),
    FOREIGN KEY (ID_PRODUTO) REFERENCES PRODUTOS(ID_PRODUTO),
    FOREIGN KEY (ID_VENDA) REFERENCES VENDAS(ID_VENDA) ON DELETE CASCADE
);
CREATE INDEX IDX_VENDA_T ON TRANSACOES (ID_VENDA);

--#endregion

--#region VIEWS
CREATE VIEW VENDAS_MENSAIS (VENDEDOR, NOME, QUANTIDADE_VENDIDA, VALOR_TOTAL) AS
    SELECT 
        VENDAS.ID_VENDEDOR, VENDEDORES.NOME, SUM(TRANSACOES.QUANTIDADE), SUM(TRANSACOES.QUANTIDADE * PRODUTOS.CUSTO_UNITARIO)
    FROM
        VENDAS
        LEFT JOIN TRANSACOES ON VENDAS.ID_VENDA = TRANSACOES.ID_VENDA
        LEFT JOIN PRODUTOS ON TRANSACOES.ID_PRODUTO = PRODUTOS.ID_PRODUTO
        LEFT JOIN VENDEDORES ON VENDAS.ID_VENDEDOR = VENDEDORES.ID_VENDEDOR
    WHERE 
        TRANSACOES.ID_PRODUTO = PRODUTOS.ID_PRODUTO AND
        DATA_VENDA >= '2020-01-01' AND DATA_VENDA <= '2020-01-31'
    GROUP BY
        VENDAS.ID_VENDEDOR, VENDEDORES.NOME;

CREATE VIEW VENDAS_SUMARIZADAS (ID_VENDA, VALOR_TOTAL, PRODUTOS, NOME_VENDEDOR, NOME_COMPRADOR) AS
    SELECT 
        VENDAS.ID_VENDA,
        SUM(TRANSACOES.QUANTIDADE * PRODUTOS.CUSTO_UNITARIO),
        STRING_AGG(PRODUTOS.ID_PRODUTO, ','),
        VENDEDORES.NOME,
        COMPRADORES.NOME
    FROM
        VENDAS
        LEFT JOIN TRANSACOES ON VENDAS.ID_VENDA = TRANSACOES.ID_VENDA
        LEFT JOIN PRODUTOS ON TRANSACOES.ID_PRODUTO = PRODUTOS.ID_PRODUTO
        LEFT JOIN VENDEDORES ON VENDAS.ID_VENDEDOR = VENDEDORES.ID_VENDEDOR
        LEFT JOIN COMPRADORES ON VENDAS.ID_COMPRADOR = COMPRADORES.ID_COMPRADOR
    GROUP BY
        VENDAS.ID_VENDA,
        VENDEDORES.NOME,
        COMPRADORES.NOME
    ORDER BY
        VENDAS.DATA_VENDA DESC,
        VENDAS.ID_VENDEDOR DESC,
        VENDAS.ID_COMPRADOR DESC;

CREATE VIEW ESTOQUE_DISPONIVEL (ID_PRODUTO, QUANTIDADE_DISPONIVEL) AS
    SELECT 
        PRODUTOS.ID_PRODUTO, PRODUTOS.QUANTIDADE_INICIAL - SUM(TRANSACOES.QUANTIDADE)
    FROM
        PRODUTOS
        LEFT JOIN TRANSACOES ON PRODUTOS.ID_PRODUTO = TRANSACOES.ID_PRODUTO
    GROUP BY
        PRODUTOS.ID_PRODUTO;
--#endregion

--#region INSERTS
INSERT INTO PRODUTOS VALUES ('ARGILA', '11111111111111111111', '2020-01-01', 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 100.0);
INSERT INTO PRODUTOS VALUES ('CIMENT', '22222222222222222222', '2020-01-01', 1.0, 2.0, 2.0, 2.0, 2.0, 2.0, 100.0);
INSERT INTO PRODUTOS VALUES ('CONCRE', '33333333333333333333', '2020-01-01', 1.0, 3.0, 3.0, 3.0, 3.0, 3.0, 100.0);

INSERT INTO VENDEDORES VALUES ('IDCAR', '11111111111', 'Carlos', 'carlos@carlos.com');
INSERT INTO VENDEDORES VALUES ('IDLUI', '22222222222', 'Luis', 'luis@luis.com');
INSERT INTO VENDEDORES VALUES ('IDPED', '33333333333', 'Pedro', 'pedro@pedro.com');

INSERT INTO COMPRADORES VALUES ('GUST', '12345678901', 'Gustavo', '51111111111', 'Rua 1');
INSERT INTO COMPRADORES VALUES ('LORE', '23456789012', 'Lorenzo', '52222222222', 'Rua 2');
INSERT INTO COMPRADORES VALUES ('SORR', '34567890123', 'Sor', '53333333333', 'Rua 3');

INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-01-01', 'IDCAR', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-02-03', 'IDLUI', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-02-04', 'IDLUI', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-03-05', 'IDPED', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-03-06', 'IDPED', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-04-07', 'IDCAR', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-04-08', 'IDCAR', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-05-09', 'IDLUI', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-05-10', 'IDLUI', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-06-11', 'IDPED', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-06-12', 'IDPED', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-07-13', 'IDCAR', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-07-14', 'IDCAR', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-08-15', 'IDLUI', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-08-16', 'IDLUI', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-09-17', 'IDPED', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-09-18', 'IDPED', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-10-19', 'IDCAR', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-10-20', 'IDCAR', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-11-21', 'IDLUI', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-11-22', 'IDLUI', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-12-23', 'IDPED', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-12-24', 'IDPED', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-01-01', 'IDPED', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-01-02', 'IDPED', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-02-03', 'IDLUI', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-02-04', 'IDLUI', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-03-05', 'IDCAR', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-03-06', 'IDCAR', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-04-07', 'IDPED', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-04-08', 'IDPED', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-05-09', 'IDLUI', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-05-10', 'IDLUI', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-06-11', 'IDCAR', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-06-12', 'IDCAR', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-07-13', 'IDPED', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-07-14', 'IDPED', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-08-15', 'IDLUI', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-08-16', 'IDLUI', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-09-17', 'IDCAR', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-09-18', 'IDPED', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-10-19', 'IDLUI', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-10-20', 'IDLUI', 'LORE');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-11-21', 'IDCAR', 'GUST');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-11-22', 'IDCAR', 'SORR');
INSERT INTO VENDAS(DATA_VENDA, ID_VENDEDOR, ID_COMPRADOR) VALUES ('2020-12-24', 'IDPED', 'GUST');

INSERT INTO TRANSACOES VALUES ('ARGILA', 1, 1);
INSERT INTO TRANSACOES VALUES ('CONCRE', 1, 4);
INSERT INTO TRANSACOES VALUES ('ARGILA', 2, 5);
INSERT INTO TRANSACOES VALUES ('ARGILA', 3, 6);
INSERT INTO TRANSACOES VALUES ('CIMENT', 4, 12);
INSERT INTO TRANSACOES VALUES ('CIMENT', 5, 16);
INSERT INTO TRANSACOES VALUES ('CIMENT', 6, 1);
INSERT INTO TRANSACOES VALUES ('CIMENT', 7, 4);
INSERT INTO TRANSACOES VALUES ('CONCRE', 8, 6);
INSERT INTO TRANSACOES VALUES ('CONCRE', 9, 5);
INSERT INTO TRANSACOES VALUES ('CONCRE', 10, 8);
INSERT INTO TRANSACOES VALUES ('CONCRE', 11, 19);
INSERT INTO TRANSACOES VALUES ('ARGILA', 12, 8);
INSERT INTO TRANSACOES VALUES ('ARGILA', 13, 11);
INSERT INTO TRANSACOES VALUES ('ARGILA', 14, 12);
INSERT INTO TRANSACOES VALUES ('ARGILA', 15, 3);
INSERT INTO TRANSACOES VALUES ('CIMENT', 16, 6);
INSERT INTO TRANSACOES VALUES ('CIMENT', 17, 7);
INSERT INTO TRANSACOES VALUES ('CIMENT', 18, 6);
INSERT INTO TRANSACOES VALUES ('CIMENT', 19, 9);
INSERT INTO TRANSACOES VALUES ('CONCRE', 20, 1);
INSERT INTO TRANSACOES VALUES ('CONCRE', 21, 1);
INSERT INTO TRANSACOES VALUES ('CONCRE', 22, 1);
INSERT INTO TRANSACOES VALUES ('ARGILA', 22, 9);
INSERT INTO TRANSACOES VALUES ('CONCRE', 23, 11);
INSERT INTO TRANSACOES VALUES ('CONCRE', 24, 4);
INSERT INTO TRANSACOES VALUES ('CONCRE', 25, 2);
INSERT INTO TRANSACOES VALUES ('CONCRE', 26, 1);
INSERT INTO TRANSACOES VALUES ('CONCRE', 27, 7);
INSERT INTO TRANSACOES VALUES ('CIMENT', 28, 8);
INSERT INTO TRANSACOES VALUES ('CIMENT', 29, 9);
INSERT INTO TRANSACOES VALUES ('CIMENT', 30, 1);
INSERT INTO TRANSACOES VALUES ('CIMENT', 31, 1);
INSERT INTO TRANSACOES VALUES ('ARGILA', 32, 2);
INSERT INTO TRANSACOES VALUES ('ARGILA', 33, 4);
INSERT INTO TRANSACOES VALUES ('ARGILA', 34, 3);
INSERT INTO TRANSACOES VALUES ('ARGILA', 35, 5);
INSERT INTO TRANSACOES VALUES ('CONCRE', 36, 14);
INSERT INTO TRANSACOES VALUES ('CONCRE', 37, 2);
INSERT INTO TRANSACOES VALUES ('CONCRE', 38, 2);
INSERT INTO TRANSACOES VALUES ('CONCRE', 39, 15);
INSERT INTO TRANSACOES VALUES ('CIMENT', 40, 2);
INSERT INTO TRANSACOES VALUES ('CIMENT', 41, 3);
INSERT INTO TRANSACOES VALUES ('CIMENT', 42, 8);
INSERT INTO TRANSACOES VALUES ('CIMENT', 43, 7);
INSERT INTO TRANSACOES VALUES ('ARGILA', 44, 6);
INSERT INTO TRANSACOES VALUES ('ARGILA', 45, 8);
INSERT INTO TRANSACOES VALUES ('ARGILA', 46, 4);
--#endregion

SELECT * FROM VENDAS_MENSAIS;
SELECT * FROM VENDAS_SUMARIZADAS;
SELECT * FROM ESTOQUE_DISPONIVEL;