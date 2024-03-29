USE [Alaska_documents_dev]
GO
/****** Object:  Table [dbo].[Doc]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Doc](
	[DocID] [uniqueidentifier] NOT NULL,
	[OriginalFileName] [varchar](200) NOT NULL,
	[FilePath] [varchar](1200) NOT NULL,
	[LinkText] [varchar](100) NOT NULL,
	[DistrictCode] [varchar](15) NULL,
	[SchoolCode] [varchar](15) NULL,
	[OptionKey] [varchar](35) NULL,
	[VersionKey] [uniqueidentifier] NOT NULL,
	[CreatedDate] [datetime] NULL,
 CONSTRAINT [PK_Doc] PRIMARY KEY CLUSTERED 
(
	[DocID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Doc] ADD  CONSTRAINT [DF_Doc_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
