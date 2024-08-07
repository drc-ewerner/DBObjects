USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[Environments]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[Environments](
	[AdministrationID] [int] NOT NULL,
	[Environment] [varchar](30) NOT NULL,
	[RepositoryURL] [varchar](500) NULL,
	[FormDataURL] [varchar](500) NULL,
	[TestClientURL] [varchar](500) NULL,
 CONSTRAINT [pk_Environments] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Environment] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
