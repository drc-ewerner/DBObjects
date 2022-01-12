USE [Alaska_udb_dev]
GO
/****** Object:  Table [XRef].[CedsMap]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [XRef].[CedsMap](
	[Category] [varchar](50) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Value] [varchar](100) NOT NULL,
	[CedsGroup] [varchar](100) NOT NULL,
	[CedsValue] [varchar](100) NOT NULL,
 CONSTRAINT [PK_XRef_CedsMap] PRIMARY KEY CLUSTERED 
(
	[Category] ASC,
	[Name] ASC,
	[Value] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
