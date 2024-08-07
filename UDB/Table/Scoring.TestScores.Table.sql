USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestScores]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestScores](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[Description] [varchar](1000) NULL,
	[MinScaleScore] [decimal](10, 5) NULL,
	[MaxScaleScore] [decimal](10, 5) NULL,
 CONSTRAINT [pk_TestScores] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Score] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestScores]  WITH CHECK ADD  CONSTRAINT [fk_TestScores_Tests] FOREIGN KEY([AdministrationID], [Test])
REFERENCES [Scoring].[Tests] ([AdministrationID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestScores] CHECK CONSTRAINT [fk_TestScores_Tests]
GO
