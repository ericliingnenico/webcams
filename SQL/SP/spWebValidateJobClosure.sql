Use CAMS
Go
if exists(Select 1 from sysobjects where name = 'spWebValidateJobClosure')
	drop proc spWebValidateJobClosure
go
CREATE proc spWebValidateJobClosure 
	(
		@UserID int,
		@JobID bigint,
		@From tinyint
	)
as

--Purpose: verification before closure
--@From = 1: Desktop
--@From = 2: PDA
DECLARE @ret int,
	@IsSurveyMandatory	bit,
	@IsSignatureMandatory	bit,
	@ClientID varchar(3),
	@JobType varchar(20)

 --init
 set @ret = 0


 if not exists(select 1 from WebCAMS.dbo.tblUser where UserID = @UserID	and IsActive = 1)
  begin
	select @ret = -1
	raiserror('Invalid user.',16,1)
	GOTO Exit_Handle
  end
  

 if dbo.fnIsSwapCall(@JobID) = 1
  begin
	select @ClientID = ClientID,
			@JobType = 'SWAP'
	  from Calls
	  where CallNumber = CAST(@JobID as varchar)
  end
 else
  begin
	select @ClientID = ClientID,
			@JobType = JobType
	  from vwIMSJob
	  where JobID = @JobID
  end
   

 --if @From = 1  -- From Desktop
 -- begin
 ----save the signature image
 --IF not EXISTS(SELECT 1 FROM tblMerchantSignedJobSheet WHERE JobID = @JobID)
 -- BEGIN
	--select @ret = -1
	--raiserror('Please scan and upload Merchant Signed Jobsheet prior to close the job.',16,1)
	--GOTO Exit_Handle
 -- END
  --end

 if @From = 2  -- From PDA
  begin
	select @IsSurveyMandatory = IsSurveyMandatory,
			@IsSignatureMandatory = IsSignatureMandatory
		from tblSurvey 
		where ClientID = @ClientID
			and JobType = @JobType
			and IsActive = 1
			
	--verify if survey needs
	if @IsSurveyMandatory = 1 and not exists(select 1 from tblSurveyAnswer where JobID = @JobID)
	 begin
		select @ret = -1
		raiserror('Please conduct site survey prior closure.',16,1)
		GOTO Exit_Handle
	 end
	--verify if signature needs
	if @IsSignatureMandatory = 1 and not exists(select 1 from tblMerchantAcceptance where JobID = @JobID)
	 begin
		select @ret = -1
		raiserror('Please collect merchant signature prior closure.',16,1)
		GOTO Exit_Handle
	 end
	
  end
  
--Return
Exit_Handle:
RETURN @ret
Go

grant exec on dbo.spWebValidateJobClosure to CAMSApp, eCAMS_Role
go


Use webCAMS
go

if exists(Select 1 from sysobjects where name = 'spWebValidateJobClosure')
	drop proc spWebValidateJobClosure
go

CREATE Procedure dbo.spWebValidateJobClosure 
	(
		@UserID int,
		@JobID bigint,
		@From tinyint
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/06/11 17:34 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebValidateJobClosure.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebValidateJobClosure 
		@UserID = @UserID,
		@JobID = @JobID,
		@From = @From


 SELECT @ret  --buble up to SqlHelper.ExecuteScalar

 RETURN @ret

/*
spWebValidateJobClosure 199516, 1234, '23'
*/
Go

GRANT EXEC on spWebValidateJobClosure to eCAMS_Role
Go
