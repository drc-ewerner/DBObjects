USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[ItemScoringRules]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[ItemScoringRules](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[ScoringRulesXml] [xml] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [pk_ItemScoringRules] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Scoring].[ItemScoringRules]  WITH CHECK ADD  CONSTRAINT [fk_ItemScoringRules_Items] FOREIGN KEY([AdministrationID], [Test], [ItemID])
REFERENCES [Scoring].[Items] ([AdministrationID], [Test], [ItemID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[ItemScoringRules] CHECK CONSTRAINT [fk_ItemScoringRules_Items]
GO
