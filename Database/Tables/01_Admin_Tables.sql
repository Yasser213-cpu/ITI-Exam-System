-- ============================================================
-- ITI Exam System — Organizational Entities
-- PostgreSQL Compatible
-- ============================================================

-- 1. Branch
CREATE TABLE Branch (
    BranchID   SERIAL PRIMARY KEY,
    BranchName VARCHAR(100) NOT NULL,
    Location   VARCHAR(200) NOT NULL,
    CONSTRAINT uq_branch_name UNIQUE (BranchName)
);

-- 2. Track
CREATE TABLE Track (
    TrackID    SERIAL PRIMARY KEY,
    TrackName  VARCHAR(100) NOT NULL,
    BranchID   INT          NOT NULL,
    CONSTRAINT fk_track_branch
        FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 3. Instructor
CREATE TABLE Instructor (
    InstructorID SERIAL PRIMARY KEY,
    FullName     VARCHAR(150) NOT NULL,
    DepartmentNo INT          NOT NULL,
    Email        VARCHAR(150) NOT NULL,
    CONSTRAINT uq_instructor_email UNIQUE (Email)
);

-- 4. Course
CREATE TABLE Course (
    CourseID     SERIAL PRIMARY KEY,
    CourseName   VARCHAR(100) NOT NULL,
    TrackID      INT          NOT NULL,
    InstructorID INT          NOT NULL,
    CONSTRAINT fk_course_track
        FOREIGN KEY (TrackID) REFERENCES Track(TrackID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_course_instructor
        FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 5. Student
CREATE TABLE Student (
    StudentID  SERIAL PRIMARY KEY,
    FullName   VARCHAR(150) NOT NULL,
    Email      VARCHAR(150) NOT NULL,
    BranchID   INT          NOT NULL,
    TrackID    INT          NOT NULL,
    CONSTRAINT uq_student_email UNIQUE (Email),
    CONSTRAINT fk_student_branch
        FOREIGN KEY (BranchID) REFERENCES Branch(BranchID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_student_track
        FOREIGN KEY (TrackID) REFERENCES Track(TrackID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

