USE [Alaska_documents_dev]
GO
/****** Object:  Table [dbo].[DocGroup]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocGroup](
	[DocGroupID] [int] IDENTITY(1,1) NOT NULL,
	[DocTypeID] [int] NOT NULL,
	[AdministrationId] [int] NOT NULL,
	[FileTypeExt] [varchar](10) NOT NULL,
	[LowestAuthRole] [varchar](35) NULL,
	[Descr] [varchar](255) NULL,
	[ApproverRole] [varchar](35) NULL,
	[UserGroupId] [uniqueidentifier] NULL,
	[IsPublic] [bit] NOT NULL,
	[Title] [varchar](100) NULL,
	[StateRptsViewableByLowerRoles] [bit] NULL,
	[IsAutomatedPublishEnabled] [bit] NULL,
	[AudienceID] [int] NULL,
 CONSTRAINT [PK_DocGroup] PRIMARY KEY CLUSTERED 
(
	[DocGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocGroup] ADD  CONSTRAINT [DF_DocGroup_IsPublic]  DEFAULT ((0)) FOR [IsPublic]
GO
ALTER TABLE [dbo].[DocGroup] ADD  DEFAULT ((1)) FOR [StateRptsViewableByLowerRoles]
GO
ALTER TABLE [dbo].[DocGroup] ADD  DEFAULT ((0)) FOR [IsAutomatedPublishEnabled]
GO
ALTER TABLE [dbo].[DocGroup]  WITH CHECK ADD FOREIGN KEY([AudienceID])
REFERENCES [dbo].[Audience] ([AudienceID])
GO
ALTER TABLE [dbo].[DocGroup]  WITH CHECK ADD FOREIGN KEY([AudienceID])
REFERENCES [dbo].[Audience] ([AudienceID])
GO
ALTER TABLE [dbo].[DocGroup]  WITH CHECK ADD  CONSTRAINT [FK_DocGroup_DocType] FOREIGN KEY([DocTypeID])
REFERENCES [dbo].[DocType] ([DocTypeID])
GO
ALTER TABLE [dbo].[DocGroup] CHECK CONSTRAINT [FK_DocGroup_DocType]
GO
ALTER TABLE [dbo].[DocGroup]  WITH CHECK ADD  CONSTRAINT [FK_DocGroup_FileType] FOREIGN KEY([FileTypeExt])
REFERENCES [dbo].[FileType] ([FileTypeExt])
GO
ALTER TABLE [dbo].[DocGroup] CHECK CONSTRAINT [FK_DocGroup_FileType]
GO
