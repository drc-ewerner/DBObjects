USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[UnprocessedOnlineTests]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[UnprocessedOnlineTests](
	[AdministrationID] [int] NOT NULL,
	[UnprocessedOnlineTestID] [int] IDENTITY(1,1) NOT NULL,
	[DocumentID] [int] NOT NULL,
	[Method] [varchar](20) NULL,
	[CreateDate] [datetime] NOT NULL,
	[UnprocessedReason] [varchar](50) NULL,
	[Section] [varchar](20) NULL,
 CONSTRAINT [pk_UnprocessedOnlineTests] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[UnprocessedOnlineTestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Insight].[UnprocessedOnlineTests] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
