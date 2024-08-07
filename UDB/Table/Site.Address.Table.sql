USE [Alaska_udb_dev]
GO
/****** Object:  Table [Site].[Address]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Site].[Address](
	[AdministrationID] [int] NOT NULL,
	[ShipmentShortName] [varchar](25) NOT NULL,
	[SiteID] [uniqueidentifier] NOT NULL,
	[ShipID] [uniqueidentifier] NOT NULL,
	[ShipmentStatus] [varchar](25) NULL,
	[ShipmentStatusID] [uniqueidentifier] NULL,
	[ShipmentLongName] [varchar](50) NULL,
	[UsingOpsMMSFlag] [bit] NOT NULL,
	[ShipmentLockedFlag] [bit] NOT NULL,
	[DueDate] [datetime] NULL,
	[PackDate] [datetime] NULL,
	[OpsMMSExportDate] [datetime] NULL,
	[ContactTypeID] [uniqueidentifier] NULL,
	[ContactType] [varchar](35) NULL,
	[AddressTypeID] [uniqueidentifier] NULL,
	[AddressType] [varchar](35) NULL,
	[SiteContactAddressID] [uniqueidentifier] NULL,
	[ContactAddressStatus] [varchar](25) NULL,
	[ContactAddressStatusID] [uniqueidentifier] NULL,
	[ContactID] [uniqueidentifier] NULL,
	[Prefix] [varchar](8) NULL,
	[FirstName] [varchar](15) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[LastName] [varchar](20) NULL,
	[Suffix] [varchar](5) NULL,
	[JobTitle] [varchar](50) NULL,
	[Phone] [varchar](20) NULL,
	[Extension] [varchar](10) NULL,
	[Fax] [varchar](20) NULL,
	[Email] [varchar](50) NULL,
	[AddressID] [uniqueidentifier] NULL,
	[Line1] [varchar](35) NULL,
	[Line2] [varchar](35) NULL,
	[Line3] [varchar](35) NULL,
	[City] [varchar](30) NULL,
	[StateAbbr] [varchar](5) NULL,
	[Zipcode] [varchar](5) NULL,
	[ZipcodeExt] [varchar](4) NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_Address] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[ShipmentShortName] ASC,
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Site].[Address] ADD  DEFAULT ((0)) FOR [UsingOpsMMSFlag]
GO
ALTER TABLE [Site].[Address] ADD  DEFAULT ((0)) FOR [ShipmentLockedFlag]
GO
ALTER TABLE [Site].[Address] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Site].[Address] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
