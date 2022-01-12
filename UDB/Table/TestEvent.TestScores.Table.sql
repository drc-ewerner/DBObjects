USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestEvent].[TestScores]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestEvent].[TestScores](
	[AdministrationID] [int] NOT NULL,
	[TestEventID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[RawScore] [decimal](10, 5) NULL,
	[ScaleScore] [decimal](10, 5) NULL,
	[PerformanceLevel] [varchar](20) NULL,
	[ItemsAttempted] [int] NULL,
	[AttemptedStatus] [tinyint] NULL,
	[RescoreFlag] [int] NOT NULL,
	[SEM] [decimal](10, 5) NULL,
	[SEMUpper] [decimal](10, 5) NULL,
	[SEMLower] [decimal](10, 5) NULL,
	[MaxRawScore] [decimal](10, 5) NULL,
	[MaxScaleScore] [decimal](10, 5) NULL,
	[MaxItemsAttempted] [int] NULL,
	[Ability] [decimal](10, 5) NULL,
	[ScaleFactor] [decimal](15, 10) NULL,
	[ScaleBase] [decimal](15, 10) NULL,
	[PercentCorrect]  AS (CONVERT([decimal](10,5),case isnull([MaxRawScore],(0)) when (0) then NULL else ((100.0)*[RawScore])/[MaxRawScore] end,(0))),
	[EAPAbility] [decimal](10, 5) NULL,
	[EAPSEM] [decimal](10, 5) NULL,
	[EAPSEMUpper] [decimal](10, 5) NULL,
	[EAPSEMLower] [decimal](10, 5) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestEventID] ASC,
	[Test] ASC,
	[Score] ASC,
	[RescoreFlag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [TestEvent].[TestScores] ADD  DEFAULT ((0)) FOR [RescoreFlag]
GO
ALTER TABLE [TestEvent].[TestScores]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [Score])
REFERENCES [Scoring].[TestScores] ([AdministrationID], [Test], [Score])
GO
ALTER TABLE [TestEvent].[TestScores]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [TestEventID], [Test])
REFERENCES [Core].[TestEvent] ([AdministrationID], [TestEventID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestEvent].[TestScores]  WITH CHECK ADD CHECK  (([AttemptedStatus]=(1) OR [AttemptedStatus]=(0)))
GO
ALTER TABLE [TestEvent].[TestScores]  WITH CHECK ADD CHECK  (([ScaleScore]<=[MaxScaleScore]))
GO
ALTER TABLE [TestEvent].[TestScores]  WITH CHECK ADD CHECK  (([RawScore]<=[MaxRawScore]))
GO
ALTER TABLE [TestEvent].[TestScores]  WITH CHECK ADD CHECK  (([ItemsAttempted]<=[MaxItemsAttempted]))
GO
