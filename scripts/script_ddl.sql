
-- ============================================================
-- Atividade 03
-- ============================================================



-- ============================================================
-- 0. LIMPEZA (IDEMPOTÊNCIA)
-- ============================================================
DROP VIEW IF EXISTS academico.vw_usuario_publico CASCADE;
DROP FUNCTION IF EXISTS seguranca.fn_prevent_delete() CASCADE;

DROP TABLE IF EXISTS academico.matricula CASCADE;
DROP TABLE IF EXISTS academico.disciplina CASCADE;
DROP TABLE IF EXISTS academico.usuario CASCADE;
DROP TABLE IF EXISTS academico.docente CASCADE;
DROP TABLE IF EXISTS academico.operador_pedagogico CASCADE;

DROP SCHEMA IF EXISTS academico CASCADE;
DROP SCHEMA IF EXISTS seguranca CASCADE;

DROP ROLE IF EXISTS professor_role;
DROP ROLE IF EXISTS coordenador_role;

-- ============================================================
-- 1. CRIAÇÃO DOS SCHEMAS (NAMESPACES)
-- ============================================================
CREATE SCHEMA academico;
CREATE SCHEMA seguranca;

SET search_path TO academico, seguranca, public;

-- ============================================================
-- 2. CRIAÇÃO DAS TABELAS (DDL)
-- ============================================================

