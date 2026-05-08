-- ============================================================
-- SisGESC - Sistema de Gestão Escolar
-- Fase 6: Script de RESET
-- ATENÇÃO: Apaga todos os dados e estruturas do banco!
-- ============================================================

USE sisgesc;

-- Desabilita checagem de FK para permitir DROP na ordem correta
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- DROP das tabelas OLAP
-- ============================================================
DROP TABLE IF EXISTS fato_financeiro;
DROP TABLE IF EXISTS dim_tempo;
DROP TABLE IF EXISTS dim_aluno;
DROP TABLE IF EXISTS dim_curso;
DROP TABLE IF EXISTS dim_unidade;

-- ============================================================
-- DROP das tabelas OLTP - Módulo Financeiro
-- ============================================================
DROP TABLE IF EXISTS pagamentos;
DROP TABLE IF EXISTS mensalidades;

-- ============================================================
-- DROP das tabelas OLTP - Módulo RH
-- ============================================================
DROP TABLE IF EXISTS folha_pagamento;
DROP TABLE IF EXISTS funcionarios;
DROP TABLE IF EXISTS cargos;

-- ============================================================
-- DROP das tabelas OLTP - Módulo Acadêmico
-- ============================================================
DROP TABLE IF EXISTS matriculas;
DROP TABLE IF EXISTS disciplinas;
DROP TABLE IF EXISTS alunos;
DROP TABLE IF EXISTS professores;
DROP TABLE IF EXISTS cursos;
DROP TABLE IF EXISTS unidades;

-- Reabilita checagem de FK
SET FOREIGN_KEY_CHECKS = 1;

-- Confirmação
SELECT 'Reset concluído com sucesso.' AS status;
