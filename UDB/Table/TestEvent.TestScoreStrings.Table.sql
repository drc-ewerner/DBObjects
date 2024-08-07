USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestEvent].[TestScoreStrings]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestEvent].[TestScoreStrings](
	[AdministrationID] [int] NOT NULL,
	[TestEventID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[Type] [varchar](20) NOT NULL,
	[ResponseString] [varchar](max) NULL,
	[RescoreFlag] [int] NOT NULL,
 CONSTRAINT [pk_TestScoreStrings] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestEventID] ASC,
	[Test] ASC,
	[Score] ASC,
	[Type] ASC,
	[RescoreFlag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [TestEvent].[TestScoreStrings] ADD  DEFAULT ((0)) FOR [RescoreFlag]
GO
ALTER TABLE [TestEvent].[TestScoreStrings]  WITH CHECK ADD  CONSTRAINT [fk_TestScoreStrings_Scoring_TestScores] FOREIGN KEY([AdministrationID], [Test], [Score])
REFERENCES [Scoring].[TestScores] ([AdministrationID], [Test], [Score])
GO
ALTER TABLE [TestEvent].[TestScoreStrings] CHECK CONSTRAINT [fk_TestScoreStrings_Scoring_TestScores]
GO
ALTER TABLE [TestEvent].[TestScoreStrings]  WITH CHECK ADD  CONSTRAINT [fk_TestScoreStrings_TestScores] FOREIGN KEY([AdministrationID], [TestEventID], [Test], [Score], [RescoreFlag])
REFERENCES [TestEvent].[TestScores] ([AdministrationID], [TestEventID], [Test], [Score], [RescoreFlag])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestEvent].[TestScoreStrings] CHECK CONSTRAINT [fk_TestScoreStrings_TestScores]
GO
