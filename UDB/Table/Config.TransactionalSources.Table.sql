USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[TransactionalSources]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[TransactionalSources](
	[AdministrationID] [int] NOT NULL,
	[InputID] [int] NOT NULL,
	[Source] [varchar](20) NOT NULL,
	[Status] [varchar](30) NOT NULL,
 CONSTRAINT [pk_TransactionalSources] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[InputID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_TransactionalSources] UNIQUE NONCLUSTERED 
(
	[AdministrationID] ASC,
	[Source] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Config].[TransactionalSources] ADD  DEFAULT ('Active') FOR [Status]
GO
ALTER TABLE [Config].[TransactionalSources]  WITH CHECK ADD  CONSTRAINT [ck_TransactionalSources_InputID] CHECK  (([InputID]<(0)))
GO
ALTER TABLE [Config].[TransactionalSources] CHECK CONSTRAINT [ck_TransactionalSources_InputID]
GO
