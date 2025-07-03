Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebUpdateJobInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebUpdateJobInfo]
GO



Create Procedure dbo.spWebUpdateJobInfo 
	(
		@UserID int,
		@JobID bigint,
		@JobInfo varchar(4000)
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/04/15 16:20 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebUpdateJobInfo.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT OFF
 DECLARE @ret int

 EXEC @ret = CAMS.dbo.spWebUpdateJobInfo @UserID = @UserID, 
				@JobID = @JobID, 
				@JobInfo = @JobInfo

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar

 RETURN @ret

/*
spWebUpdateJobInfo 3, 187196

*/
Go


Grant EXEC on spWebUpdateJobInfo to eCAMS_Role
Go


Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebUpdateJobInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebUpdateJobInfo]
GO


Create Procedure dbo.spWebUpdateJobInfo 
	(
		@UserID int,
		@JobID bigint,
		@JobInfo varchar(4000)	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/04/03 13:04 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebUpdateJobInfo.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Update Site details from Web Portal
 SET NOCOUNT OFF
 DECLARE @ret int,
		@ClientID varchar(3),
		@OperatorName varchar(50),
		@OperatorEmail varchar(100),
		@ServiceDeskEmail varchar(100),
		@JobTypeID tinyint,
		@Subject varchar(200)




 --init
 SELECT @ret = 0

 SELECT
	@Subject = 'UpdateJobInfo [JobID: ' + CAST(@JobID as varchar) + ' ]-',
	@JobInfo = dbo.fnCRLF() + 'Please update the job <JobID: ' + CAST(@JobID as varchar) + ' > with the info as below:' + dbo.fnCRLF()
				+ @JobInfo + dbo.fnCRLF()


 IF LEN(@JobID) = 11
	SELECT @ClientID = ClientID,
		@JobTypeID = 4,
		@Subject = @Subject + [Name]
	 FROM Calls WITH (NOLOCK) WHERE CallNumber = @JobID
 ELSE
	SELECT @ClientID = ClientID,
			@JobTypeID = JobTypeID,
		@Subject = @Subject + [Name]
	   FROM IMS_Jobs WITH (NOLOCK) WHERE JobID = @JobID


 --get email address
 SELECT  @ServiceDeskEmail = EmailAddress
   FROM tblClientJobEmailList
	WHERE ClientID = @ClientID
		AND JobTypeID = @JobTypeID 

 IF @ServiceDeskEmail IS NULL
	 SELECT  @ServiceDeskEmail = EmailAddress
	   FROM tblClientJobEmailList
		WHERE ClientID = @ClientID
			AND JobTypeID = 0



 --verify before update
 IF EXISTS(SELECT 1 FROM WebCAMS.dbo.tblUser u JOIN WebCAMS.dbo.vwUserClient uc ON u.UserID = uc.UserID 
			WHERE u.UserID = @UserID AND uc.ClientID = @ClientID)
  BEGIN

	SELECT @OperatorName = ISNULL(UserName, @ClientID + CAST(@UserID as varchar)),
			@OperatorEmail = EmailAddress
	   FROM WebCAMS.dbo.tblUser
	  WHERE UserID = @UserID

	 --append time stamp
	SELECT @JobInfo = @JobInfo + '  '  + dbo.fnGetOperatorStamp(@UserID) + dbo.fnCRLF()
	
	IF LEN(@JobID) = 11
	 BEGIN	  
		 EXEC @ret  = dbo.spAddNotesToCall
			@CallNumber = @JobID,
			@NewNotes = @JobInfo,
			@OperatorName = @OperatorName

	 END
	ELSE
	 BEGIN	  
		 EXEC @ret  = dbo.spAddNotesToIMSJob
			@JobID = @JobID,
			@NewNotes = @JobInfo,
			@OperatorName = @OperatorName


	 END
	
	--log the request
	--tblWebUpdateInfoRequestLog
	INSERT tblWebUpdateInfoRequestLog(
			JobID,
			UserID,
			JobInfo,
			LoggedDateTime)
	  SELECT @JobID,
			@UserID,
			@JobInfo,	
			GetDate()
	SELECT @ret = @@ERROR





	IF EXISTS(SELECT 1 FROM tblControl WHERE Attribute = 'IsLiveDB' AND AttrValue = 'YES')
	  BEGIN
		SELECT @ServiceDeskEmail = @ServiceDeskEmail --+ ';bli@keycorp.net'
	  END
	ELSE
	  BEGIN
		SELECT @ServiceDeskEmail = 'bli@keycorp.net'
	  END


	--send email
	if @ServiceDeskEmail is not null
	 begin
		EXEC Master.dbo.upSendCDOsysMail 
			@From = @OperatorEmail, 
			@To = @ServiceDeskEmail, 
			@Subject = @Subject, 
			@Body = @JobInfo
	 end

	SELECT @ret = @@ERROR
  END

 return @ret
/*
dbo.spWebUpdateJobInfo 
		@UserID = 199955,
		@JobID = 699793,
		@JobInfo ='test'

*/
GO

Grant EXEC on spWebUpdateJobInfo to eCAMS_Role
Go
