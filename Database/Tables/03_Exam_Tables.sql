-- 9. Exam
CREATE TABLE Exam (
    ExamID          SERIAL         PRIMARY KEY,
    ExamName        VARCHAR(200)    NOT NULL,
    CourseID        INT             NOT NULL,
    CreatedDate     TIMESTAMP       NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_Exam_Course FOREIGN KEY (CourseID) REFERENCES Course(CourseID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 10. ExamQuestion
CREATE TABLE ExamQuestion (
    ExamQID     SERIAL          PRIMARY KEY,
    ExamID      INT             NOT NULL,
    QuestionID  INT             NOT NULL,
    OrderNo     INT             NOT NULL,
    Points      DECIMAL(5,2)    NOT NULL DEFAULT 1.00,
    CONSTRAINT uq_ExamQuestion_ExamQuestion     UNIQUE (ExamID, QuestionID),
    CONSTRAINT chk_ExamQuestion_Points          CHECK (Points > 0),
    CONSTRAINT fk_ExamQuestion_Exam             FOREIGN KEY (ExamID)      REFERENCES Exam(ExamID)         ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_ExamQuestion_Question         FOREIGN KEY (QuestionID)  REFERENCES Question(QuestionID) ON DELETE RESTRICT ON UPDATE CASCADE
);
-- 11. StudentExam
CREATE TABLE StudentExam (
    StudentExamID   SERIAL          PRIMARY KEY,
    StudentID       INT             NOT NULL,
    ExamID          INT             NOT NULL,
    StartTime       TIMESTAMP,
    EndTime         TIMESTAMP,
    TotalGrade      DECIMAL(6,2),
    MaxPoints       DECIMAL(6,2),
    Percentage      DECIMAL(5,2),
    CONSTRAINT uq_StudentExam_StudentExam       UNIQUE (StudentID, ExamID),
    CONSTRAINT chk_StudentExam_Times            CHECK (EndTime IS NULL OR EndTime >= StartTime),
    CONSTRAINT chk_StudentExam_Percentage       CHECK (Percentage IS NULL OR (Percentage >= 0 AND Percentage <= 100)),
    CONSTRAINT fk_StudentExam_Student           FOREIGN KEY (StudentID) REFERENCES Student(StudentID) ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_StudentExam_Exam              FOREIGN KEY (ExamID)    REFERENCES Exam(ExamID)       ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 12. StudentAnswer
CREATE TABLE StudentAnswer (
    AnswerID        SERIAL  PRIMARY KEY,
    StudentExamID   INT     NOT NULL,
    ExamQID         INT     NOT NULL,
    ChosenOptionID  INT,
    CONSTRAINT uq_StudentAnswer_ExamQStudent    UNIQUE (StudentExamID, ExamQID),
    CONSTRAINT fk_StudentAnswer_StudentExam     FOREIGN KEY (StudentExamID)    REFERENCES StudentExam(StudentExamID) ON DELETE CASCADE  ON UPDATE CASCADE,
    CONSTRAINT fk_StudentAnswer_ExamQuestion    FOREIGN KEY (ExamQID)          REFERENCES ExamQuestion(ExamQID)      ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_StudentAnswer_Option          FOREIGN KEY (ChosenOptionID)   REFERENCES Option(OptionID)         ON DELETE RESTRICT ON UPDATE CASCADE
);
-- 13. AuditLog
CREATE TABLE AuditLog (
    LogID       SERIAL          PRIMARY KEY,
    TableName   VARCHAR(100)    NOT NULL,
    Operation   VARCHAR(10)     NOT NULL,
    RecordID    INT             NOT NULL,
    ChangedBy   VARCHAR(100)    NOT NULL DEFAULT CURRENT_USER,
    ChangedAt   TIMESTAMP       NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_AuditLog_Operation CHECK (Operation IN ('INSERT', 'UPDATE', 'DELETE'))
);

