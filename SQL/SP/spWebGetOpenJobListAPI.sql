USE [CAMS]
GO

if object_id('spWebGetOpenJobListAPI') is null
	exec ('create procedure dbo.spWebGetOpenJobListAPI as return 1')
go


alter proc dbo.spWebGetOpenJobListAPI 
		@UserID int,
		@ClientID varchar(3) = NULL,
		@JobType varchar(20) = NULL
AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/09/15 15:21 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetOpenJobListAPI.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Retrieve Open Job List   
*/

 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 SET NOCOUNT ON;

declare @ret int
exec @ret = dbo.spWebIsUserAllowedAPIAccessNG @UserID = @UserID, @MethodID = 4	--1: UpdateJobNote; 2: CloseJob; 3: LogNewJob; 4: GetOpenJobList; 5: GetJob; 6: GetCall
if @ret <> 0 return @ret

if ISNULL(@ClientID, 'ALL') = 'ALL'
  begin
	select
			cast(c.CallNumber as bigint) as JobID,
			dbo.fnGetClientJobType (c.ClientID, 4) as JobType,
			c.ProblemNumber AS ClientRef, 
			c.ProjectNo,
			c.Status,
			c.StatusNote,
			NULL as DelayReason,
			c.SpecialConditions1 as SpecInstruct,
			c.LoggedDateTime,
			dbo.fnGetOperatorName(c.LoggedBy) as LoggedBy,
			NULL as JobMethod,
			c.Fault,
			c.RequiredDateTimeLocal as SLA,
			cm.CallMemo as JobNotes,
			
			c.MerchantID, 
			c.[Name] as MerchantName,
			c.Address as MerchantAddress,
			c.Address2 as MerchantAddress2,
			c.City as MerchantCity,
			c.Postcode as MerchantPostCode,
			c.State as MerchantState,
			c.Caller as ContactName,
			c.CallerPhone as PhoneNumber,
			null as AlternatePhone,
			c.Region,
			c.TradingHours,
			c.TerminalID,
			NULL as OldTerminalID,
			NULL AS CAIC,
			c.DeviceType,
			null as OldDeviceType
			
		from vwCalls c JOIN vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					left outer join Call_Memos cm on c.CallNumber = cm.CallNumber
			where u.UserID = @UserID
				and (isnull(@JobType, 'all') = 'all' or @JobType = 'swap')

	union all

	select 
			cast(j.JobID as bigint) as JobID,
			j.JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.Status, 
			j.StatusNote,
			j.DelayReason,
			j.SpecInstruct,
			j.LoggedDateTime,
			dbo.fnGetOperatorName(j.LoggedBy) as LoggedBy,
			j.JobMethod,
			NULL as Fault,
			j.RequiredDateTimeLocal as SLA,
			j.Notes as JobNotes,
			
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.Address as MerchantAddress,
			j.Address2 as MerchantAddress2,
			j.City as MerchantCity,
			j.Postcode as MerchantPostCode,
			j.State as MerchantState,
			j.Contact as ContactName,
			j.PhoneNumber,
			j.MobileNumber as AlternatePhone,
			j.Region,
			NULL AS [Trading Hours],
			j.TerminalID,
			j.OldTerminalID,
			j.CAIC,
			j.DeviceType,
			j.OldDeviceType
			
		from vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
			where u.UserID = @UserID
				and (isnull(@JobType, 'all') = 'all' or j.JobType = @JobType )
		 order by JobID;
  end
 else
   begin
	select
			cast(c.CallNumber as bigint) as JobID,
			dbo.fnGetClientJobType (c.ClientID, 4) as JobType,
			c.ProblemNumber AS ClientRef, 
			c.ProjectNo,
			c.Status,
			c.StatusNote,
			NULL as DelayReason,
			c.SpecialConditions1 as SpecInstruct,
			c.LoggedDateTime,
			dbo.fnGetOperatorName(c.LoggedBy) as LoggedBy,
			NULL as JobMethod,
			c.Fault,
			c.RequiredDateTimeLocal as SLA,
			cm.CallMemo as JobNotes,
			
			c.MerchantID, 
			c.[Name] as MerchantName,
			c.Address as MerchantAddress,
			c.Address2 as MerchantAddress2,
			c.City as MerchantCity,
			c.Postcode as MerchantPostCode,
			c.State as MerchantState,
			c.Caller as ContactName,
			c.CallerPhone as PhoneNumber,
			null as AlternatePhone,
			c.Region,
			c.TradingHours,
			c.TerminalID,
			NULL as OldTerminalID,
			NULL AS CAIC,
			c.DeviceType,
			null as OldDeviceType
			
		from vwCalls c JOIN vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					left outer join Call_Memos cm on c.CallNumber = cm.CallNumber
			where u.UserID = @UserID
				and c.ClientID = @ClientID
				and (isnull(@JobType, 'all') = 'all' or @JobType = 'swap')

	union all

	select 
			cast(j.JobID as bigint) as JobID,
			j.JobType,
			j.ProblemNumber AS ClientRef, 
			j.ProjectNo,
			j.Status, 
			j.StatusNote,
			j.DelayReason,
			j.SpecInstruct,
			j.LoggedDateTime,
			dbo.fnGetOperatorName(j.LoggedBy) as LoggedBy,
			j.JobMethod,
			NULL as Fault,
			j.RequiredDateTimeLocal as SLA,
			j.Notes as JobNotes,
			
			j.MerchantID, 
			j.[Name] as MerchantName,
			j.Address as MerchantAddress,
			j.Address2 as MerchantAddress2,
			j.City as MerchantCity,
			j.Postcode as MerchantPostCode,
			j.State as MerchantState,
			j.Contact as ContactName,
			j.PhoneNumber,
			j.MobileNumber as AlternatePhone,
			j.Region,
			NULL AS [Trading Hours],
			j.TerminalID,
			j.OldTerminalID,
			j.CAIC,
			j.DeviceType,
			j.OldDeviceType
			
		from vwIMSJob j JOIN UserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
			where u.UserID = @UserID
				and j.ClientID = @ClientID
				and (isnull(@JobType, 'all') = 'all' or j.JobType = @JobType )
		 order by JobID;
  end


/*

dbo.spWebGetOpenJobListAPI 
		@UserID = 210001,
		@ClientID  = 'cba',
		@JobType = 'all'

dbo.spWebGetOpenJobListAPI 
		@UserID = 210000,
		@ClientID  = 'cba',
		@JobType = 'swap'

dbo.spWebGetOpenJobListAPI 
		@UserID = 210000,
		@ClientID  = 'cba',
		@JobType = 'install'

dbo.spWebGetOpenJobListAPI 
		@UserID = 210000,
		@ClientID  = 'cba',
		@JobType = 'upgrade'

dbo.spWebGetOpenJobListAPI 
		@UserID = 210000,
		@ClientID  = 'cba',
		@JobType = 'deinstall'
*/
GO

Grant EXEC on spWebGetOpenJobListAPI to eCAMS_Role
Go
