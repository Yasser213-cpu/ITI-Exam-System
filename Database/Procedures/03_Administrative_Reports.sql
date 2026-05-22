-- ============================================================
-- sp_Report_StudentsByDept
-- Purpose    : Returns all students in a given department
-- Parameters : p_departmentno INT - Department number
-- Returns    : StudentID, FullName, Email, BranchName, TrackName
-- Author     : ITI Dev Team
-- Date       : 2026-03-01
-- Version    : 1.0
-- ============================================================
CREATE OR REPLACE FUNCTION sp_Report_StudentsByDept(p_departmentno INT)
RETURNS TABLE (
    StudentID  INT,
    FullName   VARCHAR(150),
    Email      VARCHAR(150),
    BranchName VARCHAR(100),
    TrackName  VARCHAR(100)
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT s.StudentID, s.FullName, s.Email, b.BranchName, t.TrackName
    FROM Student    s
    JOIN Branch     b ON s.BranchID     = b.BranchID
    JOIN Track      t ON s.TrackID      = t.TrackID
    JOIN Course     c ON t.TrackID      = c.TrackID
    JOIN Instructor i ON c.InstructorID = i.InstructorID
    WHERE i.DepartmentNo = p_departmentno;
END;
$$;


-- ============================================================
-- sp_Report_InstructorCourses
-- Purpose    : Returns all courses taught by an instructor
--              with enrolled student counts
-- Parameters : p_instructorid INT - Instructor ID
-- Returns    : CourseName, TrackName, StudentCount
-- Author     : ITI Dev Team
-- Date       : 2026-03-01
-- Version    : 1.0
-- ============================================================
CREATE OR REPLACE FUNCTION sp_Report_InstructorCourses(p_instructorid INT)
RETURNS TABLE (
    CourseName   VARCHAR(100),
    TrackName    VARCHAR(100),
    StudentCount BIGINT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT c.CourseName, t.TrackName, COUNT(s.StudentID)::BIGINT AS StudentCount
    FROM Course  c
    JOIN Track   t ON c.TrackID = t.TrackID
    LEFT JOIN Student s ON c.TrackID = s.TrackID
    WHERE c.InstructorID = p_instructorid
    GROUP BY c.CourseName, t.TrackName;
END;
$$;