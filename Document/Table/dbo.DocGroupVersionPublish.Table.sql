USE [Alaska_documents_dev]
GO
/****** Object:  Table [dbo].[DocGroupVersionPublish]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocGroupVersionPublish](
	[DocGroupVerID] [bigint] NOT NULL,
	[EnvironmentCode] [varchar](20) NOT NULL,
	[ApprovedDate] [datetime] NULL,
	[ApprovedUser] [varchar](100) NULL,
	[PublishBeginDate] [datetime] NOT NULL,
	[PublishEndDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DocGroupVersionPublish] PRIMARY KEY CLUSTERED 
(
	[DocGroupVerID] ASC,
	[EnvironmentCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocGroupVersionPublish]  WITH CHECK ADD  CONSTRAINT [FK_DocGroupVersionPublish_DocGroupVersion] FOREIGN KEY([DocGroupVerID])
REFERENCES [dbo].[DocGroupVersion] ([DocGroupVerID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DocGroupVersionPublish] CHECK CONSTRAINT [FK_DocGroupVersionPublish_DocGroupVersion]
GO
