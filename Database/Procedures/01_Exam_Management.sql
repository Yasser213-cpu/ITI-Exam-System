-- ============================================================
-- sp_GenerateExam
-- Purpose  : Generate a randomized exam for a given course
-- Author   : ITI Dev Team
-- Version  : 1.0
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_GenerateExam(
    p_CourseID  INT,
    p_ExamName  VARCHAR(200),
    p_NumMCQ    INT,
    p_NumTF     INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ExamID    INT;
    v_MCQCount  INT;
    v_TFCount   INT;
BEGIN
    -- Check course exists
    IF NOT EXISTS (
        SELECT 1 FROM Course WHERE CourseID = p_CourseID
    ) THEN
        RAISE EXCEPTION 'CourseID % does not exist.', p_CourseID;
    END IF;

    -- Count available questions
    SELECT COUNT(*) INTO v_MCQCount
    FROM Question
    WHERE CourseID = p_CourseID AND QuestionType = 'MCQ';

    SELECT COUNT(*) INTO v_TFCount
    FROM Question
    WHERE CourseID = p_CourseID AND QuestionType = 'TF';

    -- Check sufficient questions
    IF v_MCQCount < p_NumMCQ THEN
        RAISE EXCEPTION 'Insufficient MCQ questions. Available: %, Requested: %',
            v_MCQCount, p_NumMCQ;
    END IF;

    IF v_TFCount < p_NumTF THEN
        RAISE EXCEPTION 'Insufficient TF questions. Available: %, Requested: %',
            v_TFCount, p_NumTF;
    END IF;

    -- Create exam record
    INSERT INTO Exam (ExamName, CourseID, CreatedDate)
    VALUES (p_ExamName, p_CourseID, NOW())
    RETURNING ExamID INTO v_ExamID;

    -- Insert randomly selected MCQ questions
    INSERT INTO ExamQuestion (ExamID, QuestionID, OrderNo, Points)
    SELECT
        v_ExamID,
        QuestionID,
        ROW_NUMBER() OVER (ORDER BY RANDOM()),
        1.00
    FROM Question
    WHERE CourseID = p_CourseID AND QuestionType = 'MCQ'
    ORDER BY RANDOM()
    LIMIT p_NumMCQ;

    -- Insert randomly selected TF questions
    INSERT INTO ExamQuestion (ExamID, QuestionID, OrderNo, Points)
    SELECT
        v_ExamID,
        QuestionID,
        p_NumMCQ + ROW_NUMBER() OVER (ORDER BY RANDOM()),
        1.00
    FROM Question
    WHERE CourseID = p_CourseID AND QuestionType = 'TF'
    ORDER BY RANDOM()
    LIMIT p_NumTF;

    RAISE NOTICE 'Exam "%" created successfully. ExamID = %', p_ExamName, v_ExamID;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;


-- ============================================================
-- sp_CorrectExam
-- Purpose  : Grade a student exam by comparing answers to
--            model answers and updating TotalGrade, Percentage
-- Author   : ITI Dev Team
-- Version  : 1.0
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_CorrectExam(
    p_StudentExamID INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_TotalGrade DECIMAL(6,2);
    v_MaxPoints  DECIMAL(6,2);
    v_Percentage DECIMAL(5,2);
BEGIN
    -- Check StudentExam exists
    IF NOT EXISTS (
        SELECT 1 FROM StudentExam WHERE StudentExamID = p_StudentExamID
    ) THEN
        RAISE EXCEPTION 'StudentExamID % does not exist.', p_StudentExamID;
    END IF;

    -- Check exam has not already been graded
    IF EXISTS (
        SELECT 1 FROM StudentExam
        WHERE StudentExamID = p_StudentExamID
        AND TotalGrade IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'Exam already graded.';
    END IF;

    -- Calculate MaxPoints
    SELECT COALESCE(SUM(eq.Points), 0)
    INTO v_MaxPoints
    FROM ExamQuestion eq
    JOIN StudentExam  se ON se.ExamID = eq.ExamID
    WHERE se.StudentExamID = p_StudentExamID;

    -- Calculate TotalGrade (correct answers only)
    SELECT COALESCE(SUM(eq.Points), 0)
    INTO v_TotalGrade
    FROM StudentAnswer sa
    JOIN ExamQuestion  eq ON eq.ExamQID    = sa.ExamQID
    JOIN ModelAnswer   ma ON ma.QuestionID = eq.QuestionID
    WHERE sa.StudentExamID  = p_StudentExamID
    AND   sa.ChosenOptionID = ma.CorrectOptionID;

    -- Calculate Percentage
    IF v_MaxPoints > 0 THEN
        v_Percentage := ROUND((v_TotalGrade / v_MaxPoints) * 100, 2);
    ELSE
        v_Percentage := 0;
    END IF;

    -- Update StudentExam with results
    UPDATE StudentExam
    SET
        TotalGrade = v_TotalGrade,
        MaxPoints  = v_MaxPoints,
        Percentage = v_Percentage
    WHERE StudentExamID = p_StudentExamID;

    RAISE NOTICE 'Exam corrected. Grade: % / % (% %%)',
        v_TotalGrade, v_MaxPoints, v_Percentage;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;


-- ============================================================
-- fn_Report_WeakQuestions
-- Purpose  : Return questions where failure rate exceeds
--            the given threshold
-- Author   : ITI Dev Team
-- Version  : 1.0
-- ============================================================
CREATE OR REPLACE FUNCTION fn_Report_WeakQuestions(
    p_CourseID      INT,
    p_FailThreshold FLOAT
)
RETURNS TABLE (
    QuestionID   INT,
    QuestionText TEXT,
    FailureRate  FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check course exists
    IF NOT EXISTS (
        SELECT 1 FROM Course WHERE CourseID = p_CourseID
    ) THEN
        RAISE EXCEPTION 'CourseID % does not exist.', p_CourseID;
    END IF;

    RETURN QUERY
    SELECT
        q.QuestionID,
        q.QuestionText,
        ROUND(
            100.0 * SUM(
                CASE
                    WHEN sa.ChosenOptionID != ma.CorrectOptionID
                      OR sa.ChosenOptionID IS NULL
                    THEN 1
                    ELSE 0
                END
            ) / COUNT(sa.AnswerID),
        2)::FLOAT AS FailureRate
    FROM Question      q
    JOIN ExamQuestion  eq ON eq.QuestionID  = q.QuestionID
    JOIN ModelAnswer   ma ON ma.QuestionID  = q.QuestionID
    JOIN StudentAnswer sa ON sa.ExamQID     = eq.ExamQID
    WHERE q.CourseID = p_CourseID
    GROUP BY q.QuestionID, q.QuestionText
    HAVING
        ROUND(
            100.0 * SUM(
                CASE
                    WHEN sa.ChosenOptionID != ma.CorrectOptionID
                      OR sa.ChosenOptionID IS NULL
                    THEN 1
                    ELSE 0
                END
            ) / COUNT(sa.AnswerID),
        2) > p_FailThreshold
    ORDER BY FailureRate DESC;
END;
$$;