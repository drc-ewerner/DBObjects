USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetGroupDocCountsByEnv]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eweb_GetGroupDocCountsByEnv]
(@groupId INT
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	WITH MaxApprovedVersion AS (
		SELECT	dgvp.EnvironmentCode, Max(dgv.Version) AS Version
		from	DocGroupVersion dgv
			INNER JOIN DocGroupVersionPublish dgvp ON dgv.DocGroupVerId = dgvp.DocGroupVerId
		where	dgvp.ApprovedDate IS NOT NULL
		and		dgv.DocGroupId = @groupId
		GROUP BY dgvp.EnvironmentCode
	), 
	NewUnApprovedVersion AS (
		SELECT	dgvp.EnvironmentCode, Max(dgv.Version) AS Version
		from	DocGroupVersion dgv
			INNER JOIN DocGroupVersionPublish dgvp ON dgv.DocGroupVerId = dgvp.DocGroupVerId
		where	dgvp.ApprovedDate IS NULL
		and		dgv.DocGroupId = @groupId
		and		(not exists(select * from MaxApprovedVersion av where av.EnvironmentCode = dgvp.EnvironmentCode) 
		or		dgv.Version > (select Max(Version) from MaxApprovedVersion av where av.EnvironmentCode = dgvp.EnvironmentCode))
		GROUP BY dgvp.EnvironmentCode
	), 
	DocApproved AS (
	select	ver.EnvironmentCode, d.VersionKey, d.DocId, dgv.Version, d.FilePath
	from	DocGroupVersion dgv
			INNER JOIN MaxApprovedVersion ver ON ver.Version = dgv.Version
			INNER JOIN DocGroupVersionDoc dgvd ON dgvd.DocGroupVerId = dgv.DocGroupVerId
			INNER JOIN Doc d ON dgvd.DocId = d.DocId
	where	dgv.DocGroupId = @groupId
	), 
	DocNew AS (
	select	ver.EnvironmentCode, d.VersionKey, d.DocId, dgv.Version, d.FilePath
	from	DocGroupVersion dgv
			INNER JOIN NewUnApprovedVersion ver ON ver.Version = dgv.Version
			INNER JOIN DocGroupVersionDoc dgvd ON dgvd.DocGroupVerId = dgv.DocGroupVerId
			INNER JOIN Doc d ON dgvd.DocId = d.DocId
	where	dgv.DocGroupId = @groupId
	),
	Environments AS (
	SELECT	DISTINCT EnvironmentCode 
	from	DocGroupVersionPublish
	), 
	Updated AS (
	SELECT	DocNew.EnvironmentCode, Count(*) AS UpdatedCount
	FROM	DocNew
			INNER JOIN DocApproved ON DocNew.VersionKey = DocApproved.VersionKey 
				AND DocNew.FilePath<>DocApproved.FilePath
				AND DocNew.EnvironmentCode = DocApproved.EnvironmentCode
	GROUP BY DocNew.EnvironmentCode
	), 
	Added AS (
	SELECT	DocNew.EnvironmentCode, Count(*) AS AddedCount
	FROM	DocNew 
			WHERE NOT Exists(SELECT * FROM DocApproved WHERE DocNew.VersionKey = DocApproved.VersionKey
				AND DocNew.EnvironmentCode = DocApproved.EnvironmentCode)
	GROUP BY DocNew.EnvironmentCode
	),
	Approved AS (
			select	EnvironmentCode, count(*) As ApprovedCount
			from	DocApproved
			group BY EnvironmentCode
	),
	UnApproved AS (
			select	EnvironmentCode, count(*) As UnApprovedCount
			from	DocNew
			GROUP BY EnvironmentCode
	)
	

	SELECT	Environments.EnvironmentCode, ApprovedCount, UnapprovedCount, UpdatedCount, AddedCount
	FROM	Environments
		LEFT OUTER JOIN Approved ON Approved.EnvironmentCode = Environments.EnvironmentCode
		LEFT OUTER JOIN Unapproved ON UnApproved.EnvironmentCode = Environments.EnvironmentCode
		LEFT OUTER JOIN Updated ON Updated.EnvironmentCode = Environments.EnvironmentCode
		LEFT OUTER JOIN Added ON Added.EnvironmentCode = Environments.EnvironmentCode
END


GO
