-- 6. Question
CREATE TABLE Question (
    QuestionID   SERIAL      PRIMARY KEY,
    QuestionText TEXT        NOT NULL,
    QuestionType VARCHAR(10) NOT NULL,
    CourseID     INT         NOT NULL,
    CreatedDate  TIMESTAMP   NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_Question_Type
        CHECK (QuestionType IN ('MCQ', 'TF')),
    CONSTRAINT fk_Question_Course
        FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 7. Options 
CREATE TABLE Options (
    OptionID   SERIAL       PRIMARY KEY,
    QuestionID INT          NOT NULL,
    OptionText VARCHAR(500) NOT NULL,
    OrderNo    SMALLINT     NOT NULL,         
    CONSTRAINT chk_Options_OrderNo
        CHECK (OrderNo BETWEEN 1 AND 4),
    CONSTRAINT uq_Options_Order
        UNIQUE (QuestionID, OrderNo),         
    CONSTRAINT fk_Options_Question
        FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 8. ModelAnswer
CREATE TABLE ModelAnswer (
    ModelAnswerID   SERIAL PRIMARY KEY,
    QuestionID      INT    NOT NULL UNIQUE,   
    CorrectOptionID INT    NOT NULL,
    CONSTRAINT fk_ModelAnswer_Question
        FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID)
        ON DELETE RESTRICT ON UPDATE CASCADE, 
    CONSTRAINT fk_ModelAnswer_Option
        FOREIGN KEY (CorrectOptionID) REFERENCES Options(OptionID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);