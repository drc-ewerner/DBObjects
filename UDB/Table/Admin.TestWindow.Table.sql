USE [Alaska_udb_dev]
GO
/****** Object:  Table [Admin].[TestWindow]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Admin].[TestWindow](
	[AdministrationID] [int] NOT NULL,
	[TestWindow] [varchar](20) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Description] [varchar](100) NULL,
	[AllowSessionDateEdits] [tinyint] NOT NULL,
	[IsDefault] [tinyint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestWindow] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Admin].[TestWindow] ADD  DEFAULT ((0)) FOR [AllowSessionDateEdits]
GO
ALTER TABLE [Admin].[TestWindow] ADD  DEFAULT ((0)) FOR [IsDefault]
GO
