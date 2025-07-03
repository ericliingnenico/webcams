Use CAMS
Go


Alter Procedure dbo.spPDADelJobParts 
	(
		@UserID int,
		@JobID bigint,
		@PartID varchar(16)
	)
	AS
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 21/09/06 2:38p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDADelJobParts.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Delete Parts. It is only applied to IMS Jobs
-- 22/09/2006 Bo	Handled Call Parts
DECLARE @Location int,
	@ret int


 --Get Location for the user
 SELECT @Location = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 IF @Location IS NULL
 	RETURN -1

 --verify if the job exists
 IF LEN(@JobID) = 11
  BEGIN
	--@Serial - PartID, @NewSerial - Qty
	DELETE Call_Parts
	 WHERE CallNumber = @JobID
		AND PartID = @PartID

	SELECT @ret = @@ERROR
	IF @ret <> 0
		GOTO Exit_Handle

  END
 ELSE
  BEGIN
	--@Serial - PartID, @NewSerial - Qty
	DELETE IMS_Job_Parts
	 WHERE JobID = @JobID
		AND PartID = @PartID

	SELECT @ret = @@ERROR
	IF @ret <> 0
		GOTO Exit_Handle

 END -- job exists


Exit_Handle:

 RETURN @ret

GO

Grant EXEC on spPDADelJobParts to eCAMS_Role
Go
