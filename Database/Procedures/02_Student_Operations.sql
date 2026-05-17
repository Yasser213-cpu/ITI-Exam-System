-- ============================================================
-- sp_SubmitExamAnswers
-- Purpose  : Generate a randomized exam for a given course
-- Author   : ITI Dev Team
-- Version  : 1.0
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_SubmitExamAnswers(
	p_StudentExamID INT,
	p_ExamQID INT,
	p_ChosenOptionID INT,
)
LANGUAGE plpgsql
AS $$
BEGIN

	-- Check if answer already exists
	IF EXISTS (
        SELECT 1
        FROM StudentAnswer
        WHERE StudentExamID = p_StudentExamID
          AND ExamQID = p_ExamQID
    	) THEN
        	RAISE EXCEPTION 'Answer already submitted for this question!';
    	END IF;

	-- Insert student answer
	INSERT INTO StudentAnswer (
        StudentExamID,
        ExamQID,
        ChosenOptionID
    	)
    	VALUES (
        	p_StudentExamID,
       		p_ExamQID,
        	p_ChosenOptionID
    	);
END;
$$;

-- ============================================================
-- sp_Report_StudentGrades
-- Purpose  : Generate a randomized exam for a given course
-- Author   : ITI Dev Team
-- Version  : 1.0
-- ============================================================

CREATE OR REPLACE FUNCTION sp_Report_StudentGrades()
RETURNS TABLE (
    StudentName VARCHAR,
    ExamName VARCHAR,
    TotalGrade DECIMAL,
    Percentage DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT
        s.StudentName,
        e.ExamName,
        se.TotalGrade,
        se.Percentage
    FROM StudentExam se
    JOIN Student s
        ON se.StudentID = s.StudentID
    JOIN Exam e
        ON se.ExamID = e.ExamID;

END;
$$;