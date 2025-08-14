---لیست دانشجوها به همراه نام دانشکده‌شان

SELECT s.S#, s.sname, c.clgname
FROM stud s
JOIN clg c ON s.clg# = c.clg#;

---تعداد دانشجوها در هر دانشکده
SELECT c.clgname, COUNT(s.S#) AS StudentCount
FROM clg c
LEFT JOIN stud s ON c.clg# = s.clg#
GROUP BY c.clgname;

----لیست درس‌ها و تعداد واحد هر کدام
SELECT cname, unit
FROM crs;

----لیست درس‌هایی که بیش از 3 واحد دارند
SELECT cname, unit
FROM crs
WHERE unit > 3;

----افزودن دانشجو جدید
CREATE PROCEDURE AddStudent
    @Sname NVARCHAR(50),
    @City NVARCHAR(50),
    @Avg DECIMAL(4,2),
    @ClgID INT
AS
BEGIN
    INSERT INTO stud (sname, city, avg, clg#)
    VALUES (@Sname, @City, @Avg, @ClgID);
END;

----محاسبه معدل یک دانشجو بر اساس شماره دانشجو
CREATE FUNCTION GetStudentAverage (@StudentID INT)
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @Avg DECIMAL(4,2);
    SELECT @Avg = avg FROM stud WHERE S# = @StudentID;
    RETURN @Avg;
END;

-----ثبت یک درس برای دانشجو در جدول sec
BEGIN TRANSACTION;

BEGIN TRY
    INSERT INTO sec (c#, s#, term, pname)
    VALUES (101, 1, '1403-1', 'دکتر رضایی');

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT 'خطا: ' + ERROR_MESSAGE();
END CATCH;

-----لیست دانشجوها، درس‌های انتخابی و نام استاد هر درس
SELECT s.sname, c.cname, sec.term, p.pname
FROM stud s
JOIN sec ON s.S# = sec.s#
JOIN crs c ON sec.c# = c.c#
JOIN prof p ON sec.pname = p.pname;

----فهرست تمام دانشجویانی که یا معدل آن‌ها بالاتر یا مساوی 17 است یا حداقل یک درس با بیش از 3 واحد انتخاب کرده‌اند را همراه با نام درس و ترم نمایش دهید.
SELECT 
    s.S# AS StudentID,
    s.sname AS StudentName,
    c.cname AS CourseName,
    sec.term AS Term
FROM 
    stud s
    INNER JOIN sec ON s.S# = sec.s#
    INNER JOIN crs c ON sec.c# = c.c#
WHERE 
    s.avg >= 17

UNION

SELECT 
    s.S# AS StudentID,
    s.sname AS StudentName,
    c.cname AS CourseName,
    sec.term AS Term
FROM 
    stud s
    INNER JOIN sec ON s.S# = sec.s#
    INNER JOIN crs c ON sec.c# = c.c#
WHERE 
    c.unit >= 3;
	
	
	----بازگرداندن دانشجوها و دروسی که یا معدل دانشجو ≥ 17 است یا واحد درس ≥ 3."

EXEC GetHighAvgOrBigUnitCourses;


-- ایجاد یک Table-Valued Function برای گرفتن لیست درس‌های یک دانشجو
CREATE FUNCTION dbo.GetStudentCourses(@StudentID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        c.cname AS CourseName,
        c.unit AS Units,
        sec.term AS Term,
        p.pname AS ProfessorName
    FROM sec
    JOIN crs c ON sec.c# = c.c#
    JOIN prof p ON sec.pname = p.pname
    WHERE sec.s# = @StudentID
);

SELECT * 
FROM dbo.GetStudentCourses(1);



