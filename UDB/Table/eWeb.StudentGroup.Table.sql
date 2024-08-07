USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[StudentGroup]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[StudentGroup](
	[StudentGroupID] [int] IDENTITY(1,1) NOT NULL,
	[AdministrationID] [int] NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[GroupName] [varchar](50) NOT NULL,
	[DistrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_StudentGroup] PRIMARY KEY CLUSTERED 
(
	[StudentGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
