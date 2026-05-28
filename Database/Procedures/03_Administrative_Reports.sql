-- ============================================================
-- fn_Report_StudentsByDept
-- Purpose    : Returns all students in a given department
-- Parameters : p_departmentno INT - Department number
-- Returns    : StudentID, FullName, Email, BranchName, TrackName
-- Author     : ITI Dev Team
-- Date       : 2026-03-01
-- Version    : 1.0
-- ============================================================
DROP FUNCTION IF EXISTS sp_report_studentsbydept(INT);

CREATE OR REPLACE FUNCTION fn_report_studentsbydept(p_departmentno INT)
RETURNS TABLE (
    studentid  INT,
    fullname   VARCHAR(150),
    email      VARCHAR(150),
    branchname VARCHAR(100),
    trackname  VARCHAR(100)
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Check department exists
    IF NOT EXISTS (
        SELECT 1 FROM instructor WHERE departmentno = p_departmentno
    ) THEN
        RAISE EXCEPTION 'DepartmentNo % does not exist.', p_departmentno;
    END IF;

    RETURN QUERY
    SELECT DISTINCT
        s.studentid,
        s.fullname,
        s.email,
        b.branchname,
        t.trackname
    FROM student     s
    JOIN branch      b ON s.branchid     = b.branchid
    JOIN track       t ON s.trackid      = t.trackid
    JOIN course      c ON t.trackid      = c.trackid
    JOIN instructor  i ON c.instructorid = i.instructorid
    WHERE i.departmentno = p_departmentno
    ORDER BY s.fullname;
END;
$$;


-- ============================================================
-- fn_Report_InstructorCourses
-- Purpose    : Returns all courses taught by an instructor
--              with enrolled student counts
-- Parameters : p_instructorid INT - Instructor ID
-- Returns    : CourseName, TrackName, StudentCount
-- Author     : ITI Dev Team
-- Date       : 2026-03-01
-- Version    : 1.0
-- ============================================================
DROP FUNCTION IF EXISTS sp_report_instructorcourses(INT);

CREATE OR REPLACE FUNCTION fn_report_instructorcourses(p_instructorid INT)
RETURNS TABLE (
    coursename   VARCHAR(100),
    trackname    VARCHAR(100),
    studentcount BIGINT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Check instructor exists
    IF NOT EXISTS (
        SELECT 1 FROM instructor WHERE instructorid = p_instructorid
    ) THEN
        RAISE EXCEPTION 'InstructorID % does not exist.', p_instructorid;
    END IF;

    RETURN QUERY
    SELECT
        c.coursename,
        t.trackname,
        COUNT(DISTINCT s.studentid)::BIGINT AS studentcount
    FROM course  c
    JOIN track   t ON c.trackid = t.trackid
    LEFT JOIN student s ON s.trackid = c.trackid
    WHERE c.instructorid = p_instructorid
    GROUP BY c.coursename, t.trackname
    ORDER BY c.coursename;
END;
$$;