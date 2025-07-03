Use CAMS
Go


Alter Procedure dbo.spPDAApplyExceptionRuleOnDeviceOut 
	(
		@JobID bigint,
		@MMD_ID varchar(5) OUTPUT,
		@Serial varchar(32) OUTPUT,
		@FSPOperatorNumber int,
		@IsDone bit OUTPUT
	)
	AS
--<!--$$Revision: 32 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/11/11 14:03 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAApplyExceptionRuleOnDeviceOut.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Apply the PDA exception rules to device out
--	10/10/2005: Added special case handling on the deviceout with the same merchantid but on different site
--	24/10/2005: Swapped Case 3 and Case 4 to process device in odds-and-ends first. (Task 521: Exception handling Adding devices to inventory - even if present in Odds and Ends)
DECLARE @ret int,
	@IsMoveFromOtherSite bit,
	@IsMoveFromOtherLocation bit,
	@IsAddToInventory bit,
	@JobClientID varchar(3),
	@JobTerminalID varchar(20),
	@ClientID varchar(3),
	@TerminalID varchar(20),
	@Memo varchar(1000),
	
	@SoftwareVersion varchar(20),
	@HardwareRevision varchar(20),
	
	@SESerial varchar(32),

	@Is3DES bit,
	@IsEMV bit,

	@Count int,

	@IsValid bit,

	@MerchantID varchar(16),
	@CRLF varchar(2),
	@Signature varchar(50)




 --init
 SELECT @IsDone = 0,
	@Is3DES = 0,  
	@IsEMV = 0,
	@IsValid = 0,
	@CRLF = CHAR(13) + CHAR(10),
	@Signature = CONVERT(varchar, GETDATE(), 103) + ' ' + CONVERT(varchar, GETDATE(), 108) + ' (' + CAST(@FSPOperatorNumber as varchar) + ')' + @CRLF


 IF LEN(@JobID) = 11
	SELECT @JobClientID = ClientID,
		@JobTerminalID = TerminalID
	  FROM Calls
	 WHERE CallNumber = @JobID
 ELSE
	SELECT @JobClientID = ClientID,
		@JobTerminalID = CASE WHEN JobTypeID = 3 THEN OldTerminalID
					ELSE TerminalID END
	  FROM IMS_Jobs
	 WHERE JobID = @JobID

