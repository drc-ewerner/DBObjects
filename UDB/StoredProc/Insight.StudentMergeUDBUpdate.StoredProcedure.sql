USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[StudentMergeUDBUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Insight].[StudentMergeUDBUpdate]
	@AdministrationID int,
	@StudentID int,
	@MergedStudentID int
as

declare @MergeDate Datetime
Set @MergeDate = GetDate();

Insert Into Student.ReassignedDocuments(AdministrationID, StudentID, DocumentID, Action, ReassignDate)
select D.AdministrationID, @StudentID, D.DocumentID,'Merged',getdate()
from core.Document D
Where NOT EXISTS (select * from Student.ReassignedDocuments R 
					where R.Administrationid =  D.Administrationid
					and R.DocumentID = D.DocumentID)
AND  D.AdministrationID = @AdministrationID
AND D.StudentID = @MergedStudentID; 

Update Core.Document
Set StudentID = @StudentID
where AdministrationID = @AdministrationID
And StudentID = @MergedStudentID;

Update Student.TestEventGroups
Set StudentID = @StudentID,
GroupID = GroupID + isnull((Select MAX(GroupID)
                     from Student.TestEventGroups x
                     where AdministrationID = @AdministrationID
                     and StudentID = @StudentID and x.GroupName=g.GroupName
                     ), 0)
from Student.TestEventGroups g
where AdministrationID = @AdministrationID
and StudentID = @MergedStudentID;

Update Student.ReassignedDocuments
Set StudentID = @StudentID
Where AdministrationID = @AdministrationID
and StudentID = @MergedStudentID;

Update Student.LinkedStudents
Set StudentID = @StudentID
where AdministrationID = @AdministrationID
and StudentID = @MergedStudentID;

Update Student.LinkedStudents
Set LinkStudentID = @StudentID
where LinkAdministrationID = @AdministrationID
and LinkStudentID = @MergedStudentID;

Update Student.LinkedStudentsLog
Set StudentID = @StudentID
where AdministrationID = @AdministrationID
and StudentID = @MergedStudentID;

Update Student.LinkedStudentsLog
Set LinkStudentID = @StudentID
where LinkAdministrationID = @AdministrationID
and LinkStudentID = @MergedStudentID;

Update Student.Attributions
Set StudentID = @StudentID
where AdministrationID = @AdministrationID
And StudentID = @MergedStudentID;

Update StudentGroup.Links
Set StudentID = @StudentID
from StudentGroup.Links
where AdministrationID = @AdministrationID
and StudentID = @MergedStudentID
and GroupID not in (Select GroupID from StudentGroup.Links where AdministrationID = @AdministrationID and StudentID = @StudentID);

Delete from StudentGroup.Links
where AdministrationID = @AdministrationID
and StudentID = @MergedStudentID;

-- This Delete will cascade delets on Student.Extensions, Student.CorrectionReasons, Student.CorrectionStatus, Student.InsightUserName
Delete from Core.Student
Where AdministrationID = @AdministrationID
and StudentID = @MergedStudentID;
GO
