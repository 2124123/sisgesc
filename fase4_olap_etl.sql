-- ============================================================
-- SisGESC - Sistema de Gestão Escolar
-- Fase 4: OLAP - Star Schema + ETL + Consultas Analíticas
-- ============================================================

USE sisgesc;

-- ============================================================
-- 1. MODELAGEM DIMENSIONAL (Star Schema)
-- Granularidade: 1 linha = 1 pagamento de mensalidade por aluno por mês
-- ============================================================

-- Dimensão Tempo
CREATE TABLE IF NOT EXISTS dim_tempo (
    sk_tempo        INT         NOT NULL AUTO_INCREMENT,
    data_completa   DATE        NOT NULL,
    ano             INT         NOT NULL,
    semestre        INT         NOT NULL,
    trimestre       INT         NOT NULL,
    mes             INT         NOT NULL,
    nome_mes        VARCHAR(20) NOT NULL,
    dia             INT         NOT NULL,
    dia_semana      VARCHAR(15) NOT NULL,
    CONSTRAINT pk_dim_tempo PRIMARY KEY (sk_tempo),
    CONSTRAINT uq_dim_tempo_data UNIQUE (data_completa)
);

-- Dimensão Aluno
CREATE TABLE IF NOT EXISTS dim_aluno (
    sk_aluno        INT             NOT NULL AUTO_INCREMENT,
    id_aluno_oltp   INT             NOT NULL,   -- chave natural do OLTP
    nome_aluno      VARCHAR(120)    NOT NULL,
    email           VARCHAR(120)    NOT NULL,
    CONSTRAINT pk_dim_aluno PRIMARY KEY (sk_aluno),
    CONSTRAINT uq_dim_aluno_oltp UNIQUE (id_aluno_oltp)
);

-- Dimensão Curso
CREATE TABLE IF NOT EXISTS dim_curso (
    sk_curso        INT             NOT NULL AUTO_INCREMENT,
    id_curso_oltp   INT             NOT NULL,
    nome_curso      VARCHAR(100)    NOT NULL,
    modalidade      VARCHAR(20)     NOT NULL,
    CONSTRAINT pk_dim_curso PRIMARY KEY (sk_curso),
    CONSTRAINT uq_dim_curso_oltp UNIQUE (id_curso_oltp)
);

-- Dimensão Unidade
CREATE TABLE IF NOT EXISTS dim_unidade (
    sk_unidade      INT             NOT NULL AUTO_INCREMENT,
    id_unidade_oltp INT             NOT NULL,
    nome_unidade    VARCHAR(100)    NOT NULL,
    cidade          VARCHAR(80)     NOT NULL,
    estado          CHAR(2)         NOT NULL,
    CONSTRAINT pk_dim_unidade PRIMARY KEY (sk_unidade),
    CONSTRAINT uq_dim_unidade_oltp UNIQUE (id_unidade_oltp)
);

-- Tabela Fato Financeiro
CREATE TABLE IF NOT EXISTS fato_financeiro (
    sk_fato         INT             NOT NULL AUTO_INCREMENT,
    sk_tempo        INT             NOT NULL,
    sk_aluno        INT             NOT NULL,
    sk_curso        INT             NOT NULL,
    sk_unidade      INT             NOT NULL,
    id_mensalidade_oltp INT         NOT NULL,   -- chave de auditoria
    valor_original  DECIMAL(10,2)   NOT NULL,
    valor_pago      DECIMAL(10,2)   NOT NULL,
    valor_inadimplente DECIMAL(10,2) NOT NULL,
    status_pagamento VARCHAR(20)    NOT NULL,
    CONSTRAINT pk_fato_financeiro PRIMARY KEY (sk_fato),
    CONSTRAINT uq_fato_mensalidade UNIQUE (id_mensalidade_oltp),
    CONSTRAINT fk_fato_tempo    FOREIGN KEY (sk_tempo)    REFERENCES dim_tempo(sk_tempo),
    CONSTRAINT fk_fato_aluno    FOREIGN KEY (sk_aluno)    REFERENCES dim_aluno(sk_aluno),
    CONSTRAINT fk_fato_curso    FOREIGN KEY (sk_curso)    REFERENCES dim_curso(sk_curso),
    CONSTRAINT fk_fato_unidade  FOREIGN KEY (sk_unidade)  REFERENCES dim_unidade(sk_unidade)
);

-- ============================================================
-- 2. PROCESSO ETL (Extração → Transformação → Carga)
-- ============================================================

-- -------------------------------------------------
-- ETL - EXTRAÇÃO E CARGA: dim_tempo
-- Popula datas a partir das competências existentes
-- -------------------------------------------------
INSERT IGNORE INTO dim_tempo (data_completa, ano, semestre, trimestre, mes, nome_mes, dia, dia_semana)
SELECT DISTINCT
    m.competencia                                           AS data_completa,
    YEAR(m.competencia)                                     AS ano,
    IF(MONTH(m.competencia) <= 6, 1, 2)                    AS semestre,
    QUARTER(m.competencia)                                  AS trimestre,
    MONTH(m.competencia)                                    AS mes,
    MONTHNAME(m.competencia)                                AS nome_mes,
    DAY(m.competencia)                                      AS dia,
    DAYNAME(m.competencia)                                  AS dia_semana
