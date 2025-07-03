Use CAMS
Go


ALTER Procedure dbo.spWebQuickFind 
	(
		@UserID int,
		@ClientID varchar(3),
		@Scope char(1),
		@TerminalID varchar(20) = NULL,
		@MerchantID varchar(16) = NULL,
		@ProblemNumber varchar(20) = NULL,
		@JobID bigint = NULL,
		@CustomerNumber varchar(20) = NULL
	)
	AS
--<!--$$Revision: 29 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 8/11/10 9:16 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebQuickFind.sql $-->
--<!--$$NoKeywords: $-->
--06/03/2008	Bo	Added ability to search on JobID
 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


 IF @TerminalID IS NOT NULL
  BEGIN
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
		'Open' as Status,
		j.ClientID, 
		MerchantID, 
		CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
		     ELSE TerminalID 
		END as TerminalID,
		CASE WHEN JobType = 'UPGRADE' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + ''')">' + OldTerminalID + '</A>'
		     ELSE OldTerminalID 
		END as OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
		CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
		     WHEN JobType = 'UPGRADE' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + '">View</A>'
		     ELSE NULL 
		END as SiteEquipment
		FROM vwIMSJob j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND (TerminalID = @TerminalID OR OldTerminalID = @TerminalID)
			AND u.UserID = @UserID
			
	 UNION
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
		'Closed' as Status,
		j.ClientID, 
		MerchantID, 
		CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
			ELSE TerminalID
		END as TerminalID,
		OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
		CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
			ELSE NULL 
		END as SiteEquipment
		FROM vwIMSJobHistory  j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND (TerminalID = @TerminalID OR OldTerminalID = @TerminalID)
			AND u.UserID = @UserID
	 UNION
	
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, 4) as Type,
		'Open' as Status,
		j.ClientID, 
		MerchantID as MerchantID, 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
		NULL as OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
		'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment
		FROM vwCalls j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE  @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND TerminalID = @TerminalID
			AND u.UserID = @UserID
	 UNION
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, 4) as Type,
		'Closed' as Status,
		j.ClientID, 
		MerchantID as MerchantID,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
		NULL as OldTerminalID,	     	
		LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
		'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment
		FROM vwCallsHistory j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
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
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
		'Open' as Status,
		j.ClientID, 
		MerchantID, 
		CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
		     ELSE TerminalID 
		END as TerminalID,
		CASE WHEN JobType = 'UPGRADE' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + ''')">' + OldTerminalID + '</A>'
		     ELSE OldTerminalID 
		END as OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
		CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
		     WHEN JobType = 'UPGRADE' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + '">View</A>'
		     ELSE NULL 
		END as SiteEquipment,
		j.CustomerNumber,
		j.AltMerchantID as MID2
		FROM vwIMSJob j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE   @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND (MerchantID = @MerchantID OR AltMerchantID = @MerchantID)
			AND u.UserID = @UserID
	 UNION
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
		'Closed' as Status,
		j.ClientID, 
		MerchantID, 
		CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
			ELSE TerminalID
		END as TerminalID,
		OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
		CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
			ELSE NULL 
		END as SiteEquipment,
		j.CustomerNumber,
		j.AltMerchantID as MID2
		FROM vwIMSJobHistory j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND (MerchantID = @MerchantID OR AltMerchantID = @MerchantID)
			AND u.UserID = @UserID

	 UNION
	
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, 4) as Type,
		'Open' as Status,
		j.ClientID, 
		j.MerchantID as MerchantID, 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + j.TerminalID + ''')">' + j.TerminalID + '</A>' as TerminalID,
		NULL as OldTerminalID,
     	LoggedDateTime,
		j.[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
		'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + j.TerminalID + '">View</A>' as SiteEquipment,
		s.CustomerNumber,
		s.AltMerchantID as MID2
		FROM vwCalls j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		INNER JOIN Sites s on s.ClientID = j.ClientID AND j.TerminalID = s.TerminalID
		WHERE   @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND (j.MerchantID = @MerchantID OR s.AltMerchantID = @MerchantID)
			AND u.UserID = @UserID

	 UNION
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, 4) as Type,
		'Closed' as Status,
		j.ClientID, 
		j.MerchantID as MerchantID, 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + j.TerminalID + ''')">' + j.TerminalID + '</A>' as TerminalID,
		NULL as OldTerminalID,
     	LoggedDateTime,
		j.[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
		'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + j.TerminalID + '">View</A>' as SiteEquipment,
		s.CustomerNumber,
		s.AltMerchantID as MID2
		FROM vwCallsHistory j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		INNER JOIN Sites s on s.ClientID = j.ClientID AND j.TerminalID = s.TerminalID
		WHERE @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND (j.MerchantID = @MerchantID or s.AltMerchantID = @MerchantID)
			AND u.UserID = @UserID

	 Order by LoggedDateTime DESC

	--Return
	RETURN @@ERROR
 END --IF @MerchantID IS NOT NULL

 IF @ProblemNumber IS NOT NULL
  BEGIN
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
		'Open' as Status,
		j.ClientID, 
		MerchantID, 
		CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
		     ELSE TerminalID 
		END as TerminalID,
		CASE WHEN JobType = 'UPGRADE' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + ''')">' + OldTerminalID + '</A>'
		     ELSE OldTerminalID 
		END as OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
		CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
		     WHEN JobType = 'UPGRADE' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + '">View</A>'
		     ELSE NULL 
		END as SiteEquipment
		FROM vwIMSJob j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND ProblemNumber = @ProblemNumber
			AND u.UserID = @UserID

	 UNION
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
		'Closed' as Status,
		j.ClientID, 
		MerchantID, 
		CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
			ELSE TerminalID
		END as TerminalID,
		OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
		CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
			ELSE NULL 
		END as SiteEquipment
		FROM vwIMSJobHistory j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND ProblemNumber = @ProblemNumber
			AND u.UserID = @UserID

	 UNION
	
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, 4) as Type,
		'Open' as Status,
		j.ClientID, 
		MerchantID as MerchantID, 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
		NULL as OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
		'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment
		FROM vwCalls j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND ProblemNumber = @ProblemNumber
			AND u.UserID = @UserID
	 UNION
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, 4) as Type,
		'Closed' as Status,
		j.ClientID, 
		MerchantID as MerchantID, 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
		NULL as OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
		'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment
		FROM vwCallsHistory j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
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
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
		'Open' as Status,
		j.ClientID, 
		MerchantID, 
		CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
		     ELSE TerminalID 
		END as TerminalID,
		CASE WHEN JobType = 'UPGRADE' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + ''')">' + OldTerminalID + '</A>'
		     ELSE OldTerminalID 
		END as OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
		CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
		     WHEN JobType = 'UPGRADE' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + '">View</A>'
		     ELSE NULL 
		END as SiteEquipment
		FROM vwIMSJob j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND j.JobID = @JobID
			AND u.UserID = @UserID
			
	 UNION
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
		'Closed' as Status,
		j.ClientID, 
		MerchantID, 
		CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
			ELSE TerminalID
		END as TerminalID,
		OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
		CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
			ELSE NULL 
		END as SiteEquipment
		FROM vwIMSJobHistory  j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
		WHERE  @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND j.JobID = @JobID
			AND u.UserID = @UserID
	 UNION
	
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, 4) as Type,
		'Open' as Status,
		j.ClientID, 
		MerchantID as MerchantID, 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
		NULL as OldTerminalID,
     	LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
		'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment
		FROM vwCalls j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE  @Scope IN ('O', 'B')
			AND j.ClientID = @ClientID 
			AND j.CallNumber = CAST(@JobID as varchar)
			AND u.UserID = @UserID
	 UNION
	 SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
		dbo.fnGetClientJobType(j.ClientID, 4) as Type,
		'Closed' as Status,
		j.ClientID, 
		MerchantID as MerchantID,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
		NULL as OldTerminalID,	     	
		LoggedDateTime,
		[Name] as MerchantName,
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
		'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment
		FROM vwCallsHistory j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
		WHERE  @Scope IN ('C', 'B')
			AND j.ClientID = @ClientID 
			AND j.CallNumber = CAST(@JobID as varchar)
			AND u.UserID = @UserID

	 Order by LoggedDateTime DESC
	--Return
	RETURN @@ERROR
  END  ---IF @JobID IS NOT NULL

 IF @CustomerNumber IS NOT NULL
	BEGIN
		SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
			dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
			'Open' as Status,
			j.ClientID, 
			MerchantID, 
			CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
				 ELSE TerminalID 
			END as TerminalID,
			CASE WHEN JobType = 'UPGRADE' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + ''')">' + OldTerminalID + '</A>'
				 ELSE OldTerminalID 
			END as OldTerminalID,
     		LoggedDateTime,
			[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
			CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
				 WHEN JobType = 'UPGRADE' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + '">View</A>'
				 ELSE NULL 
			END as SiteEquipment,
			j.CustomerNumber,
			j.AltMerchantID as MID2
			FROM vwIMSJob j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
			WHERE  @Scope IN ('O', 'B')
				AND j.ClientID = @ClientID 
				AND j.CustomerNumber = @CustomerNumber
				AND u.UserID = @UserID
			
		 UNION
		 SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
			dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
			'Closed' as Status,
			j.ClientID, 
			MerchantID, 
			CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
				ELSE TerminalID
			END as TerminalID,
			OldTerminalID,
     		LoggedDateTime,
			[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
			CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
				ELSE NULL 
			END as SiteEquipment,
			j.CustomerNumber,
			j.AltMerchantID as MID2
			FROM vwIMSJobHistory  j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
			WHERE  @Scope IN ('C', 'B')
				AND j.ClientID = @ClientID 
				AND j.CustomerNumber = @CustomerNumber
				AND u.UserID = @UserID

		SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
			dbo.fnGetClientJobType(j.ClientID, 4) as Type,
			'Open' as Status,
			j.ClientID, 
			j.MerchantID as MerchantID, 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + j.TerminalID + ''')">' + j.TerminalID + '</A>' as TerminalID,
			NULL as OldTerminalID,
     		LoggedDateTime,
			j.[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
			'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + j.TerminalID + '">View</A>' as SiteEquipment,
			s.CustomerNumber,
			s.AltMerchantID as MID2
			FROM vwCalls j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
			INNER JOIN Sites s on s.ClientID = j.ClientID AND j.TerminalID = s.TerminalID
			WHERE  @Scope IN ('O', 'B')
				AND j.ClientID = @ClientID 
				AND s.CustomerNumber = @CustomerNumber
				AND u.UserID = @UserID
		 UNION
		 SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
			dbo.fnGetClientJobType(j.ClientID, 4) as Type,
			'Closed' as Status,
			j.ClientID, 
			j.MerchantID as MerchantID,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + j.TerminalID + ''')">' + j.TerminalID + '</A>' as TerminalID,
			NULL as OldTerminalID,	     	
			LoggedDateTime,
			j.[Name] as MerchantName,
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
			'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + j.TerminalID + '">View</A>' as SiteEquipment,
			s.CustomerNumber,
			s.AltMerchantID as MID2
			FROM vwCallsHistory j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
			INNER JOIN Sites s on s.ClientID = j.ClientID AND j.TerminalID = s.TerminalID
			WHERE  @Scope IN ('C', 'B')
				AND j.ClientID = @ClientID 
				AND s.CustomerNumber = @CustomerNumber
				AND u.UserID = @UserID

	 Order by LoggedDateTime DESC
	 --Return
	 RETURN @@ERROR
	END

GO

Grant EXEC on spWebQuickFind to eCAMS_Role
Go


Use WebCAMS
Go


ALTER Procedure dbo.spWebQuickFind 
	(
		@UserID int,
		@ClientID varchar(3),
		@Scope char(1),
		@TerminalID varchar(20) = NULL,
		@MerchantID varchar(16) = NULL,
		@ProblemNumber varchar(20) = NULL,
		@JobID bigint = NULL,
		@CustomerNumber varchar(20) = NULL
	)
	AS
--<!--$$Revision: 11 $-->
--<!--$$Author: Thanh $-->
--<!--$$Date: 26/07/04 1:39p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebQuickFind.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC CAMS.dbo.spWebQuickFind 
						@UserID = @UserID, 
						@ClientID = @ClientID, 
						@Scope = @Scope,
						@TerminalID = @TerminalID, 
						@MerchantID = @MerchantID, 
						@ProblemNumber = @ProblemNumber,
						@JobID = @JobID,
						@CustomerNumber = @CustomerNumber


/*
exec spWebQuickFind 
		@UserID=200462,
		@ClientID='CTX',
		@Scope='B',
		@TerminalID='28747',
		@MerchantID=NULL,
		@ProblemNumber=NULL,
		@JobID=NULL


*/

Go

Grant EXEC on spWebQuickFind to eCAMS_Role
Go



