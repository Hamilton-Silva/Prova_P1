-- ----------------------------------------------------------------
-- 1 Base de dados e criação de tabela
--escreva a sua solução aqui
-- Cria a base de dados necessária para a tarefa 
CREATE TABLE student_analysis (
    id SERIAL PRIMARY KEY,
    student_id VARCHAR(50) NOT NULL,
    mother_edu INT,
    father_edu INT,
    prep_study INT,
    prep_exam INT,
    salary INT,
    grade INT
);

-- ----------------------------------------------------------------
-- 2 Resultado em função da formação dos pais
--escreva a sua solução aqui
--Cria o resultado em função da formação dos pais seguindo um passo a passo
DO $$
DECLARE
    -- 1. Declaração do cursor
    cur_delete REFCURSOR;
    v_tupla RECORD;
BEGIN
    -- 2. Abertura do cursor
    OPEN cur_delete SCROLL FOR
        SELECT * FROM student_analysis;
    LOOP
        -- 3. Recuperação de dados
        FETCH cur_delete INTO v_tupla;
        EXIT WHEN NOT FOUND;
        IF v_tupla.mother_edu IS NULL OR v_tupla.father_edu IS NULL OR 
           v_tupla.prep_study IS NULL OR v_tupla.prep_exam IS NULL OR 
           v_tupla.salary IS NULL OR v_tupla.grade IS NULL THEN
            DELETE FROM student_analysis WHERE CURRENT OF cur_delete;
        END IF;
    END LOOP;

    -- Exibe as tuplas restantes em ordem inversa
    LOOP
        FETCH BACKWARD FROM cur_delete INTO v_tupla;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE '%', v_tupla;
    END LOOP;

    -- 4. Fechamento do cursor
    CLOSE cur_delete;
END;
$$;


-- ----------------------------------------------------------------
-- 3 Resultado em função dos estudos
--escreva a sua solução aqui
DO $$
DECLARE
    v_educacao_phd INT := 3;  
    v_num_aprovados INT;

    -- 1. Declaração do cursor
    cur_aprovados_phd CURSOR(educacao_phd INT)
        FOR SELECT COUNT(*) FROM student_analysis 
        WHERE grade >= 1 AND (mother_edu = educacao_phd OR father_edu = educacao_phd);
BEGIN
    -- 2. Abertura do cursor com parâmetro
    OPEN cur_aprovados_phd(v_educacao_phd);

    -- 3. Recuperação do dado de interesse
    FETCH cur_aprovados_phd INTO v_num_aprovados;
    IF v_num_aprovados IS NULL THEN
        RAISE NOTICE 'Não encontrei nenhum aluno aprovado cujos pais possuam PhD';
    ELSE
        RAISE NOTICE 'Exibe o número de alunos aprovados com pelo menos um dos pais
		que possua PhD: %', v_num_aprovados;
    END IF;

    -- 4. Fechamento do cursor
    CLOSE cur_aprovados_phd;
END;
$$;


-- ----------------------------------------------------------------
-- 4 Salário versus estudos
--escreva a sua solução aqui
DO $$
DECLARE
    -- 1. Declaração do cursor
    cur_regular CURSOR FOR
        SELECT COUNT(*) AS num_regular
        FROM student_analysis
        WHERE salary > 410 AND prep_exam = 1;
    v_num_regular INT;
BEGIN
    -- 2. Abertura do cursor
    OPEN cur_regular;

    -- 3. Recuperação de dados
    FETCH cur_regular INTO v_num_regular;

    -- Exibe o resultado
    RAISE NOTICE 'Exibe o número de alunos com salário > 410 e cujo estudo é regular: %', v_num_regular;

    -- 4. Fechamento do cursor
    CLOSE cur_regular;
END;
$$;

-- ----------------------------------------------------------------
-- 5. Limpeza de valores NULL
--escreva a sua solução aqui
-- 1. Declaração do cursor 
DO $$
DECLARE
    cur_individuals REFCURSOR;
    v_count_alunos INT;
    v_condicao_study INT := 1;
BEGIN
    -- 2. Abertura do cursor com query dinâmica
    OPEN cur_individuals FOR EXECUTE
        'SELECT COUNT(*) FROM student_analysis WHERE grade >= 1 AND prep_study = $1' 
        USING v_condicao_study;

    -- 3. Recuperação do dado de interesse
    FETCH cur_individuals INTO v_count_alunos;

    -- Verifica se não há registros
    IF v_count_alunos = 0 THEN
        RAISE NOTICE 'Valor: -1';
    ELSE
        RAISE NOTICE 'Verifica o número de alunos aprovados que estudam sozinhos: %', v_count_alunos;
    END IF;

    -- 4. Fechamento do cursor
    CLOSE cur_individuals;
END;
$$;


-- ----------------------------------------------------------------