FROM mensalidades m;

-- -------------------------------------------------
-- ETL - EXTRAÇÃO E CARGA: dim_aluno
-- -------------------------------------------------
INSERT IGNORE INTO dim_aluno (id_aluno_oltp, nome_aluno, email)
SELECT
    a.id_aluno,
    a.nome,
    a.email
FROM alunos a;

-- -------------------------------------------------
-- ETL - EXTRAÇÃO E CARGA: dim_curso
-- -------------------------------------------------
INSERT IGNORE INTO dim_curso (id_curso_oltp, nome_curso, modalidade)
SELECT
    c.id_curso,
    c.nome_curso,
    c.modalidade
FROM cursos c;

-- -------------------------------------------------
-- ETL - EXTRAÇÃO E CARGA: dim_unidade
-- -------------------------------------------------
INSERT IGNORE INTO dim_unidade (id_unidade_oltp, nome_unidade, cidade, estado)
SELECT
    u.id_unidade,
    u.nome_unidade,
    u.cidade,
    u.estado
FROM unidades u;

-- -------------------------------------------------
-- ETL - EXTRAÇÃO, TRANSFORMAÇÃO E CARGA: fato_financeiro
-- Combina dados do OLTP com surrogate keys das dimensões
-- -------------------------------------------------
INSERT IGNORE INTO fato_financeiro (
    sk_tempo,
    sk_aluno,
    sk_curso,
    sk_unidade,
    id_mensalidade_oltp,
    valor_original,
    valor_pago,
    valor_inadimplente,
    status_pagamento
)
SELECT
    dt.sk_tempo,
    da.sk_aluno,
    dc.sk_curso,
    du.sk_unidade,
    m.id_mensalidade,
    m.valor_original,
    m.valor_pago,
    -- Transformação: calcula inadimplência
    ROUND(m.valor_original - m.valor_pago, 2)   AS valor_inadimplente,
    m.status
FROM mensalidades m
JOIN alunos       a  ON a.id_aluno    = m.id_aluno
JOIN cursos       c  ON c.id_curso    = a.id_curso
JOIN unidades     u  ON u.id_unidade  = a.id_unidade
-- Junções com dimensões OLAP (surrogate keys)
JOIN dim_tempo    dt ON dt.data_completa = m.competencia
JOIN dim_aluno    da ON da.id_aluno_oltp = a.id_aluno
JOIN dim_curso    dc ON dc.id_curso_oltp = c.id_curso
JOIN dim_unidade  du ON du.id_unidade_oltp = u.id_unidade;

-- ============================================================
-- 3. VALIDAÇÃO OBRIGATÓRIA: OLTP = OLAP
-- Os valores abaixo DEVEM ser idênticos
-- ============================================================
SELECT 'OLTP' AS origem, SUM(valor_pago) AS total_pago FROM mensalidades
UNION ALL
SELECT 'OLAP',           SUM(valor_pago) FROM fato_financeiro;
-- Resultado esperado: mesma soma nos dois lados ✔

-- ============================================================
-- 4. CONSULTAS ANALÍTICAS (OLAP)
-- ============================================================

-- 4.1 Faturamento por mês
SELECT
    dt.nome_mes,
    dt.ano,
    SUM(ff.valor_pago)      AS faturamento,
    SUM(ff.valor_original)  AS faturamento_previsto,
    SUM(ff.valor_inadimplente) AS inadimplencia
FROM fato_financeiro ff
JOIN dim_tempo dt ON ff.sk_tempo = dt.sk_tempo
GROUP BY dt.ano, dt.mes, dt.nome_mes
ORDER BY dt.ano, dt.mes;

-- 4.2 Faturamento por curso
SELECT
    dc.nome_curso,
    COUNT(ff.sk_fato)       AS qtd_mensalidades,
    SUM(ff.valor_pago)      AS receita_total,
    ROUND(AVG(ff.valor_pago), 2) AS ticket_medio
FROM fato_financeiro ff
JOIN dim_curso dc ON ff.sk_curso = dc.sk_curso
GROUP BY dc.sk_curso, dc.nome_curso
ORDER BY receita_total DESC;

-- 4.3 Inadimplência por unidade
SELECT
    du.nome_unidade,
    du.cidade,
    SUM(ff.valor_inadimplente) AS total_inadimplente,
    COUNT(CASE WHEN ff.status_pagamento IN ('pendente','atrasado') THEN 1 END) AS qtd_em_aberto
FROM fato_financeiro ff
JOIN dim_unidade du ON ff.sk_unidade = du.sk_unidade
GROUP BY du.sk_unidade, du.nome_unidade, du.cidade
ORDER BY total_inadimplente DESC;

-- 4.4 Ranking de alunos por valor pago (análise por semestre)
SELECT
    da.nome_aluno,
    dt.ano,
    dt.semestre,
    SUM(ff.valor_pago) AS total_pago
FROM fato_financeiro ff
JOIN dim_aluno da ON ff.sk_aluno = da.sk_aluno
JOIN dim_tempo dt ON ff.sk_tempo = dt.sk_tempo
GROUP BY da.sk_aluno, da.nome_aluno, dt.ano, dt.semestre
ORDER BY dt.ano, dt.semestre, total_pago DESC;
