USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [dbo].[usp_updatestats]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_updatestats]
with execute as 'dbo'
as
exec sp_updatestats
GO
