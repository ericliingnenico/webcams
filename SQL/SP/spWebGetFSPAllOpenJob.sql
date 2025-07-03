Use CAMS
Go


Alter Procedure dbo.spWebGetFSPAllOpenJob 
	(
		@UserID int,
		@FSPID int,
		@From tinyint,
		@JobType varchar(20) = null,
		@DueDateTime datetime = null,
		@NoDeviceReservedOnly bit = null,
		@ProjectNo varchar(20) = null,
		@City varchar(50) = null,
		@Postcode varchar(10) = null,
		@IncludeChildDepot bit = null,
		@JobIDs varchar(1000) = null
	)
	AS
--<!--$$Revision: 65 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/07/16 14:51 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPAllOpenJob.sql $-->
--<!--$$NoKeywords: $-->
---Get all open jobs for a FSP
--
DECLARE @InstallerID int,
	@FromDate datetime,
	@ToDate datetime

 --init
 SELECT @JobType = CASE WHEN @JobType = 'ALL' THEN NULL ELSE @JobType END

   
 --format date range
 SELECT @FromDate = CONVERT(varchar, @DueDateTime, 106),
	@ToDate = CONVERT(varchar, @DueDateTime, 106) + ' 23:59:59:999'

 CREATE TABLE #tmpJob (JobID bigint, DeviceReserved bit)

 SELECT @InstallerID = InstallerID 
   FROM WebCams.dbo.tblUser
  WHERE UserID = @UserID

 IF @FSPID IS NOT NULL
  --FSPID has been passed in, verify if the FSPID is in user's location family
  BEGIN
	IF EXISTS(SELECT 1 FROM dbo.fnGetLocationChildrenExt(@InstallerID) WHERE Location = @FSPID)
		SELECT @InstallerID = @FSPID
	ELSE
		SELECT @InstallerID = NULL
  END


 CREATE TABLE #MyLoc (Location int)
 IF isnull(@IncludeChildDepot, 0) = 1
  BEGIN
	INSERT #MyLoc (Location) SELECT * FROM dbo.fnGetLocationChildrenExt(@InstallerID)
  END
 ELSE
  BEGIN
	INSERT #MyLoc (Location) SELECT @InstallerID
  END


 IF @From in (1, 3)  --from desk top web
  BEGIN
	if LEN(ISNULL(@JobIDs,'')) > 2
	 begin
		--split JobIDs into temp table for join
		INSERT #tmpJob (JobID, DeviceReserved)
			select LTRIM(RTRIM(t.f)),0
			  from dbo.fnConvertListToTable(@JobIDs) t join IMS_Jobs j with (nolock) on LTRIM(RTRIM(t.f)) = j.JobID
													join #MyLoc loc with (nolock) on j.BookedInstaller = Loc.Location
			  where dbo.fnIsSwapCall(LTRIM(RTRIM(t.f))) = 0
			union
			select t.f,0
			  from dbo.fnConvertListToTable(@JobIDs) t join Calls j with (nolock) on cast(LTRIM(RTRIM(t.f)) as varchar)= j.CallNumber
													join #MyLoc loc with (nolock) on j.AssignedTo = Loc.Location
			  where dbo.fnIsSwapCall(LTRIM(RTRIM(t.f))) = 1
	 end --@JobIDs passed in
	else
	 begin
		IF @JobType IS NULL OR @JobType <> 'SWAP'
		 BEGIN
			INSERT #tmpJob (JobID, DeviceReserved)
			SELECT j.JobID, 1
				FROM vwIMSJob j with (nolock) JOIN #MyLoc loc ON j.BookedInstaller = Loc.Location
				WHERE j.AllowFSPWebAccess = 1
					AND j.AgentSLADateTimeLocal >= ISNULL(@FromDate, j.AgentSLADateTimeLocal)
					AND j.AgentSLADateTimeLocal <= ISNULL(@ToDate, j.AgentSLADateTimeLocal)
					AND j.JobType = ISNULL(@JobType, j.JobType)
					AND ISNULL(j.ProjectNo, '') = ISNULL(@ProjectNo, ISNULL(j.ProjectNo, ''))
					AND j.City = ISNULL(@City, j.City)
					AND j.Postcode = ISNULL(@Postcode, j.Postcode)

			if dbo.fnCanFSPBookJob(@FSPID) = 1 -- append proposed ones
			 begin
				INSERT #tmpJob (JobID, DeviceReserved)
				SELECT j.JobID, 0
					FROM vwIMSJob j with (nolock) 
					where j.ProposedInstaller = @FSPID 
						and j.BookedInstaller is null
						AND j.JobType = ISNULL(@JobType, j.JobType)
						AND ISNULL(j.ProjectNo, '') = ISNULL(@ProjectNo, ISNULL(j.ProjectNo, ''))
						AND j.City = ISNULL(@City, j.City)
						AND j.Postcode = ISNULL(@Postcode, j.Postcode)
			 end 

		 END --IF @JobType IS NULL OR @JobType <> 'SWAP'

		IF @JobType IS NULL OR @JobType = 'SWAP'
		 BEGIN
			INSERT #tmpJob (JobID, DeviceReserved)
			SELECT j. CallNumber, 1
				FROM vwCalls j with (nolock) JOIN #MyLoc loc ON j.AssignedTo = Loc.Location
				WHERE j.AllowFSPWebAccess = 1
					AND j.AgentSLADateTimeLocal >= ISNULL(@FromDate, j.AgentSLADateTimeLocal)
					AND j.AgentSLADateTimeLocal <= ISNULL(@ToDate, j.AgentSLADateTimeLocal)
					AND ISNULL(j.ProjectNo, '') = ISNULL(@ProjectNo, ISNULL(j.ProjectNo, ''))
					AND j.City = ISNULL(@City, j.City)
					AND j.Postcode = ISNULL(@Postcode, j.Postcode)

		 END --IF @JobType IS NULL OR @JobType = 'SWAP'

		IF @NoDeviceReservedOnly = 1 
		 BEGIN
			--upgrade job with no reserved devices only
			UPDATE t
			   SET DeviceReserved = 0
			  FROM #tmpJob t JOIN IMS_Job_Equipment e ON t.JobID = e.JobID
					JOIN IMS_Jobs j ON t.JobID = j.JobID
			 WHERE (dbo.fnIsSerialisedDevice(e.Serial) = 0
				AND e.ActionID = 1) --IN ('INSTALL', 'CONFIRM')
				

			DELETE #tmpJob
			 WHERE DeviceReserved = 1
 		 END
	 end -- no @JobIDs passed in
	 
	--return resultset
	 if @From = 1 --from desktop web
	  begin
 		SELECT 
			APM=dbo.fnAPMStar(j.AgentSLADateTime, j.StatusID, @From) + dbo.fnPhoneIcon(j.ClientID, j.InstallerNotes,@From),
			CASE WHEN j.AllowFSPWebAccess = 1 AND j.AgentSLADateTimeLocal IS NOT NULL THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + cast(j.JobID as varchar) + ''')">' + cast(j.JobID as varchar) + '</A>' 
				ELSE cast(j.JobID as varchar)  END as JobID,
			j.BookedInstaller as [To],
			j.ClientID, 
			j.JobType,
			j.DeviceType,
     		AgentSLADateTimeLocal AS RequiredBy,
			[Name] as MerchantName,
			City,
			j.ProjectNo,
			j.Status,
			CASE WHEN j.AllowFSPWebAccess = 1 AND j.AgentSLADateTimeLocal IS NOT NULL THEN 
					'<A HREF="../Member/FSPReAssignJob.aspx?JID=' + cast(j.JobID as varchar) + '">ReAssign</A>  - 
					<A HREF="../Member/FSPJob.aspx?JID=' + cast(j.JobID as varchar) + '">Closure</A>'
				ELSE ''
			END 
			+ case when dbo.fnCanFSPBookJob(@FSPID) = 1 then ' - <A HREF="../Member/FSPBookJob.aspx?JID=' + cast(j.JobID as varchar) + '">Book</A>' else '' end		
			as [Action],
			'<INPUT type="checkbox" name="chkBulk" value="' + cast(j.JobID as varchar) + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')" class="clsjobid" jobid="' + cast(j.JobID as varchar) + '" >' as [Bulk]
			FROM vwIMSJob j with (nolock) JOIN #tmpJob t ON j.JobID = t.JobID
		UNION
		SELECT 
			APM=dbo.fnAPMStar(j.AgentSLADateTime, j.StatusID, @From) + dbo.fnPhoneIcon(j.ClientID, cm.FaultMemo,@From),
			CASE WHEN j.AllowFSPWebAccess = 1 AND j.AgentSLADateTimeLocal IS NOT NULL THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + j.CallNumber + ''')">' + j.CallNumber + '</A>' 
				ELSE j.CallNumber END as JobID,
			AssignedTo as [To],
 			 j.ClientID, 
			'SWAP' as JobType,
			DeviceType = j.CallType,
     		AgentSLADateTimeLocal AS RequiredBy,
			[Name] as MerchantName,
			City,
			j.ProjectNo,
			j.Status,
			CASE WHEN j.AllowFSPWebAccess = 1 AND j.AgentSLADateTimeLocal IS NOT NULL THEN 
					'<A HREF="../Member/FSPReAssignJob.aspx?JID=' + j.CallNumber + '">ReAssign</A> -
					<A HREF="../Member/FSPJob.aspx?JID=' + j.CallNumber + '">Closure</A>'
				ELSE '' 
			END as [Action],
			'<INPUT type="checkbox" name="chkBulk" value="' + j.CallNumber + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')" class="clsjobid" jobid="' + j.CallNumber + '">' as [Bulk]
			FROM vwCalls j with (nolock)  JOIN #tmpJob t ON j.CallNumber = t.JobID
					left outer join Call_Memos cm with (nolock) on j.CallNumber = cm.CallNumber
		Order by RequiredBy
	  end --IF @From = 1 --from desktop

	 if @From = 3 --from download
	  begin
		--no fsp passed in, only return user's jobs
 		SELECT 
 			JobID = cast(j.JobID as bigint),
 			j.Name,
 			j.Address,
 			j.JobType,
 			j.ClientID,
 			j.DeviceType,
 			j.city,
 			j.state,
 			j.Postcode,
 			j.PhoneNumber,
 			j.AgentSLADateTimeLocal,
			dbo.fnConvertShortDateTime(j.AgentSLADateTimeLocal) AS RequiredBy,
			j.BookedInstaller,
			j.ProjectNo,
			j.Status
			FROM vwIMSJob j with (nolock)  JOIN #tmpJob t ON j.JobID = t.JobID
		UNION
		SELECT 
 			JobID = j.CallNumber,
 			j.Name,
 			j.Address,
 			JobType = 'SWAP',
 			j.ClientID,
 			DeviceType = j.CallType,
 			j.city,
 			j.state,
 			j.Postcode,
 			PhoneNumber = j.CallerPhone,
 			j.AgentSLADateTimeLocal,
			dbo.fnConvertShortDateTime(j.AgentSLADateTimeLocal) AS RequiredBy,
			BookedInstaller = j.AssignedTo,
			j.ProjectNo,
			j.Status
			FROM vwCalls j with (nolock) JOIN #tmpJob t ON j.CallNumber = t.JobID
					left outer join Call_Memos cm with (nolock) on j.CallNumber = cm.CallNumber
		Order by RequiredBy
	end --IF @From = 3 --from download


  END --from desktop web

 IF @From = 2 --from PDA web
  BEGIN
    if webcams.dbo.fnCanUseNewPCAMS(@UserID) = 1
     begin
		--no fsp passed in, only return user's jobs
 		SELECT 
 			JobID = cast(j.JobID as bigint),
 			j.Name,
 			j.Address,
 			j.JobType,
 			j.ClientID,
 			j.DeviceType,
 			j.city,
 			j.state,
 			j.Postcode,
 			j.PhoneNumber,
 			j.AgentSLADateTimeLocal,
			dbo.fnConvertShortDateTime(j.AgentSLADateTimeLocal) AS RequiredBy,
			j.BookedInstaller,
			APM=dbo.fnAPMStar(j.AgentSLADateTime, j.StatusID, @From),
			PhoneIcon = dbo.fnPhoneIcon(j.ClientID, j.InstallerNotes,@From)
			FROM vwIMSJob j with (nolock) 
			WHERE j.BookedInstaller = @InstallerID
				AND j.AllowFSPWebAccess = 1
		UNION
		SELECT 
 			JobID = j.CallNumber,
 			j.Name,
 			j.Address,
 			JobType = 'SWAP',
 			j.ClientID,
 			DeviceType = j.CallType,
 			j.city,
 			j.state,
 			j.Postcode,
 			PhoneNumber = j.CallerPhone,
 			j.AgentSLADateTimeLocal,
			dbo.fnConvertShortDateTime(j.AgentSLADateTimeLocal) AS RequiredBy,
			BookedInstaller = j.AssignedTo,
			APM=dbo.fnAPMStar(j.AgentSLADateTime, j.StatusID, @From),
			PhoneIcon = dbo.fnPhoneIcon(j.ClientID, cm.FaultMemo,@From)
			FROM vwCalls j with (nolock) left outer join Call_Memos cm with (nolock) on j.CallNumber = cm.CallNumber
			WHERE j.AssignedTo = @InstallerID
				AND j.AllowFSPWebAccess = 1
		Order by RequiredBy
	 end
	else
	 begin	
 		SELECT 
			CASE WHEN j.AllowFSPWebAccess = 1 AND j.AgentSLADateTimeLocal IS NOT NULL THEN '<A HREF="../Member/pFSPReAssignJob.aspx?JID=' + cast(JobID as varchar) + '">ReAssign</A>' 
				ELSE '' 
			END as [Action],
			j.ClientID as CID, 
			CASE j.JobType WHEN 'INSTALL' THEN 'I'
					WHEN 'DEINSTALL' THEN 'D'
					ELSE 'U' END as T,
	     		dbo.fnConvertShortDateTime(AgentSLADateTimeLocal) AS RequiredBy,
			City,
			j.BookedInstaller as [To]
			FROM vwIMSJob j with (nolock) 
			WHERE j.BookedInstaller = @InstallerID
				AND j.AllowFSPWebAccess = 1
		UNION
		SELECT 
			CASE WHEN j.AllowFSPWebAccess = 1 AND j.AgentSLADateTimeLocal IS NOT NULL THEN '<A HREF="../Member/pFSPReAssignJob.aspx?JID=' + CallNumber + '">ReAssign</A>'
				ELSE '' 
			END as [Action],
 			 j.ClientID as CID, 
			'S' as T,
	     		dbo.fnConvertShortDateTime(AgentSLADateTimeLocal) AS RequiredBy,
			City,
			AssignedTo as [To]

			FROM vwCalls j with (nolock) 
			WHERE j.AssignedTo = @InstallerID
				AND j.AllowFSPWebAccess = 1
		Order by RequiredBy
	end
  END --IF @From = 2 --from PDA web





GO

Grant EXEC on spWebGetFSPAllOpenJob to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPAllOpenJob 
	(
		@UserID int,
		@FSPID int,
		@From tinyint,
		@JobType varchar(20) = null,
		@DueDateTime datetime = null,
		@NoDeviceReservedOnly bit = null,
		@ProjectNo varchar(20) = null,
		@City varchar(50) = null,
		@Postcode varchar(10) = null,
		@IncludeChildDepot bit = null,
		@JobIDs varchar(1000) = null
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 11:41a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPAllOpenJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPAllOpenJob 
			@UserID = @UserID, 
			@FSPID = @FSPID, 
			@From = @From, 
			@JobType = @JobType, 
			@DueDateTime = @DueDateTime,
			@NoDeviceReservedOnly = @NoDeviceReservedOnly,
			@ProjectNo = @ProjectNo,
			@City = @City,
			@Postcode = @Postcode,
			@IncludeChildDepot = @IncludeChildDepot,
			@JobIDs = @JobIDs

/*
select * from webcams.dbo.tblUser

spWebGetFSPAllOpenJob 199512, 3001, 1, 'INSTALL'  2
*/
Go

Grant EXEC on spWebGetFSPAllOpenJob to eCAMS_Role
Go
