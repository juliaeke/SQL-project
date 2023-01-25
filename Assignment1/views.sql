CREATE VIEW BasicInformation AS
    SELECT idnr, name, login, program
    FROM Students
    RIGHT JOIN
    Branches
    ON
    name
    ORDER BY idnr;
    
CREATE VIEW FinishedCourses AS
    (SELECT student, course, grade
    FROM Taken)
    UNION
    (Select credits
    FROM Courses)
    ORDER BY student;