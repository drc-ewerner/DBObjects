USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[OnlineTestTestScores]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[OnlineTestTestScores](
	[AdministrationID] [int] NOT NULL,
	[OnlineTestID] [int] NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[RawScore] [decimal](10, 5) NULL,
	[ScaleScore] [decimal](10, 5) NULL,
	[PerformanceLevel] [varchar](20) NULL,
	[ItemsAttempted] [int] NULL,
	[AttemptedStatus] [tinyint] NULL,
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
 CONSTRAINT [pk_OnlineTestTestScores] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[OnlineTestID] ASC,
	[Score] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Insight].[OnlineTestTestScores]  WITH CHECK ADD  CONSTRAINT [fk_OnlineTestTestScores_OnlineTests] FOREIGN KEY([AdministrationID], [OnlineTestID])
REFERENCES [Insight].[OnlineTests] ([AdministrationID], [OnlineTestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[OnlineTestTestScores] CHECK CONSTRAINT [fk_OnlineTestTestScores_OnlineTests]
GO
ALTER TABLE [Insight].[OnlineTestTestScores]  WITH CHECK ADD  CONSTRAINT [ck_OnlineTestTestScores_AttemptedStatus] CHECK  (([AttemptedStatus]=(1) OR [AttemptedStatus]=(0)))
GO
ALTER TABLE [Insight].[OnlineTestTestScores] CHECK CONSTRAINT [ck_OnlineTestTestScores_AttemptedStatus]
GO
