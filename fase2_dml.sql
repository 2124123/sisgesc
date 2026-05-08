-- ============================================================
-- SisGESC - Sistema de Gestão Escolar
-- Fase 2: DML - Carga de Dados (IDEMPOTENTE)
-- Estratégia: INSERT IGNORE (não duplica em reexecução)
-- ============================================================

USE sisgesc;

-- ============================================================
-- MÓDULO ACADÊMICO
-- ============================================================

-- Cursos
INSERT IGNORE INTO cursos (id_curso, nome_curso, carga_horaria, modalidade) VALUES
(1, 'Análise e Desenvolvimento de Sistemas', 1600, 'presencial'),
(2, 'Administração de Empresas',             2400, 'presencial'),
(3, 'Gestão de Recursos Humanos',            1600, 'hibrido'),
(4, 'Ciência da Computação',                 3200, 'presencial'),
(5, 'Marketing Digital',                     1200, 'ead');

-- Unidades
INSERT IGNORE INTO unidades (id_unidade, nome_unidade, cidade, estado) VALUES
(1, 'Unidade Centro',   'São Paulo',   'SP'),
(2, 'Unidade Norte',    'São Paulo',   'SP'),
(3, 'Unidade Campinas', 'Campinas',    'SP'),
(4, 'Unidade BH',       'Belo Horizonte', 'MG');

-- Professores
INSERT IGNORE INTO professores (id_professor, nome, cpf, email, especialidade, id_unidade) VALUES
(1,  'Carlos Andrade',   '11122233344', 'carlos.andrade@sisgesc.edu',   'Banco de Dados',        1),
(2,  'Fernanda Lima',    '22233344455', 'fernanda.lima@sisgesc.edu',    'Redes e Sistemas',      1),
(3,  'Roberto Souza',    '33344455566', 'roberto.souza@sisgesc.edu',    'Gestão Empresarial',    2),
(4,  'Ana Paula Melo',   '44455566677', 'ana.melo@sisgesc.edu',         'Recursos Humanos',      3),
(5,  'Juliana Costa',    '55566677788', 'juliana.costa@sisgesc.edu',    'Marketing e Mídias',    4);

-- Alunos
INSERT IGNORE INTO alunos (id_aluno, nome, cpf, email, data_nascimento, id_curso, id_unidade, saldo) VALUES
(1,  'Lucas Pereira',      '10111222333', 'lucas.pereira@email.com',     '2001-03-15', 1, 1, 0.00),
(2,  'Mariana Silva',      '20222333444', 'mariana.silva@email.com',     '2000-07-22', 1, 1, 0.00),
(3,  'João Oliveira',      '30333444555', 'joao.oliveira@email.com',     '1999-11-08', 2, 2, 0.00),
(4,  'Beatriz Santos',     '40444555666', 'beatriz.santos@email.com',    '2002-01-30', 2, 2, 0.00),
(5,  'Rafael Costa',       '50555666777', 'rafael.costa@email.com',      '2001-06-14', 3, 3, 0.00),
(6,  'Camila Ferreira',    '60666777888', 'camila.ferreira@email.com',   '2000-09-03', 3, 3, 0.00),
(7,  'Felipe Alves',       '70777888999', 'felipe.alves@email.com',      '1998-12-19', 4, 1, 0.00),
(8,  'Larissa Mendes',     '80888999000', 'larissa.mendes@email.com',    '2003-04-25', 4, 4, 0.00),
(9,  'Bruno Carvalho',     '90999000111', 'bruno.carvalho@email.com',    '2001-08-11', 5, 4, 0.00),
(10, 'Tatiane Rodrigues',  '91000111222', 'tatiane.rodrigues@email.com', '2000-02-17', 5, 2, 0.00);

-- Disciplinas
INSERT IGNORE INTO disciplinas (id_disciplina, nome_disciplina, id_curso, id_professor, carga_horaria) VALUES
(1,  'Banco de Dados I',              1, 1, 80),
(2,  'Banco de Dados II',             1, 1, 80),
(3,  'Redes de Computadores',         1, 2, 60),
(4,  'Programação Orientada a Objetos',1,2, 80),
(5,  'Gestão Estratégica',            2, 3, 60),
(6,  'Finanças Empresariais',         2, 3, 60),
(7,  'Recrutamento e Seleção',        3, 4, 60),
(8,  'Treinamento e Desenvolvimento', 3, 4, 60),
(9,  'Algoritmos e Estruturas',       4, 1, 80),
(10, 'Marketing Digital Avançado',    5, 5, 60);

