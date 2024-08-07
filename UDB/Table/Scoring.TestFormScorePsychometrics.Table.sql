USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormScorePsychometrics]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormScorePsychometrics](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[RawScore] [decimal](10, 5) NOT NULL,
	[ScaleScore] [decimal](10, 5) NULL,
	[PerformanceLevel] [varchar](20) NULL,
	[SEM] [decimal](10, 5) NULL,
	[SEM_LowerBound] [decimal](10, 5) NULL,
	[SEM_UpperBound] [decimal](10, 5) NULL,
	[Ability] [decimal](10, 5) NULL,
	[NumberOfQuestions] [int] NULL,
 CONSTRAINT [pk_TestFormScorePsychometrics] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[Score] ASC,
	[RawScore] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormScorePsychometrics] ADD  DEFAULT ((0)) FOR [RawScore]
GO
ALTER TABLE [Scoring].[TestFormScorePsychometrics]  WITH CHECK ADD  CONSTRAINT [fk_TestFormScorePsychometrics_TestFormScores] FOREIGN KEY([AdministrationID], [Test], [Level], [Form], [Score])
REFERENCES [Scoring].[TestFormScores] ([AdministrationID], [Test], [Level], [Form], [Score])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormScorePsychometrics] CHECK CONSTRAINT [fk_TestFormScorePsychometrics_TestFormScores]
GO
