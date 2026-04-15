# Atividade 01

respota 01:

A escolha de um SGBD relacional, como o PostgreSQL, se justifica pelas propriedades ACID, que garantem transações seguras e consistentes: atomicidade, consistência, isolamento e durabilidade. Além disso, recursos como chaves primárias e estrangeiras asseguram a integridade dos dados e evitam inconsistências. Diferentemente do NoSQL, que prioriza escalabilidade e flexibilidade, o modelo relacional é mais adequado para sistemas que exigem alta confiabilidade e controle das informações.

Resposta 02:

O uso de schemas em um ambiente profissional de Engenharia de Dados é recomendado porque permite uma melhor organização e separação lógica dos objetos do banco de dados. Ao agrupar tabelas por domínio, como academico ou seguranca, facilita-se a manutenção, o entendimento e a escalabilidade do sistema.

Além disso, os schemas proporcionam maior controle de segurança, permitindo a definição de permissões específicas de acesso para diferentes usuários ou aplicações. Isso não é possível de forma eficiente quando todas as tabelas estão concentradas no schema padrão public.

Portanto, a utilização de schemas melhora a organização, a segurança e a governança dos dados, sendo uma prática recomendada em ambientes profissionais.


Atividade 02:

# Normalização de Dados e Modelagem do Banco de Dados

## Tabela Legada

A planilha original apresenta os seguintes atributos:

ID_Matricula, Nome_Usuario, Email_Usuario, Endereco_Usuario, Cod_Servico_Academico, Nome_Disciplina, Carga_H, Matricula_Operador_Pedagogico, Nome_Docente, Data_Ingresso, Score_Final, Ciclo_Calendario.

Cada linha representa a matrícula de um aluno em uma disciplina em um determinado ciclo acadêmico.

---

## Aplicação das Formas Normais

### 1ª Forma Normal (1NF)

A 1ª Forma Normal exige que todos os atributos sejam atômicos, não existam grupos repetitivos e que cada registro possua uma chave primária. A tabela legada já atende a esses requisitos, pois todos os campos possuem valores atômicos e cada linha representa uma única ocorrência de matrícula.

Para garantir a unicidade dos registros, define-se a seguinte chave primária composta:

(ID_Matricula, Cod_Servico_Academico, Ciclo_Calendario)

**Tabela em 1NF:**

MATRICULA_1NF(
    ID_Matricula,
    Cod_Servico_Academico,
    Ciclo_Calendario,
    Nome_Usuario,
    Email_Usuario,
    Endereco_Usuario,
    Data_Ingresso,
    Matricula_Operador_Pedagogico,
    Nome_Disciplina,
    Carga_H,
    Nome_Docente,
    Score_Final,
    PRIMARY KEY (ID_Matricula, Cod_Servico_Academico, Ciclo_Calendario)
)

---

### 2ª Forma Normal (2NF)

A 2ª Forma Normal requer que a tabela esteja na 1NF e que todos os atributos não pertencentes à chave primária dependam totalmente dela, eliminando dependências parciais.

**Dependências Funcionais Identificadas:**
- ID_Matricula → Nome_Usuario, Email_Usuario, Endereco_Usuario, Data_Ingresso, Matricula_Operador_Pedagogico
- Cod_Servico_Academico → Nome_Disciplina, Carga_H, Nome_Docente
- (ID_Matricula, Cod_Servico_Academico, Ciclo_Calendario) → Score_Final

Para eliminar essas dependências parciais, a tabela é decomposta nas seguintes estruturas:

USUARIO(
    ID_Matricula PRIMARY KEY,
    Nome_Usuario,
    Email_Usuario,
    Endereco_Usuario,
    Data_Ingresso,
    Matricula_Operador_Pedagogico
)

DISCIPLINA(
    Cod_Servico_Academico PRIMARY KEY,
    Nome_Disciplina,
    Carga_H,
    Nome_Docente
)

