# SisGESC – Sistema de Gestão Escolar
**Projeto de Banco de Dados | Entrega Final**

---

## Como executar

### Pré-requisitos
- MySQL 8.0+ ou MariaDB 10.5+
- VS Code com extensão **SQLTools** ou **MySQL** (Weijan Chen)

### Execução completa (recomendado)
```bash
mysql -u root -p < run_all.sql
```

Ou abra `run_all.sql` no VS Code e execute tudo de uma vez.

### Execução por fase
| Arquivo               | Descrição                                  |
|-----------------------|--------------------------------------------|
| `fase1_ddl.sql`       | Criação das tabelas (DDL)                  |
| `fase2_dml.sql`       | Carga de dados idempotente (DML)           |
| `fase3_oltp.sql`      | Consultas OLTP e Transações                |
| `fase4_olap_etl.sql`  | Star Schema + ETL + Consultas Analíticas   |
| `fase5_performance.sql` | Índices e EXPLAIN                        |
| `fase6_reset.sql`     | Reset completo (DROP de todas as tabelas)  |

---

## Estrutura do Banco

### Módulo Acadêmico
- `cursos` — catálogo de cursos oferecidos
- `unidades` — unidades físicas da instituição
- `professores` — corpo docente
- `alunos` — alunos matriculados
- `disciplinas` — disciplinas vinculadas a cursos e professores
- `matriculas` — registro de alunos em disciplinas

### Módulo Financeiro
- `mensalidades` — cobranças mensais por aluno
- `pagamentos` — registros de transações de pagamento

### Módulo RH
- `cargos` — cargos disponíveis
- `funcionarios` — funcionários administrativos
- `folha_pagamento` — folha mensal por funcionário

### Camada OLAP (Star Schema)
- `fato_financeiro` — tabela fato principal
- `dim_tempo` — dimensão temporal
- `dim_aluno` — dimensão aluno
- `dim_curso` — dimensão curso
- `dim_unidade` — dimensão unidade

---

## Garantias de qualidade

- **Idempotência**: todos os INSERTs usam `INSERT IGNORE` com chaves únicas. Reexecutar o DML não duplica dados.
- **Integridade referencial**: todas as FKs estão declaradas e ativas.
- **Padrão de nomes**: snake_case em todas as tabelas e colunas.
- **ETL validado**: `SUM(valor_pago)` no OLTP é igual ao `SUM(valor_pago)` no OLAP.

---

## Penalidades evitadas

| Critério                | Como foi tratado                              |
|-------------------------|-----------------------------------------------|
| Duplicidade de dados    | `INSERT IGNORE` + `UNIQUE` constraints        |
| Falta de PK/FK          | Todas declaradas explicitamente com nomes     |
| ETL incorreto           | Validação OLTP vs OLAP incluída               |
| OLAP sem validação      | Consulta de conferência no final da Fase 4    |
| Script não comentado    | Todos os scripts possuem comentários de seção |
