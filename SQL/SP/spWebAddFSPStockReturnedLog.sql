Use CAMS
Go

IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebAddFSPStockReturnedLog' and type = 'p')
	drop procedure dbo.spWebAddFSPStockReturnedLog
go


Create Procedure dbo.spWebAddFSPStockReturnedLog 
	(
		@UserID int,
		@BatchID int,
		@Serial varchar(32)
	)
	AS
--<!--$$Revision: 13 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 11/06/08 10:03a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAddFSPStockReturnedLog.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add FSP stock returned to tblFSPStockReturnedLog
DECLARE @ret int,
	@MMD_ID varchar(5),
	@CaseID tinyint,
	@Condition int,
	@Location int,
	@LastCondition int,
	@LastLocation int,
	@FSPLocation int,
	@Count int,
	@FSPOperatorNumber int,
	@FromLocation int,
	@ToLocation int,
	@DateIn datetime,

	@KitSerial varchar(32),
	@KitMMD_ID varchar(5),
	@PinpadSerial varchar(32),
	@PinpadMMD_ID varchar(5),
	@PrinterSerial varchar(32),
	@PrinterMMD_ID varchar(5),
	@TerminalSerial varchar(32),
	@TerminalMMD_ID varchar(5),

	@KitLocation int,
	@KitCondition int,

	@SiteClientID varchar(3),
	@SiteName varchar(50),
	@TerminalID varchar(20),

	@InvNote varchar(65),
	
	@NewCondition int,
	@NewInvNote varchar(65),

	@DeviceName varchar(150),

	@CurDateTime datetime,
	@BaseLocation int

 -- get base location
 SELECT @BaseLocation = dbo.fnGetMyBaseLocation()

 SELECT @ret = 0,
	@NewCondition = 2,
	@NewInvNote = NULL,
 	@CurDateTime = dbo.fnGetDate()



 --Get Location for the user
 SELECT @FSPLocation = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = -@FSPLocation

 SELECT @Serial = UPPER(dbo.fnLeftPadSerial(@Serial))

 --get StockReturned Batch details
 SELECT @FromLocation = FromLocation,
	@ToLocation = ToLocation
   FROM tblFSPStockReturned
  WHERE BatchID = @BatchID

 --cache FSP Location family
 SELECT *
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamily(@FSPLocation)


 SELECT * 
   INTO #myLocChildren
   FROM dbo.fnGetLocationChildrenExt(@FSPLocation)


 --set new condition
 IF @ToLocation <> @BaseLocation
  BEGIN
	SELECT @NewCondition = 20,
		@NewInvNote = 'RETURNED TO SWAP POOL BY FSP-' + CAST(@FSPOperatorNumber as varchar)

  END

 --Get device
 SELECT @MMD_ID = MMD_ID,
	@Condition = Condition,
	@Location = Location,
	@LastCondition = LastCondition,
	@LastLocation = LastLocation
   FROM Equipment_Inventory
  WHERE Serial = @Serial

 SELECT @Count = @@ROWCOUNT

 IF @Count > 1
  BEGIN
	--multiple devices found on this serial, noew narrow the search to FSP group
	SELECT @MMD_ID = MMD_ID,
		@Condition = Condition,
		@Location = Location,
		@LastCondition = LastCondition,
		@LastLocation = LastLocation
	   FROM Equipment_Inventory
	  WHERE Serial = @Serial
		AND Location IN (SELECT Location FROM #myLocFamily)
	
	SELECT @Count = @@ROWCOUNT

  END

 --unique record
 IF @Count = 1
  BEGIN
	--case 1: device was expected 
	IF @Condition IN (31, 59, 37, 53) 
		AND EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @Location)

	 BEGIN
		---Update current inventory record to ToLocation/2
		EXEC @ret = dbo.spChangeInventoryConditionLocation 
			@Serial = @Serial,
			@MMD_ID = @MMD_ID,
			@NewCondition = @NewCondition,
			@NewLocation = @ToLocation,
			@Note = @NewInvNote,
			@AddedBy = @FSPOperatorNumber
	
		SELECT @CaseID = 1
	
		GOTO Exit_Handle
	 END

	--case-2: device was within the FSP or at a child location and condition <> 9
	IF EXISTS(SELECT 1 FROM #myLocChildren WHERE Location = @Location) 
		AND @Condition <> 9
	 BEGIN
		---Update current inventory record to ToLocation/2
		EXEC @ret = dbo.spChangeInventoryConditionLocation 
			@Serial = @Serial,
			@MMD_ID = @MMD_ID,
			@NewCondition = @NewCondition,
			@NewLocation = @ToLocation,
			@Note = @NewInvNote,
			@AddedBy = @FSPOperatorNumber
	
		SELECT @CaseID = 2
	
		GOTO Exit_Handle

	 END	

	--case-3: Device was at another location with acceptable location/condition
	IF NOT EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @Location) 
	 BEGIN
		IF @Condition IN (1, 3, 42, 53, 55, 58, 59, 64, 66, 70, 80, 87, 88, 92)
			OR @Location in (211, 238, 311, 411, 511, 611, 711, 996, 998, 999, 8100, 8211, 8311, 8411, 8511, 8611)
			OR @Location in (4100)
			OR @Location BETWEEN 1200 AND 1999
			OR @DateIn < DATEADD(day, -180, GETDATE())
		 BEGIN
			---Update current inventory record to ToLocation/2
			EXEC @ret = dbo.spChangeInventoryConditionLocation 
				@Serial = @Serial,
				@MMD_ID = @MMD_ID,
				@NewCondition = @NewCondition,
				@NewLocation = @ToLocation,
				@Note = @NewInvNote,
				@AddedBy = @FSPOperatorNumber
		
			SELECT @CaseID = 3
		
			GOTO Exit_Handle
		 END

		IF @Condition = 31 
			AND @Location <> @BaseLocation 
			AND EXISTS(SELECT 1 FROM Locations_Master WHERE Location = @Location AND IsExternalRepair = 1)
		 BEGIN
			---Update current inventory record to ToLocation/2
			EXEC @ret = dbo.spChangeInventoryConditionLocation 
				@Serial = @Serial,
				@MMD_ID = @MMD_ID,
				@NewCondition = @NewCondition,
				@NewLocation = @ToLocation,
				@Note = @NewInvNote,
				@AddedBy = @FSPOperatorNumber
		
			SELECT @CaseID = 3
		
			GOTO Exit_Handle
		 END

		IF @Location = @BaseLocation
			AND @Condition = 9
		 BEGIN
			--in a kit?
			SELECT @KitSerial = ek.KitSerial,
				@KitMMD_ID = ek.KitMMD_ID,
				@PinpadSerial = ek.PinpadSerial,
				@PinpadMMD_ID = ek.PinpadMMD_ID,
				@PrinterSerial = ek.PrinterSerial,
				@PrinterMMD_ID = ek.PrinterMMD_ID,
				@TerminalSerial = ek.TerminalSerial,
				@TerminalMMD_ID = ek.TerminalMMD_ID,
				@KitLocation = k.Location,
				@KitCondition = k.Condition
			  FROM Equipment_Kits ek JOIN Equipment_Inventory k ON ek.KitSerial = k.Serial
										AND ek.KitMMD_ID = k.MMD_ID
			 WHERE (ek.PinpadSerial = @Serial AND ek.PinpadMMD_ID = @MMD_ID)
				OR (ek.PrinterSerial = @Serial AND ek.PrinterMMD_ID = @MMD_ID)
				OR (ek.TerminalSerial = @Serial AND ek.TerminalMMD_ID = @MMD_ID)
			
			IF @KitLocation IS NOT NULL
			 BEGIN
 				SELECT @InvNote = 'KIT UNPACKED BY ' + Cast(@FSPOperatorNumber as varchar)

				 --unpack terminal to @KitLocation/@KitCondition
				 IF @TerminalSerial IS NOT NULL
				  BEGIN
					 EXEC @ret = dbo.spChangeInventoryConditionLocation 
						@Serial = @TerminalSerial,
						@MMD_ID = @TerminalMMD_ID,
						@NewCondition = @KitCondition,
						@NewLocation = @KitLocation,
						@Note = @InvNote,
						@AddedBy = @FSPOperatorNumber
					
					 IF @ret <> 0 
						GOTO Exit_Handle	
				   END
				
				 --unpack printer to @KitLocation/@KitCondition
				 IF @PrinterSerial IS NOT NULL
				  BEGIN
					 EXEC @ret = dbo.spChangeInventoryConditionLocation 
						@Serial = @PrinterSerial,
						@MMD_ID = @PrinterMMD_ID,
						@NewCondition = @KitCondition,
						@NewLocation = @KitLocation,
						@Note = @InvNote,
						@AddedBy = @FSPOperatorNumber
					
					 IF @ret <> 0 
						GOTO Exit_Handle	
				   END
				
				 --unpack pinpad to FSP/19
				 IF @PinpadSerial IS NOT NULL
				  BEGIN
					 EXEC @ret = dbo.spChangeInventoryConditionLocation 
						@Serial = @PinpadSerial,
						@MMD_ID = @PinpadMMD_ID,
						@NewCondition = @KitCondition,
						@NewLocation = @KitLocation,
						@Note = @InvNote,
						@AddedBy = @FSPOperatorNumber
					
					 IF @ret <> 0 
						GOTO Exit_Handle	
				   END
				

				 --Change Kit Condition location/86, location/20
				 EXEC @ret = dbo.spChangeInventoryConditionLocation 
					@Serial = @KitSerial,
					@MMD_ID = @KitMMD_ID,
					@NewCondition = 86,
					@NewLocation = @Location,
					@Note = @InvNote,
					@AddedBy = @FSPOperatorNumber
				
				 IF @ret <> 0 
					GOTO Exit_Handle
				
				 EXEC @ret = dbo.spChangeInventoryConditionLocation 
					@Serial = @KitSerial,
					@MMD_ID = @KitMMD_ID,
					@NewCondition = 20,
					@NewLocation = @Location,
					@Note = @InvNote,
					@AddedBy = @FSPOperatorNumber
				
				 IF @ret <> 0 
					GOTO Exit_Handle
				
				 --Delete Kit from inventory
				 DELETE Equipment_Inventory
				  WHERE Serial = @KitSerial
					AND MMD_ID = @KitMMD_ID
				
				 SELECT @ret = @@ERROR
				 IF @ret <> 0 
					GOTO Exit_Handle
				
				
				 --Begin to move kit from Equipment Kit table to Equipment_Kits_History
				 UPDATE Equipment_Kits
				   SET DateUnpacked = @CurDateTime,
					UnpackNotes =@InvNote
				   WHERE KitSerial = @KitSerial
					 AND KitMMD_ID = @KitMMD_ID
				 
				 SELECT @ret = @@ERROR
				 IF @ret <> 0 
					GOTO Exit_Handle
				
				 INSERT Equipment_Kits_History
				   	SELECT * FROM Equipment_Kits
						   WHERE KitSerial = @KitSerial
							 AND KitMMD_ID = @KitMMD_ID
				 
				 SELECT @ret = @@ERROR
				 IF @ret <> 0 
					GOTO Exit_Handle
				
				
				 DELETE Equipment_Kits
				   WHERE KitSerial = @KitSerial
					 AND KitMMD_ID = @KitMMD_ID
				 
				 SELECT @ret = @@ERROR
				 IF @ret <> 0 
					GOTO Exit_Handle


				---Update current inventory record to ToLocation/2
				EXEC @ret = dbo.spChangeInventoryConditionLocation 
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@NewCondition = @NewCondition,
					@NewLocation = @ToLocation,
					@Note = @NewInvNote,
					@AddedBy = @FSPOperatorNumber
			
				SELECT @CaseID = 3
			
				GOTO Exit_Handle



			 END

		 END

	 END	



  END

 --multiple records
 IF @Count > 1
  BEGIN
	SELECT @CaseID = 5      --Serial number was duplicated, MMD_ID to be confirmed	

	GOTO Exit_Handle
  END 

 --Device was showing as installed in a merchant site.
 SELECT @SiteClientID = se.ClientID,
	@SiteName = ISNULL(s.Name, ''),
	@TerminalID = s.TerminalID,
	@DeviceName = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '')
  FROM Site_Equipment se JOIN Sites s ON se.ClientID = s.ClientID
					AND se.TerminalID = s.TerminalID
			JOIN M_M_D m on se.MMD_ID = m.MMD_ID
  WHERE se.Serial = @Serial 

 IF @@ROWCOUNT = 1
  BEGIN
	RAISERROR('<b>Serial %s - %s <br>not expected:<br><br>Device is showing as installed at %s %s <br>%s</b><br>', 16, 1, @Serial, @DeviceName, @SiteClientID, @TerminalID, @SiteName)
	SELECT @CaseID = 4
	GOTO Exit_Handle
  END

  --Case 6      Device was not expected
  SELECT @DeviceName = ISNULL(@DeviceName, '')
  RAISERROR('<b>Serial %s - %s <br>not expected:<br><br>Device not expected</b><br>', 16, 1, @Serial, @DeviceName)
  SELECT @CaseID = 6


