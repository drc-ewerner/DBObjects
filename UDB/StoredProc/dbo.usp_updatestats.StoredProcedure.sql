USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [dbo].[usp_updatestats]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_updatestats]
with execute as 'dbo'
as
exec sp_updatestats
GO
