USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateTeacher]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[UpdateTeacher]
    @AdministrationID INT, @TeacherID INT, @FirstName NVARCHAR (100), @LastName NVARCHAR (100), @StateTeacherID VARCHAR (50), @Email VARCHAR (256)
    AS
    BEGIN

        /* 08/31/2010 - Version 1.0 */
        update Core.Teacher 
        set FirstName=@FirstName,LastName=@LastName,Email=@Email,StateTeacherID=@StateTeacherID, UpdateDate = GetDate()
        from Core.Teacher 
        where AdministrationID=@AdministrationID and TeacherID=@TeacherID

    END
GO