Exit_Handle:
 INSERT tblFSPStockReturnedLog (BatchID, Serial, MMD_ID, CaseID, ScanAtDespatch)
	Values (@BatchID, @Serial, @MMD_ID, @CaseID, @CurDateTime)

 --return to my swap pool
 IF @ToLocation <> @BaseLocation
  BEGIN
	IF EXISTS(SELECT 1 FROM tblFSPStockReturnedCase WHERE CaseID = @CaseID and Status = 'OK')
	 BEGIN
		--set stock return flags on job equipment
		EXEC dbo.spSetStockReturnOnJobEquipment @Serial = @Serial,
							@MMD_ID = @MMD_ID,
							@StockReturnTypeID = 2,
							@StockReturnedDateTime = @CurDateTime

   	 END
  END
 RETURN @@ERROR

GO

Grant EXEC on spWebAddFSPStockReturnedLog to eCAMS_Role
Go


Use WebCAMS
Go


IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebAddFSPStockReturnedLog' and type = 'p')
	drop procedure dbo.spWebAddFSPStockReturnedLog
go

Create Procedure dbo.spWebAddFSPStockReturnedLog 
	(
		@UserID int,
		@BatchID int,
		@Serial varchar(32)
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDACloseJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebAddFSPStockReturnedLog 
		@UserID = @UserID,
		@BatchID = @BatchID,
		@Serial = @Serial

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

/*

spWebAddFSPStockReturnedLog @UserID = 199649,
		@BatchID = 14,
		@Serial = '       A79661195'
		
*/
Go

Grant EXEC on spWebAddFSPStockReturnedLog to eCAMS_Role
Go

