USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[XmlOptions]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[XmlOptions](
	[AdministrationID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [xml] NOT NULL,
 CONSTRAINT [pk_XmlOptions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
