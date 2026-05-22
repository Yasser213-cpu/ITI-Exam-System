-- ============================================================
-- sp_SubmitExamAnswers
-- Purpose  : Insert a single student answer for a given question
-- Author   : ITI Dev Team
-- Version  : 1.0
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_SubmitExamAnswers(
    p_StudentExamID  INT,
    p_ExamQID        INT,
    p_ChosenOptionID INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if answer already exists
    IF EXISTS (
        SELECT 1 FROM StudentAnswer
        WHERE StudentExamID = p_StudentExamID
        AND ExamQID = p_ExamQID
    ) THEN
        RAISE EXCEPTION 'Answer already submitted for this question.';
    END IF;

    -- Insert student answer
    INSERT INTO StudentAnswer (StudentExamID, ExamQID, ChosenOptionID)
    VALUES (p_StudentExamID, p_ExamQID, p_ChosenOptionID);

END;
$$;


-- ============================================================
-- fn_Report_StudentGrades
-- Purpose  : Return all exam grades and percentages for a student
-- Author   : ITI Dev Team
-- Version  : 1.0
-- ============================================================
CREATE OR REPLACE FUNCTION fn_Report_StudentGrades(
    p_StudentID INT
)
RETURNS TABLE (
    StudentName VARCHAR,
    ExamName    VARCHAR,
    TotalGrade  DECIMAL,
    Percentage  DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check student exists
    IF NOT EXISTS (
        SELECT 1 FROM Student WHERE StudentID = p_StudentID
    ) THEN
        RAISE EXCEPTION 'StudentID % does not exist.', p_StudentID;
    END IF;

    RETURN QUERY
    SELECT
        s.FullName,
        e.ExamName,
        se.TotalGrade,
        se.Percentage
    FROM StudentExam se
    JOIN Student s ON se.StudentID = s.StudentID
    JOIN Exam    e ON se.ExamID    = e.ExamID
    WHERE se.StudentID = p_StudentID;
END;
$$;