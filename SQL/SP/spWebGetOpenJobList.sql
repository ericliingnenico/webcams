Use CAMS
Go


ALTER Procedure [dbo].[spWebGetOpenJobList] 
	(
		@UserID int,
		@ClientID varchar(3),
		@JobType varchar(20),
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
 Purpose: Enforce to look up tblUserClient.   
 7/05/2007: Filter on Status
*/

 DECLARE @STATUS_ALL int
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 --init
 SELECT @STATUS_ALL = 22

 IF ISNULL(@ClientID, 'ALL') = 'ALL'
  BEGIN
	 IF ISNULL(@State, 'ALL') = 'ALL'
	 	SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as JobID,
			j.ClientID, 
			ProblemNumber AS ProblemNo, 
			j.DeviceType,
			MerchantID, 
			CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
			     ELSE TerminalID 
			END as TerminalID,
			CASE WHEN JobType = 'UPGRADE' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + ''')">' + OldTerminalID + '</A>'
			     ELSE OldTerminalID 
			END as OldTerminalID,
			Status, 
			j.StatusNote,
		    LoggedDateTime,
			[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
			CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
			     WHEN JobType = 'UPGRADE' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + '">View</A>'
			     ELSE NULL 
			END as SiteEquipment

			FROM vwIMSJob j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
					JOIN tblWebJobFilterStatus ws ON j.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN j.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 0
			WHERE u.UserID = @UserID
				AND JobType = @JobType
			 Order by JobID
	 ELSE
	 	SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as JobID,
			j.ClientID, 
			ProblemNumber AS ProblemNo,
			j.DeviceType,
			MerchantID, 
			CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
			     ELSE TerminalID 
			END as TerminalID,
			CASE WHEN JobType = 'UPGRADE' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + ''')">' + OldTerminalID + '</A>'
			     ELSE OldTerminalID 
			END as OldTerminalID,
			Status, 
			j.StatusNote,
		    LoggedDateTime,
			[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
			CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
			     WHEN JobType = 'UPGRADE' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + '">View</A>'
			     ELSE NULL 
			END as SiteEquipment
			FROM vwIMSJob j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
					JOIN tblWebJobFilterStatus ws ON j.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN j.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 0
			WHERE u.UserID = @UserID
				AND State = @State
				AND JobType = @JobType
			 Order by JobID
  END
 ELSE
  BEGIN
	 IF ISNULL(@State, 'ALL') = 'ALL'
	 	SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as JobID,
			j.ClientID, 
			ProblemNumber AS ProblemNo,
			j.DeviceType,
			MerchantID, 
			CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
			     ELSE TerminalID 
			END as TerminalID,
			CASE WHEN JobType = 'UPGRADE' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + ''')">' + OldTerminalID + '</A>'
			     ELSE OldTerminalID 
			END as OldTerminalID,
			Status, 
			j.StatusNote,
		    LoggedDateTime,
			[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
			CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
			     WHEN JobType = 'UPGRADE' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + '">View</A>'
			     ELSE NULL 
			END as SiteEquipment
			FROM vwIMSJob j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
					JOIN tblWebJobFilterStatus ws ON j.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN j.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 0
			WHERE u.UserID = @UserID
				AND j.ClientID = @ClientID
				AND JobType = @JobType
			 Order by JobID
	 ELSE
	 	SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as JobID,
			j.ClientID, 
			ProblemNumber AS ProblemNo,
			j.DeviceType,
			MerchantID, 
			CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
			     ELSE TerminalID 
			END as TerminalID,
			CASE WHEN JobType = 'UPGRADE' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + ''')">' + OldTerminalID + '</A>'
			     ELSE OldTerminalID 
			END as OldTerminalID,
			Status, 
			j.StatusNote,
		    LoggedDateTime,
			[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
			CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
			     WHEN JobType = 'UPGRADE' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + '">View</A>'
			     ELSE NULL 
			END as SiteEquipment
			FROM vwIMSJob j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
					JOIN tblWebJobFilterStatus ws ON j.StatusID = CASE WHEN @FilterStatusID = @STATUS_ALL THEN j.StatusID ELSE ws.StatusID END AND ws.FilterStatusID = @FilterStatusID AND ws.IsSwap = 0
			WHERE u.UserID = @UserID
				AND j.ClientID = @ClientID
				AND State = @State
				AND JobType = @JobType
			 Order by JobID

  END




GO

Grant EXEC on spWebGetOpenJobList to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebGetOpenJobList 
	(
		@UserID int,
		@ClientID varchar(3),
		@JobType varchar(20),
		@FilterStatusID tinyint,
		@State varchar(3) = null
	)
	AS
--<!--$$Revision: 11 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/05/03 15:22 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetOpenJobList.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC CAMS.dbo.spWebGetOpenJobList @UserID = @UserID, @ClientID = @ClientID, @JobType = @JobType, @FilterStatusID = @FilterStatusID, @State = @State
/*
spWebGetOpenJobList 199510, 'nab', 'install',22, 'all'
*/
Go

Grant EXEC on spWebGetOpenJobList to eCAMS_Role
Go
