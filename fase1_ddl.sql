-- ============================================================
-- SisGESC - Sistema de Gestão Escolar
-- Fase 1: DDL - Criação das Tabelas (OLTP)
-- Banco: MySQL / MariaDB
-- Padrão: snake_case
-- ============================================================

-- Script de criação do schema
CREATE DATABASE IF NOT EXISTS sisgesc;
USE sisgesc;

-- ============================================================
-- MÓDULO ACADÊMICO
-- ============================================================

-- Tabela: cursos
CREATE TABLE IF NOT EXISTS cursos (
    id_curso        INT             NOT NULL AUTO_INCREMENT,
    nome_curso      VARCHAR(100)    NOT NULL,
    carga_horaria   INT             NOT NULL,
    modalidade      ENUM('presencial','ead','hibrido') NOT NULL DEFAULT 'presencial',
    ativo           TINYINT(1)      NOT NULL DEFAULT 1,
    criado_em       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_cursos PRIMARY KEY (id_curso),
    CONSTRAINT uq_cursos_nome UNIQUE (nome_curso)
);

-- Tabela: unidades
CREATE TABLE IF NOT EXISTS unidades (
    id_unidade      INT             NOT NULL AUTO_INCREMENT,
    nome_unidade    VARCHAR(100)    NOT NULL,
    cidade          VARCHAR(80)     NOT NULL,
    estado          CHAR(2)         NOT NULL,
    ativo           TINYINT(1)      NOT NULL DEFAULT 1,
    CONSTRAINT pk_unidades PRIMARY KEY (id_unidade),
    CONSTRAINT uq_unidades_nome UNIQUE (nome_unidade)
);

-- Tabela: alunos
CREATE TABLE IF NOT EXISTS alunos (
    id_aluno        INT             NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(120)    NOT NULL,
    cpf             CHAR(11)        NOT NULL,
    email           VARCHAR(120)    NOT NULL,
    data_nascimento DATE            NOT NULL,
    id_curso        INT             NOT NULL,
    id_unidade      INT             NOT NULL,
    saldo           DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    ativo           TINYINT(1)      NOT NULL DEFAULT 1,
    criado_em       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_alunos PRIMARY KEY (id_aluno),
    CONSTRAINT uq_alunos_cpf UNIQUE (cpf),
    CONSTRAINT uq_alunos_email UNIQUE (email),
    CONSTRAINT fk_alunos_curso FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    CONSTRAINT fk_alunos_unidade FOREIGN KEY (id_unidade) REFERENCES unidades(id_unidade)
);

-- Tabela: professores
CREATE TABLE IF NOT EXISTS professores (
    id_professor    INT             NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(120)    NOT NULL,
    cpf             CHAR(11)        NOT NULL,
    email           VARCHAR(120)    NOT NULL,
    especialidade   VARCHAR(100)    NOT NULL,
    id_unidade      INT             NOT NULL,
    ativo           TINYINT(1)      NOT NULL DEFAULT 1,
    criado_em       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_professores PRIMARY KEY (id_professor),
    CONSTRAINT uq_professores_cpf UNIQUE (cpf),
    CONSTRAINT uq_professores_email UNIQUE (email),
    CONSTRAINT fk_professores_unidade FOREIGN KEY (id_unidade) REFERENCES unidades(id_unidade)
);

-- Tabela: disciplinas
CREATE TABLE IF NOT EXISTS disciplinas (
    id_disciplina   INT             NOT NULL AUTO_INCREMENT,
    nome_disciplina VARCHAR(100)    NOT NULL,
    id_curso        INT             NOT NULL,
    id_professor    INT             NOT NULL,
    carga_horaria   INT             NOT NULL,
    CONSTRAINT pk_disciplinas PRIMARY KEY (id_disciplina),
    CONSTRAINT fk_disciplinas_curso FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    CONSTRAINT fk_disciplinas_professor FOREIGN KEY (id_professor) REFERENCES professores(id_professor)
);

-- Tabela: matriculas
CREATE TABLE IF NOT EXISTS matriculas (
    id_matricula    INT             NOT NULL AUTO_INCREMENT,
    id_aluno        INT             NOT NULL,
    id_disciplina   INT             NOT NULL,
    data_matricula  DATE            NOT NULL DEFAULT (CURRENT_DATE),
    status          ENUM('ativa','trancada','concluida') NOT NULL DEFAULT 'ativa',
    nota_final      DECIMAL(4,2)    NULL,
    CONSTRAINT pk_matriculas PRIMARY KEY (id_matricula),
    CONSTRAINT uq_matriculas_aluno_disc UNIQUE (id_aluno, id_disciplina),
    CONSTRAINT fk_matriculas_aluno FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno),
    CONSTRAINT fk_matriculas_disciplina FOREIGN KEY (id_disciplina) REFERENCES disciplinas(id_disciplina)
);

