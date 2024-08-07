USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormLog]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormLog](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[Action] [varchar](20) NOT NULL,
	[LogTime] [datetime] NOT NULL,
	[FormVersion] [datetime] NULL,
 CONSTRAINT [pk_TestFormLog] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[Action] ASC,
	[LogTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
