USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[Items]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[Items](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[ItemType] [varchar](10) NOT NULL,
	[ItemStatus] [varchar](10) NOT NULL,
	[LoadInfo] [varchar](1000) NULL,
	[OnlineData] [xml] NULL,
	[ItemQuestion] [varchar](max) NULL,
 CONSTRAINT [pk_Items] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
