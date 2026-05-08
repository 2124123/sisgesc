-- ============================================================
-- SisGESC - Sistema de Gestão Escolar
-- Fase 5: Performance e Otimização
-- ============================================================

USE sisgesc;

-- ============================================================
-- 1. CRIAÇÃO DE ÍNDICES (OLTP)
-- Foco: FKs e colunas usadas em JOINs e filtros frequentes
-- ============================================================

-- Índices na tabela alunos
CREATE INDEX IF NOT EXISTS idx_alunos_id_curso    ON alunos(id_curso);
CREATE INDEX IF NOT EXISTS idx_alunos_id_unidade  ON alunos(id_unidade);
CREATE INDEX IF NOT EXISTS idx_alunos_ativo        ON alunos(ativo);

-- Índices na tabela matriculas
CREATE INDEX IF NOT EXISTS idx_matriculas_id_aluno      ON matriculas(id_aluno);
CREATE INDEX IF NOT EXISTS idx_matriculas_id_disciplina ON matriculas(id_disciplina);
CREATE INDEX IF NOT EXISTS idx_matriculas_status        ON matriculas(status);

-- Índices na tabela mensalidades
CREATE INDEX IF NOT EXISTS idx_mensalidades_id_aluno    ON mensalidades(id_aluno);
CREATE INDEX IF NOT EXISTS idx_mensalidades_status      ON mensalidades(status);
CREATE INDEX IF NOT EXISTS idx_mensalidades_competencia ON mensalidades(competencia);

-- Índices na tabela pagamentos
CREATE INDEX IF NOT EXISTS idx_pagamentos_id_aluno      ON pagamentos(id_aluno);
CREATE INDEX IF NOT EXISTS idx_pagamentos_id_mensalidade ON pagamentos(id_mensalidade);

-- Índices na tabela disciplinas
CREATE INDEX IF NOT EXISTS idx_disciplinas_id_curso     ON disciplinas(id_curso);
CREATE INDEX IF NOT EXISTS idx_disciplinas_id_professor ON disciplinas(id_professor);

-- Índices na tabela funcionarios
CREATE INDEX IF NOT EXISTS idx_funcionarios_id_cargo    ON funcionarios(id_cargo);
CREATE INDEX IF NOT EXISTS idx_funcionarios_id_unidade  ON funcionarios(id_unidade);

-- Índices na tabela folha_pagamento
CREATE INDEX IF NOT EXISTS idx_folha_id_funcionario ON folha_pagamento(id_funcionario);
CREATE INDEX IF NOT EXISTS idx_folha_competencia    ON folha_pagamento(competencia);

-- ============================================================
-- 2. ÍNDICES NA CAMADA OLAP
-- ============================================================

-- Fato financeiro: colunas de JOIN
CREATE INDEX IF NOT EXISTS idx_fato_sk_tempo    ON fato_financeiro(sk_tempo);
CREATE INDEX IF NOT EXISTS idx_fato_sk_aluno    ON fato_financeiro(sk_aluno);
CREATE INDEX IF NOT EXISTS idx_fato_sk_curso    ON fato_financeiro(sk_curso);
CREATE INDEX IF NOT EXISTS idx_fato_sk_unidade  ON fato_financeiro(sk_unidade);
CREATE INDEX IF NOT EXISTS idx_fato_status      ON fato_financeiro(status_pagamento);

-- Dim tempo: coluna de filtro por ano/mês
CREATE INDEX IF NOT EXISTS idx_dim_tempo_ano_mes ON dim_tempo(ano, mes);

-- ============================================================
-- 3. DEMONSTRAÇÃO DE GANHO DE PERFORMANCE (EXPLAIN)
-- ============================================================

-- 3.1 Consulta SEM índice explícito relevante (antes da criação dos índices)
--     Use EXPLAIN para visualizar o plano de execução
EXPLAIN
SELECT a.nome, SUM(m.valor_pago) AS total_pago
FROM mensalidades m
JOIN alunos a ON m.id_aluno = a.id_aluno
WHERE m.status = 'pago'
GROUP BY a.id_aluno, a.nome;

-- 3.2 A mesma consulta COM índices (após a criação acima)
--     O campo "key" no EXPLAIN deve mostrar o índice sendo utilizado
EXPLAIN
SELECT a.nome, SUM(m.valor_pago) AS total_pago
FROM mensalidades m
JOIN alunos a ON m.id_aluno = a.id_aluno
WHERE m.status = 'pago'
GROUP BY a.id_aluno, a.nome;

-- 3.3 EXPLAIN em consulta OLAP com JOIN em surrogate keys
EXPLAIN
SELECT
    dt.nome_mes,
    dc.nome_curso,
    SUM(ff.valor_pago) AS faturamento
FROM fato_financeiro ff
JOIN dim_tempo  dt ON ff.sk_tempo  = dt.sk_tempo
JOIN dim_curso  dc ON ff.sk_curso  = dc.sk_curso
GROUP BY dt.nome_mes, dc.nome_curso
ORDER BY faturamento DESC;

-- ============================================================
-- Como interpretar o EXPLAIN:
-- - type = 'ALL'   → full table scan (ruim, sem índice)
-- - type = 'ref'   → uso de índice (bom)
-- - type = 'const' → acesso por PK (ótimo)
-- - key            → nome do índice utilizado
-- - rows            → estimativa de linhas varridas (menor = melhor)
-- ============================================================
