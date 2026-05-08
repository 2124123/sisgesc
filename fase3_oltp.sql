-- ============================================================
-- SisGESC - Sistema de Gestão Escolar
-- Fase 3: Operações OLTP - Consultas e Transações
-- ============================================================

USE sisgesc;

-- ============================================================
-- 1. SELECTs SIMPLES
-- ============================================================

-- 1.1 Listar todos os alunos ativos com seu curso e unidade
SELECT
    a.id_aluno,
    a.nome          AS aluno,
    c.nome_curso    AS curso,
    u.nome_unidade  AS unidade,
    a.email
FROM alunos a
JOIN cursos   c ON a.id_curso   = c.id_curso
JOIN unidades u ON a.id_unidade = u.id_unidade
WHERE a.ativo = 1
ORDER BY a.nome;

-- 1.2 Listar mensalidades pendentes ou atrasadas
SELECT
    a.nome          AS aluno,
    m.competencia,
    m.valor_original,
    m.status
FROM mensalidades m
JOIN alunos a ON m.id_aluno = a.id_aluno
WHERE m.status IN ('pendente', 'atrasado')
ORDER BY m.competencia, a.nome;

-- 1.3 Listar professores e suas disciplinas
SELECT
    p.nome          AS professor,
    d.nome_disciplina AS disciplina,
    c.nome_curso    AS curso,
    d.carga_horaria
FROM professores p
JOIN disciplinas d ON p.id_professor = d.id_professor
JOIN cursos      c ON d.id_curso      = c.id_curso
ORDER BY p.nome;

-- 1.4 Listar funcionários com cargo e unidade
SELECT
    f.nome          AS funcionario,
    ca.nome_cargo,
    u.nome_unidade,
    f.salario,
    f.data_admissao
FROM funcionarios f
JOIN cargos   ca ON f.id_cargo    = ca.id_cargo
JOIN unidades u  ON f.id_unidade  = u.id_unidade
WHERE f.ativo = 1
ORDER BY ca.nome_cargo;

-- ============================================================
-- 2. SUBSELECTS (nível intermediário / avançado)
-- ============================================================

-- 2.1 Alunos que pagaram mais de R$ 1.500 no total
--     (Subselect com agregação)
SELECT
    a.nome,
    a.email
FROM alunos a
WHERE a.id_aluno IN (
    SELECT m.id_aluno
    FROM mensalidades m
    GROUP BY m.id_aluno
    HAVING SUM(m.valor_pago) > 1500
)
ORDER BY a.nome;

-- 2.2 Alunos que ainda NÃO quitaram todas as mensalidades
--     (Subselect com correlação)
SELECT
    a.nome,
    a.email,
    (SELECT COUNT(*) 
     FROM mensalidades m 
     WHERE m.id_aluno = a.id_aluno 
       AND m.status IN ('pendente','atrasado')) AS mensalidades_em_aberto
FROM alunos a
WHERE EXISTS (
    SELECT 1
    FROM mensalidades m
    WHERE m.id_aluno = a.id_aluno
      AND m.status IN ('pendente','atrasado')
)
ORDER BY mensalidades_em_aberto DESC;

-- 2.3 Cursos com receita total acima da média geral dos cursos
--     (Subselect com agregação e subquery escalar)
SELECT
    c.nome_curso,
    SUM(m.valor_pago) AS receita_total
FROM cursos c
JOIN alunos       a ON a.id_curso  = c.id_curso
JOIN mensalidades m ON m.id_aluno  = a.id_aluno
GROUP BY c.id_curso, c.nome_curso
HAVING SUM(m.valor_pago) > (
    SELECT AVG(receita_por_curso)
    FROM (
        SELECT SUM(m2.valor_pago) AS receita_por_curso
        FROM alunos a2
        JOIN mensalidades m2 ON m2.id_aluno = a2.id_aluno
        GROUP BY a2.id_curso
    ) AS sub
)
ORDER BY receita_total DESC;

-- 2.4 Top 3 alunos com maior nota média nas disciplinas concluídas
SELECT
    a.nome,
    ROUND(AVG(mat.nota_final), 2) AS media_notas,
    COUNT(mat.id_matricula)       AS disciplinas_concluidas
FROM alunos a
JOIN matriculas mat ON mat.id_aluno = a.id_aluno
WHERE mat.status = 'concluida'
  AND mat.nota_final IS NOT NULL
GROUP BY a.id_aluno, a.nome
ORDER BY media_notas DESC
LIMIT 3;

-- ============================================================
-- 3. CONTROLE TRANSACIONAL
-- ============================================================

-- -------------------------------------------------
-- CENÁRIO 1: ROLLBACK (simulação de erro)
-- Objetivo: provar que o banco desfaz a operação
-- -------------------------------------------------

START TRANSACTION;

-- Tentativa de inserir uma mensalidade
INSERT INTO mensalidades (id_aluno, competencia, valor_original, valor_pago, status)
VALUES (1, '2024-04-01', 850.00, 0.00, 'pendente');

-- Simulando detecção de erro → ROLLBACK
ROLLBACK;

-- Validação: o registro NÃO deve existir
SELECT id_mensalidade, id_aluno, competencia, status
FROM mensalidades
WHERE id_aluno = 1 AND competencia = '2024-04-01';
-- Resultado esperado: nenhuma linha retornada ✔

-- -------------------------------------------------
-- CENÁRIO 2: COMMIT (confirmação de operação)
-- Objetivo: provar que a transação é persistida
-- -------------------------------------------------

START TRANSACTION;

INSERT INTO mensalidades (id_aluno, competencia, valor_original, valor_pago, status)
VALUES (1, '2024-04-01', 850.00, 0.00, 'pendente');

COMMIT;

-- Validação: o registro DEVE existir
SELECT id_mensalidade, id_aluno, competencia, status
FROM mensalidades
WHERE id_aluno = 1 AND competencia = '2024-04-01';
-- Resultado esperado: 1 linha retornada ✔

-- -------------------------------------------------
-- CENÁRIO 3 (diferencial): Transação múltipla com ROLLBACK
-- Simula pagamento + atualização de saldo
-- Se qualquer etapa falhar, tudo é desfeito
-- -------------------------------------------------

START TRANSACTION;

-- Passo 1: registrar pagamento da mensalidade
INSERT INTO pagamentos (id_aluno, id_mensalidade, valor, forma_pagamento)
VALUES (1, (SELECT id_mensalidade FROM mensalidades WHERE id_aluno=1 AND competencia='2024-04-01'), 850.00, 'pix');

-- Passo 2: atualizar status da mensalidade
UPDATE mensalidades
SET valor_pago = 850.00,
    data_pagamento = CURRENT_DATE(),
    status = 'pago'
WHERE id_aluno = 1 AND competencia = '2024-04-01';

-- Passo 3: simulando regra de negócio violada → ROLLBACK
-- (ex: desconto indevido que não deve persistir)
ROLLBACK;

-- Validação: mensalidade continua como 'pendente' ✔
SELECT id_aluno, competencia, valor_pago, status
FROM mensalidades
WHERE id_aluno = 1 AND competencia = '2024-04-01';
