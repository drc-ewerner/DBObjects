USE [Alaska_documents_dev]
GO
/****** Object:  Table [dbo].[DocBatch]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocBatch](
	[DocBatchID] [int] IDENTITY(1,1) NOT NULL,
	[DocGroupId] [int] NULL,
	[BatchName] [nvarchar](100) NOT NULL,
	[DocSourceID] [int] NOT NULL,
	[DocGroupVerID] [bigint] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DocBatch] PRIMARY KEY CLUSTERED 
(
	[DocBatchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocBatch]  WITH CHECK ADD  CONSTRAINT [FK_DocBatch_DocGroup] FOREIGN KEY([DocGroupId])
REFERENCES [dbo].[DocGroup] ([DocGroupID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DocBatch] CHECK CONSTRAINT [FK_DocBatch_DocGroup]
GO
ALTER TABLE [dbo].[DocBatch]  WITH CHECK ADD  CONSTRAINT [FK_DocBatch_DocSource] FOREIGN KEY([DocSourceID])
REFERENCES [dbo].[DocSource] ([DocSourceID])
GO
ALTER TABLE [dbo].[DocBatch] CHECK CONSTRAINT [FK_DocBatch_DocSource]
GO
