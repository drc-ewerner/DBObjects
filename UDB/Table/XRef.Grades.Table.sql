USE [Alaska_udb_dev]
GO
/****** Object:  Table [XRef].[Grades]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [XRef].[Grades](
	[AdministrationID] [int] NOT NULL,
	[Grade] [varchar](2) NOT NULL,
	[Description] [varchar](50) NOT NULL,
	[LongDescription] [varchar](100) NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[DisplayOrder] [int] NULL,
	[IsNotOnlineTesting] [varchar](10) NULL,
 CONSTRAINT [pk_Grades] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Grade] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [XRef].[Grades] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [XRef].[Grades] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
