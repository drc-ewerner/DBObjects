USE [Alaska_udb_dev]
GO
/****** Object:  Table [Site].[Attributes]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Site].[Attributes](
	[AdministrationID] [int] NOT NULL,
	[SiteID] [uniqueidentifier] NOT NULL,
	[AttributeName] [varchar](25) NOT NULL,
	[AttributeValue] [varchar](255) NOT NULL,
	[AttributeType] [varchar](35) NOT NULL,
	[AttributeTypeID] [uniqueidentifier] NOT NULL,
	[DataType] [varchar](35) NOT NULL,
	[DataTypeID] [uniqueidentifier] NOT NULL,
	[AttributeValueID] [uniqueidentifier] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_Attributes] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[SiteID] ASC,
	[AttributeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Site].[Attributes] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Site].[Attributes] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
