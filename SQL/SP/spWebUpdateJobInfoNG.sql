USE CAMS
go

if object_id('spWebUpdateJobInfoNG') is null
	exec ('create procedure dbo.spWebUpdateJobInfoNG as return 1')
go


alter Procedure dbo.spWebUpdateJobInfoNG 
	(
		@UserID int,
		@JobID bigint,
		@JobInfo varchar(4000)	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 18/11/15 16:25 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebUpdateJobInfoNG.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add JobNote
 SET NOCOUNT OFF
 DECLARE @ret int,
		@ClientID varchar(3),
		@OperatorName varchar(50),
		@OperatorEmail varchar(500),
		@ServiceDeskEmail varchar(500),
		@JobTypeID tinyint,
		@Subject varchar(200),
		@Message varchar(max),
		@AssignedTo int


 --init
 exec @ret = dbo.spWebIsUserAllowedAPIAccessNG @UserID = @UserID, @MethodID = 1	--1: UpdateJobNote; 2: CloseJob; 3: LogNewJob; 4: GetOpenJobList; 5: GetJob; 6: GetCall
 if @ret <> 0 return @ret

 SELECT
	@Subject = 'UpdateJobInfo [JobID: ' + CAST(@JobID as varchar) + ' ]-',
	@Message = dbo.fnCRLF() + 'The job <JobID: ' + CAST(@JobID as varchar) + ' > notes has been updated with the info as below:' + dbo.fnCRLF()
				+ @JobInfo + dbo.fnCRLF()


 IF LEN(@JobID) = 11
	SELECT @ClientID = ClientID,
		@JobTypeID = 4,
		@AssignedTo = AssignedTo,
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
 IF EXISTS(SELECT 1 FROM UserClientDeviceType
			WHERE UserID = @UserID AND ClientID = @ClientID)
  BEGIN

	SELECT @OperatorName = ISNULL(UserName, @ClientID + CAST(@UserID as varchar)),
			@OperatorEmail = Email
	   FROM AspNetUsers
	  WHERE LegacyUserId = @UserID

	 --append time stamp
	SELECT @JobInfo = @JobInfo + '  '  + dbo.fnGetOperatorStamp(@UserID) + dbo.fnCRLF()
	
	IF LEN(@JobID) = 11
	 BEGIN	  
		 EXEC @ret  = dbo.spAddNotesToCall
			@CallNumber = @JobID,
			@NewNotes = @JobInfo,
			@OperatorName = @OperatorName

		--Accenture - reassign call from POS Level3 (118) to POS Level2 (101)
		if @ClientID = 'CTX' and @AssignedTo = 118 and @JobInfo like '%AssignedToCXMarketingPOS%'  --due to unix whitespace 0xA0 posted from Accenture
		 begin
			update Calls
			 set AssignedTo = 101,
				StatusID = 2,
				AssignedDateTime = dbo.fnGetDate(),
				RequiredDateTime = null,
				RequiredDateTimeOffset = null,
				AgentSLADateTime = null,
				AgentSLADateTimeOffset = null,
				CurrentETADateTime = null,
				CurrentETADateTimeOffset = null,
				DueDateTime = null,
				DueDateTimeOffset = null,
				NextFollowUpDateTime = null,
				NextFollowUpDateTimeOffset = null
			 where CallNumber = @JobID
		 end

		--Accenture - reassign call from BOS Level3 (119, 136) to BOS Level2 (123)
		if @ClientID = 'CTX' and @AssignedTo in (119, 136) and @JobInfo like '%AssignedToCXMarketingBOS%'  --due to unix whitespace 0xA0 posted from Accenture
		 begin
			update Calls
			 set AssignedTo = 123,
				StatusID = 2,
				AssignedDateTime = dbo.fnGetDate(),
				RequiredDateTime = null,
				RequiredDateTimeOffset = null,
				AgentSLADateTime = null,
				AgentSLADateTimeOffset = null,
				CurrentETADateTime = null,
				CurrentETADateTimeOffset = null,
				DueDateTime = null,
				DueDateTimeOffset = null,
				NextFollowUpDateTime = null,
				NextFollowUpDateTimeOffset = null
			 where CallNumber = @JobID
		 end

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
			@Body = @Message

	 end

	SELECT @ret = @@ERROR
  END
 else
  begin
	raiserror('You do not have permission to update this job', 16, 1)
	set @ret = -1
  end

 return @ret
/*
declare @ret int
exec @ret = dbo.spWebUpdateJobInfoNG 
		@UserID = 210001,
		@JobID = 1828419,
		@JobInfo ='cag test'

select @ret

*/
GO

Grant EXEC on spWebUpdateJobInfoNG to eCAMS_Role
Go
