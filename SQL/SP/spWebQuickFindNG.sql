
Use CAMS
Go

if object_id('spWebQuickFindNG') is null
	exec ('create procedure dbo.spWebQuickFindNG as return 1')
go


ALTER Procedure dbo.spWebQuickFindNG 
	(
		@UserID int,
		@ClientID varchar(3),
		@Scope char(1),
		@TerminalID varchar(20) = NULL,
		@MerchantID varchar(16) = NULL,
		@ProblemNumber varchar(20) = NULL,
		@JobID bigint = NULL
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/08/15 10:55 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebQuickFindNG.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


 IF @TerminalID IS NOT NULL
  BEGIN
	 SELECT 
			cast(j.JobID as varchar) as JobID,
			dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Open' as Status, 
			j.State,
			j.LoggedDateTime
		FROM vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND (TerminalID = @TerminalID OR OldTerminalID = @TerminalID)
			AND u.UserID = @UserID
			
	 UNION
	 SELECT 
			cast(j.JobID as varchar) as JobID,
			dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Closed' as Status, 
			j.State,
			j.LoggedDateTime
		FROM vwIMSJobHistory  j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND (TerminalID = @TerminalID OR OldTerminalID = @TerminalID)
			AND u.UserID = @UserID
	 UNION
	
	 SELECT 
			j.CallNumber as JobID,
			dbo.fnGetClientJobType(j.ClientID, 4) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			null as OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Open' as Status,
			j.State,
			j.LoggedDateTime
		FROM vwCalls j JOIN vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE  @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND TerminalID = @TerminalID
			AND u.UserID = @UserID
	 UNION
	 SELECT 
			j.CallNumber as JobID,
			dbo.fnGetClientJobType(j.ClientID, 4) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			null as OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Closed' as Status,
			j.State,
			j.LoggedDateTime
		FROM vwCallsHistory j JOIN vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE  @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND TerminalID = @TerminalID
			AND u.UserID = @UserID

	 Order by LoggedDateTime DESC
	--Return
	RETURN @@ERROR
  END  ---IF @TerminalID IS NOT NULL

 IF @MerchantID IS NOT NULL
  BEGIN
	 SELECT 
			cast(j.JobID as varchar) as JobID,
			dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Open' as Status, 
			j.State,
			j.LoggedDateTime
		FROM vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE   @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND MerchantID = @MerchantID
			AND u.UserID = @UserID
	 UNION
	 SELECT 
			cast(j.JobID as varchar) as JobID,
			dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Closed' as Status, 
			j.State,
			j.LoggedDateTime
		FROM vwIMSJobHistory j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND MerchantID = @MerchantID
			AND u.UserID = @UserID

	 UNION
	
	 SELECT 
			j.CallNumber as JobID,
			dbo.fnGetClientJobType(j.ClientID, 4) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			null as OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Open' as Status,
			j.State,
			j.LoggedDateTime
		FROM vwCalls j JOIN vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE   @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND MerchantID = @MerchantID
			AND u.UserID = @UserID

	 UNION
	 SELECT 
			j.CallNumber as JobID,
			dbo.fnGetClientJobType(j.ClientID, 4) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			null as OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Closed' as Status,
			j.State,
			j.LoggedDateTime
		FROM vwCallsHistory j JOIN vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND MerchantID = @MerchantID
			AND u.UserID = @UserID

	 Order by LoggedDateTime DESC

	--Return
	RETURN @@ERROR
 END --IF @MerchantID IS NOT NULL

 IF @ProblemNumber IS NOT NULL
  BEGIN
	 SELECT 
			cast(j.JobID as varchar) as JobID,
			dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Open' as Status, 
			j.State,
			j.LoggedDateTime
		FROM vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND ProblemNumber = @ProblemNumber
			AND u.UserID = @UserID

	 UNION
	 SELECT 
			cast(j.JobID as varchar) as JobID,
			dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Closed' as Status, 
			j.State,
			j.LoggedDateTime
		FROM vwIMSJobHistory j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND ProblemNumber = @ProblemNumber
			AND u.UserID = @UserID

	 UNION
	
	 SELECT 
			j.CallNumber as JobID,
			dbo.fnGetClientJobType(j.ClientID, 4) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			null as OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Open' as Status,
			j.State,
			j.LoggedDateTime
		FROM vwCalls j JOIN vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND ProblemNumber = @ProblemNumber
			AND u.UserID = @UserID
	 UNION
	 SELECT 
			j.CallNumber as JobID,
			dbo.fnGetClientJobType(j.ClientID, 4) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			null as OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Closed' as Status,
			j.State,
			j.LoggedDateTime
		FROM vwCallsHistory j JOIN vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND ProblemNumber = @ProblemNumber
			AND u.UserID = @UserID

	 Order by LoggedDateTime DESC

	--Return
	RETURN @@ERROR

  END --IF @ProblemNumber IS NOT NULL

 IF @JobID IS NOT NULL
  BEGIN
	 SELECT 
			cast(j.JobID as varchar) as JobID,
			dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Open' as Status, 
			j.State,
			j.LoggedDateTime
		FROM vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND j.JobID = @JobID
			AND u.UserID = @UserID
			
	 UNION
	 SELECT 
			cast(j.JobID as varchar) as JobID,
			dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			j.OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Closed' as Status, 
			j.State,
			j.LoggedDateTime
		FROM vwIMSJobHistory  j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND j.JobID = @JobID
			AND u.UserID = @UserID
	 UNION
	 SELECT 
			j.CallNumber as JobID,
			dbo.fnGetClientJobType(j.ClientID, 4) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			null as OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Open' as Status,
			j.State,
			j.LoggedDateTime
		FROM vwCalls j JOIN vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE  @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND j.CallNumber = CAST(@JobID as varchar)
			AND u.UserID = @UserID
	 UNION
	 SELECT 
			j.CallNumber as JobID,
			dbo.fnGetClientJobType(j.ClientID, 4) as JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.DeviceType,
			j.TerminalID,
			null as OldTerminalID,
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.City,
			j.Postcode,
			'Closed' as Status,
			j.State,
			j.LoggedDateTime
		FROM vwCallsHistory j JOIN vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE  @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND j.CallNumber = CAST(@JobID as varchar)
			AND u.UserID = @UserID

	 Order by LoggedDateTime DESC
	--Return
	RETURN @@ERROR
  END  ---IF @JobID IS NOT NULL



GO

Grant EXEC on spWebQuickFindNG to eCAMS_Role
Go


/*
  exec dbo.spWebQuickFindNG @UserID=210000,@ClientID='CBA',@Scope='B',@TerminalID='35210200',@MerchantID=NULL,@ProblemNumber=NULL,@JobID=NULL
*/
Go