-- ============================================================
-- ITI Exam System — Test Cases
-- PostgreSQL Compatible | Version 1.0
-- Run sample_data.sql first before running these tests
-- ============================================================


-- ------------------------------------------------------------
-- TC-01: Generate valid exam
-- Input  : CourseID=1, ExamName='MidTerm Exam', NumMCQ=10, NumTF=5
-- Expected: Exam record created, 15 ExamQuestion rows, no duplicates
-- ------------------------------------------------------------
CALL sp_generateexam(1, 'MidTerm Exam', 10, 5);

SELECT * FROM exam;
SELECT * FROM examquestion ORDER BY orderno;


-- ------------------------------------------------------------
-- TC-02: Insufficient questions
-- Input  : CourseID=2 (no questions), NumMCQ=10
-- Expected: ERROR — Insufficient MCQ questions for this course
-- ------------------------------------------------------------
CALL sp_generateexam(2, 'Python Exam', 10, 5);


-- ------------------------------------------------------------
-- TC-03: Submit exam answers
-- Input  : StudentID=1, ExamID=1, 15 answers via XML
-- Expected: StudentExam created, 15 StudentAnswer rows, TotalGrade=NULL
-- NOTE: Run TC-01 first to confirm ExamQIDs (should be 1-15)
-- ------------------------------------------------------------
CALL sp_submitexamanswers(
    1, 1, NOW(),
    '<Answers>
        <Answer><ExamQID>1</ExamQID><ChosenOptionID>21</ChosenOptionID></Answer>
        <Answer><ExamQID>2</ExamQID><ChosenOptionID>73</ChosenOptionID></Answer>
        <Answer><ExamQID>3</ExamQID><ChosenOptionID>29</ChosenOptionID></Answer>
        <Answer><ExamQID>4</ExamQID><ChosenOptionID>77</ChosenOptionID></Answer>
        <Answer><ExamQID>5</ExamQID><ChosenOptionID>5</ChosenOptionID></Answer>
        <Answer><ExamQID>6</ExamQID><ChosenOptionID>49</ChosenOptionID></Answer>
        <Answer><ExamQID>7</ExamQID><ChosenOptionID>17</ChosenOptionID></Answer>
        <Answer><ExamQID>8</ExamQID><ChosenOptionID>33</ChosenOptionID></Answer>
        <Answer><ExamQID>9</ExamQID><ChosenOptionID>25</ChosenOptionID></Answer>
        <Answer><ExamQID>10</ExamQID><ChosenOptionID>65</ChosenOptionID></Answer>
        <Answer><ExamQID>11</ExamQID><ChosenOptionID>98</ChosenOptionID></Answer>
        <Answer><ExamQID>12</ExamQID><ChosenOptionID>89</ChosenOptionID></Answer>
        <Answer><ExamQID>13</ExamQID><ChosenOptionID>94</ChosenOptionID></Answer>
        <Answer><ExamQID>14</ExamQID><ChosenOptionID>84</ChosenOptionID></Answer>
        <Answer><ExamQID>15</ExamQID><ChosenOptionID>88</ChosenOptionID></Answer>
    </Answers>'::XML
);

SELECT * FROM studentexam;
SELECT * FROM studentanswer;


-- ------------------------------------------------------------
-- TC-04: Correct exam — all correct
-- Input  : StudentExamID=1 (all correct answers)
-- Expected: TotalGrade=15, MaxPoints=15, Percentage=100.00
-- ------------------------------------------------------------
CALL sp_correctexam(1);

SELECT studentexamid, totalgrade, maxpoints, percentage
FROM studentexam WHERE studentexamid = 1;


-- ------------------------------------------------------------
-- TC-05: Correct exam — partial
-- Input  : StudentID=2, some wrong answers
-- Expected: TotalGrade < 15, Percentage < 100
-- ------------------------------------------------------------
CALL sp_submitexamanswers(
    2, 1, NOW(),
    '<Answers>
        <Answer><ExamQID>1</ExamQID><ChosenOptionID>22</ChosenOptionID></Answer>
        <Answer><ExamQID>2</ExamQID><ChosenOptionID>74</ChosenOptionID></Answer>
        <Answer><ExamQID>3</ExamQID><ChosenOptionID>29</ChosenOptionID></Answer>
        <Answer><ExamQID>4</ExamQID><ChosenOptionID>77</ChosenOptionID></Answer>
        <Answer><ExamQID>5</ExamQID><ChosenOptionID>6</ChosenOptionID></Answer>
        <Answer><ExamQID>6</ExamQID><ChosenOptionID>49</ChosenOptionID></Answer>
        <Answer><ExamQID>7</ExamQID><ChosenOptionID>18</ChosenOptionID></Answer>
        <Answer><ExamQID>8</ExamQID><ChosenOptionID>33</ChosenOptionID></Answer>
        <Answer><ExamQID>9</ExamQID><ChosenOptionID>26</ChosenOptionID></Answer>
        <Answer><ExamQID>10</ExamQID><ChosenOptionID>65</ChosenOptionID></Answer>
        <Answer><ExamQID>11</ExamQID><ChosenOptionID>98</ChosenOptionID></Answer>
        <Answer><ExamQID>12</ExamQID><ChosenOptionID>90</ChosenOptionID></Answer>
        <Answer><ExamQID>13</ExamQID><ChosenOptionID>93</ChosenOptionID></Answer>
        <Answer><ExamQID>14</ExamQID><ChosenOptionID>84</ChosenOptionID></Answer>
        <Answer><ExamQID>15</ExamQID><ChosenOptionID>87</ChosenOptionID></Answer>
    </Answers>'::XML
);

CALL sp_correctexam(2);

SELECT studentexamid, totalgrade, maxpoints, percentage
FROM studentexam WHERE studentexamid = 2;


-- ------------------------------------------------------------
-- TC-06: Re-submission blocked
-- Input  : StudentID=1 re-submitting Exam 1
-- Expected: ERROR — Student 1 already submitted Exam 1
-- ------------------------------------------------------------
CALL sp_submitexamanswers(
    1, 1, NOW(),
    '<Answers>
        <Answer><ExamQID>1</ExamQID><ChosenOptionID>21</ChosenOptionID></Answer>
    </Answers>'::XML
);


-- ------------------------------------------------------------
-- TC-07: Report — Student grades
-- Input  : StudentID=1
-- Expected: Rows with CourseName, ExamName, TotalGrade, MaxPoints, Percentage
-- ------------------------------------------------------------
SELECT * FROM fn_report_studentgrades(1);


-- ------------------------------------------------------------
-- TC-08: Report — Students by department
-- Input  : DepartmentNo=1
-- Expected: Ali Mahmoud, Mona Adel, Youssef Tarek
-- ------------------------------------------------------------
SELECT * FROM fn_report_studentsbydept(1);
