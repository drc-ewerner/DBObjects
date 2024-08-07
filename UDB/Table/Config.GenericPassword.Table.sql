USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[GenericPassword]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[GenericPassword](
	[AdministrationID] [int] NOT NULL,
	[Password] [varchar](20) NOT NULL,
	[EffectiveBeginDate] [datetime] NOT NULL,
	[EffectiveEndDate] [datetime] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_GenericPassword] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Password] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_GenericPassword] UNIQUE NONCLUSTERED 
(
	[AdministrationID] ASC,
	[EffectiveBeginDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_GenericPassword_2] UNIQUE NONCLUSTERED 
(
	[AdministrationID] ASC,
	[EffectiveEndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Config].[GenericPassword] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
