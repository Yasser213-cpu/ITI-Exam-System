-- ============================================================
-- sp_SubmitExamAnswers
-- Purpose  : Insert a single student answer for a given question
-- Author   : ITI Dev Team
-- Version  : 1.0
-- ============================================================
CREATE OR REPLACE PROCEDURE sp_submitexamanswers(
    p_StudentID  INT,
    p_ExamID     INT,
    p_EndTime    TIMESTAMPTZ,
    p_AnswersXML XML
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_StudentExamID INT;
BEGIN
    -- Check student exists
    IF NOT EXISTS (
        SELECT 1 FROM student WHERE studentid = p_StudentID
    ) THEN
        RAISE EXCEPTION 'StudentID % does not exist.', p_StudentID;
    END IF;

    -- Check exam exists
    IF NOT EXISTS (
        SELECT 1 FROM exam WHERE examid = p_ExamID
    ) THEN
        RAISE EXCEPTION 'ExamID % does not exist.', p_ExamID;
    END IF;

    -- Check student has not already submitted
    IF EXISTS (
        SELECT 1 FROM studentexam
        WHERE studentid = p_StudentID AND examid = p_ExamID
    ) THEN
        RAISE EXCEPTION 'Student % already submitted Exam %.',
            p_StudentID, p_ExamID;
    END IF;

    -- Create StudentExam record
    INSERT INTO studentexam (studentid, examid, starttime, endtime)
    VALUES (p_StudentID, p_ExamID, NOW(), p_EndTime)
    RETURNING studentexamid INTO v_StudentExamID;

    -- Parse XML and insert student answers
    INSERT INTO studentanswer (studentexamid, examqid, chosenoptionid)
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


-- ============================================================
-- fn_Report_StudentGrades
-- Purpose  : Return all exam grades and percentages for a student
-- Author   : ITI Dev Team
-- Version  : 1.0
-- ============================================================

CREATE OR REPLACE FUNCTION fn_report_studentgrades(
    p_StudentID INT
)
RETURNS TABLE (
    CourseName VARCHAR,
    ExamName   VARCHAR,
    TotalGrade DECIMAL,
    MaxPoints  DECIMAL,
    Percentage DECIMAL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM student WHERE studentid = p_StudentID
    ) THEN
        RAISE EXCEPTION 'StudentID % does not exist.', p_StudentID;
    END IF;

    RETURN QUERY
    SELECT
        c.coursename,
        e.examname,
        se.totalgrade,
        se.maxpoints,
        se.percentage
    FROM studentexam se
    JOIN exam    e ON e.examid   = se.examid
    JOIN course  c ON c.courseid = e.courseid
    WHERE se.studentid   = p_StudentID
    AND   se.totalgrade IS NOT NULL
    ORDER BY e.createddate;
END;
$$;