-- ============================================================
-- ITI Exam System — Organizational Entities
-- PostgreSQL Compatible
-- ============================================================

-- 6. Question
CREATE TABLE Question (
    QuestionID      SERIAL          PRIMARY KEY,
    QuestionText    TEXT            NOT NULL,
    QuestionType    VARCHAR(10)     NOT NULL,
    CourseID        INT             NOT NULL,
    CreatedDate     TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_Question_Type 
        CHECK (QuestionType IN ('MCQ', 'TF')),

    CONSTRAINT fk_Question_Course 
        FOREIGN KEY (CourseID) 
        REFERENCES Course(CourseID) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);

-- 7. Option
CREATE TABLE Option (
    OptionID       SERIAL PRIMARY KEY,
    QuestionID     INT    NOT NULL,
    OptionText     TEXT   NOT NULL,
    IsCorrect      BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_Option_Question 
        FOREIGN KEY (QuestionID) 
        REFERENCES Question(QuestionID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- 8. ModelAnswer
CREATE TABLE ModelAnswer (
    AnswerID     SERIAL PRIMARY KEY,
    QuestionID   INT    NOT NULL UNIQUE,
    AnswerText   TEXT   NOT NULL,

    CONSTRAINT fk_ModelAnswer_Question 
        FOREIGN KEY (QuestionID) 
        REFERENCES Question(QuestionID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- Constraints (SO IMPORTANT)
CREATE UNIQUE INDEX uq_OneCorrectOption_PerQuestion
ON Option (QuestionID)
WHERE IsCorrect = TRUE;