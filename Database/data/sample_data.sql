-- ============================================================
-- ITI Exam System — Sample Data
-- PostgreSQL Compatible | Version 1.0
-- ============================================================


-- ============================================================
-- STEP 1: CLEAN ALL TABLES
-- ============================================================
TRUNCATE TABLE auditlog       RESTART IDENTITY CASCADE;
TRUNCATE TABLE studentanswer  RESTART IDENTITY CASCADE;
TRUNCATE TABLE studentexam    RESTART IDENTITY CASCADE;
TRUNCATE TABLE examquestion   RESTART IDENTITY CASCADE;
TRUNCATE TABLE exam           RESTART IDENTITY CASCADE;
TRUNCATE TABLE modelanswer    RESTART IDENTITY CASCADE;
TRUNCATE TABLE options        RESTART IDENTITY CASCADE;
TRUNCATE TABLE question       RESTART IDENTITY CASCADE;
TRUNCATE TABLE student        RESTART IDENTITY CASCADE;
TRUNCATE TABLE course         RESTART IDENTITY CASCADE;
TRUNCATE TABLE instructor     RESTART IDENTITY CASCADE;
TRUNCATE TABLE track          RESTART IDENTITY CASCADE;
TRUNCATE TABLE branch         RESTART IDENTITY CASCADE;


-- ============================================================
-- STEP 2: INSERT DATA
-- ============================================================

-- 1. Branch
INSERT INTO branch (branchname, location) VALUES
('Cairo Branch',      'Cairo, Nasr City'),
('Alexandria Branch', 'Alexandria, Smouha'),
('Mansoura Branch',   'Mansoura, Gomhouria St');

-- 2. Track
INSERT INTO track (trackname, branchid) VALUES
('Software Development', 1),
('Data Science',         1),
('Network Engineering',  2),
('Software Development', 2),
('Data Science',         3);

-- 3. Instructor
INSERT INTO instructor (fullname, departmentno, email) VALUES
('Ahmed Hassan', 1, 'ahmed.hassan@iti.gov.eg'),
('Sara Mohamed', 1, 'sara.mohamed@iti.gov.eg'),
('Omar Khalil',  2, 'omar.khalil@iti.gov.eg'),
('Nada Samy',    2, 'nada.samy@iti.gov.eg');

-- 4. Course
INSERT INTO course (coursename, trackid, instructorid) VALUES
('Database Fundamentals', 1, 1),
('Python Programming',    1, 2),
('Machine Learning',      2, 2),
('Network Security',      3, 3),
('Web Development',       4, 4);

-- 5. Student
INSERT INTO student (fullname, email, branchid, trackid) VALUES
('Ali Mahmoud',   'ali.mahmoud@student.iti.eg',   1, 1),
('Mona Adel',     'mona.adel@student.iti.eg',     1, 1),
('Youssef Tarek', 'youssef.tarek@student.iti.eg', 1, 2),
('Hana Sayed',    'hana.sayed@student.iti.eg',    2, 3),
('Karim Nasser',  'karim.nasser@student.iti.eg',  2, 4);

-- 6. Question (Course 1 — Database Fundamentals)
-- MCQ (20 questions)
INSERT INTO question (questiontext, questiontype, courseid) VALUES
('What does SQL stand for?',                            'MCQ', 1),
('Which command is used to retrieve data?',             'MCQ', 1),
('What is a Primary Key?',                              'MCQ', 1),
('Which JOIN returns all rows from both tables?',       'MCQ', 1),
('What does DISTINCT do in a SELECT statement?',        'MCQ', 1),
('Which command is used to delete a table?',            'MCQ', 1),
('What is a Foreign Key?',                              'MCQ', 1),
('Which aggregate function returns the highest value?', 'MCQ', 1),
('What does GROUP BY do?',                              'MCQ', 1),
('Which clause filters grouped results?',               'MCQ', 1),
('What is normalization?',                              'MCQ', 1),
('Which normal form eliminates transitive dependency?', 'MCQ', 1),
('What is an index used for?',                          'MCQ', 1),
('Which command adds a new row?',                       'MCQ', 1),
('What does ROLLBACK do?',                              'MCQ', 1),
('Which command saves a transaction?',                  'MCQ', 1),
('What is a VIEW in SQL?',                              'MCQ', 1),
('Which operator checks for NULL values?',              'MCQ', 1),
('What does COUNT(*) return?',                          'MCQ', 1),
('Which command modifies existing data?',               'MCQ', 1);

-- TF (10 questions)
INSERT INTO question (questiontext, questiontype, courseid) VALUES
('A table can have more than one Primary Key.',     'TF', 1),
('NULL means zero in SQL.',                         'TF', 1),
('SELECT * retrieves all columns.',                 'TF', 1),
('DELETE removes the table structure.',             'TF', 1),
('A Foreign Key can be NULL.',                      'TF', 1),
('HAVING is used instead of WHERE with GROUP BY.',  'TF', 1),
('An index always speeds up INSERT operations.',    'TF', 1),
('INNER JOIN returns only matching rows.',          'TF', 1),
('TRUNCATE can be rolled back.',                    'TF', 1),
('A VIEW stores data physically.',                  'TF', 1);

