USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[SessionLog]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[SessionLog](
	[AdminID] [int] NOT NULL,
	[TestSessionID] [int] NOT NULL,
	[Username] [nvarchar](256) NOT NULL,
	[Action] [varchar](200) NOT NULL,
	[ActionDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
