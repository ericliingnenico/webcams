Use CAMS
Go

If exists(select 1 from sysobjects where name = 'spWebAddFaultyOutOfBoxDevice')
 drop proc dbo.spWebAddFaultyOutOfBoxDevice
Go

Create Procedure dbo.spWebAddFaultyOutOfBoxDevice 
	(
		@UserID int,
		@Serial varchar(32),
		@Note varchar(60)
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 20/09/11 14:34 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAddFaultyOutOfBoxDevice.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add F.O.B. device
DECLARE @ret int,
	@JobNotes varchar(255),
	@FSPOperatorNumber int,
	@MMD_ID varchar(5),
	@Location int,
	@FSPLocation int,
	@Condition int,
	@Count int

    --init
    SELECT @ret = 0

	 --Get Location for the user
	 SELECT @FSPOperatorNumber = 0 - InstallerID,
			@FSPLocation = InstallerID
	   FROM WebCAMS.dbo.tblUser
	  WHERE UserID = @UserID

	if @FSPOperatorNumber is null
		return @ret

	set @Serial = dbo.fnLeftPadSerial(@Serial)

 --get device details
 SELECT @MMD_ID = MMD_ID,
	@Condition = Condition,
	@Location = Location
	FROM Equipment_Inventory
	WHERE Serial = @Serial 
		AND Location IN (SELECT * FROM dbo.fnGetLocationFamilyExt(@FSPLocation))

 SELECT @Count = @@ROWCOUNT


 --insert into log first
 INSERT tblFaultyOutOfBoxDeviceLog (UserID, Serial, Note, InventoryQty, UploadDateTime)
	Values (@UserID, @Serial, @Note, @Count, GetDate())

 --device is unique in equipment inventory
 IF @Count = 1
  BEGIN

	 --verify if the device is part of Kit
	IF EXISTS(SELECT 1 FROM Equipment_Kits WHERE (PinpadSerial = @Serial AND PinpadMMD_ID = @MMD_ID) 
							OR (PrinterSerial = @Serial AND PrinterMMD_ID = @MMD_ID) 
							OR (TerminalSerial = @Serial AND TerminalMMD_ID = @MMD_ID) )
	 BEGIN
		--in a kit, unpack it from PDA
		EXEC dbo.spPDAProcessKit 
			@UserID = @UserID,
			@Serial = @Serial,
			@MMD_ID = @MMD_ID,
			@IsFaultyOutOfBox = 1


	 END


	--if device is at FSP/37, won't update it again
	IF @Condition = 37 AND @FSPLocation = @Location
	 BEGIN
		IF @Note IS NOT NULL
		 BEGIN
			--set notes only
			UPDATE Equipment_Inventory
			   SET Note = @Note
			 WHERE Serial = @Serial
				AND MMD_ID = @MMD_ID
		 END
	 END
	ELSE
	 BEGIN
		---Update current inventory record to FSP/37
		EXEC @ret = dbo.spChangeInventoryConditionLocation 
			@Serial = @Serial,
			@MMD_ID = @MMD_ID,
			@NewCondition = 37,
			@NewLocation = @FSPLocation,
			@Note = @Note,
			@AddedBy = @FSPOperatorNumber
	 END	
  END
 ELSE
  BEGIN
    RAISERROR('Device does not exist', 16, 1)
    SELECT @ret = -1
  END


Exit_Handle:

 RETURN @ret


GO

Grant EXEC on spWebAddFaultyOutOfBoxDevice to eCAMS_Role
Go

Use WebCAMS
Go

If exists(select 1 from sysobjects where name = 'spWebAddFaultyOutOfBoxDevice')
 drop proc dbo.spWebAddFaultyOutOfBoxDevice
Go


Create Procedure dbo.spWebAddFaultyOutOfBoxDevice 
	(
		@UserID int,
		@Serial varchar(32),
		@Note varchar(60)
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 3/05/04 2:25p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebAddFaultyOutOfBoxDevice.sql $-->
--<!--$$NoKeywords: $-->
DECLARE @ret int

 SET NOCOUNT ON

 EXEC @ret = Cams.dbo.spWebAddFaultyOutOfBoxDevice @UserID = @UserID,
		@Serial = @Serial, 
		@Note = @Note

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

/*
spWebAddFaultyOutOfBoxDevice 199516
*/
Go

Grant EXEC on spWebAddFaultyOutOfBoxDevice to eCAMS_Role
Go
