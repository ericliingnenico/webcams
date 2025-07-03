Use WebCAMS
Go


if exists(select 1 from sysobjects where name = 'spWebLogApplicationAndAssignMID')
 drop proc spWebLogApplicationAndAssignMID
Go

create proc  dbo.spWebLogApplicationAndAssignMID 
	(
	@UserID	int,
	@MerchantID varchar(20) OUTPUT,
	@PayMarkID	bigint OUTPUT,
	@CountryID	int,
	@PartnerID	int,
	@AccountID	bigint,
	@AccountType	varchar(50),
	@ApplicationID	bigint,
	@ProductType	varchar(50),
	@ContactName	varchar(256),
	@GSTNumber	int,
	@TradingName	varchar(64),
	@LegalName	varchar(128),
	@DescriptionOfBusiness	varchar(512),
	@BusinessAddress1	varchar(64),
	@BusinessAddress2	varchar(64),
	@BusinessCity	varchar(64),
	@BusinessState	int,
	@BusinessPostcode	varchar(16),
	@BusinessCountry	int,
	@IsThePrimaryBusinessFaceToFace	bit,
	@IsBillerProvided	bit,
	@AnnualCardSalesTurnover	varchar(32),
	@AverageTicketSize	varchar(32),
	@SubMerchantBusinessIdentifier	varchar(32),
	@RefundPolicy	varchar(256),
	@CancellationPolicy	varchar(256),
	@DeliveryTimeframes	varchar(32),
	@PaymentPageSample	varchar(256),
	@ReceiptSample	varchar(256),
	@BusinessPhone	varchar(32),
	@Privatephone	varchar(32),
	@WebAddress	varchar(256),
	@EmailAddress	varchar(128),
	@FaxNumber	varchar(32),
	@Director1Name	varchar(256),
	@Director1DOB	date,
	@Director1Address1	varchar(64),
	@Director1Address2	varchar(64),
	@Director1City	varchar(64),
	@Director1State	int,
	@Director1Postcode	varchar(16),
	@Director1Country	int,
	@Director2Name	varchar(256),
	@Director2DOB	date,
	@Director2Address1	varchar(64),
	@Director2Address2	varchar(64),
	@Director2City	varchar(64),
	@Director2State	int,
	@Director2Postcode	varchar(16),
	@Director2Country	int,
	@Director3Name	varchar(256),
	@Director3DOB	date,
	@Director3Address1	varchar(64),
	@Director3Address2	varchar(64),
	@Director3City	varchar(64),
	@Director3State	int,
	@Director3Postcode	varchar(16),
	@Director3Country	int,
	@MerchantCategoryIndustry	varchar(64),
	@MerchantCategoryCode	varchar(64),
	@ExportRestrictionsApply	bit,
	@OfficeID	varchar(64),
	@AccountName	varchar(256),
	@SettlementAccountNumber	varchar(1024),
	@IsCreditCheck	bit,
	@IsKYCCheck	bit,
	@IsSignedSubMerchantAgreement	bit,
	@IsWebsiteComplianceCheck	bit,
	@IsHighRiskMCCCodeCheck	bit,
	@IsPCIComplianceCheck	bit
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-03-15 14:52:58$-->
--<!--$ModifiedBy: Bo Li <bo.li@bambora.com>$-->
--<!--$Comment: icm-57$-->
--<!--$Commit$-->
/*
 Purpose: MID Allocation
*/
 SET NOCOUNT ON
 DECLARE @ret int

  --init 
 select @ret = -1


  if not exists(select 1 from tblUserModule where UserID = @UserID and ModuleID = 6)
   begin
	raiserror ('Permission denied. Abort.',16,1)
	return 
   end



  exec CAMS.dbo.spSetContextInfo @Section = 7, @Value = 'y'

  exec @ret = CAMS.dbo.spLogApplicationAndAssignMID 
		@MerchantID = @MerchantID OUTPUT,
		@PayMarkID	= @PayMarkID OUTPUT,
		@CountryID	= @CountryID,
		@PartnerID	= @PartnerID,
		@AccountID = @AccountID,
		@AccountType = @AccountType,
		@ApplicationID = @ApplicationID,
		@ProductType = @ProductType,
		@ContactName = @ContactName,
		@GSTNumber = @GSTNumber,
		@TradingName = @TradingName,
		@LegalName = @LegalName,
		@DescriptionOfBusiness	= @DescriptionOfBusiness,
		@BusinessAddress1 = @BusinessAddress1,
		@BusinessAddress2 = @BusinessAddress2,
		@BusinessCity = @BusinessCity,
		@BusinessState = @BusinessState ,
		@BusinessPostcode = @BusinessPostcode,
		@BusinessCountry = @BusinessCountry,
		@IsThePrimaryBusinessFaceToFace	= @IsThePrimaryBusinessFaceToFace,
		@IsBillerProvided = @IsBillerProvided,
		@AnnualCardSalesTurnover = @AnnualCardSalesTurnover,
		@AverageTicketSize = @AverageTicketSize,
		@SubMerchantBusinessIdentifier	= @SubMerchantBusinessIdentifier,
		@RefundPolicy = @RefundPolicy,
		@CancellationPolicy	= @CancellationPolicy,
		@DeliveryTimeframes	= @DeliveryTimeframes,
		@PaymentPageSample	= @PaymentPageSample,
		@ReceiptSample = @ReceiptSample,
		@BusinessPhone = @BusinessPhone,
		@Privatephone = @Privatephone,
		@WebAddress = @WebAddress,
		@EmailAddress = @EmailAddress,
		@FaxNumber = @FaxNumber,
		@Director1Name = @Director1Name,
		@Director1DOB = @Director1DOB,
		@Director1Address1 = @Director1Address1,
		@Director1Address2 = @Director1Address2,
		@Director1City = @Director1City,
		@Director1State	= @Director1State,
		@Director1Postcode = @Director1Postcode,
		@Director1Country = @Director1Country,
		@Director2Name = @Director2Name,
		@Director2DOB = @Director2DOB,
		@Director2Address1 = @Director2Address1,
		@Director2Address2 = @Director2Address2,
		@Director2City = @Director2City,
		@Director2State = @Director2State,
		@Director2Postcode = @Director2Postcode,
		@Director2Country = @Director2Country,
		@Director3Name = @Director3Name,
		@Director3DOB = @Director3DOB,
		@Director3Address1 = @Director3Address1,
		@Director3Address2 = @Director3Address2,
		@Director3City = @Director3City,
		@Director3State	= @Director3State,
		@Director3Postcode	= @Director3Postcode,
		@Director3Country = @Director3Country,
		@MerchantCategoryIndustry = @MerchantCategoryIndustry,
		@MerchantCategoryCode = @MerchantCategoryCode,
		@ExportRestrictionsApply = @ExportRestrictionsApply,
		@OfficeID = @OfficeID,
		@AccountName = @AccountName,
		@SettlementAccountNumber = @SettlementAccountNumber,
		@IsCreditCheck = @IsCreditCheck,
		@IsKYCCheck = @IsKYCCheck,
		@IsSignedSubMerchantAgreement = @IsSignedSubMerchantAgreement,
		@IsWebsiteComplianceCheck = @IsWebsiteComplianceCheck,
		@IsHighRiskMCCCodeCheck = @IsHighRiskMCCCodeCheck,
		@IsPCIComplianceCheck = @IsPCIComplianceCheck,
		@UserID	= @UserID

 exec @ret = cams.dbo.spApproveApplicationMID 
		@CountryID = @CountryID,
		@PartnerID	= @PartnerID,
		@AccountID	= @AccountID,
		@UserID	= @UserID

Exit_Handle:
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

Go

Grant EXEC on spWebLogApplicationAndAssignMID to eCAMS_Role
Go

