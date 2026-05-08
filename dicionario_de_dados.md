# Dicionário de Dados — SisGESC

## Módulo Acadêmico

### cursos
| Coluna        | Tipo                              | Restrições       | Descrição                                  |
|---------------|-----------------------------------|------------------|--------------------------------------------|
| id_curso      | INT                               | PK, AUTO_INCREMENT | Identificador único do curso             |
| nome_curso    | VARCHAR(100)                      | NOT NULL, UNIQUE | Nome completo do curso                     |
| carga_horaria | INT                               | NOT NULL         | Total de horas do curso                    |
| modalidade    | ENUM('presencial','ead','hibrido')| NOT NULL         | Modalidade de ensino                       |
| ativo         | TINYINT(1)                        | DEFAULT 1        | 1 = ativo, 0 = inativo                     |
| criado_em     | DATETIME                          | DEFAULT NOW()    | Data/hora de cadastro                      |

### unidades
| Coluna        | Tipo         | Restrições        | Descrição                    |
|---------------|--------------|-------------------|------------------------------|
| id_unidade    | INT          | PK, AUTO_INCREMENT| Identificador único da unidade|
| nome_unidade  | VARCHAR(100) | NOT NULL, UNIQUE  | Nome da unidade física        |
| cidade        | VARCHAR(80)  | NOT NULL          | Cidade onde a unidade está    |
| estado        | CHAR(2)      | NOT NULL          | Sigla do estado (UF)          |
| ativo         | TINYINT(1)   | DEFAULT 1         | 1 = ativa, 0 = inativa        |

### alunos
| Coluna          | Tipo         | Restrições         | Descrição                         |
|-----------------|--------------|--------------------|-----------------------------------|
| id_aluno        | INT          | PK, AUTO_INCREMENT | Identificador único do aluno      |
| nome            | VARCHAR(120) | NOT NULL           | Nome completo                     |
| cpf             | CHAR(11)     | NOT NULL, UNIQUE   | CPF sem formatação                |
| email           | VARCHAR(120) | NOT NULL, UNIQUE   | E-mail de contato                 |
| data_nascimento | DATE         | NOT NULL           | Data de nascimento                |
| id_curso        | INT          | FK → cursos        | Curso em que está matriculado     |
| id_unidade      | INT          | FK → unidades      | Unidade de estudo                 |
| saldo           | DECIMAL(10,2)| DEFAULT 0.00       | Saldo de crédito do aluno         |
| ativo           | TINYINT(1)   | DEFAULT 1          | 1 = ativo, 0 = inativo            |
| criado_em       | DATETIME     | DEFAULT NOW()      | Data/hora de cadastro             |

### professores
| Coluna       | Tipo         | Restrições         | Descrição                        |
|--------------|--------------|--------------------|----------------------------------|
| id_professor | INT          | PK, AUTO_INCREMENT | Identificador único do professor |
| nome         | VARCHAR(120) | NOT NULL           | Nome completo                    |
| cpf          | CHAR(11)     | NOT NULL, UNIQUE   | CPF sem formatação               |
| email        | VARCHAR(120) | NOT NULL, UNIQUE   | E-mail institucional             |
| especialidade| VARCHAR(100) | NOT NULL           | Área de especialidade            |
| id_unidade   | INT          | FK → unidades      | Unidade onde leciona             |
| ativo        | TINYINT(1)   | DEFAULT 1          | 1 = ativo                        |
| criado_em    | DATETIME     | DEFAULT NOW()      | Data/hora de cadastro            |

### disciplinas
| Coluna          | Tipo         | Restrições           | Descrição                           |
|-----------------|--------------|----------------------|-------------------------------------|
| id_disciplina   | INT          | PK, AUTO_INCREMENT   | Identificador único da disciplina   |
| nome_disciplina | VARCHAR(100) | NOT NULL             | Nome da disciplina                  |
| id_curso        | INT          | FK → cursos          | Curso ao qual pertence              |
| id_professor    | INT          | FK → professores     | Professor responsável               |
| carga_horaria   | INT          | NOT NULL             | Carga horária em horas              |

