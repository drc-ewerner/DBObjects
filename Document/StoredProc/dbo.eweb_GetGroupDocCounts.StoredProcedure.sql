USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetGroupDocCounts]    Script Date: 1/12/2022 2:12:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create PROCEDURE [dbo].[eweb_GetGroupDocCounts]
@groupId INT, @envCode NVARCHAR (20)
AS
BEGIN
	SET NOCOUNT ON;

	WITH MaxApprovedVersion AS (
		SELECT	Max(dgv.Version) AS Version
		from	DocGroupVersion dgv
			INNER JOIN DocGroupVersionPublish dgvp ON dgv.DocGroupVerId = dgvp.DocGroupVerId
		where	dgvp.EnvironmentCode = @EnvCode	
		and		dgvp.ApprovedDate IS NOT NULL
		and		dgv.DocGroupId = @groupId
	), 
	NewUnApprovedVersion AS (
		SELECT	Max(dgv.Version) AS Version
		from	DocGroupVersion dgv
			INNER JOIN DocGroupVersionPublish dgvp ON dgv.DocGroupVerId = dgvp.DocGroupVerId
		where	dgvp.EnvironmentCode = @EnvCode	
		and		dgvp.ApprovedDate IS NULL
		and		dgv.DocGroupId = @groupId
		and		((select * from MaxApprovedVersion)IS NULL
		or		dgv.Version > (select Max(Version) from MaxApprovedVersion))
	), 
	DocApproved AS (
	select	d.VersionKey, d.DocId, dgv.Version, d.FilePath
	from	DocGroupVersion dgv
			INNER JOIN MaxApprovedVersion ver ON ver.Version = dgv.Version
			INNER JOIN DocGroupVersionDoc dgvd ON dgvd.DocGroupVerId = dgv.DocGroupVerId
			INNER JOIN Doc d ON dgvd.DocId = d.DocId
	where	dgv.DocGroupId = @groupId and dgvd.IsActive = 1
	), 
	DocNew AS (
	select	d.VersionKey, d.DocId, dgv.Version, d.FilePath
	from	DocGroupVersion dgv
			INNER JOIN NewUnApprovedVersion ver ON ver.Version = dgv.Version
			INNER JOIN DocGroupVersionDoc dgvd ON dgvd.DocGroupVerId = dgv.DocGroupVerId
			INNER JOIN Doc d ON dgvd.DocId = d.DocId
	where	dgv.DocGroupId = @groupId and dgvd.IsActive = 1
	),
	Updated AS (
	SELECT	Count(*) AS UpdatedCount
	FROM	DocNew 
			INNER JOIN DocApproved ON DocNew.VersionKey = DocApproved.VersionKey 
				AND DocNew.FilePath<>DocApproved.FilePath
	), 
	Added AS (
	SELECT	Count(*) AS AddedCount
	FROM	DocNew 
			WHERE NOT Exists(SELECT * FROM DocApproved WHERE DocNew.VersionKey = DocApproved.VersionKey)
	),
	Approved AS (
			select	count(*) As ApprovedCount
			from	DocApproved
	),
	UnApproved AS (
			select	count(*) As UnApprovedCount
			from	DocNew
	)

	SELECT ApprovedCount, UnapprovedCount, UpdatedCount, AddedCount
	FROM	Approved, Unapproved, Updated, Added
END
GO
