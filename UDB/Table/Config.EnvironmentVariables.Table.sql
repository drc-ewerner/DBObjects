USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[EnvironmentVariables]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[EnvironmentVariables](
	[AdministrationID] [int] NOT NULL,
	[Environment] [varchar](100) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](1000) NOT NULL,
 CONSTRAINT [pk_EnvironmentVariables] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Environment] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
