USE [Alaska_udb_dev]
GO
/****** Object:  Table [Core].[TestSession]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[TestSession](
	[AdministrationID] [int] NOT NULL,
	[TestSessionID] [int] NOT NULL,
	[DistrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NOT NULL,
	[Name] [varchar](100) NULL,
	[Mode] [varchar](50) NOT NULL,
	[TestWindow] [varchar](20) NULL,
	[ScheduleSource] [varchar](20) NULL,
	[TeacherID] [int] NULL,
	[ClassCode] [varchar](15) NULL,
	[Form] [varchar](20) NULL,
	[UserID] [varchar](100) NULL,
	[ScoringOption] [varchar](50) NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[OptionalItems] [varchar](50) NULL,
	[TestMonitoring] [varchar](100) NULL,
	[TestAccessControl] [varchar](100) NULL,
	[RegistrationID] [varchar](100) NULL,
 CONSTRAINT [pk_TestSession] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestSessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Core].[TestSession] ADD  DEFAULT (NEXT VALUE FOR [Core].[TestSession_SeqEven]) FOR [TestSessionID]
GO
ALTER TABLE [Core].[TestSession] ADD  DEFAULT ('Online') FOR [Mode]
GO
ALTER TABLE [Core].[TestSession] ADD  DEFAULT ('') FOR [ScoringOption]
GO
ALTER TABLE [Core].[TestSession] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Core].[TestSession] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
ALTER TABLE [Core].[TestSession]  WITH CHECK ADD  CONSTRAINT [fk_TestSession_Admin_AssessmentSchedule] FOREIGN KEY([AdministrationID], [Test], [Level], [Mode], [TestWindow])
REFERENCES [Admin].[AssessmentSchedule] ([AdministrationID], [Test], [Level], [Mode], [TestWindow])
GO
ALTER TABLE [Core].[TestSession] CHECK CONSTRAINT [fk_TestSession_Admin_AssessmentSchedule]
GO
ALTER TABLE [Core].[TestSession]  WITH CHECK ADD  CONSTRAINT [fk_TestSession_Scoring_TestForms] FOREIGN KEY([AdministrationID], [Test], [Level], [Form])
REFERENCES [Scoring].[TestForms] ([AdministrationID], [Test], [Level], [Form])
GO
ALTER TABLE [Core].[TestSession] CHECK CONSTRAINT [fk_TestSession_Scoring_TestForms]
GO
ALTER TABLE [Core].[TestSession]  WITH CHECK ADD  CONSTRAINT [fk_TestSession_Scoring_TestLevels] FOREIGN KEY([AdministrationID], [Test], [Level])
REFERENCES [Scoring].[TestLevels] ([AdministrationID], [Test], [Level])
GO
ALTER TABLE [Core].[TestSession] CHECK CONSTRAINT [fk_TestSession_Scoring_TestLevels]
GO
ALTER TABLE [Core].[TestSession]  WITH CHECK ADD  CONSTRAINT [fk_TestSession_Teacher] FOREIGN KEY([AdministrationID], [TeacherID])
REFERENCES [Core].[Teacher] ([AdministrationID], [TeacherID])
GO
ALTER TABLE [Core].[TestSession] CHECK CONSTRAINT [fk_TestSession_Teacher]
GO
