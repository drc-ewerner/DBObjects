USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestEvent].[ItemScores]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestEvent].[ItemScores](
	[AdministrationID] [int] NOT NULL,
	[TestEventID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[DetailID] [varchar](20) NOT NULL,
	[Response] [varchar](10) NULL,
	[Attempt] [tinyint] NULL,
	[Correct] [tinyint] NULL,
	[RawScore] [decimal](10, 5) NULL,
	[NonScoreCode] [varchar](3) NULL,
	[Density] [varchar](50) NULL,
	[ErasureCategory] [varchar](10) NULL,
	[RescoreFlag] [int] NOT NULL,
	[Position] [int] NULL,
	[UsedForScore] [varchar](50) NULL,
	[CorrectResponse] [varchar](10) NULL,
	[Difficulty] [decimal](10, 5) NULL,
	[ItemVersion] [datetime] NULL,
	[Status] [varchar](50) NULL,
 CONSTRAINT [pk_ItemScores] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestEventID] ASC,
	[Test] ASC,
	[ItemID] ASC,
	[DetailID] ASC,
	[RescoreFlag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [TestEvent].[ItemScores] ADD  DEFAULT ((0)) FOR [RescoreFlag]
GO
ALTER TABLE [TestEvent].[ItemScores]  WITH CHECK ADD  CONSTRAINT [fk_ItemScores_Core_TestEvent] FOREIGN KEY([AdministrationID], [TestEventID], [Test])
REFERENCES [Core].[TestEvent] ([AdministrationID], [TestEventID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestEvent].[ItemScores] CHECK CONSTRAINT [fk_ItemScores_Core_TestEvent]
GO
ALTER TABLE [TestEvent].[ItemScores]  WITH CHECK ADD  CONSTRAINT [fk_ItemScores_Scoring_ItemDetails] FOREIGN KEY([AdministrationID], [Test], [ItemID], [DetailID])
REFERENCES [Scoring].[ItemDetails] ([AdministrationID], [Test], [ItemID], [DetailID])
GO
ALTER TABLE [TestEvent].[ItemScores] CHECK CONSTRAINT [fk_ItemScores_Scoring_ItemDetails]
GO
ALTER TABLE [TestEvent].[ItemScores]  WITH CHECK ADD  CONSTRAINT [ck_ItemScores_Attempt] CHECK  (([Attempt]=(1) OR [Attempt]=(0)))
GO
ALTER TABLE [TestEvent].[ItemScores] CHECK CONSTRAINT [ck_ItemScores_Attempt]
GO
ALTER TABLE [TestEvent].[ItemScores]  WITH CHECK ADD  CONSTRAINT [ck_ItemScores_Correct] CHECK  (([Correct]=(1) OR [Correct]=(0)))
GO
ALTER TABLE [TestEvent].[ItemScores] CHECK CONSTRAINT [ck_ItemScores_Correct]
GO
