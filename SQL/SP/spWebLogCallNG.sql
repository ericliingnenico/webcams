USE CAMS
Go

if object_id('spWebLogCallNG') is null
	exec ('create procedure dbo.spWebLogCallNG as return 1')
go

Alter PROCEDURE dbo.spWebLogCallNG 
	(
		@UserID int,
		@CallNumber			varchar(11) OUTPUT,
		@ProblemNumber			varchar(20),
		@ClientID			varchar(3),
		@MerchantID			varchar(16),
		@TerminalID			varchar(20),
		@SpecInstruct			varchar(100),
	
		@Name				varchar(50),
		@Address			varchar(50),
		@Address2			varchar(50),
		@City				varchar(50),
		@State				varchar(3),
		@Postcode			varchar(10),
		@Contact			varchar(50),
		@PhoneNumber			varchar(20),
		@MobileNumber			varchar(15),
		@LineType			varchar(20),
		@DialPrefix		varchar(5),

		@CallTypeID		int,
		@SymptomID		int,
		@FaultID		int,
		@BusinessActivity		varchar(40),

		@Urgent			bit,

		@TradingHoursMon varchar(15),
		@TradingHoursTue varchar(15),
		@TradingHoursWed varchar(15),
		@TradingHoursThu varchar(15),
		@TradingHoursFri varchar(15),
		@TradingHoursSat 	varchar(15),
		@TradingHoursSun 	varchar(15),
		@UpdateSiteTradingHours bit,

		@ConfigXML varchar(4000),
		@AdditionalServiceTypeID int,

		@JobNote		varchar(400),
		@SwapComponent varchar(200),
		@CAIC varchar(20)
	)
	AS
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 27/10/15 13:58 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebLogCallNG.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Log a call
*/
 SET NOCOUNT ON
 DECLARE @ret int,
	@RegionID	tinyint,
	@SiteNote varchar(60),
	@RequestReceivedDateTime DateTime,
	@CallNote		varchar(4000),
	@FaultNote	varchar(4000),
	@TradingHoursInfo varchar(200),
	@SpecialNotes varchar(6000),
	@EquipmentCode		varchar(10),
	@MaintenanceCode varchar(6),
	@SeverityID	tinyint,
	@AdditionalServiceAmount money,
	@RelatedCAMSJobID varchar(11),
	@RequiredDatetime datetime,
	@RequiredDatetimeOffset int,
	@RequestDateTimeMerchantLocal datetime,
	@JobTypeID tinyint,
	@IsJABAutoBookingOK 	bit,
	@ProposedFSP 		int,
	@ParentPickpackDepotLocation int,
	@ClientSLADateTime 	datetime,
	@AgentSLADateTime 	datetime,
	@MerchantDateTimeOffset int,
	@VerifyAutoBooking bit,
	@SwapPartsOnly bit,	
	@MMD_ID varchar(5),
	@MMDList varchar(200),
	@ProjectNo varchar(20),
	@Component varchar(50),
	@ConfigFieldNote varchar(1000),
	@LogID int,
	@UploadLogID bigint,--negative CallNumber for reference
	@LoggedBy	smallint,
	@DeviceType			varchar(15)




 --validation
 --verify if the user has right to log call for this client
 if not EXISTS(SELECT 1 FROM UserClientDeviceType where UserID = @UserID and ClientID = @ClientID)
  begin
	raiserror('You do not have permission to log job on this client. Aborted.', 16, 1)
	goto Exit_Handle
  end

 SELECT @JobTypeID = 4
 IF @AdditionalServiceTypeID IS NOT NULL
  BEGIN
	SELECT @JobTypeID = 5
  END

 EXEC @ret = dbo.spWebValidateTIDBeforeLogJobNG  @UserID = @UserID, @ClientID = @ClientID, @TerminalID = @TerminalID, @JobTypeID = @JobTypeID
 IF @ret <> 0
	GOTO Exit_Handle

 --verify if the trading hours OK
 IF dbo.fnIsTradingHoursLongEnough(@TradingHoursMon) = 0 OR
	dbo.fnIsTradingHoursLongEnough(@TradingHoursTue) = 0 OR
	dbo.fnIsTradingHoursLongEnough(@TradingHoursWed) = 0 OR
	dbo.fnIsTradingHoursLongEnough(@TradingHoursThu) = 0 OR
	dbo.fnIsTradingHoursLongEnough(@TradingHoursFri) = 0
  BEGIN
		RAISERROR('TradingHours was too short. It must be greater than 1 hour. Aborted.', 16, 1)
		SELECT @ret = -1
		GOTO Exit_Handle
  END


