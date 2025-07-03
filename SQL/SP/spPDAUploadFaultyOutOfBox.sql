Use CAMS
Go

Alter Procedure dbo.spPDAUploadFaultyOutOfBoxDevice 
	(
		@UserID int,
		@Serial varchar(16),
		@Note varchar(65)
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 18/06/08 11:52a $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAUploadFaultyOutOfBox.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Upload FOB and Send exception report
DECLARE @ret int,
	@MMD_ID varchar(5),
	@Location int,
	@FSPLocation int,
	@Condition int,
	@Count int,
	@FSPOperatorNumber int,
	@Msg varchar(1000),
	@CRLF char(2),
	@TAB char(1),
	@Subject varchar(100),
	@ToEmail varchar(100)


 

 -- init
 SELECT @CRLF = CHAR(13) + CHAR(10),
	@TAB = CHAR(9)


 --set ToEmail
 IF EXISTS(SELECT 1 FROM tblControl WHERE Attribute = 'IsLiveDB' AND AttrValue = 'YES')
  BEGIN
	SELECT @ToEmail = 'FSPFaultyOutOfBoxScan@keycorp.net'
  END
 ELSE
  BEGIN
	SELECT @ToEmail = 'bli@keycorp.net'
  END



 --convert empty to null
 IF LTRIM(@Note) = '' 
	SELECT @Note = NULL

 --Get Location for the user
 SELECT @FSPLocation = InstallerID,
	@Subject = 'Faulty out of box: Exception (Scanned by ' + CAST(InstallerID as varchar) + '-' + UserName + ')'
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = -@FSPLocation

 --get device details
 SELECT @MMD_ID = MMD_ID,
	@Condition = Condition,
	@Location = Location
	FROM Equipment_Inventory
	WHERE Serial = @Serial 
		AND Condition IN (18, 19, 20, 2, 9, 37)
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
	--compose message
	SELECT @Msg = 'There is an exception on uploading the following device:' + @CRLF +
			@TAB + 'Serial: ' + LTRIM(ISNULL(@Serial, '')) + @CRLF +
			@TAB + 'Notes: ' + ISNULL(@Note, '') + @CRLF +
			@TAB + 'Number of matching record found: ' + CAST(@Count as varchar) + @CRLF


	--notify stock controller with the exception
	EXEC master.dbo.upSendCDOsysMail 
		@From = 'SQLMail@keycorp.net', 
		@To = @ToEmail, 
		@Subject = @Subject, 
		@Body = @Msg


  END


Exit_Handle:

 RETURN @@ERROR

GO

Grant EXEC on spPDAUploadFaultyOutOfBoxDevice to eCAMS_Role
Go


Use WebCAMS
Go

Alter Procedure dbo.spPDAUploadFaultyOutOfBoxDevice 
	(
		@UserID int,
		@Serial varchar(16),
		@Note varchar(65)
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDACloseJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON

 EXEC Cams.dbo.spPDAUploadFaultyOutOfBoxDevice @UserID = @UserID,
		@Serial = @Serial,
		@Note = @Note

/*

spPDAUploadFaultyOutOfBoxDevice @UserID = 199516,
		@Serial = 'pop',
		@Note = 'mm'

*/
Go

Grant EXEC on spPDAUploadFaultyOutOfBoxDevice to eCAMS_Role
Go
