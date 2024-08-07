USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[AssessmentSchedule]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[AssessmentSchedule](
	[AdministrationID] [int] NOT NULL,
	[AssessmentScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[TestingScheduleID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Mode] [varchar](50) NOT NULL,
	[BeginDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[CanReactivateTicket] [bit] NOT NULL,
	[IsSessionReadOnly] [bit] NOT NULL,
 CONSTRAINT [pk_AssessmentSchedule] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[AssessmentScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
