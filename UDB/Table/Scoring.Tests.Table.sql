USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[Tests]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[Tests](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Description] [varchar](1000) NULL,
	[ContentArea] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
 CONSTRAINT [pk_Tests] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
