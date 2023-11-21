USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[DRC_SchemaVersion]    Script Date: 11/21/2023 8:39:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DRC_SchemaVersion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ScriptName] [nvarchar](500) NULL,
	[RunDate] [datetime] NULL
) ON [PRIMARY]
GO
