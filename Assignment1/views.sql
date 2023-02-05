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
    student, course, 'registered' AS status 
    FROM Students, Registered
    WHERE Students.idnr = Registered.student
    UNION
    SELECT 
    student, course, 'waiting' AS status
    FROM Students, Waitinglist
    WHERE Students.idnr = Waitinglist.student;


CREATE VIEW MandatoryCourses AS
    SELECT 
    idnr, 
    BasicInformation.program, 
    BasicInformation.branch, 
    course
    FROM BasicInformation
    JOIN MandatoryProgram 
    ON MandatoryProgram.program = BasicInformation.program
    UNION
    SELECT 
    idnr, 
    BasicInformation.program, 
    BasicInformation.branch, 
    course
    FROM BasicInformation
    JOIN MandatoryBranch 
    ON MandatoryBranch.program=BasicInformation.program 
    AND MandatoryBranch.branch=BasicInformation.branch;


CREATE VIEW UnreadMandatory AS
    SELECT 
    Students.idnr AS student, 
    MandatoryCourses.course
    FROM Students
    JOIN MandatoryCourses 
    ON Students.idnr=MandatoryCourses.idnr
    EXCEPT
    SELECT 
    student, 
    course
    FROM PassedCourses;
   
CREATE VIEW TotalCredits AS
    SELECT 
    student,
    SUM(credits) as totalcredits
    FROM PassedCourses
    GROUP BY student;

CREATE VIEW MandatoryLeft AS
    SELECT 
    student, 
    COUNT(student) as mandatoryleft
    FROM UnreadMandatory
    GROUP BY student;

CREATE VIEW MathCredits AS
    SELECT 
    student, 
    SUM(credits) as mathcredits
    FROM PassedCourses, Classified
    WHERE
    PassedCourses.course = Classified.course 
    AND Classified.classification = 'math'
    GROUP BY student;

CREATE VIEW ResearchCredits AS
    SELECT 
    student, 
    SUM(credits) as researchcredits
    FROM PassedCourses, Classified
    WHERE
    PassedCourses.course = Classified.course 
    AND Classified.classification = 'research'
    GROUP BY student;


CREATE VIEW SeminarCourses AS
    SELECT 
    student, 
    COUNT(PassedCourses.course) as seminarcourses
    FROM PassedCourses, Classified
    WHERE
    PassedCourses.course = Classified.course 
    AND Classified.classification = 'seminar'
    GROUP BY student;


CREATE VIEW RecommendedCourses AS
    SELECT 
    student, 
    RecommendedBranch.course AS course,
    Courses.credits as credits
    FROM StudentBranches, RecommendedBranch
    LEFT OUTER JOIN
    Courses 
    ON RecommendedBranch.course = Courses.code
    WHERE StudentBranches.branch = RecommendedBranch.branch 
    AND StudentBranches.program = RecommendedBranch.program;


CREATE VIEW PassedRecommendedCourses AS 
    SELECT *
    FROM RecommendedCourses
    INTERSECT
    SELECT 
    PassedCourses.student as student, 
    PassedCourses.course as course,
    PassedCourses.credits as credits
    FROM PassedCourses;


CREATE VIEW Requirements AS
    SELECT
    BasicInformation.idnr as student,
    COALESCE(MandatoryLeft.mandatoryleft, 0) as mandatory,
    COALESCE(PassedRecommendedCourses.credits, 0) as recommended,
    COALESCE(MathCredits.mathcredits, 0) as math,
    COALESCE(ResearchCredits.researchcredits, 0) as research,
    COALESCE(SeminarCourses.seminarcourses, 0) as seminar
    FROM BasicInformation
    LEFT OUTER JOIN 
    MandatoryLeft
    ON BasicInformation.idnr = MandatoryLeft.student
    LEFT OUTER JOIN
    PassedRecommendedCourses
    ON BasicInformation.idnr = PassedRecommendedCourses.student
    LEFT OUTER JOIN
    MathCredits
    ON BasicInformation.idnr = MathCredits.student
    LEFT OUTER JOIN
    ResearchCredits
    ON BasicInformation.idnr = ResearchCredits.student
    LEFT OUTER JOIN
    SeminarCourses
    ON BasicInformation.idnr = SeminarCourses.student;
     
CREATE VIEW Qualified AS
    SELECT
    Requirements.student AS student,
    CASE
        WHEN (Requirements.mandatory = 0
        AND Requirements.recommended >= 10
        AND Requirements.math >= 20
        AND Requirements.research >= 20
        AND Requirements.seminar >= 1)
        THEN TRUE
        ELSE FALSE
    END as qualified
    FROM Requirements;


CREATE VIEW PathToGraduation AS
    SELECT 
    Requirements.student AS student,
    COALESCE(TotalCredits.totalcredits, 0) as TotalCredits,
    Requirements.mandatory AS mandatoryLeft,
    Requirements.math AS mathCredits,
    Requirements.research AS researchCredits,
    Requirements.seminar AS seminarCourses, 
    Qualified.qualified AS qualified
    FROM Requirements
    LEFT OUTER JOIN
    Qualified 
    ON Qualified.student = Requirements.student
    LEFT OUTER JOIN
    TotalCredits
    ON Requirements.student = TotalCredits.student