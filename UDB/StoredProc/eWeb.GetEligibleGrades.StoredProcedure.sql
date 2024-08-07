USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetEligibleGrades]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [eWeb].[GetEligibleGrades]
	@adminID int,
	@test varchar(50),
	@level varchar(20)
	
as
begin
	select distinct XG.Grade from Xref.Grades XG
	inner join [Scoring].[TestLevelGrades] TLG on XG.Grade = TLG.Grade
	where TLG.AdministrationID = @adminID
	and TLG.[Test] = @test
	and TLG.[Level] = @level
	order by XG.grade asc
end
GO
