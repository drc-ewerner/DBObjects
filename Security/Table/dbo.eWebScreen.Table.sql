USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebScreen]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebScreen](
	[ScreenCode] [varchar](100) NOT NULL,
	[ScreenName] [varchar](100) NOT NULL,
	[PermissionID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](300) NULL,
	[IsInternalOnly] [bit] NOT NULL,
	[IsDeny] [bit] NULL,
 CONSTRAINT [PK_eWebPermission] PRIMARY KEY CLUSTERED 
(
	[PermissionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [Unique_eWebScreenCode] UNIQUE NONCLUSTERED 
(
	[ScreenCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eWebScreen] ADD  DEFAULT ((0)) FOR [IsInternalOnly]
GO
ALTER TABLE [dbo].[eWebScreen] ADD  DEFAULT ((0)) FOR [IsDeny]
GO