-- ============================================================
-- MÓDULO FINANCEIRO
-- ============================================================

-- Tabela: mensalidades
CREATE TABLE IF NOT EXISTS mensalidades (
    id_mensalidade  INT             NOT NULL AUTO_INCREMENT,
    id_aluno        INT             NOT NULL,
    competencia     DATE            NOT NULL,   -- primeiro dia do mês de referência
    valor_original  DECIMAL(10,2)   NOT NULL,
    valor_pago      DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    data_pagamento  DATE            NULL,
    status          ENUM('pendente','pago','atrasado','cancelado') NOT NULL DEFAULT 'pendente',
    CONSTRAINT pk_mensalidades PRIMARY KEY (id_mensalidade),
    CONSTRAINT uq_mensalidades_aluno_comp UNIQUE (id_aluno, competencia),
    CONSTRAINT fk_mensalidades_aluno FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno)
);

-- Tabela: pagamentos
CREATE TABLE IF NOT EXISTS pagamentos (
    id_pagamento    INT             NOT NULL AUTO_INCREMENT,
    id_aluno        INT             NOT NULL,
    id_mensalidade  INT             NOT NULL,
    valor           DECIMAL(10,2)   NOT NULL,
    data_pagamento  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    forma_pagamento ENUM('boleto','cartao','pix','dinheiro') NOT NULL,
    CONSTRAINT pk_pagamentos PRIMARY KEY (id_pagamento),
    CONSTRAINT fk_pagamentos_aluno FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno),
    CONSTRAINT fk_pagamentos_mensalidade FOREIGN KEY (id_mensalidade) REFERENCES mensalidades(id_mensalidade)
);

-- ============================================================
-- MÓDULO RH
-- ============================================================

-- Tabela: cargos
CREATE TABLE IF NOT EXISTS cargos (
    id_cargo        INT             NOT NULL AUTO_INCREMENT,
    nome_cargo      VARCHAR(80)     NOT NULL,
    salario_base    DECIMAL(10,2)   NOT NULL,
    CONSTRAINT pk_cargos PRIMARY KEY (id_cargo),
    CONSTRAINT uq_cargos_nome UNIQUE (nome_cargo)
);

-- Tabela: funcionarios
CREATE TABLE IF NOT EXISTS funcionarios (
    id_funcionario  INT             NOT NULL AUTO_INCREMENT,
    nome            VARCHAR(120)    NOT NULL,
    cpf             CHAR(11)        NOT NULL,
    email           VARCHAR(120)    NOT NULL,
    id_cargo        INT             NOT NULL,
    id_unidade      INT             NOT NULL,
    data_admissao   DATE            NOT NULL,
    salario         DECIMAL(10,2)   NOT NULL,
    ativo           TINYINT(1)      NOT NULL DEFAULT 1,
    CONSTRAINT pk_funcionarios PRIMARY KEY (id_funcionario),
    CONSTRAINT uq_funcionarios_cpf UNIQUE (cpf),
    CONSTRAINT uq_funcionarios_email UNIQUE (email),
    CONSTRAINT fk_funcionarios_cargo FOREIGN KEY (id_cargo) REFERENCES cargos(id_cargo),
    CONSTRAINT fk_funcionarios_unidade FOREIGN KEY (id_unidade) REFERENCES unidades(id_unidade)
);

-- Tabela: folha_pagamento
CREATE TABLE IF NOT EXISTS folha_pagamento (
    id_folha        INT             NOT NULL AUTO_INCREMENT,
    id_funcionario  INT             NOT NULL,
    competencia     DATE            NOT NULL,
    salario_bruto   DECIMAL(10,2)   NOT NULL,
    descontos       DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    salario_liquido DECIMAL(10,2)   NOT NULL,
    CONSTRAINT pk_folha PRIMARY KEY (id_folha),
    CONSTRAINT uq_folha_func_comp UNIQUE (id_funcionario, competencia),
    CONSTRAINT fk_folha_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionarios(id_funcionario)
);

-- ============================================================
-- VALIDAÇÃO DA ESTRUTURA
-- ============================================================
-- Execute após o script para confirmar as tabelas criadas:
-- SELECT table_name, table_rows
-- FROM information_schema.tables
-- WHERE table_schema = 'sisgesc'
-- ORDER BY table_name;