--CBA case: no siet equipment provided, we have to check inventory record first
if @JobClientID = 'CBA'
 begin
	if exists(select 1 from Equipment_Inventory with (nolock) where Serial = @Serial and ClientID = @JobClientID)
	 begin
		select @MMD_ID = MMD_ID
		 from Equipment_Inventory with (nolock) 
			where Serial = @Serial and ClientID = @JobClientID
	 end
 end


 --first, verify serial number format
 EXEC  dbo.spVerifySerialFormat @Serial = @Serial, 
				@MMD_ID = @MMD_ID, 
				@IsValid = @IsValid OUTPUT

 --return if the serial number format is invalid
 IF @IsValid = 0
  BEGIN
	GOTO Exit_Handle
  END


 --get rule
 SELECT @IsMoveFromOtherSite = IsMoveFromOtherSite,
	@IsMoveFromOtherLocation = IsMoveFromOtherLocation,
	@IsAddToInventory = IsAddToInventory
   FROM tblPDAExceptionRuleOnDeviceOut
  WHERE MMD_ID = @MMD_ID
	AND LEN(LTRIM(@Serial)) = SerialLength
	AND LTRIM(@Serial) BETWEEN SerialFrom AND SerialTo

 SELECT @Count = @@ROWCOUNT

 --Start Transaction
 DECLARE @bInCallerTransaction bit
 SET @bInCallerTransaction = @@TRANCOUNT
 IF @bInCallerTransaction = 0
	BEGIN TRAN

 --is it in the rule
 IF @Count > 0
  BEGIN

	/* ***case 1 ***
	If device on other site then
		if MoveFromOtherSite = 1 then
			Move from other site to this site with notes
			set @IsDone = 1
			return
		end if
	end if
	*/
	IF @IsMoveFromOtherSite = 1 
	 BEGIN
		--get site equipment details
		SELECT @ClientID = ClientID,
			@TerminalID = TerminalID,
			@SoftwareVersion = SoftwareVersion,
			@HardwareRevision = HardwareRevision,
			@Is3DES = Is3DES,
			@IsEMV = IsEMV
		  FROM Site_Equipment
		  WHERE Serial = @Serial
			AND MMD_ID = @MMD_ID

		IF @@ROWCOUNT > 0
		 BEGIN
			--'Delete the Site Equipment record
			DELETE Site_Equipment
	                  WHERE Serial = @Serial
				AND MMD_ID = @MMD_ID
	
			SELECT @ret = @@ERROR
			IF @ret <> 0 
				GOTO RollBack_Handle
	
	
			--Add Site Notes
			SELECT @Memo = 'Device MMD [' + @MMD_ID + '] Serial [' + ltrim(@Serial) + '] removed from site ' + @TerminalID + 
						' ref job: <' + CAST(@JobID as varchar) + '> ' + @Signature


			SELECT @ret = @@ERROR
			IF @ret <> 0 
				GOTO RollBack_Handle
	
			EXEC @ret = spAddNotesToSite 
					@ClientID = @ClientID,
					@TerminalID = @TerminalID,
					@NewNotes = @Memo
	
			IF @ret <> 0 
				GOTO RollBack_Handle
	
	
	
			--add this device to Job site
			EXEC @ret = spAddMissingDeviceToSiteEquipment
				@JobID = @JobID,
				@MMD_ID = @MMD_ID,
				@Serial = @Serial,
				@SoftwareVersion = @SoftwareVersion,
				@HardwareRevision = @HardwareRevision,
				@Is3DES = @Is3DES,
				@IsEMV = @IsEMV,
				@OperatorNumber = @FSPOperatorNumber
	
	
			IF @ret <> 0 
				GOTO RollBack_Handle
	
			--set the return value		
			SET @IsDone = 1
	
			--log this
			INSERT tblPDAExceptionRuleLog (JobID, MMD_ID, Serial, CaseID) 
				Values(@JobID, @MMD_ID, @Serial, 1)
	
			--return
			GOTO Return_Handle
			
	    	 END --on site?

	 END --IF @IsMoveFromOtherSite = 1 


	/* ***case 2 ***
	if device in inventory then --case 8100/99 TELSTRA PRIOR TO EE HANDOVER
		if MoveFromOtherLocation =1 then
			set this device into this site with notes
			delete from inventory
			set @IsDone =1
			return
		end if
	end if
	*/
	IF @IsMoveFromOtherLocation = 1
	 BEGIN
		--Get details from equipment inventory
		SELECT
			@SoftwareVersion = SoftwareVersion,
			@HardwareRevision = HardwareRevision,
			@Is3DES = Is3DES,
			@IsEMV = IsEMV
		  FROM Equipment_Inventory
		 WHERE Serial = @Serial 
			AND MMD_ID = @MMD_ID

		IF @@ROWCOUNT > 0
		 BEGIN
	
			--add this device to Job site
			EXEC @ret = spAddMissingDeviceToSiteEquipment
				@JobID = @JobID,
				@MMD_ID = @MMD_ID,
				@Serial = @Serial,
				@SoftwareVersion = @SoftwareVersion,
				@HardwareRevision = @HardwareRevision,
				@Is3DES = @Is3DES,
				@IsEMV = @IsEMV,
				@OperatorNumber = @FSPOperatorNumber
	
	
			IF @ret <> 0 
				GOTO RollBack_Handle
	
			DELETE Equipment_Inventory
				WHERE Serial = @Serial
					AND MMD_ID = @MMD_ID
	
			SELECT @ret = @@ERROR
	
	
			IF @ret <> 0 
				GOTO RollBack_Handle
	
			--set the return value		
			SET @IsDone = 1
	
			--log this
			INSERT tblPDAExceptionRuleLog (JobID, MMD_ID, Serial, CaseID) 
				Values(@JobID, @MMD_ID, @Serial, 2)
	
	
			--return
			GOTO Return_Handle
			
		 END --in inventory?
	  END --IF @IsMoveFromOtherLocation = 1


	/* ***case 4 ***
	if device in Odds and Ends then
		if MoveFromOtherLocation =1 then
			set device into this site with notes
			delete from Odds and Ends
			set @IsDone = 1
			return
		end if
	end if
	*/

	IF @IsMoveFromOtherLocation = 1
	 BEGIN
		--Get version
		SELECT
			@SoftwareVersion = SoftwareVersion,
			@HardwareRevision = HardwareRevision,
			@Is3DES = Is3DES,
			@IsEMV = IsEMV
		  FROM Equipment_Odds_And_Ends
		 WHERE Serial = @Serial 
			AND MMD_ID = @MMD_ID

		IF @@ROWCOUNT > 0
		 BEGIN
	
			--add this device to Job site
			EXEC @ret = spAddMissingDeviceToSiteEquipment
				@JobID = @JobID,
				@MMD_ID = @MMD_ID,
				@Serial = @Serial,
				@SoftwareVersion = @SoftwareVersion,
				@HardwareRevision = @HardwareRevision,
				@Is3DES = @Is3DES,
				@IsEMV = @IsEMV,
				@OperatorNumber = @FSPOperatorNumber
	
	
			IF @ret <> 0 
				GOTO RollBack_Handle
	
			DELETE Equipment_Odds_and_Ends
				WHERE Serial = @Serial
					AND MMD_ID = @MMD_ID
	
			SELECT @ret = @@ERROR
	
	
			IF @ret <> 0 
				GOTO RollBack_Handle
	
			--set the return value		
			SET @IsDone = 1
	
			--log this
			INSERT tblPDAExceptionRuleLog (JobID, MMD_ID, Serial, CaseID) 
				Values(@JobID, @MMD_ID, @Serial, 4)
	
			--return
			GOTO Return_Handle
			
		 END --in Equipment_Odds_and_Ends?
	 END --IF @IsMoveFromOtherLocation = 1

	/* ***case 3 ***
	if device in equipment history then 
		if MoveFromOtherLocation =1 then
			set this device into this site with notes
			set @IsDone =1
			return
		end if
	end if
	*/
	IF @IsMoveFromOtherLocation = 1 
	 BEGIN
		--Get version - for the latest record of the history
		SELECT TOP 1
			@SoftwareVersion = SoftwareVersion,
			@HardwareRevision = HardwareRevision,
			@Is3DES = Is3DES,
			@IsEMV = IsEMV
		  FROM Equipment_History
		 WHERE Serial = @Serial 
			AND MMD_ID = @MMD_ID
		 ORDER BY DateIn DESC

		IF @@ROWCOUNT > 0
		 BEGIN
			
			--add this device to Job site
			EXEC @ret = spAddMissingDeviceToSiteEquipment
				@JobID = @JobID,
				@MMD_ID = @MMD_ID,
				@Serial = @Serial,
				@SoftwareVersion = @SoftwareVersion,
				@HardwareRevision = @HardwareRevision,
				@Is3DES = @Is3DES,
				@IsEMV = @IsEMV,
				@OperatorNumber = @FSPOperatorNumber
	
	
			IF @ret <> 0 
				GOTO RollBack_Handle
	
			--set the return value		
			SET @IsDone = 1
	
			--log this
			INSERT tblPDAExceptionRuleLog (JobID, MMD_ID, Serial, CaseID) 
				Values(@JobID, @MMD_ID, @Serial, 3)
	
			--return
			GOTO Return_Handle
			
		 END --in equipment history?
	 END --IF @IsMoveFromOtherLocation = 1 

	/* ***case 5 ***
	if AddDeviceToInventory =1 then
		set device into this site with notes
		add to new stock history (restrict by new stock mmd rule as well)
		set @IsDone = 1
		return
	end if
	*/

	IF @IsAddToInventory = 1
	 BEGIN
		--add this device to Job site
		EXEC @ret = spAddMissingDeviceToSiteEquipment
			@JobID = @JobID,
			@MMD_ID = @MMD_ID,
			@Serial = @Serial,
			@SoftwareVersion = @SoftwareVersion,
			@HardwareRevision = @HardwareRevision,
			@Is3DES = @Is3DES,
			@IsEMV = @IsEMV,
			@OperatorNumber = @FSPOperatorNumber


		IF @ret <> 0 
			GOTO RollBack_Handle

		--set the return value		
		SET @IsDone = 1

		--log this
		INSERT tblPDAExceptionRuleLog (JobID, MMD_ID, Serial, CaseID) 
			Values(@JobID, @MMD_ID, @Serial, 5)

		--return
		GOTO Return_Handle

	 END --@IsAddToInventory = 1

  END --is it in the rule


 --ok, process special case
 --Special Case 1: Device-out is on the other site with the same merchantID, we will swap these two devices
 SELECT @ClientID = ClientID,
	@TerminalID = TerminalID
   FROM Site_Equipment
  WHERE Serial = @Serial
	AND MMD_ID = @MMD_ID

 --found a unique record
 IF @@ROWCOUNT = 1
  BEGIN
	--verify if there is a similar device existing on site of JobClientID/JobTerminalID 
	SELECT @SESerial = Serial
	  FROM Site_Equipment
	 WHERE ClientID = @JobClientID
		AND TerminalID = @JobTerminalID
		AND MMD_ID = @MMD_ID
	--yes, unique record found, verify if these devices have the same merchant id
	IF @@ROWCOUNT = 1
	 BEGIN
		SELECT @MerchantID = MerchantID
		  FROM Sites
		 WHERE ClientID = @ClientID
			AND TerminalID = @TerminalID

		IF EXISTS(SELECT 1 FROM Sites WHERE ClientID = @JobClientID 
							AND TerminalID = @JobTerminalID
							AND MerchantID = @MerchantID)
		 BEGIN
			--yes, the devices have the same merchant id, let's swap them
			UPDATE Site_Equipment
			   SET Serial = @SESerial
			  WHERE ClientID = @ClientID
				AND TerminalID = @TerminalID
				AND Serial = @Serial
				AND MMD_ID = @MMD_ID

			SELECT @ret = @@ERROR
			IF @ret <> 0 
				GOTO RollBack_Handle

			UPDATE Site_Equipment
			   SET Serial = @Serial
			 WHERE ClientID = @JobClientID
				AND TerminalID = @JobTerminalID
				AND Serial = @SESerial
				AND MMD_ID = @MMD_ID

			SELECT @ret = @@ERROR
			IF @ret <> 0 
				GOTO RollBack_Handle

			--Add Site Notes
			SELECT @Memo = 'Device MMD [' + @MMD_ID + '] Serial [' + ltrim(@Serial) + '] found on site ' + @TerminalID + 
						' ref job: <' + CAST(@JobID as varchar) + '> ' + @Signature
	
			SELECT @ret = @@ERROR
			IF @ret <> 0 
				GOTO RollBack_Handle
	
			EXEC @ret = spAddNotesToSite 
					@ClientID = @JobClientID,
					@TerminalID = @JobTerminalID,
					@NewNotes = @Memo
	
			IF @ret <> 0 
				GOTO RollBack_Handle

			SELECT @Memo = 'Device MMD [' + @MMD_ID + '] Serial [' + ltrim(@SESerial) + '] found on site ' + @JobTerminalID + 
						' ref job: <' + CAST(@JobID as varchar) + '> ' + @Signature
	
			SELECT @ret = @@ERROR
			IF @ret <> 0 
				GOTO RollBack_Handle
	
			EXEC @ret = spAddNotesToSite 
					@ClientID = @ClientID,
					@TerminalID = @TerminalID,
					@NewNotes = @Memo
	
			IF @ret <> 0 
				GOTO RollBack_Handle

		
			--set the return value		
			SET @IsDone = 1
		
			--log this
			INSERT tblPDAExceptionRuleLog (JobID, MMD_ID, Serial, CaseID) 
				Values(@JobID, @MMD_ID, @Serial, 8)
		
			--return
			GOTO Return_Handle

	   	 END
	 END
		
  END


 --Special Case 2: CTX, match the right 5 digit on serial number
 IF @JobClientID = 'CTX'
  BEGIN
	--check if the right 5 digit serial matching the site device
	SELECT @SESerial = Serial
	  FROM Site_Equipment
	 WHERE ClientID = @JobClientID
		AND TerminalID = @JobTerminalID
		AND RIGHT(Serial, 5) = RIGHT(@Serial, 5)
		AND MMD_ID = @MMD_ID


	--found only ONE device
	IF @@ROWCOUNT = 1
	 BEGIN
		--set the return value		
		SET @IsDone = 1

		--log this
		INSERT tblPDAExceptionRuleLog (JobID, MMD_ID, Serial, CaseID) 
			Values(@JobID, @MMD_ID, @Serial, 6)

		--return the new serial number
		SELECT @Serial = @SESerial

		--return
		GOTO Return_Handle
		
	 END

  END	--it is CTX job


Return_Handle:

 --Commit
 IF @bInCallerTransaction = 0
	COMMIT TRAN


Exit_Handle:

 RETURN @ret

RollBack_Handle:
 IF @bInCallerTransaction = 0
	ROLLBACK TRAN

 GOTO Exit_Handle

/*

declare @d bit


exec spPDAApplyExceptionRuleOnDeviceOut 
		@JobID = 220593,
		@MMD_ID = 'WINP1',
		@Serial = '         1911037',
		@FSPOperatorNumber =-111,
		@IsDone = @d OUTPUT
select @d


*/


GO

Grant EXEC on spPDAApplyExceptionRuleOnDeviceOut to eCAMS_Role
Go


