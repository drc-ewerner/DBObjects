USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[ParticipantSync]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ParticipantSync](
	[participantId] [varchar](100) NOT NULL,
	[importTimestamp] [bigint] NOT NULL,
	[importDate]  AS ((dateadd(millisecond,[importTimestamp]%(1000),dateadd(second,[importTimestamp]/(1000),'1970-01-01T00:00:00.000Z')) AT TIME ZONE 'Central Standard Time')),
 CONSTRAINT [pk_ParticipantSynce] PRIMARY KEY CLUSTERED 
(
	[participantId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
