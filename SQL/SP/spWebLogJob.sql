USE [WebCAMS]
GO
/****** Object:  StoredProcedure [dbo].[spWebLogJob]    Script Date: 02/12/20 12:47:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[spWebLogJob] 
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
		@CAIC varchar(20),

		@ContactEmail varchar(50) = null,
		@BankersEmail varchar(50) = null,
		@MerchantEmail varchar(50) = null,
		@CustomerNumber varchar(20) = null,
		@AltMerchantID varchar(20) = null,
		@LostStolen bit = null
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-10-22 12:03:01$-->
--<!--$ModifiedBy: Andrew Falzon <afalzon@keycorp.net>$-->
--<!--$Comment: CAMS-771 Add job notes to installer notes for FDI clients.$-->
--<!--$Commit$-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 DECLARE @ret int,
	@LoggedBy smallint,
	@LogID int

 --init 
 SELECT @ret = -1

 --verify if the user has right to log call for this client
 IF EXISTS(SELECT 1 FROM tblUser u join vwUserClient uc ON u.UserID = uc.UserID and uc.ClientID = @ClientID)
  BEGIN

	--log the request into tblWebJobLog
	INSERT tblWebJobLog (
				LogDateTime,
				JobID,
				ProblemNumber,
				ClientID,
				MerchantID,
				TerminalID,
				JobTypeID,
				JobMethodID,
				DeviceType,
				SpecInstruct,
				InstallDateTime,
				[Name],
				Address,
				Address2,
				City,
				State,
				Postcode,
				Contact,
				PhoneNumber,
				MobileNumber,
				LineType,
				DialPrefix,
				OldDeviceType,
				OldTerminalID,
				BusinessActivity,
				Urgent,
				TradingHoursMon,
				TradingHoursTue,
				TradingHoursWed,
				TradingHoursThu,
				TradingHoursFri,
				TradingHoursSat,
				TradingHoursSun,
				ConfigXML,
				JobNote,
				LoggedBy,
				CAIC,
				LostStolen)
		Values (
				GetDate(),
				@JobID,
				@ProblemNumber,
				@ClientID,
				@MerchantID,
				@TerminalID,
				@JobTypeID,
				@JobMethodID,
				@DeviceType,
				@SpecInstruct,
				@InstallDateTime,
				@Name,
				@Address,
				@Address2,
				@City,
				@State,
				@Postcode,
				@Contact,
				@PhoneNumber,
				@MobileNumber,
				@LineType,
				@DialPrefix,
				@OldDeviceType,
				@OldTerminalID,
				@BusinessActivity,
				@Urgent,
				@TradingHoursMon,
				@TradingHoursTue,
				@TradingHoursWed,
				@TradingHoursThu,
				@TradingHoursFri,
				@TradingHoursSat,
				@TradingHoursSun,
				@ConfigXML,
				@JobNote,
				@UserID,
				@CAIC,
				@LostStolen)

	--validation
	if @JobTypeID = 3  --upg
		EXEC @ret = dbo.spWebValidateTIDBeforeLogJob @UserID = @UserID, @ClientID = @ClientID, @TerminalID = @OldTerminalID, @JobTypeID = @JobTypeID
	else 
		EXEC @ret = dbo.spWebValidateTIDBeforeLogJob @UserID = @UserID, @ClientID = @ClientID, @TerminalID = @TerminalID, @JobTypeID = @JobTypeID
	
	IF @ret <> 0
		GOTO Exit_Handle


	--get LogId
	SELECT @LogID = SCOPE_IDENTITY()

	--OK, user can log the call
	--convert @LoggedBy via @UserID
	SELECT @LoggedBy = CAMS.dbo.fnToggleWebUserID(@UserID)


	EXEC @ret = CAMS.dbo.spWebLogJob 		
			@JobID	= @JobID OUTPUT,
			@ProblemNumber	= @ProblemNumber,
			@ClientID = @ClientID,
			@MerchantID = @MerchantID,
			@TerminalID = @TerminalID,
			@JobTypeID = @JobTypeID,
			@JobMethodID = @JobMethodID,
			@DeviceType = @DeviceType,
			@SpecInstruct = @SpecInstruct,
		
			@InstallDateTime = @InstallDateTime,
		
			@Name = @Name,
			@Address = @Address,
			@Address2 = @Address2,
			@City = @City,
			@State = @State,
			@Postcode = @Postcode,
			@Contact = @Contact,
			@PhoneNumber = @PhoneNumber,
			@MobileNumber = @MobileNumber,
			@LineType = @LineType,
			@DialPrefix = @DialPrefix,
	
			@OldDeviceType = @OldDeviceType,
			@OldTerminalID = @OldTerminalID,
			@BusinessActivity = @BusinessActivity,
	
			@Urgent	= @Urgent,
	
			@TradingHoursMon = @TradingHoursMon,
			@TradingHoursTue = @TradingHoursTue,
			@TradingHoursWed = @TradingHoursWed,
			@TradingHoursThu = @TradingHoursThu,
			@TradingHoursFri = @TradingHoursFri,
			@TradingHoursSat = @TradingHoursSat,
			@TradingHoursSun = @TradingHoursSun,
			@UpdateSiteTradingHours = @UpdateSiteTradingHours,	
			@ConfigXML = @ConfigXML,
	
			@JobNote = @JobNote,
			@CAIC = @CAIC,
			
			@LoggedBy = @LoggedBy,

			@ContactEmail = @ContactEmail,
			@BankersEmail = @BankersEmail,
			@MerchantEmail = @MerchantEmail,
			@CustomerNumber = @CustomerNumber,
			@AltMerchantID = @AltMerchantID,
			@LostStolen = @LostStolen

	--set jobid if it is logged successfully
	IF ISNULL(@JobID, 0 ) <> 0
		UPDATE tblWebJobLog
		   SET JobID = @JobID
		 WHERE LogID = @LogID

  END	

Exit_Handle:
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

