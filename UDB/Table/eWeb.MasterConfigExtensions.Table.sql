USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[MasterConfigExtensions]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[MasterConfigExtensions](
	[ConfigId] [int] IDENTITY(1,1) NOT NULL,
	[FunctionalArea] [varchar](100) NULL,
	[Category] [varchar](50) NULL,
	[Name] [varchar](100) NULL,
	[Usage] [varchar](50) NULL,
	[Client] [varchar](100) NULL,
	[Level] [varchar](10) NULL,
	[ValueType] [varchar](50) NULL,
	[DefaultValue] [varchar](200) NULL,
	[Description] [varchar](1000) NULL,
 CONSTRAINT [pk_MasterConfigExtensions] PRIMARY KEY CLUSTERED 
(
	[ConfigId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
