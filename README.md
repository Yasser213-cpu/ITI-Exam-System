# ITI Online Examination Management System

A database-centric platform designed to automate and manage the full examination lifecycle for students enrolled in ITI (Information Technology Institute) training programs.

---

## 📋 Overview

The system handles everything from exam generation to automated grading, built entirely within PostgreSQL using stored procedures, functions, triggers, and views — with no application-layer business logic.

---

## 🗂️ Project Structure

```
ITI-Exam-System/
├── Database/
│   ├── Tables/
│   │   ├── 01_Admin_Tables.sql        # Branch, Track, Instructor, Course, Student
│   │   ├── 02_Question_Tables.sql     # Question, Options, ModelAnswer
│   │   └── 03_Exam_Tables.sql         # Exam, ExamQuestion, StudentExam, StudentAnswer, AuditLog
│   ├── Procedures/
│   │   ├── 01_Exam_Management.sql     # sp_GenerateExam, sp_SubmitExamAnswers, sp_CorrectExam
│   │   ├── 02_Student_Operations.sql  # Student CRUD operations
│   │   └── 03_Administrative_Reports.sql  # Report functions
│   ├── triggers/
│   │   ├── AuditLog.sql               # trg_AuditLog
│   │   └── LockModelAnswer.sql        # trg_LockModelAnswer
│   └── 00_Setup_DB.sql                # Database creation
├── data/
│   └── sample_data.sql                # Sample data for testing
├── tests/
│   └── test_cases.sql                 # TC-01 to TC-08
├── docs/
│   └── ITI_ERD.pdf                    # Entity Relationship Diagram
└── README.md
```

---

## 🗃️ Database Schema

The system contains **13 tables** organized into 4 groups:

| Group | Tables |
|-------|--------|
| Organizational | Branch, Track, Instructor, Course, Student |
| Question Bank | Question, Options, ModelAnswer |
| Examination | Exam, ExamQuestion, StudentExam, StudentAnswer |
| Audit | AuditLog |

---

## ⚙️ Stored Procedures & Functions

### Core Procedures

| Procedure | Description |
|-----------|-------------|
| `sp_GenerateExam` | Randomly generates an exam with configurable MCQ/TF counts |
| `sp_SubmitExamAnswers` | Accepts student answers via XML and stores them atomically |
| `sp_CorrectExam` | Auto-grades a student exam and calculates percentage |

### Report Functions

| Function | Description |
|----------|-------------|
| `fn_Report_StudentsByDept` | Returns students filtered by department |
| `fn_Report_StudentGrades` | Returns all exam grades for a student |
| `fn_Report_InstructorCourses` | Returns courses taught with enrolled student counts |
| `fn_Report_WeakQuestions` | Returns questions with failure rate above threshold |

### Triggers

| Trigger | Description |
|---------|-------------|
| `trg_LockModelAnswer` | Prevents editing model answers after exam starts |
| `trg_AuditLog` | Logs all DML operations on sensitive tables |

---

## 🚀 Setup Instructions

### Prerequisites
- PostgreSQL 13+
- pgAdmin 4 (or any PostgreSQL client)

### Steps

**1. Create the database:**
```sql
CREATE DATABASE ITI_Exam_DB;
```

**2. Run scripts in order:**
```
01 — Database/Tables/01_Admin_Tables.sql
02 — Database/Tables/02_Question_Tables.sql
03 — Database/Tables/03_Exam_Tables.sql
04 — Database/Procedures/01_Exam_Management.sql
05 — Database/Procedures/02_Student_Operations.sql
06 — Database/Procedures/03_Administrative_Reports.sql
07 — Database/triggers/AuditLog.sql
08 — Database/triggers/LockModelAnswer.sql
09 — data/sample_data.sql
```

> ⚠️ **Important:** PostgreSQL converts table and column names to lowercase automatically. Use lowercase names when writing queries.

**3. Run test cases:**
```
tests/test_cases.sql
```

---

## 🧪 Test Cases

| TC | Scenario | Expected Result |
|----|----------|----------------|
| TC-01 | Generate valid exam | Exam + 15 ExamQuestion rows created |
| TC-02 | Insufficient questions | ERROR: Insufficient MCQ questions |
| TC-03 | Submit exam answers | StudentExam + 15 StudentAnswer rows created |
| TC-04 | Correct exam — all correct | TotalGrade=15, Percentage=100.00 |
| TC-05 | Correct exam — partial | TotalGrade < 15, Percentage < 100 |
| TC-06 | Re-submission blocked | ERROR: Student already submitted |
| TC-07 | Report student grades | Returns grade rows with percentage |
| TC-08 | Report students by dept | Returns filtered student list |

---

## 💻 Technologies Used

- **PostgreSQL 15** — Database engine
- **PL/pgSQL** — Stored procedures, functions, and triggers
- **pgAdmin 4** — Database management and testing
- **XML** — Answer submission format

---

## 📌 Key Design Decisions

- All business logic lives inside the database layer (no app-layer SQL)
- Schema follows **3NF** — no transitive dependencies
- `SERIAL` used for all primary keys (auto-increment)
- `VARCHAR` fields support Arabic character sets
- `RANDOM()` used for true exam randomization
- Model answers are **immutable** once an exam session starts (enforced by trigger)