MATRICULA(
    ID_Matricula,
    Cod_Servico_Academico,
    Ciclo_Calendario,
    Score_Final,
    PRIMARY KEY (ID_Matricula, Cod_Servico_Academico, Ciclo_Calendario),
    FOREIGN KEY (ID_Matricula) REFERENCES USUARIO(ID_Matricula),
    FOREIGN KEY (Cod_Servico_Academico) REFERENCES DISCIPLINA(Cod_Servico_Academico)
)

---

### 3ª Forma Normal (3NF)

A 3ª Forma Normal exige que a tabela esteja na 2NF e que não existam dependências transitivas, ou seja, atributos não-chave não podem depender de outros atributos não-chave.

**Dependências Transitivas Identificadas:**
- Cod_Servico_Academico → Nome_Docente (o docente é uma entidade independente).
- Matricula_Operador_Pedagogico representa uma entidade organizacional própria.

Para eliminar essas dependências, o modelo final em 3NF é composto pelas seguintes tabelas:

OPERADOR_PEDAGOGICO(
    Matricula_Operador_Pedagogico PRIMARY KEY
)

DOCENTE(
    ID_Docente SERIAL PRIMARY KEY,
    Nome_Docente NOT NULL
)

USUARIO(
    ID_Matricula PRIMARY KEY,
    Nome_Usuario NOT NULL,
    Email_Usuario NOT NULL UNIQUE,
    Endereco_Usuario,
    Data_Ingresso NOT NULL,
    Matricula_Operador_Pedagogico,
    FOREIGN KEY (Matricula_Operador_Pedagogico)
        REFERENCES OPERADOR_PEDAGOGICO(Matricula_Operador_Pedagogico)
)

DISCIPLINA(
    Cod_Servico_Academico PRIMARY KEY,
    Nome_Disciplina NOT NULL,
    Carga_H NOT NULL,
    ID_Docente NOT NULL,
    FOREIGN KEY (ID_Docente)
        REFERENCES DOCENTE(ID_Docente)
)

MATRICULA(
    ID_Matricula,
    Cod_Servico_Academico,
    Ciclo_Calendario,
    Score_Final,
    PRIMARY KEY (ID_Matricula, Cod_Servico_Academico, Ciclo_Calendario),
    FOREIGN KEY (ID_Matricula)
        REFERENCES USUARIO(ID_Matricula),
    FOREIGN KEY (Cod_Servico_Academico)
        REFERENCES DISCIPLINA(Cod_Servico_Academico)
)

---

## DER – Diagrama Entidade-Relacionamento (Representação Textual)

OPERADOR_PEDAGOGICO (1) ---- (N) USUARIO  
DOCENTE (1) ---- (N) DISCIPLINA  
USUARIO (1) ---- (N) MATRICULA  
DISCIPLINA (1) ---- (N) MATRICULA  

---

## Esquema do Modelo Lógico (SQL)

