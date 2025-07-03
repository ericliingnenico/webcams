Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutSite]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebPutSite]
GO



Create Procedure dbo.spWebPutSite 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20),
		@MerchantID varchar(16),
		@Name varchar(50),
		@Address varchar(50),
		@Address2 varchar(50),
		@City varchar(30),
		@State varchar(3),
		@Postcode varchar(10),
		@Contact varchar(50),
		@PhoneNumber varchar(20),
		@PhoneNumber2 varchar(20),
		@TradingHoursMon varchar(15),
		@TradingHoursTue varchar(15),
		@TradingHoursWed varchar(15),
		@TradingHoursThu varchar(15),
		@TradingHoursFri varchar(15),
		@TradingHoursSat varchar(15),
		@TradingHoursSun varchar(15),
		@ApplyChangeToOtherMerchantRecord bit
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/08/08 10:59a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutSite.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT OFF
 DECLARE @ret int

 EXEC @ret = CAMS.dbo.spWebPutSite @UserID = @UserID, 
				@ClientID = @ClientID, 
				@TerminalID = @TerminalID,
				@MerchantID = @MerchantID, 
				@Name = @Name, 
				@Address = @Address,
				@Address2 = @Address2, 
				@City = @City, 
				@State = @State, 
				@Postcode = @Postcode, 
				@Contact = @Contact, 
				@PhoneNumber = @PhoneNumber, 
				@PhoneNumber2 = @PhoneNumber2, 
				@TradingHoursMon = @TradingHoursMon,
				@TradingHoursTue = @TradingHoursTue,
				@TradingHoursWed = @TradingHoursWed,
				@TradingHoursThu = @TradingHoursThu,
				@TradingHoursFri = @TradingHoursFri,
				@TradingHoursSat = @TradingHoursSat, 
				@TradingHoursSun = @TradingHoursSun, 
				@ApplyChangeToOtherMerchantRecord = @ApplyChangeToOtherMerchantRecord

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar

 RETURN @ret

/*
spWebPutSite 3, 187196

*/
Go


Grant EXEC on spWebPutSite to eCAMS_Role
Go


Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutSite]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebPutSite]
GO


Create Procedure dbo.spWebPutSite 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20),
		@MerchantID varchar(16),
		@Name varchar(50),
		@Address varchar(50),
		@Address2 varchar(50),
		@City varchar(30),
		@State varchar(3),
		@Postcode varchar(10),
		@Contact varchar(50),
		@PhoneNumber varchar(20),
		@PhoneNumber2 varchar(20),
		@TradingHoursMon varchar(15),
		@TradingHoursTue varchar(15),
		@TradingHoursWed varchar(15),
		@TradingHoursThu varchar(15),
		@TradingHoursFri varchar(15),
		@TradingHoursSat varchar(15),
		@TradingHoursSun varchar(15),
		@ApplyChangeToOtherMerchantRecord bit
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/04/03 13:04 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebPutSite.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Update Site details from Web Portal
 SET NOCOUNT OFF
 DECLARE @ret int

 --init
 SELECT @ret = 0

 --verify before update
 IF EXISTS(SELECT 1 FROM WebCAMS.dbo.tblUser u JOIN WebCAMS.dbo.vwUserClient uc ON u.UserID = uc.UserID 
			WHERE u.UserID = @UserID AND uc.ClientID = @ClientID)
  BEGIN
	IF @ApplyChangeToOtherMerchantRecord = 1
	 BEGIN
		--Set @TerminalID to NULL to wildcard process the records with the same MerchantID
		SELECT @TerminalID = NULL

	 END

	--start firing conditional update trigger on Sites
	EXEC spSetContextInfo @Section = 3, @Value = 'y'


	--update Site
	UPDATE Sites
	   SET 	[Name] = @Name,
		Address = @Address,
		Address2 = @Address2,
		City = @City,
		Postcode = @Postcode,
		State = @State,
		Contact = @Contact,
		PhoneNumber = @PhoneNumber,
		PhoneNumber2 = @PhoneNumber2,
		TradingHoursMon = @TradingHoursMon,
		TradingHoursTue = @TradingHoursTue,
		TradingHoursWed = @TradingHoursWed,
		TradingHoursThu = @TradingHoursThu,
		TradingHoursFri = @TradingHoursFri,
		TradingHoursSat = @TradingHoursSat,
		TradingHoursSun = @TradingHoursSun
	  WHERE ClientID = @ClientID
		AND TerminalID = ISNULL(@TerminalID, TerminalID)
		AND MerchantID = @MerchantID

	SELECT @ret = @@ERROR
  END

 return @ret

GO

Grant EXEC on spWebPutSite to eCAMS_Role
Go
