-- ============================================================
-- SisGESC - Sistema de Gestão Escolar
-- run_all.sql — Script único de instalação completa
--
-- Como executar no terminal MySQL:
--   mysql -u root -p < run_all.sql
--
-- Como executar no VS Code (extensão MySQL/SQLTools):
--   Abrir este arquivo e executar tudo de uma vez
-- ============================================================

-- Fase 1: Criação da estrutura (DDL)
SOURCE fase1_ddl.sql;

-- Fase 2: Carga de dados idempotente (DML)
SOURCE fase2_dml.sql;

-- Fase 3: Demonstrações OLTP
SOURCE fase3_oltp.sql;

-- Fase 4: OLAP - Star Schema + ETL
SOURCE fase4_olap_etl.sql;

-- Fase 5: Índices e performance
SOURCE fase5_performance.sql;

-- ============================================================
-- Execução concluída!
-- Para resetar tudo: execute fase6_reset.sql
-- ============================================================
SELECT 'SisGESC instalado com sucesso!' AS resultado;
