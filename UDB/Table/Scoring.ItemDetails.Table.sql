USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[ItemDetails]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[ItemDetails](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[DetailID] [varchar](20) NOT NULL,
	[DetailPosition] [int] NOT NULL,
	[CorrectResponse] [varchar](10) NULL,
	[MaxScore] [decimal](10, 5) NULL,
	[ScoreRule] [varchar](50) NULL,
	[DetailType] [varchar](50) NULL,
	[ItemDifficulty] [varchar](20) NULL,
 CONSTRAINT [pk_ItemDetails] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[ItemID] ASC,
	[DetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[ItemDetails]  WITH CHECK ADD  CONSTRAINT [fk_ItemDetails_Items] FOREIGN KEY([AdministrationID], [Test], [ItemID])
REFERENCES [Scoring].[Items] ([AdministrationID], [Test], [ItemID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[ItemDetails] CHECK CONSTRAINT [fk_ItemDetails_Items]
GO
