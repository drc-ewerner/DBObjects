USE [Alaska_documents_dev]
GO
/****** Object:  Table [dbo].[DocGroupRoles]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocGroupRoles](
	[DocGroupRoleID] [int] IDENTITY(1,1) NOT NULL,
	[DocGroupID] [int] NOT NULL,
	[Role] [nvarchar](50) NULL,
 CONSTRAINT [PK_DocGroupRoles] PRIMARY KEY CLUSTERED 
(
	[DocGroupRoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocGroupRoles]  WITH CHECK ADD  CONSTRAINT [FK_DocGroupRoles_DocGroup] FOREIGN KEY([DocGroupID])
REFERENCES [dbo].[DocGroup] ([DocGroupID])
GO
ALTER TABLE [dbo].[DocGroupRoles] CHECK CONSTRAINT [FK_DocGroupRoles_DocGroup]
GO
