Use CAMS
Go

if object_id('spWebGetTerminalJobListNG') is null
	exec ('create procedure dbo.spWebGetTerminalJobListNG as return 1')
go

Alter Procedure dbo.spWebGetTerminalJobListNG 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20)
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/08/15 10:39 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetTerminalJobListNG.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 SELECT 
	cast(JobID as bigint) as JobID,
	dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
	'Open' as Status,
	j.ClientID, 
	j.MerchantID, 
	j.TerminalID,
	j.OldTerminalID,
   	j.LoggedDateTime,
	j.[Name] as MerchantName,
	j.ProblemNumber,
	dbo.fnGetOperatorName(j.LoggedBy) as LoggedBy
	FROM vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
	WHERE j.ClientID = @ClientID 
		AND (TerminalID = @TerminalID OR OldTerminalID = @TerminalID)
		AND u.UserID = @UserID
 UNION
 SELECT
	cast(JobID as bigint) as JobID,
	dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
	'Closed' as Status,
	j.ClientID, 
	j.MerchantID, 
	j.TerminalID,
	j.OldTerminalID,
   	j.LoggedDateTime,
	j.[Name] as MerchantName,
	j.ProblemNumber,
	dbo.fnGetOperatorName(j.LoggedBy) as LoggedBy
	FROM vwIMSJobHistory j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
	WHERE j.ClientID = @ClientID 
		AND (TerminalID = @TerminalID OR OldTerminalID = @TerminalID)
		AND u.UserID = @UserID

 UNION

 SELECT 
	CallNumber as JobID,
	dbo.fnGetClientJobType(j.ClientID, 4) as Type,
	'Open' as Status,
	j.ClientID, 
	j.MerchantID,
	j.TerminalID,
	NULL as OldTerminalID,
   	j.LoggedDateTime,
	j.[Name] as MerchantName,
	j.ProblemNumber,
	dbo.fnGetOperatorName(j.LoggedBy) as LoggedBy
	FROM vwCalls j JOIN vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
	WHERE j.ClientID = @ClientID 
		AND TerminalID = @TerminalID
		AND u.UserID = @UserID

 UNION
 SELECT 
	CallNumber as JobID,
	dbo.fnGetClientJobType(j.ClientID, 4) as Type,
	'Closed' as Status,
	j.ClientID, 
	j.MerchantID,
	j.TerminalID,
	NULL as OldTerminalID,
   	j.LoggedDateTime,
	j.[Name] as MerchantName,
	j.ProblemNumber,
	dbo.fnGetOperatorName(j.LoggedBy) as LoggedBy
	FROM vwCallsHistory j JOIN vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
	WHERE j.ClientID = @ClientID 
		AND TerminalID = @TerminalID
		AND u.UserID = @UserID
 Order by LoggedDateTime desc
--Return
RETURN @@ERROR

GO

Grant EXEC on spWebGetTerminalJobListNG to eCAMS_Role
Go

/*

exec spWebGetTerminalJobListNG 
		@UserID=210000,
		@ClientID='cba',
		@TerminalID='95596500'


*/
GO




