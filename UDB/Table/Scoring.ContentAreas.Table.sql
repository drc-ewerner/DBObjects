USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[ContentAreas]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[ContentAreas](
	[AdministrationID] [int] NOT NULL,
	[ContentArea] [varchar](50) NOT NULL,
	[IsForAccommodations] [bit] NOT NULL,
	[IsForTestSessions] [bit] NOT NULL,
	[DisplayDescription] [varchar](50) NULL,
	[DisplayOrder] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[ContentArea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[ContentAreas] ADD  DEFAULT ((0)) FOR [IsForAccommodations]
GO
ALTER TABLE [Scoring].[ContentAreas] ADD  DEFAULT ((0)) FOR [IsForTestSessions]
GO
