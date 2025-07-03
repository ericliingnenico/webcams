USE CAMS
Go

--if object_id('spWebLogJobNG') is null
--	exec ('create procedure dbo.spWebLogJobNG as return 1')
--go

Alter PROCEDURE dbo.spWebLogJobNG 
	(
		@UserID int,
		@JobID				int OUTPUT,
		@ProblemNumber			varchar(20),
		@ClientID			varchar(3),
		@MerchantID			varchar(16),
		@TerminalID			varchar(20),
		@JobTypeID			tinyint,
		@JobMethodID			tinyint,
		@DeviceType			varchar(15),
		@SpecInstruct			varchar(100),
	
		@InstallDateTime	datetime,
	
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

		@OldDeviceType 			varchar(15),
		@OldTerminalID 			varchar(20),
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

		@JobNote		varchar(400),
		@CAIC varchar(20)
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2017-11-20 11:28:26$-->
--<!--$ModifiedBy: Bo Li <bo.li@bambora.com>$-->
--<!--$Comment: after hours$-->
--<!--$Commit$-->
/*
 Purpose: Log a job
*/
 SET NOCOUNT ON
 DECLARE @ret int,
	@RegionID	tinyint,
	@SiteNote varchar(60),
	@RequestReceivedDateTime DateTime,
	@RequiredDateTime	datetime,
	@RequiredDateTimeOffset	int,
	@Notes		varchar(4000),
	@InstallerNotes	varchar(4000),
	@TradingHoursInfo varchar(200),
	@SpecialNotes varchar(6000),
	@PriorityID	tinyint,
	@ProjectNo varchar(20),
	@IsJABAutoBookingOK 	bit,
	@ProposedFSP 		int,
	@ParentPickpackDepotLocation int,
	@ClientSLADateTime 	datetime,
	@AgentSLADateTime 	datetime,
	@MerchantDateTimeOffset int,
	@MMDList varchar(200),
	@AgentSLADateTimeLocal 	datetime,
	@NextFollowUpDateTime datetime,
	@UploadLogID bigint,
	@LogID int,
	@LoggedBy	smallint



 --verify if the user has right to log call for this client
 if not EXISTS(SELECT 1 FROM UserClientDeviceType where UserID = @UserID and ClientID = @ClientID)
  begin
	raiserror('You do not have permission to log job on this client. Aborted.', 16, 1)
	goto Exit_Handle
  end

 --validation
 if @JobTypeID = 3  --upg
	EXEC @ret = dbo.spWebValidateTIDBeforeLogJobNG @UserID = @UserID, @ClientID = @ClientID, @TerminalID = @OldTerminalID, @JobTypeID = @JobTypeID
 else 
	EXEC @ret = dbo.spWebValidateTIDBeforeLogJobNG @UserID = @UserID, @ClientID = @ClientID, @TerminalID = @TerminalID, @JobTypeID = @JobTypeID
	
 IF @ret <> 0
	GOTO Exit_Handle


  --OK, user can log the call
 --convert @LoggedBy via @UserID
 SELECT @LoggedBy = dbo.fnToggleWebUserID(@UserID)


 --init
 SELECT @RequestReceivedDateTime = dbo.fnGetDate(),
	@Notes = '',
	@InstallerNotes = '',
	@SpecialNotes = ''




 --Set PriorityID
 IF @Urgent = 1
	SELECT @PriorityID = 2  --high
 ELSE
	SELECT @PriorityID = 1 --normal



 --get CAIC
 --select @CAIC = dbo.fnGetXMLValue(@ConfigXML, '32') --CAIC field 32
 select @CAIC = ISNULL(@CAIC, @MerchantID) --if no CAIC, user merchantid
	 

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
	SELECT @Notes = @Notes + dbo.fnEncodeNote(3, @TradingHoursInfo) + dbo.fnCRLF(),
		@InstallerNotes = @InstallerNotes + 'Trading Hours: ' + @TradingHoursInfo + dbo.fnCRLF()

  END

 --build extra attributes
 SELECT @SpecialNotes =  CASE WHEN ISNULL(@LineType, '') <> '' THEN 'LineType: ' + ISNULL(@LineType, '') + dbo.fnCRLF() 
				ELSE '' END +
			CASE WHEN ISNULL(@DialPrefix, '') <> '' THEN 'DialPrefix: ' + ISNULL(@DialPrefix, '') + dbo.fnCRLF() 
				ELSE '' END

 --Convert ConfigXML to readable string
 IF LEN(@ConfigXML) > 0 
  BEGIN
 	SELECT @SpecialNotes = @SpecialNotes + dbo.fnConvertConfigXMLToText(@ConfigXML) + dbo.fnCRLF()
  END

 --add extra special notes
 IF LEN(@SpecialNotes) > 0 
  BEGIN
	SELECT @SpecialNotes = 'Features required:' + @SpecialNotes
  END




 --add extra notes into JobNote
 SELECT @Notes = @Notes + @SpecialNotes + dbo.fnCRLF() 
 SELECT @InstallerNotes = @InstallerNotes + @SpecialNotes + dbo.fnCRLF()

 --add additional notes for FD job
 if @ClientID in ('MMS', 'WIR') --#6140 AUTOMATIC PROMPT FOR WIR / MMS JOBS
	and @JobTypeID in (1,3)
  begin
	select @InstallerNotes = @InstallerNotes + 'PLEASE NOTE THAT THIS IS A WIR- MAQUARIEJOB - PLEASE ENSURE THAT YOU REMOVE ANY FDM BRANDING PRIOR TO SITE ATTENDANCE.' + dbo.fnCRLF()
  end 

 if @ClientID in ('FDM', 'MMS', 'WIR') --#6140 AUTOMATIC PROMPT FOR WIR / MMS JOBS
	and @JobTypeID in (1,3)
	and @DeviceType = 'VX570X'
  begin
	select @InstallerNotes = @InstallerNotes + 'DATAWIRE TERMINAL - MUST TAKE CAT5 CABLE TO INSTALLATION.' + dbo.fnCRLF()
  end 
  

  
 --embed the job note as xml tag for call viewer to parse
 IF ISNULL(@JobNote, '') <> ''
  BEGIN
	 SELECT @Notes = @Notes + @JobNote + dbo.fnCRLF()
	 if @JobTypeID = 2
	  begin
		 select @InstallerNotes = @InstallerNotes  + dbo.fnCRLF() + @JobNote + dbo.fnCRLF()
	  end
  END 
 IF ISNULL(@SpecInstruct, '') <> ''
  BEGIN
	 SELECT @Notes = @Notes  + dbo.fnCRLF() + @SpecInstruct + dbo.fnCRLF()
	 select @InstallerNotes = @InstallerNotes  + dbo.fnCRLF() + @SpecInstruct + dbo.fnCRLF()
	 
  END 


 IF LEN(@InstallDateTime) > 0 
  BEGIN
	SELECT @Notes = @Notes + 'Estimated InstallDate: ' + CAST(@InstallDateTime as varchar) + dbo.fnCRLF()
  END

 --get RegionID
 SELECT @RegionID =  dbo.fnGetRegionOfClientContractPostcode(@ClientID, @DeviceType, @Postcode, @City, @State)


 --calculate SLA
 SELECT	@RequiredDateTime = dbo.fnGetSLADate(@ClientID, @JobTypeID, @RegionID, @RequestReceivedDateTime, @DeviceType, @State)

 --get time zone info
 SELECT @RequiredDateTimeOffset = dbo.fnGetTimeZoneOffset(@State, @RequiredDateTime)


 --finally add user stamp to the job notes
 if LTRIM(replace(@Notes,  dbo.fnCRLF(), '')) <> ''
	SELECT @Notes = @Notes  + '  ' +  dbo.fnGetOperatorStamp(@LoggedBy) + dbo.fnCRLF()

 --Add PLEASE CALL BEFORE ATTENDING
 --for Mobile Terminal
 if dbo.fnIsMobileDevice(@ClientID, @DeviceType) = 1 and @JobTypeID in (1,3)
	begin
		SELECT @InstallerNotes = @InstallerNotes + dbo.fnCRLF() + 'PLEASE CALL BEFORE ATTENDING'
	end

 --Get New job id
 EXEC @ret = spGetNewIMSJobID @JobID = @JobID OUTPUT
 IF @ret <> 0 
	GOTO Exit_Handle

 --job exists, abort
 IF EXISTS(SELECT 1 FROM IMS_Jobs WHERE JobID = @JobID)
  BEGIN
	RAISERROR('job (JobID: %d) exists, abort', 16, 1, @JobID)
 	SELECT @ret = -1
	GOTO Exit_Handle
  END

 --Set ProjectNo for NAB SAGEM VS Upgrade with Urgent ticked
 if @Urgent = 1 and @JobTypeID = 3
  begin
	select @ProjectNo = case when @ClientID = 'NAB' then 'NAB FORCEDUPG'
							when @ClientID = 'CBA' then 'CBA FORCEDUPG'
							else @ProjectNo end
	if @ProjectNo is null
	 begin
		select @ProjectNo = ProjectNo 
			from tblProject
			where ClientID = @ClientID
				and IsActive = 1
				and ClosureXML like '%<ForcedUpgrade>yes</ForcedUpgrade>%'
	 end
  end


 

 --Start Transaction
 DECLARE @bInCallerTransaction bit
 SET @bInCallerTransaction = @@TRANCOUNT
 IF @bInCallerTransaction = 0
	BEGIN TRAN

 --log the job
 EXEC @ret = dbo.spPutIMSJob
		@JobID = @JobID,
		@ProblemNumber = @ProblemNumber,
		@JobTypeID = @JobTypeID,
		@ClientID = @ClientID,
		@MerchantID = @MerchantID,
		@TerminalID = @TerminalID,
		@SiteNumber = null,
		@BusinessActivity = @BusinessActivity,
		@MultiDrop = 0,
		@Drops = null,
		@TerminalNumber = null,
		@JobMethodID = @JobMethodID,
		@DeviceType = @DeviceType,
		@SpecInstruct = @SpecInstruct,
		@PriorityID = @PriorityID,
		@Notes = @Notes,
		@RequestReceivedFrom = 'WEB JOB LOGGER',
		@RequestReceivedVia = 'WEB',
		@RequestReceivedDateTime = @RequestReceivedDateTime,
		@ImportFile = NULL,
		@RequiredDateTime = @RequiredDateTime,
		@RequiredDateTimeOffset = @RequiredDateTimeOffset,
		@CurrentETADateTime = null,
		@CurrentETADateTimeOffset = null,
		@DueDateTime = @RequiredDateTime,
		@DueDateTimeOffset = @RequiredDateTimeOffset,
		@Delayed = 0,
		@Name = @Name,
		@Address = @Address,
		@Address2 = @Address2,
		@City = @City,
		@State = @State,
		@Postcode = @Postcode,
		@Contact = @Contact,
		@PhoneNumber = @PhoneNumber,
		@MobileNumber = @MobileNumber,
		@ModemNumber = null,
		@FaxNumber = null,
		@Email = null,
		@RegionID = @RegionID,

		@VipYN = 0,
		@ConfigXML = @ConfigXML,

		@LineType = @LineType,
		@TransendID = null,
		@CatID = @TerminalID,
		@CAIC = @CAIC,
		@NetworkTerminalID = null,

		@OnSiteMinsReqd = null,
		@TransitMinsInReqd = null,
		@TransitMinsOutReqd = null,
		@InstallerNotes = @InstallerNotes,
		@LoggedBy = @LoggedBy,

		@ShortTermRentalYN = 0,
		@ShortTermRentalEndDate = null,
		@StatusNote = null,
		@OldDeviceType = @OldDeviceType,
		@OldTerminalID = @OldTerminalID,
		@ParentJobID = NULL,
		@ProjectNo = @ProjectNo,
		@ByPassGeoMap = 0



 IF @ret <> 0 
	GOTO RollBack_Handle


 --load job equipment
 EXEC @ret = spLogIMSJobEquipmentAndPart
	@JobID = @JobID

 IF @ret <> 0 
	GOTO RollBack_Handle

 IF @JobTypeID = 2 --'DEINSTALL'
  BEGIN
	--only add the site if not exists in CAMS.
	--should not update the site details since we use the address as pickup address for deinstall
 	IF NOT EXISTS(SELECT 1 FROM Sites WITH (NOLOCK) WHERE ClientID = @ClientID AND TerminalID = @TerminalID)
	 BEGIN
		 SELECT @SiteNote = 'ADDED FROM WEB JOB LOGGER JobID: ' + cast(@JobID as varchar)
	
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

			@Note = @SiteNote ,
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

	 END --IF NOT EXISTS(SELECT 1 FROM Sites WITH (NOLOCK) WHERE ClientID = @ClientID AND TerminalID = @TerminalID)

	--process CBA BRANCH PICKUP
	if @ClientID = 'CBA' and @TerminalID like '[0-9][0-9][0-9]-[0-9][0-9][0-9]'
	 begin
		--get proposed FSP
		select @AgentSLADateTimeLocal = convert(varchar, @RequiredDateTime, 107) + ' 16:00:00'
		select @AgentSLADateTime = dateadd(mi, 0-@RequiredDateTimeOffset, @AgentSLADateTimeLocal)

		select @ProposedFSP = FSP from dbo.fnGetPostcodeFSPAllocation(@Postcode, @City, @ClientID, @JobTypeID, @DeviceType, @AgentSLADateTimeLocal)

		if @ProposedFSP not in (328)
		 begin
			--book fsp & mark delay reason
			update IMS_Jobs
			   set BookedInstaller = @ProposedFSP,
					AgentSLADateTime = @AgentSLADateTime,
					AgentSLADateTimeOffset = @RequiredDateTimeOffset,
					BookedBy = @LoggedBy,
					StatusID = 9, --'BOOKED',
					CurrentETADateTime = Dateadd(hh,1,@AgentSLADateTime),
					CurrentETADateTimeOffset = @RequiredDateTimeOffset,
					BookedAtDateTime = getdate(),
					BookingLastUpdateAt = getdate(),
					DelayReasonID = 6, -- DELAYED BY BANK
					AllowPDADownload = 1,
					AllowFSPWebAccess = 1
			 where JobID = @JobID

			--Set DueDateTime
			exec spSetDueDateTimeOnIMSJob @JobID = @JobID

			--send job fax
			exec dbo.spPutJABBookingLog 
						@LogID	= NULL,
						@JobID	= @JobID,
						@BookedDateTime = @RequestReceivedDateTime,
						@Status	= 'O',
						@FaxedDateTime = NULL,
						@SourceID = 'W'
		 end --if @ProposedFSP not in (328)

	 end --process CBA BRANCH PICKUP

  END --IF @JobTypeID = 2 --'DEINSTALL'

 --set to hot job for EE operator to attend quickly
 --only limit to upgrades job (Ref: #6616)
 --not for PYM upgrade (Ref:  #6738)
 IF @Urgent = 1 and @JobTypeID = 3 and @ClientID not in ('PYM')
  BEGIN
	--change status to forced
	UPDATE IMS_Jobs
	   SET StatusID = 13 --'FORCED'
	  WHERE JobID = @JobID

	SET @ret = @@ERROR		
	IF @ret <> 0 
		GOTO RollBack_Handle
  END


 --set swap sla and auto book on all forced upgrade
 IF dbo.fnIsForcedUpgrade(@JobID) = 1
  BEGIN
	--get MMD list
	select @MMDList = ''
	select @MMDList = @MMDList + MMD_ID + ','
		from IMS_Job_Equipment
		where JobID = @JobID
			and ActionID = 1
				
	 --check if we can auto book the job
	 EXEC @ret = dbo.spVerifyAutoBooking
				@CAMSJobID = @JobID,
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
				@SwapPartsOnly = 0,
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
			UPDATE IMS_Jobs
			  SET RequiredDateTime = @ClientSLADateTime,
				RequiredDateTimeOffset = @MerchantDateTimeOffset,
				AgentSLADateTime = CASE WHEN @IsJABAutoBookingOK = 1 THEN @AgentSLADateTime ELSE @ClientSLADateTime END,
				AgentSLADateTimeOffset = CASE WHEN @IsJABAutoBookingOK = 1 THEN @MerchantDateTimeOffset ELSE @MerchantDateTimeOffset END,
				StatusID = CASE WHEN @IsJABAutoBookingOK = 1 THEN 9 ELSE StatusID END,  ---'BOOKED'
				BookedInstaller = CASE WHEN @IsJABAutoBookingOK = 1 THEN @ProposedFSP ELSE NULL END,
				DueDateTime = @ClientSLADateTime,
				DueDateTimeOffset = @MerchantDateTimeOffset,
				BookedBy = CASE WHEN @IsJABAutoBookingOK = 1 THEN @LoggedBy ELSE NULL END,
				BookedAtDateTime = CASE WHEN @IsJABAutoBookingOK = 1 THEN @RequestReceivedDateTime ELSE NULL END,
				AllowPDADownload = @IsJABAutoBookingOK,
				AllowFSPWebAccess = @IsJABAutoBookingOK
			 WHERE JobID = @JobID

		 END --IF @ClientSLADateTime IS NOT NULL

	 IF @IsJABAutoBookingOK = 1
		 BEGIN
			--log into tblJABBookingLog for JABFax to send the jobsheet
			EXEC dbo.spPutJABBookingLog 
					@LogID	= NULL,
					@JobID	= @JobID,
					@BookedDateTime = @RequestReceivedDateTime,
					@Status	= 'O',
					@FaxedDateTime = NULL,
					@SourceID = 'W'

		 END --IF @IsJABAutoBookingOK = 1

  END --IF @Urgent = 1 and @JobTypeID = 3 

  if @JobTypeID in (1, 3)
	 and dbo.fnIsForcedUpgrade(@JobID) = 0
   begin				
		--send Booking Email
		select @NextFollowUpDateTime = DATEADD(day, 1, dbo.fnGetDate())

		exec spSendMerchantEmail
			@JobID = @JobID,
			@NextFollowUpDateTime = @NextFollowUpDateTime,
			@UserID = @LoggedBy

		if dbo.fnExtractFirstMobilePhoneNo(@PhoneNumber, @MobileNumber,null) <> ''
		 begin
			if dbo.fnIsOKToSMS(@JobID) = 1
	 		 begin
				if dbo.fnIsTimeAfterHourInTheState(@ClientID, @State, getdate()) = 1
				 begin
					insert tblJABSMSMerchantBuffer(UploadLogID,
													JobID,
													StatusID,
													LoggedDateTime)
						select @UploadLogID,
								@JobID,
								1,
								getdate()
				 end
				else
				 begin
					update IMS_Jobs
						set ProjectNo = 'JAB_SMS'
						where JobID = @JobID

					select @NextFollowUpDateTime = DATEADD(hour, 2, dbo.fnGetDate()), @UploadLogID = 0 - @JobID

					--log for later process				
					insert tblJABSMSMerchantLog (
							UploadLogID,
							JobID,
							NextFollowupDateTime,
							StatusID,
							LoggedDateTime)
						select 
							@UploadLogID,
							@JobID,
							@NextFollowUpDateTime,
							1, --Pending to send SMS
							GETDATE()
				 end --if dbo.fnIsTimeAfterHourInTheState
			 end -- if dbo.fnIsOKToSMS
		 end --if dbo.fnExtractFirstMobilePhoneNo(@PhoneNumber, @MobileNumber,null) <> ''
   end --if @JobTypeID in (1, 3) 


 --Commit
 IF @bInCallerTransaction = 0
	COMMIT TRAN
	
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
			@JobID = JobID,
			@NextFollowUpDateTime = NextFollowUpDateTime
		from #SMSLog
			    
	exec spSendMerchantSMS
			@JobID = @JobID,
			@UserID = @LoggedBy,
			@OnErrorResumeNext = 1,
			@NextFollowUpDateTime = @NextFollowUpDateTime,
			@AttachJobAlert = 0
		
	update tblJABSMSMerchantLog 
		set StatusID = 2
		where LogID = @LogID

	delete #SMSLog
		where LogID = @LogID
	
  end

 exec spProcessJobDerived 
	@JobID = @JobID,
	@LoggedBy = @LoggedBy
  	

Exit_Handle:
 RETURN @ret

RollBack_Handle:
 IF @bInCallerTransaction = 0
	ROLLBACK TRAN

 GOTO Exit_Handle



/*
spWebLogJobNG 2, 'wbc', '21999853'
*/
Go

--Grant EXEC on spWebLogJobNG to eCAMS_Role, CAMSApp
Go




