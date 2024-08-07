USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormItemVersions]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormItemVersions](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[FormVersion] [datetime] NOT NULL,
	[ItemVersion] [datetime] NOT NULL,
	[ItemStatus] [varchar](10) NULL,
 CONSTRAINT [pk_TestFormItemVersions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[ItemID] ASC,
	[FormVersion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormItemVersions]  WITH CHECK ADD  CONSTRAINT [fk_TestFormItemVersions_ItemVersions] FOREIGN KEY([AdministrationID], [Test], [ItemID], [ItemVersion])
REFERENCES [Scoring].[ItemVersions] ([AdministrationID], [Test], [ItemID], [ItemVersion])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormItemVersions] CHECK CONSTRAINT [fk_TestFormItemVersions_ItemVersions]
GO
ALTER TABLE [Scoring].[TestFormItemVersions]  WITH CHECK ADD  CONSTRAINT [fk_TestFormItemVersions_TestFormVersions] FOREIGN KEY([AdministrationID], [Test], [Level], [Form], [FormVersion])
REFERENCES [Scoring].[TestFormVersions] ([AdministrationID], [Test], [Level], [Form], [FormVersion])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormItemVersions] CHECK CONSTRAINT [fk_TestFormItemVersions_TestFormVersions]
GO