-- 7. Options (MCQ — 4 options each)
INSERT INTO options (questionid, optiontext, orderno) VALUES
(1,  'Structured Query Language',        1),
(1,  'Simple Query Language',            2),
(1,  'Structured Question Language',     3),
(1,  'Standard Query Logic',             4),
(2,  'SELECT',                           1),
(2,  'INSERT',                           2),
(2,  'UPDATE',                           3),
(2,  'DELETE',                           4),
(3,  'A unique identifier for each row', 1),
(3,  'A key that can have duplicates',   2),
(3,  'A foreign reference',              3),
(3,  'An optional field',                4),
(4,  'FULL OUTER JOIN',                  1),
(4,  'INNER JOIN',                       2),
(4,  'LEFT JOIN',                        3),
(4,  'CROSS JOIN',                       4),
(5,  'Removes duplicate rows',           1),
(5,  'Sorts the results',                2),
(5,  'Filters rows by condition',        3),
(5,  'Groups rows together',             4),
(6,  'DROP TABLE',                       1),
(6,  'DELETE TABLE',                     2),
(6,  'REMOVE TABLE',                     3),
(6,  'TRUNCATE TABLE',                   4),
(7,  'A key linking two tables',         1),
(7,  'A key with unique values',         2),
(7,  'A key that auto-increments',       3),
(7,  'A key that allows NULLs only',     4),
(8,  'MAX()',                            1),
(8,  'SUM()',                            2),
(8,  'COUNT()',                          3),
(8,  'AVG()',                            4),
(9,  'Groups rows by column values',     1),
(9,  'Filters rows by condition',        2),
(9,  'Sorts rows in order',              3),
(9,  'Joins two tables',                 4),
(10, 'HAVING',                           1),
(10, 'WHERE',                            2),
(10, 'ORDER BY',                         3),
(10, 'GROUP BY',                         4),
(11, 'Organizing data to reduce redundancy', 1),
(11, 'Adding indexes to tables',             2),
(11, 'Encrypting database columns',          3),
(11, 'Backing up the database',              4),
(12, '3NF',                              1),
(12, '1NF',                              2),
(12, '2NF',                              3),
(12, 'BCNF',                             4),
(13, 'Speed up data retrieval',          1),
(13, 'Store backup data',                2),
(13, 'Encrypt table columns',            3),
(13, 'Link two tables',                  4),
(14, 'INSERT',                           1),
(14, 'ADD',                              2),
(14, 'CREATE',                           3),
(14, 'UPDATE',                           4),
(15, 'Undoes uncommitted transactions',  1),
(15, 'Saves the transaction',            2),
(15, 'Deletes all rows',                 3),
(15, 'Creates a savepoint',              4),
(16, 'COMMIT',                           1),
(16, 'SAVE',                             2),
(16, 'ROLLBACK',                         3),
(16, 'END',                              4),
(17, 'A virtual table based on a query', 1),
(17, 'A physical copy of a table',       2),
(17, 'A stored procedure',               3),
(17, 'An index on a table',              4),
(18, 'IS NULL',                          1),
(18, 'EQUALS NULL',                      2),
(18, '= NULL',                           3),
(18, 'NULL LIKE',                        4),
(19, 'Number of rows',                   1),
(19, 'Sum of values',                    2),
(19, 'Average of values',                3),
(19, 'Maximum value',                    4),
(20, 'UPDATE',                           1),
(20, 'MODIFY',                           2),
(20, 'ALTER',                            3),
(20, 'CHANGE',                           4);

-- Options TF (2 options each)
INSERT INTO options (questionid, optiontext, orderno) VALUES
(21, 'True', 1), (21, 'False', 2),
(22, 'True', 1), (22, 'False', 2),
(23, 'True', 1), (23, 'False', 2),
(24, 'True', 1), (24, 'False', 2),
(25, 'True', 1), (25, 'False', 2),
(26, 'True', 1), (26, 'False', 2),
(27, 'True', 1), (27, 'False', 2),
(28, 'True', 1), (28, 'False', 2),
(29, 'True', 1), (29, 'False', 2),
(30, 'True', 1), (30, 'False', 2);

-- 8. ModelAnswer
-- NOTE: OptionIDs assume clean insert starting from 1
INSERT INTO modelanswer (questionid, correctoptionid) VALUES
(1,  1),   -- Structured Query Language
(2,  5),   -- SELECT
(3,  9),   -- A unique identifier for each row
(4,  13),  -- FULL OUTER JOIN
(5,  17),  -- Removes duplicate rows
(6,  21),  -- DROP TABLE
(7,  25),  -- A key linking two tables
(8,  29),  -- MAX()
(9,  33),  -- Groups rows by column values
(10, 37),  -- HAVING
(11, 41),  -- Organizing data to reduce redundancy
(12, 45),  -- 3NF
(13, 49),  -- Speed up data retrieval
(14, 53),  -- INSERT
(15, 57),  -- Undoes uncommitted transactions
(16, 61),  -- COMMIT
(17, 65),  -- A virtual table based on a query
(18, 69),  -- IS NULL
(19, 73),  -- Number of rows
(20, 77),  -- UPDATE
(21, 82),  -- False (table has ONE PK)
(22, 84),  -- False (NULL != zero)
(23, 85),  -- True  (SELECT * = all columns)
(24, 88),  -- False (DELETE removes rows not structure)
(25, 89),  -- True  (FK can be NULL)
(26, 91),  -- True  (HAVING with GROUP BY)
(27, 94),  -- False (index slows INSERT)
(28, 95),  -- True  (INNER JOIN = matching rows)
(29, 98),  -- False (TRUNCATE cannot be rolled back)
(30, 100); -- False (VIEW is virtual not physical)
