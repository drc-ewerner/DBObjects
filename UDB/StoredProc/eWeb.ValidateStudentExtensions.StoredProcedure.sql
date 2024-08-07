USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ValidateStudentExtensions]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










--use Alaska_udb_dev;		--dev3
--use Alaska_udb_sqa;		--dev3
--use Alaska_udb_staging;	--dev3
--use Alaska_udb_prod;		--247


/* Sample XML input:
 <?xml version="1.0" encoding="utf-8"?>
 <ArrayOfStudentExtension xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <StudentExtension>
       <Category>Demographic</Category>
       <Name>Largeprint</Name>
       <Value>C</Value>
    </StudentExtension>
 </ArrayOfStudentExtension>
 */
CREATE PROCEDURE [eWeb].[ValidateStudentExtensions] 
       @AdministrationID	  int
      ,@StudentId			  int
	  ,@StudentExtensionsXml XML 
AS
DECLARE @ErrMsgs TABLE (ErrorMessage VARCHAR(255))

DECLARE @xmltable table (
		Category varchar(50),
		Name varchar(50),
		Value varchar(100)
		);


INSERT @xmltable
SELECT x.value('(Category)[1]','varchar(50)'),x.value('(Name)[1]','varchar(50)'),x.value('(Value)[1]','varchar(100)')
FROM @StudentExtensionsXml.nodes('//StagingStudentExtension') x(x)

--INSERT into State.ValidateStudentExtensions select StudentID = @studentID, *  from @xmltable
--drop table State.ValidateStudentExtensions
--select StudentID = @studentID, * into State.ValidateStudentExtensions from @xmltable


/*---------------StudentDATA------------  */

/*  Invalid Characters in Suffix  */
INSERT INTO @ErrMsgs
select 'Demographics: Invalid Characters in Suffix.'
	FROM @xmltable 
