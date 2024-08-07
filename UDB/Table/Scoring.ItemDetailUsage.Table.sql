USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[ItemDetailUsage]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[ItemDetailUsage](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[DetailID] [varchar](20) NOT NULL,
	[UsageStandard] [varchar](100) NOT NULL,
 CONSTRAINT [pk_ItemDetailUsage] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[ItemID] ASC,
	[DetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[ItemDetailUsage]  WITH CHECK ADD  CONSTRAINT [fk_ItemDetailUsage_ItemDetails] FOREIGN KEY([AdministrationID], [Test], [ItemID], [DetailID])
REFERENCES [Scoring].[ItemDetails] ([AdministrationID], [Test], [ItemID], [DetailID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[ItemDetailUsage] CHECK CONSTRAINT [fk_ItemDetailUsage_ItemDetails]
GO
ALTER TABLE [Scoring].[ItemDetailUsage]  WITH CHECK ADD  CONSTRAINT [fk_ItemDetailUsage_ItemUsage] FOREIGN KEY([AdministrationID], [Test], [ItemID], [UsageStandard])
REFERENCES [Scoring].[ItemUsage] ([AdministrationID], [Test], [ItemID], [UsageStandard])
GO
ALTER TABLE [Scoring].[ItemDetailUsage] CHECK CONSTRAINT [fk_ItemDetailUsage_ItemUsage]
GO
