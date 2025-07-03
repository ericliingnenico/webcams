USE CAMS
Go

if object_id('spWebLogJobAPI') is null
	exec ('create procedure dbo.spWebLogJobAPI as return 1')
go

Alter PROCEDURE dbo.spWebLogJobAPI 
	(
		@UserID			int,
		@JobID			bigint OUTPUT,
		@ProblemNumber		varchar(20),
		@ClientID			varchar(3),
		@MerchantID			varchar(16),
		@TerminalID			varchar(20),
		@JobTypeID			tinyint,
		@DeviceType			varchar(15),
	
		@Name				varchar(50),
		@Address			varchar(50),
		@Address2			varchar(50),
		@City				varchar(50),
		@State				varchar(3),
		@Postcode			varchar(10),
		@Contact			varchar(50),
		@PhoneNumber			varchar(15),
		@AlternatePhoneNumber	varchar(15),
		@BusinessActivity		varchar(40),
		@Urgent			bit,

		@ErrorCode		varchar(50),

		@TradingHoursMon varchar(15),
		@TradingHoursTue varchar(15),
		@TradingHoursWed varchar(15),
		@TradingHoursThu varchar(15),
		@TradingHoursFri varchar(15),
		@TradingHoursSat 	varchar(15),
		@TradingHoursSun 	varchar(15),

		@SpecInstruct			varchar(100),
		@JobNote		varchar(400),
		@SwapComponent varchar(200),
		@CAIC varchar(20),
		@OldDeviceType 			varchar(15),
		@OldTerminalID 			varchar(20)

	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Chester $-->
--<!--$$Date: 10/09/15 18:39 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebLogJobAPI.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Log a call
*/
 SET NOCOUNT ON
 DECLARE @ret int,
 		@CallTypeID		int,
		@SymptomID		int,
		@FaultID		int,
		@CallNumber		varchar(11)

 --init
 set @ret = 0

 --validation
 exec @ret = dbo.spWebIsUserAllowedAPIAccessNG @UserID = @UserID, @MethodID = 3	--1: UpdateJobNote; 2: CloseJob; 3: LogNewJob; 4: GetOpenJobList; 5: GetJob; 6: GetCall
 if @ret <> 0 goto Exit_Handle

 --verify if the user has right to log call for this client
 if not EXISTS(SELECT 1 FROM UserClientDeviceType where UserID = @UserID and ClientID = @ClientID)
  begin
	raiserror('You do not have permission to log job on this client. Aborted.', 16, 1)
	goto Exit_Handle
  end

 --verify JobTypeID 
 if isnull(@JobTypeID, 0)  not in (1,2,3,4)
  begin
	raiserror('Incorrect JobTypeID.', 16, 1)
	goto Exit_Handle
  end

 if isnull(@TerminalID, '') = ''
  begin
	raiserror('TerminalID is a required field.', 16, 1)
	goto Exit_Handle
  end


 --verify state
 if not exists(select 1 from tblState where State = @State)
  begin
	raiserror('State is a required field.', 16, 1)
	goto Exit_Handle
  end

 if @JobTypeID in (1,3)
  begin
	if isnull(@DeviceType, '') = ''
	 begin
		raiserror('DeviceType is a required field.', 16, 1)
		goto Exit_Handle
	 end
  end

 if @JobTypeID in (3)
  begin
	if isnull(@OldDeviceType, '') = ''
	 begin
		raiserror('OldDeviceType is a required field.', 16, 1)
		goto Exit_Handle
	 end
	if isnull(@OldTerminalID, '') = ''
	 begin
		raiserror('OldTerminalID is a required field.', 16, 1)
		goto Exit_Handle
	 end

  end

 if @JobTypeID in (4)
  begin
	if isnull(@ErrorCode, '') = ''
	 begin
		raiserror('ErrorCode is a required field.', 16, 1)
		goto Exit_Handle
	 end

	if dbo.fnIsTradingHoursOK(@TradingHoursMon) = 0 
		OR dbo.fnIsTradingHoursOK(@TradingHoursTue) = 0 
		OR dbo.fnIsTradingHoursOK(@TradingHoursWed) = 0 
		OR dbo.fnIsTradingHoursOK(@TradingHoursThu) = 0 
		OR dbo.fnIsTradingHoursOK(@TradingHoursFri) = 0 
		OR dbo.fnIsTradingHoursOK(@TradingHoursSat) = 0 
		OR dbo.fnIsTradingHoursOK(@TradingHoursSat) = 0 
		OR dbo.fnIsTradingHoursOK(@TRadingHoursSun) = 0
	 begin
		raiserror('TradingHours is in an invalid format.', 16, 1)
		goto Exit_Handle
	 end

  end


 if @JobTypeID in (1,2,3)
  begin
	exec  @ret = dbo.spWebLogJobNG 
			@UserID = @UserID,
			@JobID	= @JobID OUTPUT,
			@ProblemNumber	= @ProblemNumber,
			@ClientID	= @ClientID,
			@MerchantID	= @MerchantID,
			@TerminalID	= @TerminalID,
			@JobTypeID = @JobTypeID,
			@JobMethodID = 1,
			@DeviceType = @DeviceType,
			@SpecInstruct = @SpecInstruct,
	
			@InstallDateTime = null,
	
			@Name = @Name,
			@Address = @Address,
			@Address2 = @Address2,
			@City = @City,
			@State = @State,
			@Postcode = @Postcode,
			@Contact = @Contact,
			@PhoneNumber = @PhoneNumber,
			@MobileNumber = @AlternatePhoneNumber,
			@LineType = '',
			@DialPrefix = '',
			@OldDeviceType = @OldDeviceType,
			@OldTerminalID = @OldTerminalID,
			@BusinessActivity = @BusinessActivity,
			@Urgent = @Urgent,
			@TradingHoursMon = @TradingHoursMon,
			@TradingHoursTue = @TradingHoursTue,
			@TradingHoursWed = @TradingHoursWed,
			@TradingHoursThu = @TradingHoursThu,
			@TradingHoursFri = @TradingHoursFri,
			@TradingHoursSat = @TradingHoursSat,
			@TradingHoursSun = @TradingHoursSun,
			@UpdateSiteTradingHours = 0,
			@ConfigXML = '',
			@JobNote = @JobNote,
			@CAIC = @CAIC
  end
 else
  begin
	--get CallTypeID/SymptomID/FautlID
	select @CallTypeID = cs.CallTypeID,
			@SymptomID = cs.SymptomID,
			@FaultID = sf.FaultID
		from Site_Maintenance sm with (nolock) join tblDeviceCallType dc with (nolock) on sm.EquipmentCodes = dc.EquipmentCode
										join tblCallTypeSymptom cs with (nolock) on cs.CallTypeID = dc.CallTypeID
										join vwSymptomFault sf with (nolock) on sf.SymptomID = cs.SymptomID and sf.Fault = @ErrorCode
		where sm.ClientID = @ClientID 
			and sm.TerminalID = @TerminalID

	exec @ret = dbo.spWebLogCallNG 
			@UserID = @UserID,	
			@CallNumber = @CallNumber OUTPUT,	
			@ProblemNumber = @ProblemNumber,	
			@ClientID = @ClientID,	
			@MerchantID = @MerchantID,	
			@TerminalID = @TerminalID,	
			@SpecInstruct = @SpecInstruct,	
			@Name = @Name,	
			@Address = @Address,	
			@Address2 = @Address2,	
			@City = @City,	
			@State = @State,	
			@Postcode = @Postcode,	
			@Contact = @Contact,	
			@PhoneNumber = @PhoneNumber,	
			@MobileNumber = @AlternatePhoneNumber,	
			@LineType = '',	
			@DialPrefix = '',	
			@CallTypeID = @CallTypeID,	
			@SymptomID = @SymptomID,	
			@FaultID = @FaultID,	
			@BusinessActivity = @BusinessActivity,	
			@Urgent = @Urgent,	
			@TradingHoursMon = @TradingHoursMon,	
			@TradingHoursTue = @TradingHoursTue,	
			@TradingHoursWed = @TradingHoursWed,	
			@TradingHoursThu = @TradingHoursThu,	
			@TradingHoursFri = @TradingHoursFri,	
			@TradingHoursSat = @TradingHoursSat,	
			@TradingHoursSun = @TradingHoursSun,	
			@UpdateSiteTradingHours = 1,	
			@ConfigXML = '',	
			@AdditionalServiceTypeID = null,	
			@JobNote = @JobNote,	
			@SwapComponent = @SwapComponent,	
			@CAIC = @CAIC

	set @JobID = @CallNumber
  end


Exit_Handle:
	return @ret

 

/*

declare @JobID			bigint
exec dbo.spWebLogJobAPI 
		@UserID			= 210000,
		@JobID			= @JobID OUTPUT,
		@ProblemNumber	='BL101',
		@ClientID		='CBA',
		@MerchantID		= '9293983004',
		@TerminalID		= '81338500',
		@JobTypeID		= 4,
		@DeviceType		= 'test',
	
		@Name			='name1',
		@Address		='1 main street',
		@Address2		= null,
		@City			='mount waverley',
		@State			='vic',
		@Postcode		='3149',
		@Contact		='Bo',
		@PhoneNumber	='0394031723',
		@AlternatePhoneNumber	=null,
		@BusinessActivity		='software',
		@Urgent		=0,

		@ErrorCode	='09-DATE ISSUE',

		@TradingHoursMon ='09:30-16:30',
		@TradingHoursTue ='09:30-16:30',
		@TradingHoursWed ='09:30-16:30',
		@TradingHoursThu ='09:30-16:30',
		@TradingHoursFri ='09:30-16:30',
		@TradingHoursSat =null,
		@TradingHoursSun =null,

		@SpecInstruct	='sp1',
		@JobNote		='testnotes',
		@SwapComponent =null,
		@CAIC ='311000063621027',
		@OldDeviceType =null,
		@OldTerminalID 	=null

select @JobID
*/
Go

Grant EXEC on spWebLogJobAPI to eCAMS_Role, CAMSApp
Go