where Name = 'SUFFIX'
    AND (PATINDEX('%[^A-Z a-z,0-9,'',_,.]%',rtrim(replace(replace(Value,'-',''),'''','')) COLLATE Latin1_General_BIN) > 0)
;

/*  No commas allowed in Suffix  */
INSERT INTO @ErrMsgs
select 'Demographics: Suffix cannot contain commas.'
	FROM @xmltable 
where Name = 'SUFFIX'
    AND value like '%,%'
;

/*  Suffix max length of 5 Characters */
INSERT INTO @ErrMsgs
select 'Demographics: Suffix Max Length is 5 Characters.'
	FROM @xmltable 
where Name = 'SUFFIX'
    AND LEN(value) > 5
;


/*	Invalid TestMode */ --Commented out 12/1/21 - TK
--WITH temp as (
--	Select Name = 'TESTMODE'
--)
--INSERT INTO @ErrMsgs
--  select 'Demographics: Invalid Mode of Administration (Valid: C/P).'
--	FROM temp t
--	LEFT OUTER JOIN @xmltable x on t.Name = x.Name
--	WHERE (x.Name = 'TESTMODE' AND ltrim(Value) not in ('C','P'))
--	  OR  (x.Name is null)
;
--3.  Disability Status dropdown must be valued.
--a.       Error Message: “Demographics: Invalid Disability Status (Valid: 0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)” 
WITH temp AS (	Select Name = 'DISABILITY'	)
INSERT INTO @ErrMsgs
select 'Demographics: Invalid Disability Status (Valid: 0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)' --Removed 15 & 16 - 12/7/23 - TK
FROM temp t
Left Join @xmltable x ON x.Name = t.name
where (x.Name = 'DISABILITY' AND value not in ('0','2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14')	) --Removed 15 & 16 - 12/7/23 - TK
	OR x.Name IS null
;
--4. English Learner Status dropdown must be valued.
--a.       Error Message: “Demographics: Invalid English Learner Status (Valid: L1, LP, M1, M2, M3, X)”  
WITH temp AS (	Select Name = 'ENGLISHLEARNER'	)
INSERT INTO @ErrMsgs
select 'Demographics: Invalid English Learner Status (Valid: L1, LP, M1, M2, M3, M4, X)'
FROM temp t
Left Join @xmltable x ON x.Name = t.name
where (x.Name = 'ENGLISHLEARNER' AND value not in ('L1', 'LP', 'M1', 'M2', 'M3', 'M4', 'X')	)
	OR x.Name IS null
;
--5. Economically Disadvantaged Status dropdown must be valued.
--a.       Error Message: “Demographics: Invalid Economically Disadvantaged Status (Valid: Y, N)”  
WITH temp AS (	Select Name = 'ECONOMIC'	)
INSERT INTO @ErrMsgs
select 'Demographics: Invalid Economically Disadvantaged Status (Valid: Y, N)'
FROM temp t
Left Join @xmltable x ON x.Name = t.name
where (x.Name = 'ECONOMIC' AND value not in ('Y', 'N','Yes','No')	)
	OR x.Name IS null
;
--6.  Migrant Status dropdown must be valued.
--a.       Error Message: “Demographics: Invalid Migrant Status (Valid: Y, N)”  
WITH temp AS (	Select Name = 'MIGRANT'	)
INSERT INTO @ErrMsgs
select 'Demographics: Invalid Migrant Status (Valid: Y, N)'
FROM temp t
Left Join @xmltable x ON x.Name = t.name
where (x.Name = 'MIGRANT' AND value not in ('Y', 'N','Yes','No')	)
	OR x.Name IS null
;
--7. Parent/Guardian on Active Duty Military Status dropdown must be valued.
--a.       Error Message: “Demographics: Invalid Parent/Guardian on Active Duty Military Status (Valid: Y, N)” 
WITH temp AS (	Select Name = 'MILITARY'	)
INSERT INTO @ErrMsgs
select 'Demographics: Invalid Parent/Guardian on Active Duty Military Status (Valid: Y, N)'
FROM temp t
Left Join @xmltable x ON x.Name = t.name
where (x.Name = 'MILITARY' AND value not in ('Y', 'N','Yes','No')	)
	OR x.Name IS null
;



/**NOTES**/
/**
We found a GAP in eDirect Add Student.
•	When a user clicks the SAVE button when adding a student, eDirect does some inspecting of data on the main add student tab.  Things like allowable characters and required fields. - ok
•	It doesn’t inspect the data in the other tabs.  This has recently been push to EIS to code a stored procedure that used to belong to eDirect called eweb.ValidateStudentExtensions.
•	This stored procedure is passed the AdministrationID, StudentID and Student.Extension XML that contains the Category, Name and Value for each Student.Extension record that the user filled in.
•	This works fine for Student.Extention Name/Value pairs that we are just making sure have valid values.
•	BUT, the Alaska Science category name/value pairs should only be allowed to be selected on the accommodations page if the student is in grades 04, 08 or 10.  
o	At the time this stored procedure is executing the student has NOT been saved to Core.Student yet AND the student data being inserted is NOT passed to the stored procedure so it has no way of knowing what grade the student being added is in.
o	So a join to Core.Student on StudentID (which is currently 0 because it hasn’t been assigned one yet) doesn’t joint to a student and thus passes inspection even if the student is in Grade 07.
•	I spoke with Joanne Snegosky about passing in the Student Grade, but it would be a change to the stored procedure for ALL PROJECTS.  If the change was made and all of the stored procedures were not re-deployed to accept this new Grade field, ALL PROJECTS not re-deployed would start failing on every call to this stored procedure.  NOT A GOOD IDEA!  
•	So for example, when a student in grade 07 is initially saved, it passes the inspection for the science accommodations even though they are in grade 07.  But if they ever go back to that student and try to save them, they WILL get the inspection error because now the Core.Student record DOES exist and can be referred to by the stored procedure.

**/
--		eDirect will now be able to check these
--/*  Invalid Science TTS  */
--INSERT INTO @ErrMsgs
--select  'Accommodation Science Text-To-Speech: Invalid Science Grade/Value Combination.'
--	FROM @xmlTable x
--where x.Name = 'Online.Audio' and x.Category = 'Science'
--	and ((select grade from core.student where administrationid = @administrationid and studentid = @studentid)
--		in ('03','05','06','07','09') and x.Value ='Y')

--/*  Invalid Science Large Print  */
--INSERT INTO @ErrMsgs
--select 'Accommodation Science Large Print: Invalid Science Grade/Value Combination.'
--	FROM @xmltable x
--where x.Name = 'Online.LargePrint' and x.Category = 'Science'
--	and ((select grade from core.student where administrationid = @administrationid and studentid = @studentid)
--		in ('03','05','06','07','09') and x.Value ='Y')

--/*  Invalid Science Non-embedded Accommodation  */
--INSERT INTO @ErrMsgs
--select 'Accommodation Science Non-embedded Accommodation: Invalid Science Grade/Value Combination.'
--	FROM @xmltable x
--where x.Name = 'Online.Other' and x.Category = 'Science'
--	and ((select grade from core.student where administrationid = @administrationid and studentid = @studentid)
--		in ('03','05','06','07','09') and x.Value ='Y')

--/*  Invalid Science Audio CD  */
--INSERT INTO @ErrMsgs
--select 'Accommodation Science Audio CD: Invalid Science Grade/Value Combination.'
--	FROM @xmltable x
--where x.Name = 'Paper.AudioCD' and x.Category = 'Science'
--	and ((select grade from core.student where administrationid = @administrationid and studentid = @studentid)
--		in ('03','05','06','07','09') and x.Value ='Y')

--/*  Invalid Science Paper Large Print  */
--INSERT INTO @ErrMsgs
--select 'Accommodation Science Paper Large Print: Invalid Science Grade/Value Combination.'
--	FROM @xmltable x
--where x.Name = 'Paper.LargePrint' and x.Category = 'Science'
--	and ((select grade from core.student where administrationid = @administrationid and studentid = @studentid)
--		in ('03','05','06','07','09') and x.Value ='Y')

--/*  Invalid Science Paper Braille  */
--INSERT INTO @ErrMsgs
--select 'Accommodation Science Paper Braille: Invalid Science Grade/Value Combination.'
--	FROM @xmltable x
--where x.Name = 'Paper.Braille'and x.Category = 'Science'
--	and ((select grade from core.student where administrationid = @administrationid and studentid = @studentid)
--		in ('03','05','06','07','09') and x.Value ='Y')





/*  Now display it to eDirect  */
select ErrorMessage from @ErrMsgs






GO
