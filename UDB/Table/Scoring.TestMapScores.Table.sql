USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestMapScores]    Script Date: 1/12/2022 1:28:44 PM ******/
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
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Map] ASC,
	[Score] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestMapScores]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [Score])
REFERENCES [Scoring].[TestScores] ([AdministrationID], [Test], [Score])
GO
ALTER TABLE [Scoring].[TestMapScores]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [Map])
REFERENCES [Scoring].[TestMaps] ([AdministrationID], [Test], [Map])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
