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
-- sp_SubmitExamAnswers
-- Purpose  : Submit student answers for a given exam atomically
-- Author   : ITI Dev Team
-- Version  : 1.0
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_SubmitExamAnswers(
    p_StudentID  INT,
    p_ExamID     INT,
    p_EndTime    TIMESTAMP,
    p_AnswersXML XML
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_StudentExamID INT;
    v_StartTime     TIMESTAMP;
BEGIN
    -- Check student exists
    IF NOT EXISTS (
        SELECT 1 FROM Student WHERE StudentID = p_StudentID
    ) THEN
        RAISE EXCEPTION 'StudentID % does not exist.', p_StudentID;
    END IF;

    -- Check exam exists
    IF NOT EXISTS (
        SELECT 1 FROM Exam WHERE ExamID = p_ExamID
    ) THEN
        RAISE EXCEPTION 'ExamID % does not exist.', p_ExamID;
    END IF;

    -- Check student has not already submitted
    IF EXISTS (
        SELECT 1 FROM StudentExam
        WHERE StudentID = p_StudentID AND ExamID = p_ExamID
    ) THEN
        RAISE EXCEPTION 'Student % already submitted Exam %.',
            p_StudentID, p_ExamID;
    END IF;

    -- Create StudentExam record
    v_StartTime := NOW();
    INSERT INTO StudentExam (StudentID, ExamID, StartTime, EndTime)
    VALUES (p_StudentID, p_ExamID, v_StartTime, p_EndTime)
    RETURNING StudentExamID INTO v_StudentExamID;

    -- Parse XML and insert student answers
    INSERT INTO StudentAnswer (StudentExamID, ExamQID, ChosenOptionID)
    SELECT
        v_StudentExamID,
        (xpath('//ExamQID/text()',               answer))[1]::TEXT::INT,
        NULLIF((xpath('//ChosenOptionID/text()', answer))[1]::TEXT, '')::INT
    FROM unnest(xpath('//Answer', p_AnswersXML)) AS answer;

    RAISE NOTICE 'Exam submitted successfully. StudentExamID = %', v_StudentExamID;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;