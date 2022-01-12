USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[TestingSchedule]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[TestingSchedule](
	[AdministrationID] [int] NOT NULL,
	[TestingScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[BeginDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[IsEditable] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestingScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
