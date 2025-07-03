
Use CAMS
Go

Alter Procedure dbo.spWebGetFSPClosedJobList 
	(
		@UserID int,
		@FSPID int,
		@JobType varchar(20) = NULL,
		@FromDate datetime,
		@ToDate datetime,
		@JobIDs varchar(1000),
		@From tinyint
	)
	AS
--<!--$$Revision: 53 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/01/16 9:50 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPClosedJobList.sql $-->
--<!--$$NoKeywords: $-->
---Get closed job (IMS Job/Calls) for given FSP and date range, ignore JobType
--20/05/2008	Bo	Added @From to accomodate the download request. @From = 1 : Web UI, @From = 2: Download request
DECLARE @dt datetime,
	@InstallerID int

 SET NOCOUNT ON

 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 --get InstallerID
 SELECT @InstallerID = InstallerID 
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID


 --Passed in FSP is not part of login FSP family, return an empty resultset and quit
 IF NOT EXISTS(SELECT 1 FROM dbo.fnGetLocationChildrenExt(@InstallerID) WHERE Location = @FSPID)
  BEGIN
	SELECT
		CASE WHEN @From = 1 THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' 
			WHEN @From = 2 THEN cast(JobID as varchar)
			ELSE  cast(JobID as varchar) 
		END as JobID,
		j.BookedInstaller as FSP,
		j.ClientID, 
		j.JobType,
		j.TerminalID, 
	    j.AgentSLADateTimeLocal AS RequiredBy,
		[Name] as MerchantName,
		Postcode,
		OnSiteDateTimeLocal as OnSiteDateTime,
		j.DeviceType,
		j.ProjectNo,
		'' as [Bulk]
		FROM vwIMSJobHistory j 
	  WHERE 1 = 2

	RETURN

  END

 --cache FSP family

 SELECT * INTO #myFSP
   FROM dbo.fnGetLocationChildrenExt(@FSPID)

 --search on JobIDs
 IF LEN(@JobIDs) > 2
  BEGIN
	--split JobIDs into temp table for join
	SELECT * INTO #myID
	  FROM dbo.fnConvertListToTable(@JobIDs)

	SELECT LTRIM(RTRIM(f)) as ID INTO #myJob
	  FROM #myID
	 WHERE dbo.fnIsSwapCall(LTRIM(RTRIM(f))) = 0

	SELECT LTRIM(RTRIM(f)) as ID INTO #myCall
	  FROM #myID
	 WHERE dbo.fnIsSwapCall(LTRIM(RTRIM(f))) = 1


 	SELECT 
		CASE WHEN @From = 1 THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + cast(j.JobID as varchar) + ''')">' + cast(j.JobID as varchar) + '</A>'
			WHEN @From = 2 THEN cast(j.JobID as varchar)
			ELSE  cast(j.JobID as varchar) 
		END as JobID,
		j.BookedInstaller as FSP,
		j.ClientID, 
		j.JobType,
		j.TerminalID, 
	    j.AgentSLADateTimeLocal AS RequiredBy,
		[Name] as MerchantName,
		Postcode,
		OnSiteDateTimeLocal as OnSiteDateTime,
		j.DeviceType,
		j.ProjectNo,
		CASE WHEN j.IsChargeableFSP = 1 THEN 'Yes' ELSE 'No' END as Billable,
		j.Fix,
		CASE WHEN j.AgentSLAMet = 1 THEN 'Yes' ELSE 'No' END as SLAMet,
		j.MultipleJobID,
		case when j.FSPExtraTimeAndQuoteApproved = 1 then 
			case when j.FSPExtraTimeUnitsReq>0 then j.FSPExtraTimeUnitsReq * 15 else NULL end
			else NULL end as ExtraTime,
		--case when j.FSPExtraTimeAndQuoteApproved = 1 then 
		--	case when j.FSPQuote>0 then j.FSPQuote else NULL end
		--	else NULL end as FixPrice,
		case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 2 then 'Yes' else 'No' end as AfterHour,
		case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 1 then 'Yes' else 'No' end as Weekend,
		dbo.fnGetExtraTerminalCollected(j.JobID) as ExtTermCollected,
		
		CASE WHEN @From = 1 THEN '<INPUT type="checkbox" name="chkBulk" value="' + cast(j.JobID as varchar) + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')">'
			ELSE  ''
		END as [Bulk]
		FROM vwIMSJobHistory j JOIN #myFSP l ON j.BookedInstaller = l.Location
					JOIN #myJob m ON m.ID = j.JobID
		WHERE j.AllowFSPWebAccess = 1
	UNION
 	SELECT 
		CASE WHEN @From = 1 THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + CallNumber + ''')">' + CallNumber + '</A>'
			WHEN @From = 2 THEN CallNumber
			ELSE  CallNumber
		END as JobID,
		j.AssignedTo as FSP,		
		j.ClientID, 
		'SWAP' as JobType,
		j.TerminalID as TerminalID, 
	    j.AgentSLADateTimeLocal AS RequiredBy,
		[Name] as MerchantName,
		Postcode,
		OnSiteDateTimeLocal as OnSiteDateTime,
		j.DeviceType,
		j.ProjectNo,
		CASE WHEN j.IsChargeableFSP = 1 THEN 'Yes' ELSE 'No' END as Billable,
		j.Fix,
		CASE WHEN j.AgentSLAMet = 1 THEN 'Yes' ELSE 'No' END as SLAMet,
		j.MultipleJobID,
		case when j.FSPExtraTimeAndQuoteApproved = 1 then 
			case when j.FSPExtraTimeUnitsReq>0 then j.FSPExtraTimeUnitsReq * 15 else NULL end
			else NULL end as ExtraTime,
		--case when j.FSPExtraTimeAndQuoteApproved = 1 then 
		--	case when j.FSPQuote>0 then j.FSPQuote else NULL end
		--	else NULL end as FixPrice,
		case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 2 then 'Yes' else 'No' end as AfterHour,
		case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 1 then 'Yes' else 'No' end as Weekend,
		0 as ExtTermCollected,

		CASE WHEN @From = 1 THEN '<INPUT type="checkbox" name="chkBulk" value="' + CallNumber + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')">'
			ELSE  ''
		END as [Bulk]
		FROM vwCallsHistory j JOIN #myFSP l ON j.AssignedTo = l.Location
				JOIN #myCall m ON m.ID = j.CallNumber
		WHERE j.AllowFSPWebAccess = 1
	Order by ClientID, JobType, TerminalID
  END --Search on JobIDs
 ELSE
  BEGIN
	 --swap the date if from > to
	 IF @FromDate > @ToDate
	  BEGIN
		SELECT @dt = @ToDate
		SELECT @ToDate = @FromDate
		SELECT @FromDate = @dt
	  END
	
	
	 --format date range
	 SELECT @FromDate = CONVERT(varchar, @FromDate, 106),
		@ToDate = CONVERT(varchar, @ToDate, 106) + ' 23:59:59:999'

	 IF @JobType IS NULL OR @JobType = 'ALL'
	  BEGIN
	 	SELECT 
			CASE WHEN @From = 1 THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + cast(j.JobID as varchar) + ''')">' + cast(j.JobID as varchar) + '</A>'
				WHEN @From = 2 THEN cast(j.JobID as varchar)
				ELSE  cast(j.JobID as varchar) 
			END as JobID,
			j.BookedInstaller as FSP,
			j.ClientID, 
			j.JobType,
			j.TerminalID, 
		    j.AgentSLADateTimeLocal AS RequiredBy,
			[Name] as MerchantName,
			Postcode,
			OnSiteDateTimeLocal as OnSiteDateTime,
			j.DeviceType,
			j.ProjectNo,
			CASE WHEN j.IsChargeableFSP = 1 THEN 'Yes' ELSE 'No' END as Billable,
			j.Fix,
			CASE WHEN j.AgentSLAMet = 1 THEN 'Yes' ELSE 'No' END as SLAMet,
			j.MultipleJobID,
			case when j.FSPExtraTimeAndQuoteApproved = 1 then 
				case when j.FSPExtraTimeUnitsReq>0 then j.FSPExtraTimeUnitsReq * 15 else NULL end
				else NULL end as ExtraTime,
			--case when j.FSPExtraTimeAndQuoteApproved = 1 then 
			--	case when j.FSPQuote>0 then j.FSPQuote else NULL end
			--	else NULL end as FixPrice,
			case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 2 then 'Yes' else 'No' end as AfterHour,
			case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 1 then 'Yes' else 'No' end as Weekend,
			dbo.fnGetExtraTerminalCollected(j.JobID) as ExtTermCollected,
			
			CASE WHEN @From = 1 THEN '<INPUT type="checkbox" name="chkBulk" value="' + cast(j.JobID as varchar) + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')">'
				ELSE  ''
			END as [Bulk]
		
			FROM vwIMSJobHistory j JOIN #myFSP l ON j.BookedInstaller = l.Location
			WHERE OnSiteDateTime BETWEEN @FromDate AND @ToDate
					and j.AllowFSPWebAccess = 1

		UNION
	 	SELECT 
			CASE WHEN @From = 1 THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + CallNumber + ''')">' + CallNumber + '</A>'
				WHEN @From = 2 THEN CallNumber
				ELSE  CallNumber
			END as JobID,
			j.AssignedTo as FSP,		
			j.ClientID, 
			'SWAP' as JobType,
			j.TerminalID as TerminalID, 
		    j.AgentSLADateTimeLocal AS RequiredBy,
			[Name] as MerchantName,
			Postcode,
			OnSiteDateTimeLocal as OnSiteDateTime,
			j.DeviceType,
			j.ProjectNo,
			CASE WHEN j.IsChargeableFSP = 1 THEN 'Yes' ELSE 'No' END as Billable,
			j.Fix,
			CASE WHEN j.AgentSLAMet = 1 THEN 'Yes' ELSE 'No' END as SLAMet,
			j.MultipleJobID,
			case when j.FSPExtraTimeAndQuoteApproved = 1 then 
				case when j.FSPExtraTimeUnitsReq>0 then j.FSPExtraTimeUnitsReq * 15 else NULL end
				else NULL end as ExtraTime,
			--case when j.FSPExtraTimeAndQuoteApproved = 1 then 
			--	case when j.FSPQuote>0 then j.FSPQuote else NULL end
			--	else NULL end as FixPrice,
			case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 2 then 'Yes' else 'No' end as AfterHour,
			case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 1 then 'Yes' else 'No' end as Weekend,
			0 as ExtTermCollected,
			
			CASE WHEN @From = 1 THEN '<INPUT type="checkbox" name="chkBulk" value="' + CallNumber + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')">'
				ELSE  ''
			END as [Bulk]
	
			FROM vwCallsHistory j JOIN #myFSP l ON j.AssignedTo = l.Location
			WHERE OnSiteDateTime BETWEEN @FromDate AND @ToDate
					and j.AllowFSPWebAccess = 1
		Order by ClientID, JobType, TerminalID
	  END
	 ELSE
	  BEGIN
		IF @JobType = 'SWAP'
		 BEGIN
		 	SELECT 
				CASE WHEN @From = 1 THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + CallNumber + ''')">' + CallNumber + '</A>'
					WHEN @From = 2 THEN CallNumber
					ELSE CallNumber
				END as JobID,
				j.AssignedTo as FSP,		
				j.ClientID, 
				'SWAP' as JobType,
				j.TerminalID as TerminalID, 
			    j.AgentSLADateTimeLocal AS RequiredBy,
				[Name] as MerchantName,
				Postcode,
				OnSiteDateTimeLocal as OnSiteDateTime,
				j.DeviceType,
				j.ProjectNo,
				CASE WHEN j.IsChargeableFSP = 1 THEN 'Yes' ELSE 'No' END as Billable,
				j.Fix,
				CASE WHEN j.AgentSLAMet = 1 THEN 'Yes' ELSE 'No' END as SLAMet,
				j.MultipleJobID,
				case when j.FSPExtraTimeAndQuoteApproved = 1 then 
					case when j.FSPExtraTimeUnitsReq>0 then j.FSPExtraTimeUnitsReq * 15 else NULL end
					else NULL end as ExtraTime,
				--case when j.FSPExtraTimeAndQuoteApproved = 1 then 
				--	case when j.FSPQuote>0 then j.FSPQuote else NULL end
				--	else NULL end as FixPrice,
				case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 2 then 'Yes' else 'No' end as AfterHour,
				case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 1 then 'Yes' else 'No' end as Weekend,
				0 as ExtTermCollected,

				CASE WHEN @From = 1 THEN '<INPUT type="checkbox" name="chkBulk" value="' + CallNumber + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')">'
					ELSE  ''
				END as [Bulk]
				FROM vwCallsHistory j JOIN #myFSP l ON j.AssignedTo = l.Location
				WHERE OnSiteDateTime BETWEEN @FromDate AND @ToDate
					and j.AllowFSPWebAccess = 1
			Order by ClientID, JobType, TerminalID	 
	
	  	 END
		ELSE
		 BEGIN
		 	SELECT 
				CASE WHEN @From = 1 THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + cast(j.JobID as varchar) + ''')">' + cast(j.JobID as varchar) + '</A>'
					WHEN @From = 2 THEN cast(j.JobID as varchar)
					ELSE  cast(j.JobID as varchar) 
				END as JobID,
				j.BookedInstaller as FSP,
				j.ClientID, 
				j.JobType,
				j.TerminalID, 
			    j.AgentSLADateTimeLocal AS RequiredBy,
				[Name] as MerchantName,
				Postcode,
				OnSiteDateTimeLocal as OnSiteDateTime,
				j.DeviceType,
				j.ProjectNo,
				CASE WHEN j.IsChargeableFSP = 1 THEN 'Yes' ELSE 'No' END as Billable,
				j.Fix,
				CASE WHEN j.AgentSLAMet = 1 THEN 'Yes' ELSE 'No' END as SLAMet,
				j.MultipleJobID,
				case when j.FSPExtraTimeAndQuoteApproved = 1 then 
					case when j.FSPExtraTimeUnitsReq>0 then j.FSPExtraTimeUnitsReq * 15 else NULL end
					else NULL end as ExtraTime,
				--case when j.FSPExtraTimeAndQuoteApproved = 1 then 
				--	case when j.FSPQuote>0 then j.FSPQuote else NULL end
				--	else NULL end as FixPrice,
				case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 2 then 'Yes' else 'No' end as AfterHour,
				case when JobCost.dbo.fnGetChargeCategoryExt(j.State, j.AgentSLADateTimeLocal, j.OnSiteDateTimeLocal) = 1 then 'Yes' else 'No' end as Weekend,
				dbo.fnGetExtraTerminalCollected(j.JobID) as ExtTermCollected,
				
				CASE WHEN @From = 1 THEN '<INPUT type="checkbox" name="chkBulk" value="' + cast(j.JobID as varchar) + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')">'
					ELSE  ''
				END as [Bulk]
				FROM vwIMSJobHistory j JOIN #myFSP l ON j.BookedInstaller = l.Location
				WHERE JobType = @JobType
					AND OnSiteDateTime BETWEEN @FromDate AND @ToDate
					and j.AllowFSPWebAccess = 1
			Order by ClientID, JobType, TerminalID	 
		 END
	
	  END
  END	--search on OnSiteDate range


GO

Grant EXEC on spWebGetFSPClosedJobList to eCAMS_Role
Go

Use WebCAMS
Go

ALter Procedure dbo.spWebGetFSPClosedJobList 
	(
		@UserID int,
		@FSPID int,
		@JobType varchar(20) =  NULL,
		@FromDate datetime,
		@ToDate datetime,
		@JobIDs varchar(100) = NULL,
		@From tinyint
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 2:47p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPClosedJobList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPClosedJobList @UserID = @UserID, 
					@FSPID = @FSPID,
					@JobType = @JobType, 
					@FromDate = @FromDate,
					@ToDate = @ToDate,
					@JobIDs = @JobIDs,
					@From = @From

/*

exec spWebGetFSPClosedJobList @UserID=199649,@FSPID=6010,@JobType='ALL',@FromDate='2014-02-13 00:00:00',@ToDate='2014-02-18 00:00:00',@JobIDs=NULL,@From=1
*/
Go

Grant EXEC on spWebGetFSPClosedJobList to eCAMS_Role
Go