### matriculas
| Coluna        | Tipo                              | Restrições                     | Descrição                          |
|---------------|-----------------------------------|--------------------------------|------------------------------------|
| id_matricula  | INT                               | PK, AUTO_INCREMENT             | Identificador único da matrícula   |
| id_aluno      | INT                               | FK → alunos                    | Aluno matriculado                  |
| id_disciplina | INT                               | FK → disciplinas               | Disciplina da matrícula            |
| data_matricula| DATE                              | DEFAULT CURRENT_DATE           | Data em que foi feita a matrícula  |
| status        | ENUM('ativa','trancada','concluida')| NOT NULL, DEFAULT 'ativa'    | Situação atual da matrícula        |
| nota_final    | DECIMAL(4,2)                      | NULL                           | Nota final (preenchida ao concluir)|

---

## Módulo Financeiro

### mensalidades
| Coluna          | Tipo                                      | Restrições                   | Descrição                                    |
|-----------------|-------------------------------------------|------------------------------|----------------------------------------------|
| id_mensalidade  | INT                                       | PK, AUTO_INCREMENT           | Identificador único da mensalidade           |
| id_aluno        | INT                                       | FK → alunos                  | Aluno responsável                            |
| competencia     | DATE                                      | NOT NULL                     | Primeiro dia do mês de referência            |
| valor_original  | DECIMAL(10,2)                             | NOT NULL                     | Valor da mensalidade antes de desconto       |
| valor_pago      | DECIMAL(10,2)                             | DEFAULT 0.00                 | Valor efetivamente pago                      |
| data_pagamento  | DATE                                      | NULL                         | Data em que o pagamento foi efetuado         |
| status          | ENUM('pendente','pago','atrasado','cancelado')| DEFAULT 'pendente'       | Situação do pagamento                        |
| UNIQUE          | (id_aluno, competencia)                   | —                            | Garante 1 mensalidade por aluno por mês      |

### pagamentos
| Coluna          | Tipo                                    | Restrições             | Descrição                            |
|-----------------|-----------------------------------------|------------------------|--------------------------------------|
| id_pagamento    | INT                                     | PK, AUTO_INCREMENT     | Identificador único do pagamento     |
| id_aluno        | INT                                     | FK → alunos            | Aluno que efetuou o pagamento        |
| id_mensalidade  | INT                                     | FK → mensalidades      | Mensalidade quitada                  |
| valor           | DECIMAL(10,2)                           | NOT NULL               | Valor da transação                   |
| data_pagamento  | DATETIME                                | DEFAULT NOW()          | Data/hora do pagamento               |
| forma_pagamento | ENUM('boleto','cartao','pix','dinheiro')| NOT NULL               | Forma de pagamento utilizada         |

---

## Módulo RH

### cargos
| Coluna       | Tipo         | Restrições         | Descrição                  |
|--------------|--------------|--------------------|----------------------------|
| id_cargo     | INT          | PK, AUTO_INCREMENT | Identificador único do cargo|
| nome_cargo   | VARCHAR(80)  | NOT NULL, UNIQUE   | Nome do cargo              |
| salario_base | DECIMAL(10,2)| NOT NULL           | Salário base do cargo      |

### funcionarios
| Coluna         | Tipo         | Restrições         | Descrição                       |
|----------------|--------------|--------------------|----------------------------------|
| id_funcionario | INT          | PK, AUTO_INCREMENT | Identificador único              |
| nome           | VARCHAR(120) | NOT NULL           | Nome completo                    |
| cpf            | CHAR(11)     | NOT NULL, UNIQUE   | CPF sem formatação               |
| email          | VARCHAR(120) | NOT NULL, UNIQUE   | E-mail institucional             |
| id_cargo       | INT          | FK → cargos        | Cargo ocupado                    |
| id_unidade     | INT          | FK → unidades      | Unidade de lotação               |
| data_admissao  | DATE         | NOT NULL           | Data de contratação              |
| salario        | DECIMAL(10,2)| NOT NULL           | Salário atual (pode diferir da base)|
| ativo          | TINYINT(1)   | DEFAULT 1          | 1 = ativo, 0 = desligado         |

### folha_pagamento
| Coluna          | Tipo         | Restrições                   | Descrição                                |
|-----------------|--------------|------------------------------|------------------------------------------|
| id_folha        | INT          | PK, AUTO_INCREMENT           | Identificador único da folha             |
| id_funcionario  | INT          | FK → funcionarios            | Funcionário referenciado                 |
| competencia     | DATE         | NOT NULL                     | Primeiro dia do mês de referência        |
| salario_bruto   | DECIMAL(10,2)| NOT NULL                     | Salário antes de descontos               |
| descontos       | DECIMAL(10,2)| DEFAULT 0.00                 | Total de descontos (INSS, IR, etc.)      |
| salario_liquido | DECIMAL(10,2)| NOT NULL                     | Valor líquido a receber                  |
| UNIQUE          | (id_funcionario, competencia) | —           | Garante 1 folha por funcionário por mês  |

