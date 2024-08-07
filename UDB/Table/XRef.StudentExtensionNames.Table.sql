USE [Alaska_udb_dev]
GO
/****** Object:  Table [XRef].[StudentExtensionNames]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [XRef].[StudentExtensionNames](
	[AdministrationID] [int] NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[DisplayName] [varchar](300) NOT NULL,
	[GroupName] [varchar](100) NULL,
	[DisplayAbbreviation] [varchar](10) NULL,
	[DisplayOrder] [int] NULL,
	[ExclusivityGroup] [varchar](20) NULL,
	[TrueValue] [varchar](100) NULL,
	[FalseValue] [varchar](100) NULL,
	[ControlType] [varchar](100) NULL,
	[MaxLength] [int] NULL,
 CONSTRAINT [pk_StudentExtensionNames] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Category] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
