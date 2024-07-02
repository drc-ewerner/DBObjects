USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[DRC_SchemaVersion]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[DRC_SchemaVersion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ScriptName] [nvarchar](500) NULL,
	[RunDate] [datetime] NULL
) ON [PRIMARY]
GO
