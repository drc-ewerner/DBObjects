USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestEvent].[ItemReaderScores]    Script Date: 1/12/2022 1:28:44 PM ******/
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
PRIMARY KEY CLUSTERED 
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
ALTER TABLE [TestEvent].[ItemReaderScores]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [TestEventID], [Test])
REFERENCES [Core].[TestEvent] ([AdministrationID], [TestEventID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestEvent].[ItemReaderScores]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [ItemID], [DetailID])
REFERENCES [Scoring].[ItemDetails] ([AdministrationID], [Test], [ItemID], [DetailID])
GO
ALTER TABLE [TestEvent].[ItemReaderScores]  WITH CHECK ADD CHECK  (([ScoreContributer]=(1) OR [ScoreContributer]=(0)))
GO
ALTER TABLE [TestEvent].[ItemReaderScores]  WITH CHECK ADD CHECK  (([Status]='Exceeds Max Score' OR [Status]='NonScoreCode Mismatch' OR [Status]='Insufficient Readers' OR [Status]='Readers Exceed Maximum' OR [Status]='No Adjacent Scores' OR [Status]='Reader Not Required' OR [Status]='OK'))
GO
