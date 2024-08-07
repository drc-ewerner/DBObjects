USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestMapScores]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestMapScores](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Map] [varchar](50) NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[ScoreLabel] [varchar](100) NOT NULL,
	[DisplayOrder] [int] NOT NULL,
 CONSTRAINT [pk_TestMapScores] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Map] ASC,
	[Score] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestMapScores]  WITH CHECK ADD  CONSTRAINT [fk_TestMapScores_TestMaps] FOREIGN KEY([AdministrationID], [Test], [Map])
REFERENCES [Scoring].[TestMaps] ([AdministrationID], [Test], [Map])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestMapScores] CHECK CONSTRAINT [fk_TestMapScores_TestMaps]
GO
ALTER TABLE [Scoring].[TestMapScores]  WITH CHECK ADD  CONSTRAINT [fk_TestMapScores_TestScores] FOREIGN KEY([AdministrationID], [Test], [Score])
REFERENCES [Scoring].[TestScores] ([AdministrationID], [Test], [Score])
GO
ALTER TABLE [Scoring].[TestMapScores] CHECK CONSTRAINT [fk_TestMapScores_TestScores]
GO
