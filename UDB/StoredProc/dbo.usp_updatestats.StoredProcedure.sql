USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [dbo].[usp_updatestats]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_updatestats]
with execute as 'dbo'
as
exec sp_updatestats
GO
