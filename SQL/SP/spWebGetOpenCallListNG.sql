Use CAMS
Go
if object_id('spWebGetOpenCallListNG') is null
	exec ('create procedure dbo.spWebGetOpenCallListNG as return 1')
go

Alter Procedure dbo.spWebGetOpenCallListNG 
	(
		@UserID int,
		@ClientID varchar(3) = NULL,
		@FilterStatusID tinyint,
		@State varchar(3) = null,
		@IsSwap bit = null
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/09/15 16:01 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetOpenCallListNG.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Retrieve Open Call List   
	@IsSwap = null: return all calls
	@IsSwap = 1: return Swap calls only
	@IsSwap = 0: return ServiceDesk calls only


*/
 DECLARE @STATUS_ALL int
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 --init
 SELECT @STATUS_ALL = 22
 IF ISNULL(@ClientID, 'ALL') = 'ALL'
  BEGIN
	 IF ISNULL(@State, 'ALL') = 'ALL'
	  begin
		SELECT 
			c.CallNumber as JobID,
			c.ProblemNumber AS ClientRef, 
			c.ProjectNo,
			c.DeviceType,
			c.TerminalID,
			c.MerchantID, 
			c.[Name] as MerchantName,
			c.City,
			c.Postcode,
			c.Status,
			c.State,
			ws.FilterStatusID,
			c.StatusID

			FROM vwCalls c JOIN vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					JOIN tblWebJobFilterStatus ws ON c.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN c.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID  AND ws.IsSwap = 1
			WHERE u.UserID = @UserID
				and ((@IsSwap is null) or (@IsSwap = 1 and c.AssignedToFSP = 1) or (@IsSwap = 0 and c.AssignedToFSP = 0))
			 Order by CallNumber
	  end
	 ELSE
	  begin
		SELECT 
			c.CallNumber as JobID,
			c.ProblemNumber AS ClientRef, 
			c.ProjectNo,
			c.DeviceType,
			c.TerminalID,
			c.MerchantID, 
			c.[Name] as MerchantName,
			c.City,
			c.Postcode,
			c.Status,
			c.State,
			ws.FilterStatusID,
			c.StatusID
			FROM vwCalls c JOIN vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					JOIN tblWebJobFilterStatus ws ON c.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN c.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 1
			WHERE u.UserID = @UserID 
				AND State = @State
				and ((@IsSwap is null) or (@IsSwap = 1 and c.AssignedToFSP = 1) or (@IsSwap = 0 and c.AssignedToFSP = 0))
			 Order by CallNumber
	  end

  END
 ELSE
  BEGIN
	 IF ISNULL(@State, 'ALL') = 'ALL'
	  begin
		SELECT 
			c.CallNumber as JobID,
			c.ProblemNumber AS ClientRef, 
			c.ProjectNo,
			c.DeviceType,
			c.TerminalID,
			c.MerchantID, 
			c.[Name] as MerchantName,
			c.City,
			c.Postcode,
			c.Status,
			c.State,
			ws.FilterStatusID,
			c.StatusID
			FROM vwCalls c JOIN vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					JOIN tblWebJobFilterStatus ws ON c.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN c.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 1
			WHERE u.UserID = @UserID
				AND c.ClientID = @ClientID
				and ((@IsSwap is null) or (@IsSwap = 1 and c.AssignedToFSP = 1) or (@IsSwap = 0 and c.AssignedToFSP = 0))

			 Order by CallNumber
	  end
	 ELSE
	  begin
		SELECT 
			c.CallNumber as JobID,
			c.ProblemNumber AS ClientRef, 
			c.ProjectNo,
			c.DeviceType,
			c.TerminalID,
			c.MerchantID, 
			c.[Name] as MerchantName,
			c.City,
			c.Postcode,
			c.Status,
			c.State,
			ws.FilterStatusID,
			c.StatusID
			FROM vwCalls c JOIN vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					JOIN tblWebJobFilterStatus ws ON c.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN c.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 1
			WHERE u.UserID = @UserID AND State = @State
				AND c.ClientID = @ClientID
				and ((@IsSwap is null) or (@IsSwap = 1 and c.AssignedToFSP = 1) or (@IsSwap = 0 and c.AssignedToFSP = 0))
			 Order by CallNumber
	 end


  END
GO

Grant EXEC on spWebGetOpenCallListNG to eCAMS_Role
Go

/*
dbo.spWebGetOpenCallListNG 
		@UserID = 210000,
		@ClientID  = 'cba',
		@FilterStatusID = 22,
		@State = 'all',
		@IsSwap = null


	
*/

