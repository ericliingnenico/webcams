Use CAMS
Go

Alter Procedure dbo.spWebAddFSPStockReceivedLog 
	(
		@UserID int,
		@BatchID int,
		@Serial varchar(32)
	)
	AS
--<!--$$Revision: 22 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 11/09/08 4:24p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAddFSPStockReceivedLog.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add FSP stock received to tblTMPFSPStockReceivedLog
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
	@Depot int,
	@JobID varchar(11),
	@MerchantName varchar(50),
	@MerchantCity varchar(50),
	@CurDateTime datetime,
	@BaseLocation int

 SET NOCOUNT ON

 SELECT @ret = 0,
 	@CurDateTime = dbo.fnGetDate()

 -- get base location
 SELECT @BaseLocation = dbo.fnGetMyBaseLocation()

 --Get Location for the user
 SELECT @FSPLocation = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = -@FSPLocation

 SELECT @Serial = UPPER(dbo.fnLeftPadSerial(@Serial))

 --get StockReceived Batch details
 SELECT @Depot = Depot
   FROM tblTMPFSPStockReceived
  WHERE BatchID = @BatchID

 --cache FSP Location family
 SELECT *
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamily(@FSPLocation)

 --Get device
 SELECT @MMD_ID = MMD_ID,
	@Condition = Condition,
	@Location = Location,
	@LastCondition = LastCondition,
	@LastLocation = LastLocation
   FROM Equipment_Inventory
  WHERE Serial = @Serial

 SELECT @Count = @@ROWCOUNT

 --unique record
 IF @Count = 1
  BEGIN
	--case 1: device was expected 
	IF @Condition IN (2) 
		AND @LastCondition IN (18, 19, 20)
		AND EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @Location)
		AND @LastLocation = @BaseLocation
	 BEGIN
		---Update current inventory record to Depot/LastCondition
		EXEC @ret = dbo.spChangeInventoryConditionLocation 
			@Serial = @Serial,
			@MMD_ID = @MMD_ID,
			@NewCondition = @LastCondition,
			@NewLocation = @Depot,
			@Note = NULL,
			@AddedBy = @FSPOperatorNumber
	
		SELECT @CaseID = 1
	
		GOTO Exit_Handle
	 END

	--case-2: device was already within the FSP group
	IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @Location)
	 BEGIN
		--condition 2, updates to depot/LastCondition
		IF @Condition = 2 AND @Location <> @Depot
		 BEGIN
			---Update current inventory record to Depot/LastCondition
			EXEC @ret = dbo.spChangeInventoryConditionLocation 
				@Serial = @Serial,
				@MMD_ID = @MMD_ID,
				@NewCondition = @LastCondition,
				@NewLocation = @Depot,
				@Note = NULL,
				@AddedBy = @FSPOperatorNumber
			
			--report as case-1, stock updated
			SELECT @CaseID = 1
			GOTO Exit_Handle

	    	 END		
		IF @Condition <> 9 AND @Location <> @Depot
		 BEGIN
			---Update current inventory record to Depot/Condition
			EXEC @ret = dbo.spChangeInventoryConditionLocation 
				@Serial = @Serial,
				@MMD_ID = @MMD_ID,
				@NewCondition = @Condition,
				@NewLocation = @Depot,
				@Note = NULL,
				@AddedBy = @FSPOperatorNumber

			--report as case-1, stock updated
			SELECT @CaseID = 1
			GOTO Exit_Handle

		 END		

		IF @Condition <> 9
	     BEGIN
			--Now it is Case-2, no location update is needed
			SELECT @CaseID = 2
			GOTO Exit_Handle
		 END
	 END	

	--case-7: device was part of kit
	IF @Location = @BaseLocation 
		AND @Condition = 9 
		AND EXISTS(SELECT 1 FROM tblKit 
					WHERE Terminal_MMD_ID = @MMD_ID 
						OR Printer_MMD_ID = @MMD_ID 
						OR Pinpad_MMD_ID = @MMD_ID)
	 BEGIN
		IF EXISTS(SELECT 1 FROM Equipment_Kits 
					WHERE (PinpadSerial = @Serial AND PinpadMMD_ID = @MMD_ID)
						OR (PrinterSerial = @Serial AND PrinterMMD_ID = @MMD_ID)
						OR (TerminalSerial = @Serial AND TerminalMMD_ID = @MMD_ID))

		--the device scanned is still in an unpacked kit, ring the bell
		SELECT @CaseID = 7
		GOTO Exit_Handle
	 END


	--Case 8: device was reserved for a job
	SELECT @JobID = CAST(j.JobID as varchar),
		@MerchantName = j.Name,
		@MerchantCity = j.City
	  FROM IMS_Jobs j JOIN IMS_Job_Equipment je on j.JobID = je.JobID 
 	 WHERE je.Serial = @Serial 
		AND je.MMD_ID = @MMD_ID

	IF @JobID IS NOT NULL
	 BEGIN
		RAISERROR('<b>Exception:<br>Device (%s - %s) is reserved for job %s <br> (Merchant: %s %s)</b><br>', 16, 1, @Serial, @MMD_ID, @JobID, @MerchantName, @MerchantCity)
		SELECT @CaseID = 8
		
		GOTO Exit_Handle
	 END

	SELECT @JobID = j.CallNumber,
		@MerchantName = j.Name,
		@MerchantCity = j.PostCode
	  FROM Calls j JOIN Call_Equipment je ON j.CallNumber = je.CallNumber
	 WHERE je.NewSerial = @Serial
		AND je.NewMMD_ID = @MMD_ID

	IF @JobID IS NOT NULL
	 BEGIN
		RAISERROR('<b>Exception:<br>Device (%s - %s) is reserved for job %s <br> (Merchant: %s %s)</b><br>', 16, 1, @Serial, @MMD_ID, @JobID, @MerchantName, @MerchantCity)
		SELECT @CaseID = 8
		
		GOTO Exit_Handle
	 END

	--case-3 : device was not scanned out of EE
	IF @Location = @BaseLocation
	 BEGIN

