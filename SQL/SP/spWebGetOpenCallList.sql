Use CAMS
Go

ALTER Procedure [dbo].[spWebGetOpenCallList] 
	(
		@UserID int,
		@ClientID varchar(3) = NULL,
		@FilterStatusID tinyint,
		@State varchar(3) = null
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-10-03 09:36:52$-->
--<!--$ModifiedBy: Andrew Falzon <andrew.falzon@bambora.com>$-->
--<!--$Comment: CAMS-761 Add device type to job list and job view screens.$-->
/*
 Purpose: Retrieve Open Call List   
*/
 DECLARE @STATUS_ALL int
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 --init
 SELECT @STATUS_ALL = 22
 IF ISNULL(@ClientID, 'ALL') = 'ALL'
  BEGIN
	 IF ISNULL(@State, 'ALL') = 'ALL'
		SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as CallNumber,
	 		 c.ClientID, 
			ProblemNumber AS ProblemNo,
			c.DeviceType,
			MerchantID as MerchantID, 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + c.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
			Status, 
			c.StatusNote,
		    LoggedDateTime,
			[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
			'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + c.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment

			FROM vwCalls c JOIN WebCams.dbo.vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					JOIN tblWebJobFilterStatus ws ON c.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN c.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID  AND ws.IsSwap = 1
			WHERE u.UserID = @UserID
			 Order by CallNumber
	 ELSE
		SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as CallNumber,
	 		 c.ClientID, 
			ProblemNumber AS ProblemNo, 
			c.DeviceType,
			MerchantID as MerchantID, 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + c.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
			Status, 
			c.StatusNote,
		    LoggedDateTime,
			[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
			'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + c.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment


			FROM vwCalls c JOIN WebCams.dbo.vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					JOIN tblWebJobFilterStatus ws ON c.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN c.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 1
			WHERE u.UserID = @UserID 
				AND State = @State
			 Order by CallNumber
	
  END
 ELSE
  BEGIN
	 IF ISNULL(@State, 'ALL') = 'ALL'
		SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as CallNumber,
	 		 c.ClientID, 
			ProblemNumber AS ProblemNo, 
			c.DeviceType,
			MerchantID as MerchantID, 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + c.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
			Status, 
			c.StatusNote,
		    LoggedDateTime,
			[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
			'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + c.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment

			FROM vwCalls c JOIN WebCams.dbo.vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					JOIN tblWebJobFilterStatus ws ON c.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN c.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 1
			WHERE u.UserID = @UserID
				AND c.ClientID = @ClientID
			 Order by CallNumber
	 ELSE
		SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as CallNumber,
	 		 c.ClientID, 
			ProblemNumber AS ProblemNo, 
			c.DeviceType,
			MerchantID as MerchantID, 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + c.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
			Status, 
			c.StatusNote,
		    LoggedDateTime,
			[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
			'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + c.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment


			FROM vwCalls c JOIN WebCams.dbo.vwUserClientEquipmentCode u ON c.ClientID = u.ClientID AND c.EquipmentCodes = ISNULL(u.EquipmentCode, c.EquipmentCodes)
					JOIN tblWebJobFilterStatus ws ON c.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN c.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 1
			WHERE u.UserID = @UserID AND State = @State
				AND c.ClientID = @ClientID
			 Order by CallNumber

  END
GO

Grant EXEC on spWebGetOpenCallList to eCAMS_Role
Go

/*
dbo.spWebGetOpenCallList 
		@UserID = 200694,
		@ClientID  = 'cba',
		@FilterStatusID = 22,
		@State = 'all',
		@IsSwap = null


	
*/

Use WebCAMS
Go

Alter Procedure dbo.spWebGetOpenCallList 
	(
		@UserID int,
		@ClientID varchar(3) = NULL,
		@FilterStatusID tinyint,
		@State varchar(3) = null
	)
	AS
--<!--$$Revision: 12 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/05/03 15:22 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetOpenCallList.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC CAMS.dbo.spWebGetOpenCallList @UserID = @UserID, @ClientID = @ClientID, @FilterStatusID = @FilterStatusID, @State = @State

/*
spWebGetOpenCallList 1, 'nab', 'all'
*/

GO

Grant EXEC on spWebGetOpenCallList to eCAMS_Role
Go




