Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebDelFSPJobParts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebDelFSPJobParts]
GO


Create Procedure dbo.spWebDelFSPJobParts 
	(
		@UserID int,
		@JobID bigint,
		@PartID varchar(16)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 2/05/08 4:48p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebDelFSPJobParts.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebDelFSPJobParts 
									@UserID = @UserID, 
									@JobID = @JobID, 
									@PartID = @PartID
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*
spWebDelFSPJobParts 199663, 20050303172
spWebDelFSPJobParts 199663, 505646

312691
*/
Go

Grant EXEC on spWebDelFSPJobParts to eCAMS_Role
Go

Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebDelFSPJobParts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebDelFSPJobParts]
GO


Create Procedure dbo.spWebDelFSPJobParts 
	(
		@UserID int,
		@JobID bigint,
		@PartID varchar(16)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/03/03 17:02 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebDelFSPJobParts.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Delete Job Equipment
 DECLARE 
	@Location int,
	@JobFSP int
	



 SELECT @Location = InstallerID FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID


 --cache Location Family
 SELECT * 
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamilyExt(@Location)


 
 IF LEN(@JobID) = 11
  BEGIN
	--get call info
	SELECT @JobFSP = AssignedTo
	  FROM Calls
	 WHERE CallNumber = @JobID


	--verify the job is belong to this user
	IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
	 BEGIN
		DELETE
			FROM Call_Parts
			WHERE CallNumber = @JobID
				AND PartID = @PartID

	 END

  END
 ELSE
  BEGIN
	SELECT @JobFSP = BookedInstaller
	  FROM IMS_Jobs 
 	 WHERE JobID = @JobID

	--verify the job is belong to this user
	IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
	 BEGIN
		 DELETE
			FROM ims_job_parts
			WHERE JobID = @JobID
				AND PartID = @PartID
	
	 END
  END

GO
Grant EXEC on spWebDelFSPJobParts to eCAMS_Role
Go


