USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[ActionLog]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[ActionLog](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[ActionType] [varchar](100) NOT NULL,
	[ActionTime] [datetime] NOT NULL,
	[UserID] [uniqueidentifier] NULL,
	[UserName] [nvarchar](256) NULL,
	[ActionInfo] [xml] NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[ActionType] ASC,
	[ActionTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Document].[ActionLog] ADD  DEFAULT (getdate()) FOR [ActionTime]
GO
ALTER TABLE [Document].[ActionLog]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [DocumentID])
REFERENCES [Core].[Document] ([AdministrationID], [DocumentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
