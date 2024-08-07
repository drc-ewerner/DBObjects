USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestEvent].[ItemScoreAccommodations]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestEvent].[ItemScoreAccommodations](
	[AdministrationID] [int] NOT NULL,
	[TestEventID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[DetailID] [varchar](20) NOT NULL,
	[Accommodation] [varchar](50) NOT NULL,
	[RawScore] [decimal](10, 5) NOT NULL,
	[AccommodationScore] [decimal](10, 5) NOT NULL,
	[RescoreFlag] [int] NOT NULL,
 CONSTRAINT [pk_ItemScoreAccommodations] PRIMARY KEY CLUSTERED 
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
ALTER TABLE [TestEvent].[ItemScoreAccommodations] ADD  DEFAULT ((0)) FOR [RescoreFlag]
GO
ALTER TABLE [TestEvent].[ItemScoreAccommodations]  WITH CHECK ADD  CONSTRAINT [fk_ItemScoreAccommodations_ItemScores] FOREIGN KEY([AdministrationID], [TestEventID], [Test], [ItemID], [DetailID], [RescoreFlag])
REFERENCES [TestEvent].[ItemScores] ([AdministrationID], [TestEventID], [Test], [ItemID], [DetailID], [RescoreFlag])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestEvent].[ItemScoreAccommodations] CHECK CONSTRAINT [fk_ItemScoreAccommodations_ItemScores]
GO
ALTER TABLE [TestEvent].[ItemScoreAccommodations]  WITH CHECK ADD  CONSTRAINT [fk_ItemScoreAccommodations_Scoring_ItemDetails] FOREIGN KEY([AdministrationID], [Test], [ItemID], [DetailID])
REFERENCES [Scoring].[ItemDetails] ([AdministrationID], [Test], [ItemID], [DetailID])
GO
ALTER TABLE [TestEvent].[ItemScoreAccommodations] CHECK CONSTRAINT [fk_ItemScoreAccommodations_Scoring_ItemDetails]
GO
