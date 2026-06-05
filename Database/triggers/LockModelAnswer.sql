-- ============================================================
-- fn_Lock_ModelAnswer
-- Purpose  : Prevent modification of ModelAnswer after usage
--             in StudentAnswer (exam already taken)
-- ============================================================

CREATE OR REPLACE FUNCTION fn_Lock_ModelAnswer()
RETURNS TRIGGER AS $$
BEGIN

    -- Check if this question already used in any exam answers
    IF EXISTS (
        SELECT 1
        FROM StudentAnswer sa
        JOIN ExamQuestion eq ON eq.ExamQID = sa.ExamQID
        WHERE eq.QuestionID = OLD.QuestionID
    ) THEN

        RAISE EXCEPTION
        'ModelAnswer is locked for QuestionID % (already used in exams)',
        OLD.QuestionID;

    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- trg_Lock_ModelAnswer
-- Purpose  : Block UPDATE/DELETE on ModelAnswer after usage
-- ============================================================

DROP TRIGGER IF EXISTS trg_Lock_ModelAnswer ON ModelAnswer;

CREATE TRIGGER trg_Lock_ModelAnswer
BEFORE UPDATE OR DELETE
ON ModelAnswer
FOR EACH ROW
EXECUTE FUNCTION fn_Lock_ModelAnswer();
