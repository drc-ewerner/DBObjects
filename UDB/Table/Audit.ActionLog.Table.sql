USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[ActionLog]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ActionLog](
	[ActionLogID] [int] IDENTITY(1,1) NOT NULL,
	[AdministrationID] [int] NOT NULL,
	[UserName] [sysname] NOT NULL,
	[Host] [varchar](200) NOT NULL,
	[ActionType] [varchar](100) NOT NULL,
	[StartTime] [datetime] NOT NULL,
	[EndTime] [datetime] NULL,
	[ActionData] [xml] NULL,
	[Result] [xml] NULL,
PRIMARY KEY CLUSTERED 
(
	[ActionLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[ActionLog] ADD  DEFAULT (getdate()) FOR [StartTime]
GO
