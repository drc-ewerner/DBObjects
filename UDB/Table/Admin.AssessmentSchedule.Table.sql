USE [Alaska_udb_dev]
GO
/****** Object:  Table [Admin].[AssessmentSchedule]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Admin].[AssessmentSchedule](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Mode] [varchar](50) NOT NULL,
	[TestWindow] [varchar](20) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[AllowReactivates] [tinyint] NOT NULL,
	[AllowEdits] [tinyint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Mode] ASC,
	[TestWindow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Admin].[AssessmentSchedule] ADD  DEFAULT ((0)) FOR [AllowReactivates]
GO
ALTER TABLE [Admin].[AssessmentSchedule] ADD  DEFAULT ((0)) FOR [AllowEdits]
GO
ALTER TABLE [Admin].[AssessmentSchedule]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [Level])
REFERENCES [Scoring].[TestLevels] ([AdministrationID], [Test], [Level])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Admin].[AssessmentSchedule]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [TestWindow])
REFERENCES [Admin].[TestWindow] ([AdministrationID], [TestWindow])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
