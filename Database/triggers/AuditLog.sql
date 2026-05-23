--  trg_AuditLog
-- record AuditLog after  INSERT/UPDATE/DELETE on tables:
--   • Question
--   • ModelAnswer
--   • StudentAnswer
-- ============================================================
 
-- Function for  Question
CREATE OR REPLACE FUNCTION fn_AuditLog_Question()
RETURNS TRIGGER AS $$
DECLARE
    v_record_id INT;
    v_details   TEXT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_record_id := OLD.questionid;
        v_details   := 'QuestionText: ' || LEFT(OLD.questiontext, 100);
    ELSE
        v_record_id := NEW.questionid;
        v_details   := 'QuestionText: ' || LEFT(NEW.questiontext, 100);
    END IF;
 
    INSERT INTO AuditLog (tablename, operation, recordid, changedby, changedate, details)
    VALUES (
        'Question',
        TG_OP,
        v_record_id,
        current_user,
        NOW(),
        v_details
    );
 
    IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$$ LANGUAGE plpgsql;
 
 
-- اFunction to ModelAnswer
CREATE OR REPLACE FUNCTION fn_AuditLog_ModelAnswer()
RETURNS TRIGGER AS $$
DECLARE
    v_record_id INT;
    v_details   TEXT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_record_id := OLD.modelanswerid;
        v_details   := 'QuestionID: ' || OLD.questionid
                    || ' | CorrectOptionID: ' || OLD.correctoptionid;
    ELSE
        v_record_id := NEW.modelanswerid;
        v_details   := 'QuestionID: ' || NEW.questionid
                    || ' | CorrectOptionID: ' || NEW.correctoptionid;
    END IF;
 
    INSERT INTO AuditLog (tablename, operation, recordid, changedby, changedate, details)
    VALUES (
        'ModelAnswer',
        TG_OP,
        v_record_id,
        current_user,
        NOW(),
        v_details
    );
 
    IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$$ LANGUAGE plpgsql;
 
 
-- اFunction to StudentAnswer
CREATE OR REPLACE FUNCTION fn_AuditLog_StudentAnswer()
RETURNS TRIGGER AS $$
DECLARE
    v_record_id INT;
    v_details   TEXT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_record_id := OLD.answerid;
        v_details   := 'StudentExamID: ' || OLD.studentexamid
                    || ' | ExamQID: '     || OLD.examqid;
    ELSE
        v_record_id := NEW.answerid;
        v_details   := 'StudentExamID: ' || NEW.studentexamid
                    || ' | ExamQID: '     || NEW.examqid;
    END IF;
 
    INSERT INTO AuditLog (tablename, operation, recordid, changedby, changedate, details)
    VALUES (
        'StudentAnswer',
        TG_OP,
        v_record_id,
        current_user,
        NOW(),
        v_details
    );
 
    IF TG_OP = 'DELETE' THEN RETURN OLD; ELSE RETURN NEW; END IF;
END;
$$ LANGUAGE plpgsql;
 
 
--  link  Functions with Triggers
DROP TRIGGER IF EXISTS trg_AuditLog_Question  ON Question;
DROP TRIGGER IF EXISTS trg_AuditLog_ModelAnswer ON ModelAnswer;
DROP TRIGGER IF EXISTS trg_AuditLog_StudentAnswer ON StudentAnswer;
 
CREATE TRIGGER trg_AuditLog_Question
    AFTER INSERT OR UPDATE OR DELETE
    ON Question
    FOR EACH ROW
    EXECUTE FUNCTION fn_AuditLog_Question();
 
CREATE TRIGGER trg_AuditLog_ModelAnswer
    AFTER INSERT OR UPDATE OR DELETE
    ON ModelAnswer
    FOR EACH ROW
    EXECUTE FUNCTION fn_AuditLog_ModelAnswer();
 
CREATE TRIGGER trg_AuditLog_StudentAnswer
    AFTER INSERT OR UPDATE OR DELETE
    ON StudentAnswer
    FOR EACH ROW
    EXECUTE FUNCTION fn_AuditLog_StudentAnswer();