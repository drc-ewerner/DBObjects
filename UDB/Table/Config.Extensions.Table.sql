USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[Extensions]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[Extensions](
	[AdministrationID] [int] NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Name] [varchar](200) NOT NULL,
	[Value] [varchar](1500) NULL,
	[Usage] [varchar](200) NULL,
 CONSTRAINT [pk_Extensions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Category] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
