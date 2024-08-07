USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[ItemUsage]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[ItemUsage](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[UsageStandard] [varchar](100) NOT NULL,
 CONSTRAINT [pk_ItemUsage] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[ItemID] ASC,
	[UsageStandard] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[ItemUsage]  WITH CHECK ADD  CONSTRAINT [fk_ItemUsage_Items] FOREIGN KEY([AdministrationID], [Test], [ItemID])
REFERENCES [Scoring].[Items] ([AdministrationID], [Test], [ItemID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[ItemUsage] CHECK CONSTRAINT [fk_ItemUsage_Items]
GO
