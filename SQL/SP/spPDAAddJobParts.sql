Use CAMS
Go


Alter Procedure dbo.spPDAAddJobParts 
	(
		@UserID int,
		@JobID bigint,
		@PartID varchar(16),
		@Qty smallint,
		@Action smallint
	)
	AS
--<!--$$Revision: 10 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 13/11/06 1:31p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAAddJobParts.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add Parts. It is only applied to IMS Jobs
--22/09/2006 Bo	Handled Call Parts
DECLARE @Location int,
	@ret int

 --Get Location for the user
 SELECT @Location = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 --not valid user, return
 IF @Location IS NULL 
	RETURN -1


 IF LEN(@JobID) = 11
  BEGIN
	--parts exists, can't add it in, don't need to raise error
	IF EXISTS(SELECT 1 FROM Call_Parts WHERE CallNumber = @JobID AND PartID = @PartID)
		RETURN -1

	--add it in
	INSERT Call_Parts (CallNumber, 
				PartID, 
				Qty)
		SELECT  @JobID,
			@PartID,
			@Qty

	SELECT @ret = @@ERROR
	IF @ret <> 0
		GOTO Exit_Handle

  END
 ELSE
  BEGIN
	--parts exists, can't add it in, don't need to raise error
	IF EXISTS(SELECT 1 FROM IMS_Job_Parts WHERE JobID = @JobID AND PartID = @PartID)
		RETURN -1

	--add it in
	INSERT IMS_Job_Parts (JobID, 
				PartID, 
				Qty, 
				ActionID)
		SELECT  @JobID,
			@PartID,
			@Qty,
			@Action

	SELECT @ret = @@ERROR
	IF @ret <> 0
		GOTO Exit_Handle


  END


Exit_Handle:

 RETURN @ret

GO

Grant EXEC on spPDAAddJobParts to eCAMS_Role
Go
