USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormItemStatistics]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormItemStatistics](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[UsageStandard] [varchar](100) NOT NULL,
	[ScoreLevel] [int] NOT NULL,
	[ScorePoints] [decimal](10, 5) NOT NULL,
	[CalculationMethod] [varchar](50) NOT NULL,
	[ParamA] [decimal](10, 5) NOT NULL,
	[ParamB] [decimal](10, 5) NOT NULL,
	[ParamC] [decimal](10, 5) NOT NULL,
 CONSTRAINT [pk_TestFormItemStatistics] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[ItemID] ASC,
	[UsageStandard] ASC,
	[ScoreLevel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormItemStatistics]  WITH CHECK ADD  CONSTRAINT [fk_TestFormItemStatistics_ItemUsage] FOREIGN KEY([AdministrationID], [Test], [ItemID], [UsageStandard])
REFERENCES [Scoring].[ItemUsage] ([AdministrationID], [Test], [ItemID], [UsageStandard])
GO
ALTER TABLE [Scoring].[TestFormItemStatistics] CHECK CONSTRAINT [fk_TestFormItemStatistics_ItemUsage]
GO
ALTER TABLE [Scoring].[TestFormItemStatistics]  WITH CHECK ADD  CONSTRAINT [fk_TestFormItemStatistics_TestFormItems] FOREIGN KEY([AdministrationID], [Test], [Level], [Form], [ItemID])
REFERENCES [Scoring].[TestFormItems] ([AdministrationID], [Test], [Level], [Form], [ItemID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormItemStatistics] CHECK CONSTRAINT [fk_TestFormItemStatistics_TestFormItems]
GO
