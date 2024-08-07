USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestMapRanges]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestMapRanges](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Map] [varchar](50) NOT NULL,
	[RangeType] [varchar](50) NOT NULL,
	[Range] [varchar](50) NOT NULL,
	[MinScaleScore] [decimal](10, 5) NOT NULL,
	[MaxScaleScore] [decimal](10, 5) NOT NULL,
	[Label] [varchar](100) NOT NULL,
	[DisplayInfo] [varchar](100) NULL,
	[Content] [xml] NULL,
 CONSTRAINT [pk_TestMapRanges] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Map] ASC,
	[RangeType] ASC,
	[Range] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestMapRanges]  WITH CHECK ADD  CONSTRAINT [fk_TestMapRanges_TestMaps] FOREIGN KEY([AdministrationID], [Test], [Map])
REFERENCES [Scoring].[TestMaps] ([AdministrationID], [Test], [Map])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestMapRanges] CHECK CONSTRAINT [fk_TestMapRanges_TestMaps]
GO
