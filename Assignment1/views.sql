CREATE VIEW BasicInformation AS
    SELECT 
    Students.idnr as idnr,
    Students.name as name,
    Students.login as login,
    Students.program as program,
    StudentBranches.branch as branch
    FROM Students
    LEFT JOIN StudentBranches ON idnr = student
    ORDER BY idnr;

CREATE VIEW FinishedCourses AS
    SELECT 
    Taken.student as student,
    Taken.course as course,
    Taken.grade as grade,
    Courses.credits as credits
    FROM Taken, Courses
    WHERE Taken.course = Courses.code
    ORDER BY student;

CREATE VIEW PassedCourses AS
    SELECT
    Taken.student as student,
    Taken.course as course,
    Courses.credits as credits
    FROM Taken, Courses
    WHERE Taken.course = Courses.code AND
    NOT Taken.grade = 'U';
    
CREATE VIEW Registrations AS
    SELECT 
    student, course, 'registred' AS status 
    FROM Registered
    UNION
    SELECT student, course, 'waiting' AS status 
    FROM WaitingList;
    
CREATE VIEW MandatoryCourses AS
   SELECT 
   student, 
   MandatoryBranch.course AS course
   FROM StudentBranches, MandatoryBranch
   WHERE StudentBranches.branch = MandatoryBranch.branch 
   AND StudentBranches.program = MandatoryBranch.program
   UNION
   SELECT idnr, MandatoryProgram.course
   FROM Students, MandatoryProgram
   WHERE Students.program = MandatoryProgram.program;

CREATE VIEW UnreadMandatory AS
    SELECT *
    FROM MandatoryCourses
    EXCEPT
    SELECT student, course
    FROM PassedCourses;
   
CREATE VIEW PathToGraduation AS