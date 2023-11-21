USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[Applet]    Script Date: 11/21/2023 8:51:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[Applet](
	[AppletCode] [varchar](10) NOT NULL,
	[Descr] [varchar](100) NOT NULL,
	[MenuKey] [varchar](100) NULL,
 CONSTRAINT [pk_Applet] PRIMARY KEY CLUSTERED 
(
	[AppletCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
