USE [Alaska_udb_dev]
GO
/****** Object:  Table [Core].[StudentGroup]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[StudentGroup](
	[AdministrationID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[GroupType] [varchar](50) NOT NULL,
	[GroupName] [varchar](200) NOT NULL,
	[DistrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_StudentGroup] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Core].[StudentGroup] ADD  DEFAULT (NEXT VALUE FOR [Core].[StudentGroup_SeqEven]) FOR [GroupID]
GO
ALTER TABLE [Core].[StudentGroup] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Core].[StudentGroup] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