--OK, user can log the call
--convert @LoggedBy via @UserID
SELECT @LoggedBy = dbo.fnToggleWebUserID(@UserID)
	
	

 --init
 SELECT @RequestReceivedDateTime =  dbo.fnGetDate(),
	@CallNote = '',
	@FaultNote = '',
	@SpecialNotes = '',
	@JobTypeID = 4,
	@VerifyAutoBooking = 0,
	@SwapPartsOnly = 0,
	@MMDList = ''




 --set JobTypeID: 4 -- swap, 5--Additional service (SymptomID = 800 or FaultID = 2225
 --Validation rules in spWebValidateTIDBeforeLogJob are different for SWAP and AdditionalService
  IF @AdditionalServiceTypeID IS NOT NULL
  BEGIN
	SELECT @JobTypeID = 5
  END


 --Set PriorityID
 IF @Urgent = 1
	SELECT @SeverityID = 2  --critical
 ELSE
	SELECT @SeverityID = 4 --significant

 select @DeviceType = DeviceType
	from Sites with (nolock)
	where ClientID = @ClientID and TerminalID = @TerminalID

 
 --get RegionID
 SELECT @RegionID =  dbo.fnGetRegionOfClientContractPostcode(@ClientID, @DeviceType, @Postcode, @City, @State)


 --get Request datetime in Merchant local time zone
 SELECT	@RequestDateTimeMerchantLocal = DateAdd(mi, dbo.fnGetTimeZoneOffset(@State, @RequestReceivedDateTime), @RequestReceivedDateTime)

 --check if it is additional service
 IF @AdditionalServiceTypeID IS NOT NULL
  BEGIN
	--Set Symptom/Fault for additional service
	SELECT @SymptomID = 800, 
		@FaultID = 2225

	SELECT @AdditionalServiceAmount = AdditionalServiceAmount
	  FROM vwAdditionalServiceType 
	 WHERE ClientID = @ClientID
		AND AdditionalServiceTypeID = @AdditionalServiceTypeID

	--no row found, log eeror into call note
	IF @AdditionalServiceAmount IS NULL
	  BEGIN
		SELECT @CallNote = @CallNote + 'CAMS can not find a matching AdditionalServiceAmount.' + dbo.fnCRLF()
	  END

  END

 --no matching Symptom/Fault
 IF @FaultID IS NULL OR @SymptomID IS NULL
  BEGIN
	SELECT @CallNote = @CallNote + 'CAMS can not find a matching Symptom/Fault.' + dbo.fnCRLF()
  END
	

 --get CallTypeID based on Site equipmentcode
 --try to find it in Site_Maintenance table
 --work out equipment code and maintenance code if site maintenance doesn't exist
 IF EXISTS(SELECT 1 FROM Site_Maintenance WHERE ClientID = @ClientID 
							and TerminalID = @TerminalID
							and TerminalNumber = '01')
  BEGIN
	SELECT @EquipmentCode = EquipmentCodes,
		@MaintenanceCode = MaintenanceCode
		FROM Site_Maintenance 
			WHERE ClientID = @ClientID 
				and TerminalID = @TerminalID
				and TerminalNumber = '01'

	 SELECT @ret = @@ERROR
	 IF @ret <> 0 
		GOTO RollBack_Handle

  END

 IF @CallTypeID IS NULL
  BEGIN

	 IF LEN(@EquipmentCode) = 2
	  BEGIN
		--parse CallType
		SELECT @CallTypeID = CallTypeID
		  FROM vwDeviceCallType 
		 WHERE EquipmentCode = @EquipmentCode
			AND IsActive = 1
	
	  END
	 ELSE
	  BEGIN
		--parse CallType and no equipmentcode found, find it in tblDefaultMaintAndEqCode using devicetype
		SELECT @CallTypeID = c.CallTypeID
		  FROM vwDeviceCallType c JOIN tblDefaultMaintAndEqCode ec ON c.EquipmentCode = ec.EquipmentCode
		 WHERE ec.ClientID = @ClientID 
			AND ec.DeviceType = @DeviceType
			AND c.IsActive = 1
	
	  END
  END

 --STILL no matching CallType
 IF @CallTypeID IS NULL
  BEGIN
	SELECT @CallNote = @CallNote + 'CAMS can not find a matching CallType.' + dbo.fnCRLF()
  END



 --build trading hours info
 SELECT @TradingHoursInfo = dbo.fnGetTradingHoursInfo(@TradingHoursMon,
													@TradingHoursTue,
													@TradingHoursWed,
													@TradingHoursThu,
													@TradingHoursFri,
													@TradingHoursSat,
													@TradingHoursSun)
 IF LEN(@TradingHoursInfo) > 0
  BEGIN
	SELECT @CallNote = @CallNote + dbo.fnEncodeNote(3, @TradingHoursInfo) + dbo.fnCRLF(),
		@FaultNote = @FaultNote + 'Trading Hours: ' + @TradingHoursInfo + dbo.fnCRLF()

  END

 --build extra attributes
 SELECT @SpecialNotes =  CASE WHEN ISNULL(@LineType, '') <> '' THEN 'LineType: ' + ISNULL(@LineType, '') + dbo.fnCRLF() 
				ELSE '' END +
			CASE WHEN ISNULL(@DialPrefix, '') <> '' THEN 'DialPrefix: ' + ISNULL(@DialPrefix, '') + dbo.fnCRLF() 
				ELSE '' END

 --Convert ConfigXML to readable string
 IF LEN(@ConfigXML) > 0 
  BEGIN
 	SELECT @SpecialNotes = @SpecialNotes + 'Features required:' + dbo.fnConvertConfigXMLToText(@ConfigXML) + dbo.fnCRLF()
  END

 --check if the swap components selected, if so, add to fsp notes
 SELECT @SwapComponent = ISNULL(@SwapComponent, '')
 IF LEN(@SwapComponent) > 0 
  BEGIN
	SELECT @FaultNote = @FaultNote  + ' Please swap: '+ @SwapComponent + dbo.fnCRLF()
  END

 --NAB things
 IF @ClientID = 'NAB'
  BEGIN
	IF LEN(@SwapComponent) > 0 
	 BEGIN

		--check if VAS ticked
		--25	VAS
		SELECT @Component = ',' + Component + ','
			FROM tblComponent
			WHERE ComponentID = 25

		IF CHARINDEX(@Component, ','+@SwapComponent+',')>0
		 BEGIN
			SELECT @ProjectNo = 'NAB TAFMO USB'
		 END
		ELSE
		 BEGIN
			--check if Health ticked
			--26	Health
			SELECT @Component = ',' + Component + ','
				FROM tblComponent
				WHERE ComponentID = 26

			IF CHARINDEX(@Component, ','+@SwapComponent+',')>0
			 BEGIN
				SELECT @ProjectNo = 'NAB TAFMO USB'
			 END
		 END

		IF @ProjectNo = 'NAB TAFMO USB'
 			SELECT @FaultNote = @FaultNote  + ' PLEASE USE DEVICE WITH TAFMO SOFTWARE VERSION.'+ dbo.fnCRLF()


	 END --IF LEN(@SwapComponent) > 0 
	
	--check if it is building society
	if exists(select 1 from tblProjectTID t join tblProject p on t.ProjectID = p.ProjectID 
				where t.ProjectID in (43, 44, 45) and t.OldTerminalID = @TerminalID and p.IsActive = 1)  --only active project
	 begin
		select @ProjectNo = p.ProjectNo,
				@FaultNote = @FaultNote  +  isnull(dbo.fnGetXMLValue(p.ClosureXML, 'SiteSpCond'), '')+ dbo.fnCRLF()
			 from tblProjectTID t join tblProject p on t.ProjectID = p.ProjectID 
				where t.ProjectID in (43, 44, 45) and t.OldTerminalID = @TerminalID
	 end	

  END -- IF @ClientID = 'NAB'

 --add extra notes into JobNote
 IF LEN(@SpecialNotes) > 0
  BEGIN
	 SELECT @CallNote = @CallNote + @SpecialNotes + dbo.fnCRLF()
	 SELECT @FaultNote = @FaultNote + @SpecialNotes + dbo.fnCRLF() 
  END 

 --embed the job note as xml tag for call viewer to parse
 IF ISNULL(@JobNote, '') <> ''
  BEGIN
	 SELECT @CallNote = @CallNote + @JobNote + dbo.fnCRLF()
	 SELECT @FaultNote = @FaultNote + @JobNote + dbo.fnCRLF() 
  END 
 IF ISNULL(@SpecInstruct, '') <> ''
  BEGIN
	 SELECT @CallNote = @CallNote + @SpecInstruct + dbo.fnCRLF()
  END 
 IF LEN(@SwapComponent) > 0 
  BEGIN
	 SELECT @CallNote = @CallNote + dbo.fnEncodeNote(4, @SwapComponent) + dbo.fnCRLF()
  END


 --get related cams open job id/call number, used for addtional service request
 SELECT @RelatedCAMSJobID = JobID 
   FROM IMS_Jobs
  WHERE TerminalID = @TerminalID

 IF @RelatedCAMSJobID IS NULL
  BEGIN
	SELECT @RelatedCAMSJobID = CallNumber
	  FROM Calls
	 WHERE TerminalID = @TerminalID

  END

 IF @RelatedCAMSJobID IS NOT NULL
  BEGIN
	SELECT @CallNote = @CallNote + 'There is an open ' + CASE WHEN LEN(@RelatedCAMSJobID) = 11 THEN 'call ' ELSE 'job ' END +
				@RelatedCAMSJobID + ' on this TID' + dbo.fnCRLF()
  END


 --we still need to calculate the datetime
 SELECT @RequiredDatetime = dbo.fnCalculateSLADateForCall(@ClientID, 
																@RegionID,
																null,
																@State, 
																@RequestDateTimeMerchantLocal,
																@TradingHoursMon, 
																@TradingHoursTue, 
																@TradingHoursWed, 
																@TradingHoursThu, 
																@TradingHoursFri, 
																@TradingHoursSat, 
																@TradingHoursSun)

 SELECT @RequiredDatetimeOffset = dbo.fnGetTimeZoneOffset(@State, @RequiredDatetime)

 --convert @RequiredDateTime to CAMS time zone
 SELECT	@RequiredDatetime = DateAdd(mi, 0-@RequiredDatetimeOffset, @RequiredDatetime)

 --Get New Call Number
 EXEC @ret = spGetNewCallNumber @CallNumber = @CallNumber OUTPUT
 IF @ret <> 0 
	GOTO Exit_Handle

 --call exists, abort
 IF EXISTS(SELECT 1 FROM Calls WHERE CallNumber = @CallNumber)
  BEGIN
	RAISERROR('Call (CallNo.: %s) exists, abort', 16, 1, @CallNumber)
 	SELECT @ret = -1
	GOTO Exit_Handle
  END

 --Start Transaction
 DECLARE @bInCallerTransaction bit
 SET @bInCallerTransaction = @@TRANCOUNT
 IF @bInCallerTransaction = 0
	BEGIN TRAN



  --log the call
 INSERT Calls (
		CallNumber, 
		ClientID,
        TerminalID,
        TerminalNumber,
        ProblemNumber,
        MerchantID,
        SiteNumber,
        ReceivedDateTime,

        [Name],
        Postcode,
        Caller,
        CallerPhone,

        SpecialConditions1,
        SpecialConditions2,

        EquipmentCodes,
        MaintenanceCode,

        CallTypeID,
		SymptomID,
		FaultID,

		SeverityID,

        LoggedDateTime,
        LoggedBy,

		RequiredDatetime,
		RequiredDateTimeOffset,
		AgentSLADateTime,
		AgentSLADateTimeOffset,
		DueDateTime,
		DueDateTimeOffset,


		State,
	    RegionID,
		StatusID,
		BusinessActivity,
		AdditionalServiceTypeID,
		AdditionalServiceAmount,
		ProjectNo)
   SELECT
		@CallNumber, 
		@ClientID,
        @TerminalID,
        '01',
        @ProblemNumber,
        @MerchantID,
        left(@TerminalID, 10),  --@SiteNumber
        @RequestReceivedDateTime,

        @Name,
        @Postcode,
        @Contact,
        @PhoneNumber,

        Left(@SpecInstruct,60),
        substring(@SpecInstruct,61,60),

        @EquipmentCode,
        @MaintenanceCode,

        @CallTypeID,
		@SymptomID,
		@FaultID,

		@SeverityID,

        @RequestReceivedDateTime,
        @LoggedBy,

		@RequiredDatetime,
		@RequiredDatetimeOffset,
		@RequiredDatetime,
		@RequiredDatetimeOffset,
		@RequiredDatetime,
		@RequiredDatetimeOffset,

		@State,
        @RegionID,
		1, --'NEW'
		@BusinessActivity,
		@AdditionalServiceTypeID,
		@AdditionalServiceAmount,
		@ProjectNo

 SELECT @ret = @@ERROR
 IF @ret <> 0 
	GOTO RollBack_Handle

 --get serial number based on the devicecomponent which NAB web user selected
 SELECT DISTINCT c.MMDs, c.IsAutoBooking INTO #MyMMD FROM vwDeviceComponent c WITH (NOLOCK) join vwDeviceCallType d WITH (NOLOCK) on c.EquipmentCode = d.EquipmentCode
	WHERE d.CallTypeID = @CallTypeID AND c.Component IN (SELECT * FROM dbo.fnConvertListToTable(@SwapComponent))
 

 IF EXISTS(SELECT 1 FROM #MyMMD) AND NOT EXISTS(SELECT 1 FROM #MyMMD WHERE IsAutoBooking = 0 AND MMDs IS NOT NULL)
  BEGIN
	--web user has selected some components and IsAutoBooking is OK
	--so we need to check if there is any serialised device need to be swapped out
	IF NOT EXISTS(SELECT 1 FROM #MyMMD WHERE MMDs IS NOT NULL)
	 BEGIN
		--swap parts only and they are all flaged as auto booking, so no need to verify serialised device, just book the FSP
		SELECT @SwapPartsOnly = 1
	 END
	ELSE
	 BEGIN
		--need to swap some serialised device
		SELECT se.Serial, 
				se.MMD_ID, 
				se.SoftwareVersion, 
				se.HardwareRevision,
				se.Is3DES,
				se.IsEMV
			INTO #MySiteDevice
		FROM #MyMMD m JOIN Site_Equipment se WITH (NOLOCK) ON se.ClientID = @ClientID and se.TerminalID = @TerminalID and se.MMD_ID IN (SELECT * FROM dbo.fnConvertListToTable(m.MMDs))
		
		----check if the devices on site are matching device to be swapped
		--IF (SELECT Count(*) FROM #MySiteDevice) = (SELECT Count(*) FROM #MyMMD WHERE MMDs IS NOT NULL)
		-- BEGIN
			--add device to Call_Equipment
			INSERT Call_Equipment (
				CallNumber,
				Serial,
				MMD_ID,
				Is3DES,
				IsEMV,
				SoftwareVersion,
				HardwareRevision,
				Faulty,
				Swapped,
				NewMMD_ID,
				NewSerial)
			 SELECT  
				@CallNumber,
				Serial,
				MMD_ID,
				Is3DES,
				IsEMV,
				SoftwareVersion,
				HardwareRevision,
				1,
				0,
				MMD_ID,
				'CONFIRM01'
			 FROM #MySiteDevice
			
			--set @VerifyAutoBooking
			SELECT @VerifyAutoBooking = 1

			--Build MMD List
			WHILE EXISTS(SELECT 1 FROM #MySiteDevice)
			 BEGIN
				SELECT @MMD_ID = MMD_ID FROM #MySiteDevice
				SELECT @MMDList = @MMDList + @MMD_ID + ','
				DELETE #MySiteDevice WHERE MMD_ID = @MMD_ID
			 END

		 --END

	 END	
	
  END


 --CBA case: no device on site, set @SwapPartsOnly = 1 to allow auto booking
 IF @ClientID = 'CBA'
  begin
	insert Call_Equipment(CallNumber,
				Serial,
				MMD_ID,
				SoftwareVersion,
				Faulty,
				NewSerial,
				NewMMD_ID,
				NewSoftwareVersion,
				Swapped,
				FaultNote,
				HardwareRevision,
				NewHardwareRevision,
				Is3DES,
				IsEMV,
				NewIs3DES,
				NewIsEMV,
				StockReturnTypeID,
				StockReturnedDateTime,
				IsMerchantDamaged)
	select @CallNumber,
		Serial,
		MMD_ID,
		SoftwareVersion,
		1,
		'CONFIRM01',
		MMD_ID,
		NULL,
		0,
		NULL,
		NULL,
		NULL,
		0,
		0,
		0,
		0,
		0,
		NULL,
		0
	 from Site_Equipment
	 where ClientID = @ClientID and TerminalID = @TerminalID
	 
	if @@ROWCOUNT > 0
	 begin
		SELECT @MMDList = @MMDList + MMD_ID + ','
			from Call_Equipment
			where CallNumber = @CallNumber
	 end
  end

 --20/04/2012: Confirmed wiht NAM to allow JAB auto book
 SELECT @VerifyAutoBooking = 1
 
 --24/04/2012: Confirmed with Nam if no device selected, set to swappartsonly=1
 if @MMDList=''
  begin
	select @SwapPartsOnly = 1
  end
  
 --27/04/2012 Chris Lewis asked to stop auto-jab on FD call
 --#6467 SUBJECT: TURN OFF JAB AUTO BOOKING ON BOQ SWAP
 if @ClientID in ('FDM','WIR','MMS','PCT', 'BOQ', 'JPM', 'SUN')
  begin
	select @SwapPartsOnly = 0,
			@VerifyAutoBooking = 0
  end
  	
 IF @SwapPartsOnly = 1 OR @VerifyAutoBooking = 1
  BEGIN
	 --check if we can auto book the job
	 EXEC @ret = dbo.spVerifyAutoBooking
				@CAMSJobID = @CallNumber,
				@JobTypeID = 4, --'SWAP',
				@ClientID = @ClientID,
				@TerminalID = @TerminalID,
				@MerchantID = @MerchantID,
				@TerminalType = @DeviceType,
				@Suburb	= @City,
				@Postcode = @Postcode,
				@State = @State,
				@SpecialInstructions = '', --@SpecInstruct, --ignoer the special instruction  and leave FSP to handle it
				@SwapNote = NULL,
				@ArriveDateTime = @RequestReceivedDateTime,
				@TradingHoursMon = @TradingHoursMon,
				@TradingHoursTue = @TradingHoursTue,
				@TradingHoursWed = @TradingHoursWed,
				@TradingHoursThu = @TradingHoursThu,
				@TradingHoursFri = @TradingHoursFri,
				@TradingHoursSat = @TradingHoursSat,
				@TradingHoursSun = @TradingHoursSun,
				@ErrorCode = NULL,
				@MMDList = @MMDList,
				@SwapPartsOnly = @SwapPartsOnly,
				@SourceID = 'W',
				@IsJABAutoBookingOK = @IsJABAutoBookingOK OUTPUT,
				@ProposedFSP = @ProposedFSP OUTPUT,
				@ParentPickpackDepotLocation = @ParentPickpackDepotLocation OUTPUT,
				@ClientSLADateTime = @ClientSLADateTime OUTPUT,
				@AgentSLADateTime = @AgentSLADateTime OUTPUT

	 IF @ClientSLADateTime IS NOT NULL
		 BEGIN
			SELECT  @MerchantDateTimeOffset = dbo.fnGetTimeZoneOffset(@State, @ClientSLADateTime)

			--@ClientSLADateTime and @AgentSLADateTime are in Merchant local time zone, need to convert them to CAMS time zone
			SELECT	@ClientSLADateTime = DateAdd(mi, 0-@MerchantDateTimeOffset, @ClientSLADateTime),
				@AgentSLADateTime = DateAdd(mi, 0-@MerchantDateTimeOffset, @AgentSLADateTime)

			--set booking info
			UPDATE Calls
			  SET RequiredDateTime = @ClientSLADateTime,
				RequiredDateTimeOffset = @MerchantDateTimeOffset,
				AgentSLADateTime = CASE WHEN @IsJABAutoBookingOK = 1 THEN @AgentSLADateTime ELSE @ClientSLADateTime END,
				AgentSLADateTimeOffset = CASE WHEN @IsJABAutoBookingOK = 1 THEN @MerchantDateTimeOffset ELSE @MerchantDateTimeOffset END,
				StatusID = CASE WHEN @IsJABAutoBookingOK = 1 THEN 2 ELSE StatusID END,  ---'ASSIGNED'
				AssignedTo = CASE WHEN @IsJABAutoBookingOK = 1 THEN @ProposedFSP ELSE NULL END,
				SeverityID = CASE WHEN @IsJABAutoBookingOK = 1 THEN 4 ELSE NULL END,  --'4 - SIGNIFICANT'
				DueDateTime = @ClientSLADateTime,
				DueDateTimeOffset = @MerchantDateTimeOffset,
				AssignedBy = CASE WHEN @IsJABAutoBookingOK = 1 THEN @LoggedBy ELSE NULL END,
				AssignedDateTime = CASE WHEN @IsJABAutoBookingOK = 1 THEN @RequestReceivedDateTime ELSE NULL END,
				AllowPDADownload = @IsJABAutoBookingOK,
				AllowFSPWebAccess = @IsJABAutoBookingOK
			 WHERE CallNumber = @CallNumber

		 END

	 IF @IsJABAutoBookingOK = 1
		 BEGIN
			--log into tblJABBookingLog for JABFax to send the fax
			EXEC dbo.spPutJABBookingLog 
					@LogID	= NULL,
					@JobID	= @CallNumber,
					@BookedDateTime = @RequestReceivedDateTime,
					@Status	= 'O',
					@FaxedDateTime = NULL,
					@SourceID = 'W'

			--CBA Only
			if @ClientID = 'CBA'
			 begin
				if dbo.fnExtractFirstMobilePhoneNo(@PhoneNumber, @MobileNumber, null) <> ''
				 begin
					--check if devicetype matching sites'
					if exists(select 1 from Sites with (nolock) where ClientID = @ClientID and TerminalID	= @TerminalID and DeviceType = @DeviceType)
					 begin
						update Calls
							set ProjectNo = 'JAB_SMS'
							where CallNumber = @CallNumber

						select @UploadLogID = 0-cast(@CallNumber as bigint) --WebLogCall using negative call number

						--log for later process				
						insert tblJABSMSMerchantLog (
								UploadLogID,
								JobID,
								NextFollowupDateTime,
								StatusID,
								LoggedDateTime)
							select 
								@UploadLogID, --WebLogCall using negative call number
								@CallNumber,
								DateAdd(mi, @MerchantDateTimeOffset, @AgentSLADateTime), --convert to merchant local time
								1, --Pending to send SMS
								GETDATE()
					 end --check if devicetype matching sites'
				 end --if dbo.fnExtractFirstMobilePhoneNo(@PhoneNumber, @MobileNumber,null) <> ''
			 end --1=1 if GETDATE() between '2013-09-09' and '2014-09-09'

		 END

  END


 --Build note
 SELECT @SiteNote = 'ADDED FROM WEB JOB LOGGER JobID: ' + @CallNumber

 --put site
 EXEC @ret = dbo.spJABPutSite
		@ClientID = @ClientID,
		@TerminalID = @TerminalID,
		@MerchantID	= @MerchantID,
		@SiteNumber = @TerminalID,
		@DeviceType = @DeviceType,
		@BusinessActivity = @BusinessActivity,
		@Name	= @Name,
		@Address = @Address,
		@Address2 = @Address2,
		@City = @City,
		@State	= @State,
		@Postcode = @Postcode,
		@Contact = @Contact,
		@PhoneNumber = @PhoneNumber,
		@PhoneNumber2 = @MobileNumber,
		@TerminalNumber = null,
		@TransendID = null,
		@CatID	= null,
		@CAIC = @CAIC,
		@RegionID  = @RegionID,
		@Note = @SiteNote,
		@TradingHoursMon = @TradingHoursMon,
		@TradingHoursTue = @TradingHoursTue,
		@TradingHoursWed = @TradingHoursWed,
		@TradingHoursThu = @TradingHoursThu,
		@TradingHoursFri = @TradingHoursFri,
		@TradingHoursSat = @TradingHoursSat,
		@TradingHoursSun = @TradingHoursSun,
		@UpdateSiteTradingHours = @UpdateSiteTradingHours,
		@LineType = @LineType,
		@OperatorNumber = @LoggedBy


 IF @ret <> 0 
	GOTO RollBack_Handle

 --verify if the site details updated.
 --append call note if the site details not updated due to incomplete data from CDI or job logged before on this site in CAMS
 IF NOT EXISTS(SELECT 1 FROM Sites 
			WHERE ClientID = @ClientID 
				AND TerminalID = @TerminalID
				AND [Name] = @Name)
  BEGIN
 	SELECT @CallNote = @CallNote + dbo.fnCRLF() +
			'Merchant name has NOT been updated yet. Please click "CDI & Site" button to verify/update them manually.'
  END


 IF LEN(@MobileNumber) > 0
  BEGIN
	SELECT @CallNote = @CallNote + 'AlternativePhone:' + @MobileNumber + dbo.fnCRLF()

	SELECT @FaultNote = @FaultNote + 'AlternativePhone:' + @MobileNumber + dbo.fnCRLF()

  END


 --get devicetype/configxml from sites
 select @ConfigXML = ConfigXML
	from Sites with (nolock)
	where ClientID = @ClientID and TerminalID = @TerminalID
		 
 if dbo.fnIsIntegratedDeviceRequireNetworkConfig(@ClientID, @DeviceType) = 1 
  begin
	select @ConfigFieldNote = dbo.fnConvertIPNetworkConfigXMLToText(@ClientID, 'Integrated', @ConfigXML)
		
	if @ConfigFieldNote <> ''
	 begin
		SELECT @CallNote = @CallNote + dbo.fnCRLF() + @ConfigFieldNote
		SELECT @FaultNote = @FaultNote + dbo.fnCRLF() + @ConfigFieldNote
	 end
 end
	 
 --append time stamp
 SELECT @CallNote = @CallNote + '  ' +  dbo.fnGetOperatorStamp(@LoggedBy) + dbo.fnCRLF()

 --add notes to call
 EXEC @ret  = dbo.spAddNotesToCall
	@CallNumber = @CallNumber,
	@NewNotes = @CallNote,
	@OperatorName = @LoggedBy

 IF @ret <> 0 
	GOTO RollBack_Handle

 --Add PLEASE CALL BEFORE ATTENDING
 --for Mobile Terminal
 if dbo.fnIsMobileDevice(@ClientID, @DeviceType) = 1
	begin
		SELECT @FaultNote = ISNULL(@FaultNote, '') + dbo.fnCRLF() + 'PLEASE CALL BEFORE ATTENDING'
	end
	 
 IF ISNULL(@SpecInstruct, '') <> '' OR ISNULL(@FaultNote, '') <> ''
  BEGIN
	SELECT @FaultNote = @FaultNote  + dbo.fnCRLF() + ISNULL(@SpecInstruct, '') + dbo.fnCRLF() + 
				CONVERT(varchar, GetDate(), 103) + ' ' + CONVERT(varchar, GetDate(), 108) + '[' + CAST(@LoggedBy as varchar) + ']' + dbo.fnCRLF()

	 -- CAMS-792 project driven FSP notes
	 select @ProjectNo = P.ProjectNo, @FaultNote = isnull(@FaultNote, '') + dbo.fnCRLF() + P.Note from tblProjectTID PT
	 inner join tblProject P on P.ProjectID = PT.ProjectID
	 where OldTerminalID = @TerminalID and P.IsActive = 1 and P.Note is not null

	 if @@ROWCOUNT > 0
		begin
			update Calls set ProjectNo = @ProjectNo
			where CallNumber = @CallNumber
		end
	
	--add fault notes to call
	EXEC @ret  = dbo.spAddFaultNotesToCall
		@CallNumber = @CallNumber,
		@NewNotes = @FaultNote,
		@OperatorName = @LoggedBy
	
	IF @ret <> 0 
		GOTO RollBack_Handle
	

  END


 --Commit
 IF @bInCallerTransaction = 0
	COMMIT TRAN


 
 --georead site
 --avoid it being used inside transaction
 EXEC spToolGeoReadSite
		@ClientID = @ClientID,
		@TerminalID = @TerminalID,
		@SiteGeoAccuracy = 4

 if @ClientID = 'HIC'
  begin
	--check if there is an open HICVISASEC upgrade jobs		
	exec spCloseHICVisaSecOpenJob
			@CallerJobID = @CallNumber,
			@TerminalID = @TerminalID,
			@LoggedBy = @LoggedBy		 		
  end

if @ClientID = 'CBA'
  begin
	 --send SMS from the pending log
	 select *
		into #SMSLog
		from tblJABSMSMerchantLog
		where UploadLogID = @UploadLogID
			and StatusID = 1
	
	 while exists(select 1 from #SMSLog)
	  begin
		select top 1 
				@LogID = LogID,
				@CallNumber = JobID,
				@AgentSLADateTime = NextFollowUpDateTime  --it is agent sla local time
			from #SMSLog
			    
		exec spSendMerchantSMS
				@JobID = @CallNumber,
				@UserID = @LoggedBy,
				@OnErrorResumeNext = 1,
				@NextFollowUpDateTime = @AgentSLADateTime,
				@AttachJobAlert = 0
		
		update tblJABSMSMerchantLog 
			set StatusID = 2
			where LogID = @LogID

		delete #SMSLog
			where LogID = @LogID
	
	  end
  end ---if @ClientID = 'CBA'

Exit_Handle:
 RETURN @ret

RollBack_Handle:
 IF @bInCallerTransaction = 0
	ROLLBACK TRAN

 GOTO Exit_Handle



/*
spWebLogCallNG 2, 'wbc', '21999853'
*/
Go

Grant EXEC on spWebLogCallNG to eCAMS_Role, CAMSApp
Go




