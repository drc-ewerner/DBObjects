USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[TestSessionSchedule]    Script Date: 11/21/2023 8:51:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[TestSessionSchedule](
	[AdministrationID] [int] NOT NULL,
	[TestSessionID] [int] NOT NULL,
	[TestingScheduleID] [int] NOT NULL,
	[AssignmentLevel] [varchar](10) NOT NULL,
 CONSTRAINT [pk_TestSessionSchedule] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestSessionID] ASC,
	[TestingScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
