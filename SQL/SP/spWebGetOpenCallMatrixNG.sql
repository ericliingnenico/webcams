Use CAMS
Go
if object_id('spWebGetOpenCallMatrixNG') is null
	exec ('create procedure dbo.spWebGetOpenCallMatrixNG as return 1')
go

Alter Procedure dbo.spWebGetOpenCallMatrixNG 
	(
		@UserID int,
		@ClientID varchar(3) = NULL,
		@IsSwap bit = null
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 13/08/15 9:57 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetOpenCallMatrixNG.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Retrieve Open Call Matrix
	@IsSwap = null: return all calls
	@IsSwap = 1: return Swap calls only
	@IsSwap = 0: return ServiceDesk calls only

	added result set to speed up WebCAMS refreshGauget - refer ux js code - dashboard.viewmodel.js
*/
 DECLARE @STATUS_ALL int
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 --init
 SELECT @STATUS_ALL = 22
 IF ISNULL(@ClientID, 'ALL') = 'ALL'
  BEGIN
	select 	ws.FilterStatusID,
			FilterStatus = fs.Status,
			Qty = count(distinct c.CallNumber)
		from  vwCalls c JOIN vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					JOIN tblWebJobFilterStatus ws ON c.StatusID = ws.StatusID AND ws.IsSwap = 1
					join tblStatus fs on fs.StatusID = ws.FilterStatusID
		 where u.UserID = @UserID
				and ((@IsSwap is null) or (@IsSwap = 1 and c.AssignedToFSP = 1) or (@IsSwap = 0 and c.AssignedToFSP = 0))
		 group by ws.FilterStatusID, fs.Status
  END
 ELSE
  BEGIN
	select 	ws.FilterStatusID,
			FilterStatus = fs.Status,
			Qty = count(distinct c.CallNumber)
		from  vwCalls c JOIN vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					JOIN tblWebJobFilterStatus ws ON c.StatusID = ws.StatusID AND ws.IsSwap = 1
					join tblStatus fs on fs.StatusID = ws.FilterStatusID
		 where u.UserID = @UserID
				AND c.ClientID = @ClientID
				and ((@IsSwap is null) or (@IsSwap = 1 and c.AssignedToFSP = 1) or (@IsSwap = 0 and c.AssignedToFSP = 0))
		 group by ws.FilterStatusID, fs.Status

  END
GO

Grant EXEC on spWebGetOpenCallMatrixNG to eCAMS_Role
Go

/*
dbo.spWebGetOpenCallMatrixNG 
		@UserID = 210001,
		@ClientID  = 'cba',
		@IsSwap = 0


	
*/

