USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[AddTeacher]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [eWeb].[AddTeacher]
   @AdministrationID   int
   ,@DistrictCode varchar(15)
   ,@SchoolCode varchar(15)
   ,@FirstName nvarchar(100)
   ,@LastName nvarchar(100)
   ,@MiddleName nvarchar(100)
   ,@StateTeacherID varchar(50)
   ,@Email varchar(256)
   ,@Status varchar(20)
AS
BEGIN
	/* 08/30/2010 - Version 1.0 */
	/* 01/17/2013 - Version 2.0 -- Updated for UDB Split */

	declare @TeacherID int=next value for Core.Teacher_SeqEven;

	insert [Core].[Teacher]
           ([AdministrationID]
           ,[TeacherID]
           ,[StateTeacherID]
           ,[LastName]
           ,[FirstName]
           ,[MiddleName]
           ,[Email]
           ,[Status]
           ,[CreateDate]
           ,[UpdateDate])
     select
           @AdministrationID
           ,@TeacherID
           ,@StateTeacherID
           ,@LastName
           ,@FirstName
           ,@MiddleName
           ,@Email
           ,@Status
           ,getdate()
           ,getdate()

	insert [Teacher].[Sites]
           ([AdministrationID]
           ,[TeacherID]
           ,[DistrictCode]
           ,[SchoolCode])
     output inserted.TeacherID
     select
           @AdministrationID
           ,@TeacherID
           ,@DistrictCode
           ,@SchoolCode

END
GO
