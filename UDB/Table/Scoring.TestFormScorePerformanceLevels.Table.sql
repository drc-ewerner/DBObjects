USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormScorePerformanceLevels]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormScorePerformanceLevels](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[PerformanceLevel] [varchar](20) NOT NULL,
	[ScaleScoreLow] [decimal](18, 5) NOT NULL,
	[ScaleScoreHigh] [decimal](18, 5) NOT NULL,
	[Grade] [varchar](2) NOT NULL,
 CONSTRAINT [pk_TestFormScorePerformanceLevels] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[Score] ASC,
	[PerformanceLevel] ASC,
	[Grade] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormScorePerformanceLevels] ADD  DEFAULT ('') FOR [Grade]
GO
ALTER TABLE [Scoring].[TestFormScorePerformanceLevels]  WITH CHECK ADD  CONSTRAINT [fk_TestFormScorePerformanceLevels_TestFormScores] FOREIGN KEY([AdministrationID], [Test], [Level], [Form], [Score])
REFERENCES [Scoring].[TestFormScores] ([AdministrationID], [Test], [Level], [Form], [Score])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormScorePerformanceLevels] CHECK CONSTRAINT [fk_TestFormScorePerformanceLevels_TestFormScores]
GO
