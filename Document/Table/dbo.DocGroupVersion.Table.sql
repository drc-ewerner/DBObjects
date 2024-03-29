USE [Alaska_documents_dev]
GO
/****** Object:  Table [dbo].[DocGroupVersion]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocGroupVersion](
	[DocGroupVerID] [bigint] IDENTITY(1,1) NOT NULL,
	[DocGroupID] [int] NOT NULL,
	[Version] [smallint] NOT NULL,
 CONSTRAINT [PK_DocGroupVersion] PRIMARY KEY CLUSTERED 
(
	[DocGroupVerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocGroupVersion]  WITH CHECK ADD  CONSTRAINT [FK_DocGroupVersion_DocGroup] FOREIGN KEY([DocGroupID])
REFERENCES [dbo].[DocGroup] ([DocGroupID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DocGroupVersion] CHECK CONSTRAINT [FK_DocGroupVersion_DocGroup]
GO
