Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutFSPJobParts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebPutFSPJobParts]
GO


Create Procedure dbo.spWebPutFSPJobParts 
	(
		@UserID int,
		@JobID bigint,
		@PartID varchar(16),
		@Qty int
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 7/02/12 14:52 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPJobParts.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebPutFSPJobParts 
									@UserID = @UserID, 
									@JobID = @JobID, 
									@PartID = @PartID,
									@Qty = @Qty
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*
spWebPutFSPJobParts 199663, 20050303172
spWebPutFSPJobParts 199663, 505646

312691
*/
Go

Grant EXEC on spWebPutFSPJobParts to eCAMS_Role
Go

Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutFSPJobParts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebPutFSPJobParts]
GO


Create Procedure dbo.spWebPutFSPJobParts 
	(
		@UserID int,
		@JobID bigint,
		@PartID varchar(16),
		@Qty int
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/03/03 17:02 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebPutFSPJobParts.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Delete Job Equipment
 DECLARE 
	@Location int,
	@JobFSP int,
	@JobTypeID int
	



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
		IF EXISTS(SELECT 1 FROM Call_Parts WHERE CallNumber = @JobID AND PartID = @PartID)
			UPDATE Call_Parts
				SET Qty = @Qty
			 WHERE CallNumber = @JobID AND PartID = @PartID
		ELSE
			INSERT Call_Parts(CallNumber, PartID, Qty) Values(@JobID, @PartID, @Qty)
	 END

  END
 ELSE
  BEGIN
	SELECT @JobFSP = BookedInstaller,
			@JobTypeID = JobTypeID
	  FROM IMS_Jobs 
 	 WHERE JobID = @JobID

	--verify the job is belong to this user
	IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
	 BEGIN
		IF EXISTS(SELECT 1 FROM IMS_JOB_Parts WHERE JobID = @JobID AND PartID = @PartID)
			UPDATE IMS_JOB_Parts
				SET Qty = @Qty
			 WHERE JobID = @JobID AND PartID = @PartID
		ELSE
			INSERT IMS_JOB_Parts(JobID, PartID, Qty, ActionID) 
				Values(@JobID, @PartID, @Qty, 
						 case when @JobTypeID in (1,2) then @JobTypeID 
								else 
									case when @PartID = 'CBATT' then 2 else 1 end
						end	)
	 END
  END

GO
Grant EXEC on spWebPutFSPJobParts to eCAMS_Role
Go


