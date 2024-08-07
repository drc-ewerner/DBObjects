USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[Teacher]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[Teacher](
	[TeacherId] [uniqueidentifier] NOT NULL,
	[FirstName] [varchar](30) NOT NULL,
	[MiddleInitial] [varchar](1) NULL,
	[LastName] [varchar](30) NOT NULL,
 CONSTRAINT [pk_Teacher] PRIMARY KEY CLUSTERED 
(
	[TeacherId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