CREATE TABLE academico.operador_pedagogico (
    matricula_operador VARCHAR(10) PRIMARY KEY,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE academico.docente (
    id_docente SERIAL PRIMARY KEY,
    nome_docente VARCHAR(150) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE academico.usuario (
    id_matricula INT PRIMARY KEY,
    nome_usuario VARCHAR(150) NOT NULL,
    email_usuario VARCHAR(150) NOT NULL UNIQUE,
    endereco_usuario VARCHAR(150),
    data_ingresso DATE NOT NULL,
    matricula_operador VARCHAR(10),
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_usuario_operador
        FOREIGN KEY (matricula_operador)
        REFERENCES academico.operador_pedagogico(matricula_operador)
);

CREATE TABLE academico.disciplina (
    cod_servico_academico VARCHAR(10) PRIMARY KEY,
    nome_disciplina VARCHAR(150) NOT NULL,
    carga_h INT NOT NULL CHECK (carga_h > 0),
    id_docente INT NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_disciplina_docente
        FOREIGN KEY (id_docente)
        REFERENCES academico.docente(id_docente)
);

CREATE TABLE academico.matricula (
    id_matricula INT NOT NULL,
    cod_servico_academico VARCHAR(10) NOT NULL,
    ciclo_calendario VARCHAR(7) NOT NULL,
    score_final NUMERIC(3,1) CHECK (score_final BETWEEN 0 AND 10),
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_matricula
        PRIMARY KEY (id_matricula, cod_servico_academico, ciclo_calendario),
    CONSTRAINT fk_matricula_usuario
        FOREIGN KEY (id_matricula)
        REFERENCES academico.usuario(id_matricula),
    CONSTRAINT fk_matricula_disciplina
        FOREIGN KEY (cod_servico_academico)
        REFERENCES academico.disciplina(cod_servico_academico)
);

-- ============================================================
-- 3. GOVERNANÇA – SOFT DELETE
-- ============================================================

CREATE OR REPLACE FUNCTION seguranca.fn_prevent_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'DELETE físico não permitido. Utilize o campo "ativo" para desativar o registro.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_no_delete_usuario
BEFORE DELETE ON academico.usuario
FOR EACH ROW EXECUTE FUNCTION seguranca.fn_prevent_delete();

CREATE TRIGGER trg_no_delete_disciplina
BEFORE DELETE ON academico.disciplina
FOR EACH ROW EXECUTE FUNCTION seguranca.fn_prevent_delete();

CREATE TRIGGER trg_no_delete_docente
BEFORE DELETE ON academico.docente
FOR EACH ROW EXECUTE FUNCTION seguranca.fn_prevent_delete();

CREATE TRIGGER trg_no_delete_operador
BEFORE DELETE ON academico.operador_pedagogico
FOR EACH ROW EXECUTE FUNCTION seguranca.fn_prevent_delete();

CREATE TRIGGER trg_no_delete_matricula
BEFORE DELETE ON academico.matricula
FOR EACH ROW EXECUTE FUNCTION seguranca.fn_prevent_delete();

-- ============================================================
-- 4. SEGURANÇA – DCL (ROLES E PERMISSÕES)
-- ============================================================

CREATE ROLE professor_role;
CREATE ROLE coordenador_role;

GRANT USAGE ON SCHEMA academico, seguranca TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA academico TO coordenador_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA academico
GRANT ALL ON TABLES TO coordenador_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA academico
GRANT ALL ON SEQUENCES TO coordenador_role;

GRANT USAGE ON SCHEMA academico TO professor_role;
GRANT SELECT ON academico.disciplina TO professor_role;
GRANT SELECT ON academico.matricula TO professor_role;
GRANT UPDATE (score_final) ON academico.matricula TO professor_role;

-- ============================================================
-- 5. PRIVACIDADE – RESTRIÇÃO AO E-MAIL
-- ============================================================

REVOKE ALL ON academico.usuario FROM professor_role;

CREATE OR REPLACE VIEW academico.vw_usuario_publico AS
SELECT
    id_matricula,
    nome_usuario,
    endereco_usuario,
    data_ingresso,
    matricula_operador,
    ativo
FROM academico.usuario;

GRANT SELECT ON academico.vw_usuario_publico TO professor_role;

-- ============================================================
-- 6. POPULAÇÃO DE DADOS (DML)
-- ============================================================

INSERT INTO academico.operador_pedagogico (matricula_operador) VALUES
('OP9001'), ('OP9002'), ('OP9003'), ('OP9004'), ('OP8999'), ('OP9000');

INSERT INTO academico.docente (nome_docente) VALUES
('Prof. Carlos Mendes'),
('Profa. Juliana Castro'),
('Prof. Eduardo Pires'),
('Prof. Renato Alves'),
('Profa. Marina Lopes'),
('Prof. Ricardo Faria');

INSERT INTO academico.disciplina (cod_servico_academico, nome_disciplina, carga_h, id_docente)
VALUES
('ADS101', 'Banco de Dados', 80, 1),
('ADS102', 'Engenharia de Software', 80, 2),
('ADS103', 'Algoritmos', 60, 4),
('ADS104', 'Redes de Computadores', 60, 5),
('ADS105', 'Sistemas Operacionais', 60, 3),
('ADS106', 'Estruturas de Dados', 80, 6);

INSERT INTO academico.usuario
(id_matricula, nome_usuario, email_usuario, endereco_usuario, data_ingresso, matricula_operador)
VALUES
(2026001, 'Ana Beatriz Lima', 'ana.lima@aluno.edu.br', 'Braganca Paulista/SP', '2026-01-20', 'OP9001'),
(2026002, 'Bruno Henrique Souza', 'bruno.souza@aluno.edu.br', 'Atibaia/SP', '2026-01-21', 'OP9002'),
(2026003, 'Camila Ferreira', 'camila.ferreira@aluno.edu.br', 'Jundiai/SP', '2026-01-22', 'OP9001'),
(2026004, 'Diego Martins', 'diego.martins@aluno.edu.br', 'Campinas/SP', '2026-01-23', 'OP9003'),
(2026005, 'Eduarda Nunes', 'eduarda.nunes@aluno.edu.br', 'Itatiba/SP', '2026-01-24', 'OP9002'),
(2026006, 'Felipe Araujo', 'felipe.araujo@aluno.edu.br', 'Louveira/SP', '2026-01-25', 'OP9004'),
(2025010, 'Gabriela Torres', 'gabriela.torres@aluno.edu.br', 'Nazare Paulista/SP', '2025-08-05', 'OP8999'),
(2025011, 'Helena Rocha', 'helena.rocha@aluno.edu.br', 'Piracaia/SP', '2025-08-06', 'OP8999'),
(2025012, 'Igor Santana', 'igor.santana@aluno.edu.br', 'Jarinu/SP', '2025-08-07', 'OP9000');

INSERT INTO academico.matricula
(id_matricula, cod_servico_academico, ciclo_calendario, score_final)
VALUES
(2026001, 'ADS101', '2026/1', 9.1),
(2026001, 'ADS102', '2026/1', 8.4),
(2026001, 'ADS105', '2026/1', 8.9),
(2026002, 'ADS101', '2026/1', 7.3),
(2026002, 'ADS103', '2026/1', 6.8),
(2026002, 'ADS104', '2026/1', 7.0),
(2026003, 'ADS101', '2026/1', 5.9),
(2026003, 'ADS102', '2026/1', 7.5),
(2026003, 'ADS106', '2026/1', 6.1),
(2026004, 'ADS103', '2026/1', 4.7),
(2026004, 'ADS104', '2026/1', 6.2),
(2026004, 'ADS105', '2026/1', 5.8),
(2026005, 'ADS102', '2026/1', 9.5),
(2026005, 'ADS104', '2026/1', 8.1),
(2026005, 'ADS106', '2026/1', 8.7),
(2026006, 'ADS101', '2026/1', 6.4),
(2026006, 'ADS103', '2026/1', 5.6),
(2026006, 'ADS105', '2026/1', 6.9),
(2025010, 'ADS101', '2025/2', 6.4),
(2025010, 'ADS102', '2025/2', 7.1),
(2025011, 'ADS103', '2025/2', 8.8),
(2025011, 'ADS104', '2025/2', 7.9),
(2025012, 'ADS105', '2025/2', 5.5),
(2025012, 'ADS106', '2025/2', 6.3);