-- Matrículas
INSERT IGNORE INTO matriculas (id_matricula, id_aluno, id_disciplina, data_matricula, status, nota_final) VALUES
(1,  1,  1, '2024-02-01', 'concluida', 8.5),
(2,  1,  2, '2024-02-01', 'ativa',     NULL),
(3,  2,  1, '2024-02-01', 'concluida', 7.0),
(4,  2,  3, '2024-02-01', 'ativa',     NULL),
(5,  3,  5, '2024-02-01', 'concluida', 9.0),
(6,  3,  6, '2024-02-01', 'ativa',     NULL),
(7,  4,  5, '2024-02-01', 'concluida', 6.5),
(8,  5,  7, '2024-02-01', 'ativa',     NULL),
(9,  6,  8, '2024-02-01', 'concluida', 8.0),
(10, 7,  9, '2024-02-01', 'ativa',     NULL),
(11, 8,  9, '2024-02-01', 'ativa',     NULL),
(12, 9,  10,'2024-02-01', 'concluida', 9.5),
(13, 10, 10,'2024-02-01', 'ativa',     NULL);

-- ============================================================
-- MÓDULO FINANCEIRO
-- ============================================================

-- Mensalidades (competencia = primeiro dia do mês)
INSERT IGNORE INTO mensalidades (id_mensalidade, id_aluno, competencia, valor_original, valor_pago, data_pagamento, status) VALUES
(1,  1,  '2024-01-01', 850.00, 850.00, '2024-01-05', 'pago'),
(2,  1,  '2024-02-01', 850.00, 850.00, '2024-02-07', 'pago'),
(3,  1,  '2024-03-01', 850.00, 850.00, '2024-03-04', 'pago'),
(4,  2,  '2024-01-01', 850.00, 850.00, '2024-01-06', 'pago'),
(5,  2,  '2024-02-01', 850.00, 850.00, '2024-02-10', 'pago'),
(6,  2,  '2024-03-01', 850.00,   0.00, NULL,          'pendente'),
(7,  3,  '2024-01-01', 780.00, 780.00, '2024-01-08', 'pago'),
(8,  3,  '2024-02-01', 780.00, 780.00, '2024-02-05', 'pago'),
(9,  3,  '2024-03-01', 780.00, 780.00, '2024-03-09', 'pago'),
(10, 4,  '2024-01-01', 780.00, 780.00, '2024-01-10', 'pago'),
(11, 4,  '2024-02-01', 780.00,   0.00, NULL,          'atrasado'),
(12, 5,  '2024-01-01', 700.00, 700.00, '2024-01-07', 'pago'),
(13, 5,  '2024-02-01', 700.00, 700.00, '2024-02-09', 'pago'),
(14, 6,  '2024-01-01', 700.00, 700.00, '2024-01-11', 'pago'),
(15, 7,  '2024-01-01', 950.00, 950.00, '2024-01-03', 'pago'),
(16, 7,  '2024-02-01', 950.00, 950.00, '2024-02-04', 'pago'),
(17, 8,  '2024-01-01', 950.00, 950.00, '2024-01-09', 'pago'),
(18, 9,  '2024-01-01', 620.00, 620.00, '2024-01-12', 'pago'),
(19, 10, '2024-01-01', 620.00, 620.00, '2024-01-15', 'pago'),
(20, 10, '2024-02-01', 620.00,   0.00, NULL,          'pendente');

-- Pagamentos (registros de transações financeiras)
INSERT IGNORE INTO pagamentos (id_pagamento, id_aluno, id_mensalidade, valor, data_pagamento, forma_pagamento) VALUES
(1,  1, 1,  850.00, '2024-01-05 10:30:00', 'pix'),
(2,  1, 2,  850.00, '2024-02-07 09:15:00', 'pix'),
(3,  1, 3,  850.00, '2024-03-04 11:00:00', 'boleto'),
(4,  2, 4,  850.00, '2024-01-06 14:00:00', 'cartao'),
(5,  2, 5,  850.00, '2024-02-10 16:30:00', 'cartao'),
(6,  3, 7,  780.00, '2024-01-08 08:45:00', 'boleto'),
(7,  3, 8,  780.00, '2024-02-05 10:00:00', 'pix'),
(8,  3, 9,  780.00, '2024-03-09 13:20:00', 'boleto'),
(9,  4, 10, 780.00, '2024-01-10 11:00:00', 'dinheiro'),
(10, 5, 12, 700.00, '2024-01-07 09:30:00', 'pix'),
(11, 5, 13, 700.00, '2024-02-09 10:45:00', 'pix'),
(12, 6, 14, 700.00, '2024-01-11 15:00:00', 'cartao'),
(13, 7, 15, 950.00, '2024-01-03 08:00:00', 'boleto'),
(14, 7, 16, 950.00, '2024-02-04 09:00:00', 'boleto'),
(15, 8, 17, 950.00, '2024-01-09 12:30:00', 'pix'),
(16, 9, 18, 620.00, '2024-01-12 17:00:00', 'cartao'),
(17, 10,19, 620.00, '2024-01-15 10:15:00', 'pix');