```sql
CREATE TABLE OPERADOR_PEDAGOGICO (
    matricula_operador_pedagogico VARCHAR(10) PRIMARY KEY
);

CREATE TABLE DOCENTE (
    id_docente SERIAL PRIMARY KEY,
    nome_docente VARCHAR(150) NOT NULL
);

CREATE TABLE USUARIO (
    id_matricula INT PRIMARY KEY,
    nome_usuario VARCHAR(150) NOT NULL,
    email_usuario VARCHAR(150) NOT NULL UNIQUE,
    endereco_usuario VARCHAR(150),
    data_ingresso DATE NOT NULL,
    matricula_operador_pedagogico VARCHAR(10),
    FOREIGN KEY (matricula_operador_pedagogico)
        REFERENCES OPERADOR_PEDAGOGICO(matricula_operador_pedagogico)
);

CREATE TABLE DISCIPLINA (
    cod_servico_academico VARCHAR(10) PRIMARY KEY,
    nome_disciplina VARCHAR(150) NOT NULL,
    carga_h INT NOT NULL,
    id_docente INT NOT NULL,
    FOREIGN KEY (id_docente)
        REFERENCES DOCENTE(id_docente)
);

CREATE TABLE MATRICULA (
    id_matricula INT NOT NULL,
    cod_servico_academico VARCHAR(10) NOT NULL,
    ciclo_calendario VARCHAR(7) NOT NULL,
    score_final NUMERIC(3,1) CHECK (score_final >= 0 AND score_final <= 10),
    PRIMARY KEY (id_matricula, cod_servico_academico, ciclo_calendario),
    FOREIGN KEY (id_matricula)
        REFERENCES USUARIO(id_matricula),
    FOREIGN KEY (cod_servico_academico)
        REFERENCES DISCIPLINA(cod_servico_academico)
);



# Atividade 04:

SELECT
    u.nome_usuario AS nome_aluno,
    d.nome_disciplina,
    m.ciclo_calendario
FROM academico.matricula m
JOIN academico.usuario u
    ON u.id_matricula = m.id_matricula
JOIN academico.disciplina d
    ON d.cod_servico_academico = m.cod_servico_academico
WHERE m.ciclo_calendario = '2026/1'
  AND u.ativo = TRUE
  AND d.ativo = TRUE
  AND m.ativo = TRUE
ORDER BY u.nome_usuario, d.nome_disciplina;

SELECT
    d.nome_disciplina,
    ROUND(AVG(m.score_final), 2) AS media_notas
FROM academico.matricula m
JOIN academico.disciplina d
    ON d.cod_servico_academico = m.cod_servico_academico
WHERE m.ativo = TRUE
  AND d.ativo = TRUE
GROUP BY d.nome_disciplina
HAVING AVG(m.score_final) < 6.0
ORDER BY media_notas ASC;

SELECT
    doc.nome_docente,
    d.nome_disciplina
FROM academico.docente doc
LEFT JOIN academico.disciplina d
    ON d.id_docente = doc.id_docente
    AND d.ativo = TRUE
WHERE doc.ativo = TRUE
ORDER BY doc.nome_docente, d.nome_disciplina;

SELECT
    u.nome_usuario AS nome_aluno,
    m.score_final AS maior_nota
FROM academico.matricula m
JOIN academico.usuario u
    ON u.id_matricula = m.id_matricula
JOIN academico.disciplina d
    ON d.cod_servico_academico = m.cod_servico_academico
WHERE d.nome_disciplina = 'Banco de Dados'
  AND m.score_final = (
        SELECT MAX(m2.score_final)
        FROM academico.matricula m2
        JOIN academico.disciplina d2
            ON d2.cod_servico_academico = m2.cod_servico_academico
        WHERE d2.nome_disciplina = 'Banco de Dados'
          AND m2.ativo = TRUE
    )
  AND u.ativo = TRUE
  AND m.ativo = TRUE;



## Atividade 05:


Quando dois operadores da secretaria tentam alterar simultaneamente a nota de um mesmo `ID_Matricula`, o SGBD garante a consistência dos dados por meio da propriedade de **Isolamento**, pertencente ao modelo **ACID**, e do uso de **locks (bloqueios)**.

O **Isolamento** assegura que as transações concorrentes sejam executadas como se ocorressem de forma sequencial. Dessa maneira, mesmo que duas atualizações sejam iniciadas ao mesmo tempo, o resultado final será equivalente à execução de uma transação após a outra, evitando problemas como a **atualização perdida (lost update)** e a leitura de dados inconsistentes.

Além disso, o PostgreSQL aplica automaticamente **bloqueios em nível de linha (row-level locks)** durante operações de atualização (`UPDATE`). Quando o primeiro operador altera a nota, o registro correspondente é bloqueado. Caso um segundo operador tente modificar o mesmo registro, sua transação ficará em espera até que a primeira seja finalizada com `COMMIT` ou `ROLLBACK`. Após a liberação do bloqueio, a segunda transação prossegue utilizando o estado mais recente do dado.

Dessa forma, a combinação entre **Isolamento** e **mecanismos de lock** garante que o dado final permaneça **consistente, íntegro e livre de corrupção**, mesmo em ambientes com múltiplos usuários acessando e modificando o banco de dados simultaneamente.