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

CREATE VIEW Test AS
    SELECT idnr FROM Students;


--CREATE VIEW BasicInformation (idnr, name, login, program, branch) AS
--SELECT idnr, name, login, Students.program, StudentBranches.branch
--FROM Students 
--LEFT JOIN StudentBranches ON idnr = student;