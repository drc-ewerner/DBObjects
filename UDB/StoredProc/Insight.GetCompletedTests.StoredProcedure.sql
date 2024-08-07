USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetCompletedTests]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Insight].[GetCompletedTests]
	@AdministrationID int, 
	@DistrictCode varchar(15), 
	@SchoolCode varchar(15), 
	@Grade varchar(2), 
	@FirstName nvarchar(100) = null,
	@LastName nvarchar(100) = null,  
	@StateStudentID varchar(30) = null, 
	@DistrictStudentID varchar(30) = null
as
select distinct d.AdministrationID, d.LastName, d.FirstName, d.StudentID, d.StateStudentID, d.DistrictStudentID, d.Grade
From Insight.OnlineTests a
cross apply (select * from Insight.OnlineTestResponses b where a.AdministrationID = b.AdministrationID) b
cross apply (select * from Core.Document c where c.AdministrationID = b.AdministrationID and c.DocumentID = a.DocumentID) c
cross apply (select * from Core.Student d where d.AdministrationID = c.AdministrationID and d.StudentID = c.StudentID) d
cross apply (select * from TestSession.Links k where k.AdministrationID = a.AdministrationID and k.DocumentID = a.DocumentID) k
cross apply (select * from Core.TestSession w where w.AdministrationID = a.AdministrationID and w.TestSessionID = k.TestSessionID) w
where a.administrationid = @AdministrationID
	and b.ExtendedResponse is not null
	and w.DistrictCode = @DistrictCode
	and w.SchoolCode = @SchoolCode
	and d.Grade = @Grade
	and (d.FirstName like @FirstName + '%' or @FirstName IS NULL)
	and (d.LastName like @LastName + '%' OR  @LastName IS NULL)
	and (d.StateStudentID = @StateStudentID OR @StateStudentID IS NULL)
	and (d.DistrictStudentID = @DistrictStudentID OR @DistrictStudentID IS NULL)
order by d.LastName, d.FirstName
GO
