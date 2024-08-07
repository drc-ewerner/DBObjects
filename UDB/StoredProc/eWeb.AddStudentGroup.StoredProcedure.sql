USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[AddStudentGroup]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [eWeb].[AddStudentGroup]
	@AdministrationID int, 
	@GroupType varchar(50), 
	@GroupName varchar(200), 
    @TeacherID int, 
	@DistrictCode varchar(15), 
	@SchoolCode varchar(15)

as

/* 8/31/2010 - Version 1.0 */
/* 01/17/2013 - Version 2.0 -- Updated for UDB Split */

declare @GroupID int=next value for Core.StudentGroup_SeqEven;

insert Core.StudentGroup
	(AdministrationID, GroupID, GroupType, GroupName, DistrictCode, SchoolCode, CreateDate, UpdateDate)
select
	@AdministrationID, @GroupID, @GroupType, @GroupName, @DistrictCode, @SchoolCode, getdate(), getdate()


insert Teacher.StudentGroups (AdministrationID, TeacherID, GroupID, CreateDate, UpdateDate)
output inserted.GroupID
select @AdministrationID, @TeacherID, @GroupID, getdate(), getdate()
GO
