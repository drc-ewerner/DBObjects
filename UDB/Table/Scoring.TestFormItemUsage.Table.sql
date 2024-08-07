USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormItemUsage]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormItemUsage](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[StandardSet] [varchar](100) NOT NULL,
	[UsageStandard] [varchar](100) NOT NULL,
	[StandardDescription] [varchar](max) NOT NULL,
	[SubUse] [varchar](20) NOT NULL,
	[Domain] [varchar](25) NOT NULL,
	[Goal1] [varchar](20) NOT NULL,
	[Goal2] [varchar](20) NOT NULL,
	[Goal3] [varchar](20) NOT NULL,
	[Goal4] [varchar](20) NOT NULL,
	[Goal5] [varchar](20) NOT NULL,
	[Weight] [int] NOT NULL,
	[SubPoints] [int] NOT NULL,
	[StandardRank] [int] NOT NULL,
	[ItemDetailsXML] [xml] NULL,
 CONSTRAINT [pk_TestFormItemUsage] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[ItemID] ASC,
	[StandardSet] ASC,
	[UsageStandard] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormItemUsage]  WITH CHECK ADD  CONSTRAINT [fk_TestFormItemUsage_TestFormItems] FOREIGN KEY([AdministrationID], [Test], [Level], [Form], [ItemID])
REFERENCES [Scoring].[TestFormItems] ([AdministrationID], [Test], [Level], [Form], [ItemID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormItemUsage] CHECK CONSTRAINT [fk_TestFormItemUsage_TestFormItems]
GO
