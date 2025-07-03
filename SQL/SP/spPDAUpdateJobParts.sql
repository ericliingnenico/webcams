Use CAMS
Go


Alter Procedure dbo.spPDAUpdateJobParts 
	(
		@UserID int,
		@JobID bigint,
		@PartID varchar(16),
		@Qty smallint
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Chester $-->
--<!--$$Date: 31/10/06 5:31p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAUpdateJobParts.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Update Qty of Parts. It is only applied to IMS Jobs
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
	--set new qty, using Qty, for the time being, eventually will merge Qty and QuantityOut to one field Quantity
	--@Serial - PartID, @NewSerial - Qty
	UPDATE Call_Parts
 	   SET Qty = @Qty
	 WHERE CallNumber = @JobID
		AND PartID = @PartID

	SELECT @ret = @@ERROR
	IF @ret <> 0
		GOTO Exit_Handle
	
	
  END
 ELSE
  BEGIN
	--set new qty, using Qty, for the time being, eventually will merge Qty and QuantityOut to one field Quantity
	--@Serial - PartID, @NewSerial - Qty
	UPDATE IMS_Job_Parts
 	   SET Qty = @Qty
	 WHERE JobID = @JobID
		AND PartID = @PartID

	SELECT @ret = @@ERROR
	IF @ret <> 0
		GOTO Exit_Handle
	

  END


Exit_Handle:

 RETURN @ret

GO

Grant EXEC on spPDAUpdateJobParts to eCAMS_Role
Go
