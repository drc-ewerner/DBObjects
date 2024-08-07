USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestEvent].[ItemReaderScores]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestEvent].[ItemReaderScores](
	[AdministrationID] [int] NOT NULL,
	[TestEventID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[DetailID] [varchar](20) NOT NULL,
	[ReaderID] [varchar](10) NOT NULL,
	[ReaderSequence] [int] NULL,
	[Score] [decimal](10, 5) NULL,
	[NonScoreCode] [varchar](3) NULL,
	[Alerts] [varchar](10) NULL,
	[RescoreFlag] [int] NOT NULL,
	[ExtractDate] [datetime] NULL,
	[ScoreContributer] [tinyint] NULL,
	[Status] [varchar](50) NULL,
	[DeliverySequence] [int] NULL,
 CONSTRAINT [pk_ItemReaderScores] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestEventID] ASC,
	[Test] ASC,
	[ItemID] ASC,
	[DetailID] ASC,
	[ReaderID] ASC,
	[RescoreFlag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [TestEvent].[ItemReaderScores] ADD  DEFAULT ((0)) FOR [RescoreFlag]
GO
ALTER TABLE [TestEvent].[ItemReaderScores]  WITH CHECK ADD  CONSTRAINT [fk_ItemReaderScores_Core_TestEvent] FOREIGN KEY([AdministrationID], [TestEventID], [Test])
REFERENCES [Core].[TestEvent] ([AdministrationID], [TestEventID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestEvent].[ItemReaderScores] CHECK CONSTRAINT [fk_ItemReaderScores_Core_TestEvent]
GO
ALTER TABLE [TestEvent].[ItemReaderScores]  WITH CHECK ADD  CONSTRAINT [fk_ItemReaderScores_Scoring_ItemDetails] FOREIGN KEY([AdministrationID], [Test], [ItemID], [DetailID])
REFERENCES [Scoring].[ItemDetails] ([AdministrationID], [Test], [ItemID], [DetailID])
GO
ALTER TABLE [TestEvent].[ItemReaderScores] CHECK CONSTRAINT [fk_ItemReaderScores_Scoring_ItemDetails]
GO
ALTER TABLE [TestEvent].[ItemReaderScores]  WITH CHECK ADD  CONSTRAINT [ck_ItemReaderScores_ScoreContributer] CHECK  (([ScoreContributer]=(1) OR [ScoreContributer]=(0)))
GO
ALTER TABLE [TestEvent].[ItemReaderScores] CHECK CONSTRAINT [ck_ItemReaderScores_ScoreContributer]
GO
ALTER TABLE [TestEvent].[ItemReaderScores]  WITH CHECK ADD  CONSTRAINT [ck_ItemReaderScores_Status] CHECK  (([Status]='Exceeds Max Score' OR [Status]='NonScoreCode Mismatch' OR [Status]='Insufficient Readers' OR [Status]='Readers Exceed Maximum' OR [Status]='No Adjacent Scores' OR [Status]='Reader Not Required' OR [Status]='OK'))
GO
ALTER TABLE [TestEvent].[ItemReaderScores] CHECK CONSTRAINT [ck_ItemReaderScores_Status]
GO
