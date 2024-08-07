USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[Migrations]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[Migrations](
	[AdministrationID] [int] NOT NULL,
	[Environment] [varchar](30) NOT NULL,
	[ToEnvironment] [varchar](30) NOT NULL,
 CONSTRAINT [pk_Migrations] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Environment] ASC,
	[ToEnvironment] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