/*
--Stop it if it is not in transit ( #3877 UPDATING SERIALS NOT IN TRANSIT TO FSP'S)		

		SELECT @Condition = CASE WHEN @Condition In (18, 19, 20) THEN @Condition ELSE 20 END

		---Update current inventory record to Depot/19, 20
		EXEC @ret = dbo.spChangeInventoryConditionLocation 
			@Serial = @Serial,
			@MMD_ID = @MMD_ID,
			@NewCondition = @Condition,
			@NewLocation = @Depot,
			@Note = NULL,
			@AddedBy = @FSPOperatorNumber

*/
		SELECT @CaseID = 3
		
		GOTO Exit_Handle
	 END

	--case-4: device was at another location
	SELECT @CaseID = 4
	GOTO Exit_Handle
  END

 --multiple records
 IF @Count > 1
  BEGIN
	--verify if there is one with FSP location and in-transit
	SELECT @MMD_ID = MMD_ID,
		@Location = Location,
		@Condition = Condition,
		@LastLocation = LastLocation,
		@LastCondition = LastCondition
	  FROM	Equipment_Inventory
	 WHERE Serial = @Serial
		AND Location = @Depot
		AND Condition = 2

	--OK, unique record found, update device location/condition
	IF @@ROWCOUNT = 1
	 BEGIN
		---Update current inventory record to Depot/LastCondition
		EXEC @ret = dbo.spChangeInventoryConditionLocation 
			@Serial = @Serial,
			@MMD_ID = @MMD_ID,
			@NewCondition = @LastCondition,
			@NewLocation = @Depot,
			@Note = NULL,
			@AddedBy = @FSPOperatorNumber
	
		SELECT @CaseID = 1
	
		GOTO Exit_Handle
	 END
	
	SELECT @CaseID = 5      --Serial number was duplicated, MMD_ID to be confirmed	

	GOTO Exit_Handle
  END 
	

  --Case 6      Device was not in equipment inventory
  SELECT @CaseID = 6


Exit_Handle:
 INSERT tblTMPFSPStockReceivedLog (BatchID, Serial, MMD_ID, CaseID, ScanAtArrival)
	Values (@BatchID, @Serial, @MMD_ID, @CaseID, @CurDateTime)

 RETURN @@ERROR

GO

Grant EXEC on spWebAddFSPStockReceivedLog to eCAMS_Role
Go


Use WebCAMS
Go

Alter Procedure dbo.spWebAddFSPStockReceivedLog 
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
 EXEC @ret = Cams.dbo.spWebAddFSPStockReceivedLog 
		@UserID = @UserID,
		@BatchID = @BatchID,
		@Serial = @Serial

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

/*
select top 20 * from cams.dbo.tblTMPFSPStockReceivedLog order by logid desc

spWebAddFSPStockReceivedLog @UserID = 199513,
			@BatchID =5696,
		@Serial = '        53709250'

spWebAddFSPStockReceivedLog @UserID = 199513,
			@BatchID =5696,
		@Serial = '        74511325'


spWebAddFSPStockReceivedLog @UserID = 199513,
			@BatchID =5696,
		@Serial = '       A78557307'

*/
Go

Grant EXEC on spWebAddFSPStockReceivedLog to eCAMS_Role
Go
