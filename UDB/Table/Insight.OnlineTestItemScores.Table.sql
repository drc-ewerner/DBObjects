USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[OnlineTestItemScores]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[OnlineTestItemScores](
	[AdministrationID] [int] NOT NULL,
	[OnlineTestID] [int] NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[DetailID] [varchar](20) NOT NULL,
	[Attempt] [tinyint] NULL,
	[Correct] [tinyint] NULL,
	[RawScore] [decimal](10, 5) NULL,
	[NonScoreCode] [varchar](3) NULL,
	[UsedForScore] [varchar](50) NULL,
	[CorrectResponse] [varchar](10) NULL,
	[Difficulty] [decimal](10, 5) NULL,
 CONSTRAINT [pk_OnlineTestItemScores] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[OnlineTestID] ASC,
	[ItemID] ASC,
	[DetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Insight].[OnlineTestItemScores]  WITH CHECK ADD  CONSTRAINT [fk_OnlineTestItemScores_OnlineTests] FOREIGN KEY([AdministrationID], [OnlineTestID])
REFERENCES [Insight].[OnlineTests] ([AdministrationID], [OnlineTestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[OnlineTestItemScores] CHECK CONSTRAINT [fk_OnlineTestItemScores_OnlineTests]
GO
ALTER TABLE [Insight].[OnlineTestItemScores]  WITH CHECK ADD  CONSTRAINT [ck_OnlineTestItemScores_Attempt] CHECK  (([Attempt]=(1) OR [Attempt]=(0)))
GO
ALTER TABLE [Insight].[OnlineTestItemScores] CHECK CONSTRAINT [ck_OnlineTestItemScores_Attempt]
GO
ALTER TABLE [Insight].[OnlineTestItemScores]  WITH CHECK ADD  CONSTRAINT [ck_OnlineTestItemScores_Correct] CHECK  (([Correct]=(1) OR [Correct]=(0)))
GO
ALTER TABLE [Insight].[OnlineTestItemScores] CHECK CONSTRAINT [ck_OnlineTestItemScores_Correct]
GO