---

## Camada OLAP (Star Schema)

### dim_tempo
| Coluna       | Tipo        | Restrições         | Descrição                          |
|--------------|-------------|--------------------|------------------------------------|
| sk_tempo     | INT         | PK, AUTO_INCREMENT | Surrogate Key da dimensão tempo    |
| data_completa| DATE        | NOT NULL, UNIQUE   | Data completa (chave natural)      |
| ano          | INT         | NOT NULL           | Ano                                |
| semestre     | INT         | NOT NULL           | 1 ou 2                             |
| trimestre    | INT         | NOT NULL           | 1 a 4                              |
| mes          | INT         | NOT NULL           | 1 a 12                             |
| nome_mes     | VARCHAR(20) | NOT NULL           | Nome do mês em inglês (MONTHNAME)  |
| dia          | INT         | NOT NULL           | Dia do mês                         |
| dia_semana   | VARCHAR(15) | NOT NULL           | Nome do dia da semana              |

### dim_aluno
| Coluna         | Tipo         | Restrições          | Descrição                           |
|----------------|--------------|---------------------|-------------------------------------|
| sk_aluno       | INT          | PK, AUTO_INCREMENT  | Surrogate Key do aluno              |
| id_aluno_oltp  | INT          | NOT NULL, UNIQUE    | Chave natural do OLTP               |
| nome_aluno     | VARCHAR(120) | NOT NULL            | Nome do aluno                       |
| email          | VARCHAR(120) | NOT NULL            | E-mail do aluno                     |

### dim_curso
| Coluna        | Tipo        | Restrições          | Descrição                         |
|---------------|-------------|---------------------|-----------------------------------|
| sk_curso      | INT         | PK, AUTO_INCREMENT  | Surrogate Key do curso            |
| id_curso_oltp | INT         | NOT NULL, UNIQUE    | Chave natural do OLTP             |
| nome_curso    | VARCHAR(100)| NOT NULL            | Nome do curso                     |
| modalidade    | VARCHAR(20) | NOT NULL            | Modalidade de ensino              |

### dim_unidade
| Coluna           | Tipo        | Restrições          | Descrição                          |
|------------------|-------------|---------------------|------------------------------------|
| sk_unidade       | INT         | PK, AUTO_INCREMENT  | Surrogate Key da unidade           |
| id_unidade_oltp  | INT         | NOT NULL, UNIQUE    | Chave natural do OLTP              |
| nome_unidade     | VARCHAR(100)| NOT NULL            | Nome da unidade                    |
| cidade           | VARCHAR(80) | NOT NULL            | Cidade                             |
| estado           | CHAR(2)     | NOT NULL            | UF                                 |

### fato_financeiro
| Coluna              | Tipo          | Restrições                  | Descrição                                        |
|---------------------|---------------|-----------------------------|--------------------------------------------------|
| sk_fato             | INT           | PK, AUTO_INCREMENT          | Surrogate Key do fato                            |
| sk_tempo            | INT           | FK → dim_tempo              | Referência à dimensão tempo                      |
| sk_aluno            | INT           | FK → dim_aluno              | Referência à dimensão aluno                      |
| sk_curso            | INT           | FK → dim_curso              | Referência à dimensão curso                      |
| sk_unidade          | INT           | FK → dim_unidade            | Referência à dimensão unidade                    |
| id_mensalidade_oltp | INT           | NOT NULL, UNIQUE            | Chave de auditoria para rastrear o OLTP          |
| valor_original      | DECIMAL(10,2) | NOT NULL                    | Valor cobrado (pré-pagamento)                    |
| valor_pago          | DECIMAL(10,2) | NOT NULL                    | Valor efetivamente pago                          |
| valor_inadimplente  | DECIMAL(10,2) | NOT NULL                    | Diferença: valor_original − valor_pago           |
| status_pagamento    | VARCHAR(20)   | NOT NULL                    | Status copiado do OLTP (pago, pendente, atrasado)|