-- ============================================================
-- MÓDULO RH
-- ============================================================

-- Cargos
INSERT IGNORE INTO cargos (id_cargo, nome_cargo, salario_base) VALUES
(1, 'Coordenador Acadêmico', 5500.00),
(2, 'Secretário Acadêmico',  2800.00),
(3, 'Auxiliar Administrativo', 2200.00),
(4, 'Analista de TI',        4500.00),
(5, 'Auxiliar Financeiro',   2600.00);

-- Funcionários
INSERT IGNORE INTO funcionarios (id_funcionario, nome, cpf, email, id_cargo, id_unidade, data_admissao, salario) VALUES
(1, 'Sandra Almeida',   '11100022233', 'sandra.almeida@sisgesc.edu',  1, 1, '2020-03-01', 5800.00),
(2, 'Pedro Nascimento', '22200033344', 'pedro.nascimento@sisgesc.edu',2, 1, '2021-06-15', 2900.00),
(3, 'Cíntia Barbosa',   '33300044455', 'cintia.barbosa@sisgesc.edu',  3, 2, '2022-01-10', 2300.00),
(4, 'Marcos Teixeira',  '44400055566', 'marcos.teixeira@sisgesc.edu', 4, 1, '2019-08-20', 4800.00),
(5, 'Lúcia Freitas',    '55500066677', 'lucia.freitas@sisgesc.edu',   5, 3, '2023-02-01', 2700.00);

-- Folha de pagamento
INSERT IGNORE INTO folha_pagamento (id_folha, id_funcionario, competencia, salario_bruto, descontos, salario_liquido) VALUES
(1,  1, '2024-01-01', 5800.00, 870.00, 4930.00),
(2,  1, '2024-02-01', 5800.00, 870.00, 4930.00),
(3,  1, '2024-03-01', 5800.00, 870.00, 4930.00),
(4,  2, '2024-01-01', 2900.00, 290.00, 2610.00),
(5,  2, '2024-02-01', 2900.00, 290.00, 2610.00),
(6,  2, '2024-03-01', 2900.00, 290.00, 2610.00),
(7,  3, '2024-01-01', 2300.00, 230.00, 2070.00),
(8,  3, '2024-02-01', 2300.00, 230.00, 2070.00),
(9,  4, '2024-01-01', 4800.00, 720.00, 4080.00),
(10, 4, '2024-02-01', 4800.00, 720.00, 4080.00),
(11, 4, '2024-03-01', 4800.00, 720.00, 4080.00),
(12, 5, '2024-01-01', 2700.00, 270.00, 2430.00),
(13, 5, '2024-02-01', 2700.00, 270.00, 2430.00);

-- ============================================================
-- TESTE DE IDEMPOTÊNCIA
-- Execute antes e depois de rodar este script novamente.
-- Os totais NÃO devem mudar.
-- ============================================================
SELECT 'cursos'           AS tabela, COUNT(*) AS total FROM cursos
UNION ALL
SELECT 'unidades',          COUNT(*) FROM unidades
UNION ALL
SELECT 'professores',       COUNT(*) FROM professores
UNION ALL
SELECT 'alunos',            COUNT(*) FROM alunos
UNION ALL
SELECT 'disciplinas',       COUNT(*) FROM disciplinas
UNION ALL
SELECT 'matriculas',        COUNT(*) FROM matriculas
UNION ALL
SELECT 'mensalidades',      COUNT(*) FROM mensalidades
UNION ALL
SELECT 'pagamentos',        COUNT(*) FROM pagamentos
UNION ALL
SELECT 'cargos',            COUNT(*) FROM cargos
UNION ALL
SELECT 'funcionarios',      COUNT(*) FROM funcionarios
UNION ALL
SELECT 'folha_pagamento',   COUNT(*) FROM folha_pagamento;
