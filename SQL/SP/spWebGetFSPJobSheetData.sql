Use WebCAMS
Go


ALTER PROCEDURE dbo.spWebGetFSPJobSheetData 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2017-09-25 15:30:31$-->
--<!--$ModifiedBy: Bo Li <bo.li@bambora.com>$-->
--<!--$Comment: CAMS-443$-->
--<!--$Commit$-->
 SET NOCOUNT ON

-- Manually create a table here.
-- IAmOnSiteDateLocal & CurrentSiteDateLocal only apply to open jobs/calls

 CREATE TABLE #JobData (
			JobID bigint,
			ClientID varchar(5) collate database_default,
			TerminalID varchar(20) collate database_default,
			TerminalNumber varchar(2) collate database_default,
			MerchantID varchar(16) collate database_default,
			JobType varchar(20) collate database_default,
			[Name] varchar(50) collate database_default,
			Address varchar(50) collate database_default,
			Address2 varchar(50) collate database_default,
			City  varchar(50) collate database_default,
			PostCode  varchar(10) collate database_default,
			Contact varchar(50) collate database_default,
			Phone  varchar(50) collate database_default,
			BusinessActivity varchar(40) collate database_default,
			AgentSLADateTimeLocal datetime,
			Region varchar(15) collate database_default,	--MetroView  
			OnSiteDateTimeLocal datetime,
			OffSiteDateTimeLocal datetime,
			Notes  varchar(8000) collate database_default,
			Info  varchar(1000) collate database_default,
			EquipmentType varchar(50) collate database_default,
			InOut varchar(50) collate database_default,
			Serial varchar(32) collate database_default,
			MMD  varchar(255) collate database_default,
			InstallerID int,
			ClientRef varchar(20) collate database_default,
			InstallerName  varchar(50) collate database_default,
			Is3DES bit,
			IsEMV bit,
			Require3DES bit,
			RequireEMV bit,
			Priority varchar(15) collate database_default,
			IsOpen bit,
			CompanyName varchar(200) collate database_default,
			DeviceType varchar(50) collate database_default,
			Survey varchar(max) collate database_default,
			Latitude	float,
			Longitude	float,
			HasChildDepot bit,
			Phone1 varchar(20) collate database_default,
			Phone2 varchar(20) collate database_default,
			IAmOnSiteDateLocal datetime,
			CurrentSiteDateLocal datetime,
			HasParentDepot bit,
			TIDExt varchar(500) collate database_default,
			TMSSoftwareVersion varchar(100) collate database_default,
			TMSSerial varchar(100) collate database_default,
			TMSLastUpdated datetime)
 INSERT #JobData
   EXEC Cams.dbo.spWebGetFSPJobSheetData @UserID = @UserID, @JobID = @JobID
 
 
 SELECT * FROM #JobData

/*

spWebGetFSPJobSheetData 199513, 20040400001
spWebGetFSPJobSheetData 199513, 20031002611
spWebGetFSPJobSheetData 199513, 420008
spWebGetFSPJobSheetData 199513, 192283
spWebGetFSPJobSheetData 199525, 229056
spWebGetFSPJobSheetData 199525, 20070100316
spWebGetFSPJobSheetData @UserID = 199512, @JobID = 531024

*/
GO

Grant EXEC on spWebGetFSPJobSheetData to eCAMS_Role
Go


Use CAMS
Go

Alter Procedure dbo.spWebGetFSPJobSheetData 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2017-09-25 15:30:31$-->
--<!--$ModifiedBy: Bo Li <bo.li@bambora.com>$-->
--<!--$Comment: CAMS-443$-->
--<!--$Commit$-->

--Purpose: Retrieve data for FSP to print job sheet. The data can be from Open/Closed jobs.
-- IAmOnSiteDateLocal is used only for open jobs and fsp press IAmOnSite button

 SET NOCOUNT ON

 DECLARE @InstallerID int,
	@CompanyName varchar(200),
	@HasChildDepot bit,
	@HasParentDepot bit,
	@IAmOnSiteDateLocal datetime,
	@CurrentSiteDateLocal datetime,
	@Survey varchar(max),
	@IsOpenJob bit
	
 --init
 select @HasChildDepot = 0,
	@HasParentDepot = 0,
	@IsOpenjob = 0,
	@Survey = ''
	
	
 --Get FSPID
 SELECT @InstallerID = InstallerID 
   FROM WebCams.dbo.tblUser
   WHERE UserID = @UserID

 if exists(select 1 from dbo.fnGetLocationChildren (@InstallerID))
  begin
	set @HasChildDepot = 1
  end
  
  
 if exists(select 1 from dbo.fnGetLocationParents (@InstallerID))
  begin
	set @HasParentDepot = 1
  end
   
 SELECT @CompanyName = AttrValue 
   FROM cams.dbo.tblControl 
   WHERE Attribute = 'JobsheetCompanyName'

 if dbo.fnIsSwapCall(@JobID) = 1
  begin
	select @IsOpenJob = case when EXISTS(SELECT 1 FROM Calls WHERE CallNumber = cast(@JobID as varchar(11))) then 1 else 0 end
	if @IsOpenJob = 1 
	 begin
		select @IAmOnSiteDateLocal = (select top 1 DateAdd(mi, dbo.fnGetTimeZoneOffset(State, fos.LoggedDate), fos.LoggedDate) from tblFSPOnSiteLog fos where fos.JobID = @JobID),
				@CurrentSiteDateLocal = DateAdd(mi, dbo.fnGetTimeZoneOffset(State, dbo.fnGetDate()) , dbo.fnGetDate()),
				@Survey = dbo.fnGetSurveyCombinedText(ClientID, 'SWAP', '[br]')
			from Calls
			where CallNumber = cast(@JobID as varchar(11))
	 end
	
  end
 else
  begin
	select @IsOpenJob = case when EXISTS(SELECT 1 FROM IMS_Jobs WHERE JobID = @JobID)  then 1 else 0 end
	if @IsOpenJob = 1 
	 begin
		select @IAmOnSiteDateLocal = (select top 1 DateAdd(mi, dbo.fnGetTimeZoneOffset(State, fos.LoggedDate), fos.LoggedDate) from tblFSPOnSiteLog fos where fos.JobID = @JobID),
				@CurrentSiteDateLocal = DateAdd(mi, dbo.fnGetTimeZoneOffset(State, dbo.fnGetDate()) , dbo.fnGetDate()),
				@Survey = dbo.fnGetSurveyCombinedText(ClientID, JobType, '[br]')
			from vwIMSJob
			where JobID = @JobID
	 end

  end
 
 select * into #myLocation from dbo.fnGetLocationChildrenExt(@InstallerID)


 IF dbo.fnIsSwapCall(@JobID) = 1
  --it is a call
  BEGIN
	IF @IsOpenJob = 1 
	 BEGIN
		SELECT 
			j.CallNumber AS JobID,
			j.ClientID,
			j.TerminalID as TerminalID,
			j.TerminalNumber,
			j.MerchantID,
			'SWAP' as JobType,
			j.Name,
			j.Address,
			j.Address2,
			j.City,
			j.PostCode,
			j.Caller AS Contact,
			ISNULL(j.CallerPhone, '') as Phone,
			j.BusinessActivity,
			j.AgentSLADateTimeLocal,
			j.Region , --AS MetroView,
			j.OnSiteDateTimeLocal,
			j.OffSiteDateTimeLocal,
			CAST(m.FaultMemo as VARCHAR(8000)) as Notes,
			Info = dbo.fnJobSheetBuildInfoText(4, j.ClientID, j.CallType, NULL, NULL, j.Symptom, j.Fault, j.Severity, sm.NetworkTerminalID, sm.Acq1CAIC, NULL, NULL, j.configXML), 

			'Device' as EquipmentType,
			'Out' as InOut,
			je.Serial,
			ISNULL(md.Maker, '') + ' ' + ISNULL(md.Model, '') + ' ' + ISNULL(md.Device, '') AS MMD,
			l.Location as InstallerID,
			ProblemNumber = ISNULL(CASE WHEN ISNULL(j.ProjectNo, '')<>'' THEN j.ProjectNo ELSE j.ProblemNumber END, ''),
			i.Description as InstallerName,
			--Add 3DES/EMV
			je.Is3DES, 
			je.IsEMV,
			Require3DES = dbo.fnJobRequireCompliantDevice(j.CallNumber, 1),
			RequireEMV = dbo.fnJobRequireCompliantDevice(j.CallNumber, 2),
			Priority = '',
			IsOpen = 1,
			@CompanyName as CompanyName,
			j.CallType AS DeviceType,
			Survey = @Survey,
			j.Latitude,
			j.Longitude,
			HasChildDepot = @HasChildDepot,
			Phone1 = j.CallerPhone,
			Phone2 = null,
			IAmOnSiteDateLocal = @IAmOnSiteDateLocal,
			CurrentSiteDateLocal = @CurrentSiteDateLocal,
			HasParentDepot = @HasParentDepot,
			TIDExt = dbo.fnHighlightLetter(j.TerminalID),
			TMSSoftwareVersion = t.SoftwareVersion,
			TMSSerial = t.Serial,
			TMSLastUpdated = t.LastUpdated
		  FROM vwCalls j JOIN  #myLocation l ON j.AssignedTo = l.Location
				LEFT OUTER JOIN Call_Memos m ON j.CallNumber = m.CallNumber
				LEFT OUTER JOIN Call_Equipment je ON j.CallNumber = je.CallNumber
				LEFT OUTER JOIN M_M_D md ON md.MMD_ID = je.MMD_ID
				LEFT OUTER JOIN Site_Maintenance sm ON j.ClientID = sm.ClientID
							AND j.TerminalID = sm.TerminalID
							AND j.TerminalNumber = sm.TerminalNumber
				LEFT OUTER JOIN vwInstaller i ON i.Location = l.Location
				LEFT OUTER JOIN tblTMSData t ON t.TerminalID = j.TerminalID and t.ClientID = j.ClientID

		 WHERE j.CallNumber = @JobID	

		UNION

		SELECT 
			j.CallNumber AS JobID,
			j.ClientID,
			j.TerminalID as TerminalID,
			j.TerminalNumber,
			j.MerchantID,
			'SWAP' as JobType,
			j.Name,
			j.Address,
			j.Address2,
			j.City,
			j.PostCode,
			j.Caller AS Contact,
			ISNULL(j.CallerPhone, '') as Phone,
			j.BusinessActivity,
			j.AgentSLADateTimeLocal,
			j.Region , --AS MetroView,
			j.OnSiteDateTimeLocal,
			j.OffSiteDateTimeLocal,
			CAST(m.FaultMemo as VARCHAR(8000)) as Notes,
			Info = dbo.fnJobSheetBuildInfoText(4, j.ClientID, j.CallType, NULL, NULL, j.Symptom, j.Fault, j.Severity, sm.NetworkTerminalID, sm.Acq1CAIC, NULL, NULL, j.configXML), 

			'Device' as EquipmentType,
			'In' as InOut,
			je.NewSerial AS Serial,
			ISNULL(md.Maker, '') + ' ' + ISNULL(md.Model, '') + ' ' + ISNULL(md.Device, '') AS MMD,
			l.Location as InstallerID,
			ProblemNumber = ISNULL(CASE WHEN ISNULL(j.ProjectNo, '')<>'' THEN j.ProjectNo ELSE j.ProblemNumber END, ''),
			i.Description as InstallerName,
			--Add 3DES/EMV
			je.Is3DES, 
			je.IsEMV,
			Require3DES = dbo.fnJobRequireCompliantDevice(j.CallNumber, 1),
			RequireEMV = dbo.fnJobRequireCompliantDevice(j.CallNumber, 2),
			Priority = '',
			IsOpen = 1,
			@CompanyName as CompanyName,
			j.CallType AS DeviceType,
			Survey = @Survey,
			j.Latitude,
			j.Longitude,
			HasChildDepot = @HasChildDepot,
			Phone1 = j.CallerPhone,
			Phone2 = null,
			IAmOnSiteDateLocal = @IAmOnSiteDateLocal,
			CurrentSiteDateLocal = @CurrentSiteDateLocal,
			HasParentDepot = @HasParentDepot,
			TIDExt = dbo.fnHighlightLetter(j.TerminalID),
			TMSSoftwareVersion = t.SoftwareVersion,
			TMSSerial = t.Serial,
			TMSLastUpdated = t.LastUpdated
		  FROM vwCalls j JOIN  #myLocation l ON j.AssignedTo = l.Location
				LEFT OUTER JOIN Call_Memos m ON j.CallNumber = m.CallNumber
				LEFT OUTER JOIN Call_Equipment je ON j.CallNumber = je.CallNumber
				LEFT OUTER JOIN M_M_D md ON md.MMD_ID = je.NewMMD_ID
				LEFT OUTER JOIN Site_Maintenance sm ON j.ClientID = sm.ClientID
							AND j.TerminalID = sm.TerminalID
							AND j.TerminalNumber = sm.TerminalNumber
				LEFT OUTER JOIN vwInstaller i ON i.Location = l.Location
				LEFT OUTER JOIN tblTMSData t ON t.TerminalID = j.TerminalID and t.ClientID = j.ClientID
				
		 WHERE j.CallNumber = @JobID	

	 END
	else --IF EXISTS(SELECT 1 FROM vwCallsHistory WHERE CallNumber = CAST(@JobID AS VARCHAR(11))) 
	 -- it is a closed call
	 BEGIN
		SELECT 
			j.CallNumber AS JobID,
			j.ClientID,
			j.TerminalID as TerminalID,
			j.TerminalNumber,
			j.MerchantID,
			'SWAP' as JobType,
			j.Name,
			j.Address,
			j.Address2,
			j.City,
			j.PostCode,
			j.Caller AS Contact,
			ISNULL(j.CallerPhone, '') as Phone,
		        j.BusinessActivity,
			j.AgentSLADateTimeLocal,
			j.Region , --AS MetroView,
			j.OnSiteDateTimeLocal,
			j.OffSiteDateTimeLocal,
			CAST(m.FaultMemo as VARCHAR(8000)) as Notes,
			Info = dbo.fnJobSheetBuildInfoText(4, j.ClientID, j.CallType, NULL, NULL, j.Symptom, j.Fault, j.Severity, sm.NetworkTerminalID, sm.Acq1CAIC, NULL, NULL, j.configXML), 

			'Device' as EquipmentType,
			'Out' as InOut,
			je.Serial,
			
			ISNULL(md.Maker, '') + ' ' + ISNULL(md.Model, '') + ' ' + ISNULL(md.Device, '') AS MMD,
			l.Location as InstallerID,
			ProblemNumber = ISNULL(CASE WHEN ISNULL(j.ProjectNo, '')<>'' THEN j.ProjectNo ELSE j.ProblemNumber END, ''),
			i.Description as InstallerName,
			--Add 3DES/EMV
			je.Is3DES, 
			je.IsEMV,
			Require3DES = dbo.fnJobRequireCompliantDevice(j.CallNumber, 1),
			RequireEMV = dbo.fnJobRequireCompliantDevice(j.CallNumber, 2),
			Priority = '',
			IsOpen = 0,
			@CompanyName as CompanyName,
			j.CallType AS DeviceType,
			Survey = @Survey,
			j.Latitude,
			j.Longitude,
			HasChildDepot = @HasChildDepot,
			Phone1 = j.CallerPhone,
			Phone2 = null,
			IAmOnSiteDateLocal = null,
			CurrentSiteDateLocal = null,
			HasParentDepot = @HasParentDepot,
			TIDExt = dbo.fnHighlightLetter(j.TerminalID),
			TMSSoftwareVersion = t.SoftwareVersion,
			TMSSerial = t.Serial,
			TMSLastUpdated = t.LastUpdated
		  FROM vwCallsHistory j JOIN  #myLocation l ON j.AssignedTo = l.Location
				LEFT OUTER JOIN Call_Memo_History m ON j.CallNumber = m.CallNumber
				LEFT OUTER JOIN Call_Equipment_History je ON j.CallNumber = je.CallNumber
				LEFT OUTER JOIN M_M_D md ON md.MMD_ID = je.MMD_ID
				LEFT OUTER JOIN Site_Maintenance sm ON j.ClientID = sm.ClientID
							AND j.TerminalID = sm.TerminalID
							AND j.TerminalNumber = sm.TerminalNumber
				LEFT OUTER JOIN vwInstaller i ON i.Location = l.Location
				LEFT OUTER JOIN tblTMSData t ON t.TerminalID = j.TerminalID and t.ClientID = j.ClientID

		 WHERE j.CallNumber =CAST(@JobID AS VARCHAR(11))
		UNION
		SELECT 
			j.CallNumber AS JobID,
			j.ClientID,
			j.TerminalID as TerminalID,
			j.TerminalNumber,
			j.MerchantID,
			'SWAP' as JobType,
			j.Name,
			j.Address,
			j.Address2,
			j.City,
			j.PostCode,
			j.Caller AS Contact,
			ISNULL(j.CallerPhone, '') as Phone,
			j.BusinessActivity,
			j.AgentSLADateTimeLocal,
			j.Region , --AS MetroView,
			j.OnSiteDateTimeLocal,
			j.OffSiteDateTimeLocal,
			CAST(m.FaultMemo as VARCHAR(8000)) as Notes,
			Info = dbo.fnJobSheetBuildInfoText(4, j.ClientID, j.CallType, NULL, NULL, j.Symptom, j.Fault, j.Severity, sm.NetworkTerminalID, sm.Acq1CAIC, NULL, NULL, j.configXML), 

			'Device' as EquipmentType,
			'In' as InOut,
			je.NewSerial AS Serial,
			ISNULL(md.Maker, '') + ' ' + ISNULL(md.Model, '') + ' ' + ISNULL(md.Device, '') AS MMD,
			l.Location as InstallerID,
			ProblemNumber = ISNULL(CASE WHEN ISNULL(j.ProjectNo, '')<>'' THEN j.ProjectNo ELSE j.ProblemNumber END, ''),
			i.Description as InstallerName,
			--Add 3DES/EMV
			je.Is3DES, 
			je.IsEMV,
			Require3DES = dbo.fnJobRequireCompliantDevice(j.CallNumber, 1),
			RequireEMV = dbo.fnJobRequireCompliantDevice(j.CallNumber, 2),
			Priority = '',
			IsOpen = 0,
			@CompanyName as CompanyName,
			j.CallType AS DeviceType,
			Survey = @Survey,
			j.Latitude,
			j.Longitude,
			HasChildDepot = @HasChildDepot,
			Phone1 = j.CallerPhone,
			Phone2 = null,
			IAmOnSiteDateLocal = null,
			CurrentSiteDateLocal = null,
			HasParentDepot = @HasParentDepot,
			TIDExt = dbo.fnHighlightLetter(j.TerminalID),
			TMSSoftwareVersion = t.SoftwareVersion,
			TMSSerial = t.Serial,
			TMSLastUpdated = t.LastUpdated
		  FROM vwCallsHistory j JOIN  #myLocation l ON j.AssignedTo = l.Location
				LEFT OUTER JOIN Call_Memo_History m ON j.CallNumber = m.CallNumber
				LEFT OUTER JOIN Call_Equipment_History je ON j.CallNumber = je.CallNumber
				LEFT OUTER JOIN M_M_D md ON md.MMD_ID = je.NewMMD_ID
				LEFT OUTER JOIN Site_Maintenance sm ON j.ClientID = sm.ClientID
							AND j.TerminalID = sm.TerminalID
							AND j.TerminalNumber = sm.TerminalNumber
				LEFT OUTER JOIN vwInstaller i ON i.Location = l.Location
				LEFT OUTER JOIN tblTMSData t ON t.TerminalID = j.TerminalID and t.ClientID = j.ClientID

		 WHERE j.CallNumber = CAST(@JobID AS VARCHAR(11))


	 END

	RETURN
  END
 ELSE
  -- it is an ims job
  BEGIN
	IF @IsOpenJob = 1
	 BEGIN
		SELECT 
			j.JobID,
			j.ClientID,
			j.TerminalID,
			j.TerminalNumber,
			j.MerchantID AS MerchantID,
			j.JobType,
			j.Name,
			j.Address,
			j.Address2,
			j.City,
			j.PostCode,
			j.Contact,
			ISNULL(j.PhoneNumber, '') + CASE WHEN ISNULL(j.MobileNumber, '') <> '' THEN ', ' ELSE '' END + ISNULL(j.MobileNumber,'') as Phone,  
			j.BusinessActivity,
			j.AgentSLADateTimeLocal,
			j.Region , --AS MetroView,
			j.OnSiteDateTimeLocal,
			j.OffSiteDateTimeLocal,
			CAST(j.InstallerNotes as VARCHAR(8000)) as Notes,
			Info = dbo.fnJobSheetBuildInfoText(j.JobTypeID, j.ClientID, j.DeviceType, j.OldDeviceType, j.OldTerminalID, null, null, null, j.NetworkTerminalID,	j.CAIC,	j.TransendID, j.CatID, j.configXML),

			'Device' as EquipmentType,
			CASE je.ActionID WHEN 2 THEN 'Out' ELSE 'In' END as InOut,
			je.Serial,
			ISNULL(md.Maker, '') + ' ' + ISNULL(md.Model, '') + ' ' + ISNULL(md.Device, '') AS MMD,
			l.Location as InstallerID,
			ProblemNumber = ISNULL(CASE WHEN ISNULL(j.ProjectNo, '')<>'' THEN j.ProjectNo ELSE j.ProblemNumber END, ''),
			i.Description as InstallerName,
			--Add 3DES/EMV
			je.Is3DES, 
			je.IsEMV,
			Require3DES = dbo.fnJobRequireCompliantDevice(j.JobID, 1),
			RequireEMV = dbo.fnJobRequireCompliantDevice(j.JobID, 2),
			j.Priority,
			IsOpen = 1,
			@CompanyName as CompanyName,
			j.DeviceType,
			Survey = @Survey,
			j.Latitude,
			j.Longitude,
			HasChildDepot = @HasChildDepot,
			Phone1 = j.PhoneNumber,
			Phone2 = j.MobileNumber,
			IAmOnSiteDateLocal = @IAmOnSiteDateLocal,
			CurrentSiteDateLocal = @CurrentSiteDateLocal,
			HasParentDepot = @HasParentDepot,
			TIDExt = dbo.fnHighlightLetter(j.TerminalID),
			TMSSoftwareVersion = t.SoftwareVersion,
			TMSSerial = t.Serial,
			TMSLastUpdated = t.LastUpdated
		  FROM vwIMSJob j JOIN  #myLocation l ON j.BookedInstaller = l.Location
				LEFT OUTER JOIN IMS_Job_Equipment je ON j.JobID = je.JobID
				LEFT OUTER JOIN M_M_D md ON md.MMD_ID = je.MMD_ID
				LEFT OUTER JOIN vwInstaller i ON i.Location = l.Location
				LEFT OUTER JOIN tblTMSData t ON t.TerminalID = j.TerminalID and t.ClientID = j.ClientID
				
		 WHERE j.JobID = @JobID	

		UNION

		SELECT 
			j.JobID,
			j.ClientID,
			j.TerminalID,
			j.TerminalNumber,
			j.MerchantID AS MerchantID,
			j.JobType,
			j.Name,
			j.Address,
			j.Address2,
			j.City,
			j.PostCode,
			j.Contact,
			ISNULL(j.PhoneNumber, '')  + CASE WHEN ISNULL(j.MobileNumber, '') <> '' THEN ', ' ELSE '' END + ISNULL(j.MobileNumber,'') as Phone,
			j.BusinessActivity,
			j.AgentSLADateTimeLocal,
			j.Region , --AS MetroView,
			j.OnSiteDateTimeLocal,
			j.OffSiteDateTimeLocal,
			CAST(j.InstallerNotes as VARCHAR(8000)) as Notes,
			Info = dbo.fnJobSheetBuildInfoText(j.JobTypeID, j.ClientID, j.DeviceType, j.OldDeviceType, j.OldTerminalID, null, null, null, j.NetworkTerminalID,	j.CAIC,	j.TransendID, j.CatID, j.configXML),

			'Parts' as EquipmentType,
			CASE je.ActionID WHEN 2 THEN 'Out' ELSE 'In' END as InOut,
			CAST(je.Qty as varchar(max)) AS Serial,
			ISNULL(md.PartDescription, '') AS MMD,
			l.Location as InstallerID,
			ProblemNumber = ISNULL(CASE WHEN ISNULL(j.ProjectNo, '')<>'' THEN j.ProjectNo ELSE j.ProblemNumber END, ''),
			i.Description as InstallerName,
			--Add 3DES/EMV
			Is3DES = 0,
			IsEMV = 0,
			Require3DES = dbo.fnJobRequireCompliantDevice(j.JobID, 1),
			RequireEMV = dbo.fnJobRequireCompliantDevice(j.JobID, 2),
			j.Priority,
			IsOpen = 1,
			@CompanyName as CompanyName,
			j.DeviceType,
			Survey = @Survey,
			j.Latitude,
			j.Longitude,
			HasChildDepot = @HasChildDepot,
			Phone1 = j.PhoneNumber,
			Phone2 = j.MobileNumber,
			IAmOnSiteDateLocal = @IAmOnSiteDateLocal,
			CurrentSiteDateLocal = @CurrentSiteDateLocal,
			HasParentDepot = @HasParentDepot,
			TIDExt = dbo.fnHighlightLetter(j.TerminalID),
			TMSSoftwareVersion = t.SoftwareVersion,
			TMSSerial = t.Serial,
			TMSLastUpdated = t.LastUpdated
		  FROM vwIMSJob j JOIN  #myLocation l ON j.BookedInstaller = l.Location
				LEFT OUTER JOIN IMS_Job_Parts je ON j.JobID = je.JobID
				LEFT OUTER JOIN vwIMSPart md ON md.PartID = je.PartID
				LEFT OUTER JOIN vwInstaller i ON i.Location = l.Location
				LEFT OUTER JOIN tblTMSData t ON t.TerminalID = j.TerminalID and t.ClientID = j.ClientID
				
		 WHERE j.JobID = @JobID	
	 END
	else ---IF EXISTS(SELECT 1 FROM vwIMSJobHistory WHERE JobID = @JobID) 
	 -- it is a closed job
	 BEGIN
		SELECT 
			j.JobID,
			j.ClientID,
			j.TerminalID,
			j.TerminalNumber,
			j.MerchantID AS MerchantID,
			j.JobType,
			j.Name,
			j.Address,
			j.Address2,
			j.City,
			j.PostCode,
			j.Contact,
			ISNULL(j.PhoneNumber, '')   + CASE WHEN ISNULL(j.MobileNumber, '') <> '' THEN ', ' ELSE '' END + ISNULL(j.MobileNumber,'') as Phone,
			j.BusinessActivity,
			j.AgentSLADateTimeLocal,
			j.Region , --AS MetroView,
			j.OnSiteDateTimeLocal,
			j.OffSiteDateTimeLocal,
			CAST(j.InstallerNotes as VARCHAR(8000)) as Notes,
			Info = dbo.fnJobSheetBuildInfoText(j.JobTypeID, j.ClientID, j.DeviceType, j.OldDeviceType, j.OldTerminalID, null, null, null, j.NetworkTerminalID,	j.CAIC,	j.TransendID, j.CatID, j.configXML),

			'Device' as EquipmentType,
			CASE je.ActionID WHEN 2 THEN 'Out' ELSE 'In' END as InOut,
			je.Serial,
			ISNULL(md.Maker, '') + ' ' + ISNULL(md.Model, '') + ' ' + ISNULL(md.Device, '') AS MMD,
			l.Location as InstallerID,
			ProblemNumber = ISNULL(CASE WHEN ISNULL(j.ProjectNo, '')<>'' THEN j.ProjectNo ELSE j.ProblemNumber END, ''),
			i.Description as InstallerName,
			--Add 3DES/EMV
			je.Is3DES, 
			je.IsEMV,
			Require3DES = dbo.fnJobRequireCompliantDevice(j.JobID, 1),
			RequireEMV = dbo.fnJobRequireCompliantDevice(j.JobID, 2),
			j.Priority,
			IsOpen = 0,
			@CompanyName as CompanyName,
			j.DeviceType,
			Survey = @Survey,
			j.Latitude,
			j.Longitude,
			HasChildDepot = @HasChildDepot,
			Phone1 = j.PhoneNumber,
			Phone2 = j.MobileNumber,
			IAmOnSiteDateLocal = null,
			CurrentSiteDateLocal = null,
			HasParentDepot = @HasParentDepot,
			TIDExt = dbo.fnHighlightLetter(j.TerminalID),
			TMSSoftwareVersion = t.SoftwareVersion,
			TMSSerial = t.Serial,
			TMSLastUpdated = t.LastUpdated
		  FROM vwIMSJobHistory j JOIN  #myLocation l ON j.BookedInstaller = l.Location
				LEFT OUTER JOIN IMS_Job_Equipment_History je ON j.JobID = je.JobID
				LEFT OUTER JOIN M_M_D md ON md.MMD_ID = je.MMD_ID
				LEFT OUTER JOIN vwInstaller i ON i.Location = l.Location
				LEFT OUTER JOIN tblTMSData t ON t.TerminalID = j.TerminalID and t.ClientID = j.ClientID
				
		 WHERE j.JobID = @JobID	
		UNION
		SELECT 
			j.JobID,
			j.ClientID,
			j.TerminalID,
			j.TerminalNumber,
			j.MerchantID AS MerchantID,
			j.JobType,
			j.Name,
			j.Address,
			j.Address2,
			j.City,
			j.PostCode,
			j.Contact,
			ISNULL(j.PhoneNumber, '')  + CASE WHEN ISNULL(j.MobileNumber, '') <> '' THEN ', ' ELSE '' END + ISNULL(j.MobileNumber,'') as Phone,
			j.BusinessActivity,
			j.AgentSLADateTimeLocal,
			j.Region , --AS MetroView,
			j.OnSiteDateTimeLocal,
			j.OffSiteDateTimeLocal,
			CAST(j.InstallerNotes as VARCHAR(8000)) as Notes,
			Info = dbo.fnJobSheetBuildInfoText(j.JobTypeID, j.ClientID, j.DeviceType, j.OldDeviceType, j.OldTerminalID, null, null, null, j.NetworkTerminalID,	j.CAIC,	j.TransendID, j.CatID, j.configXML),

			'Parts' as EquipmentType,
			CASE je.ActionID WHEN 2 THEN 'Out' ELSE 'In' END as InOut,
			CAST(je.Qty as varchar(max)) AS Serial,
			ISNULL(md.PartDescription, '') AS MMD,
			l.Location as InstallerID,
			ProblemNumber = ISNULL(CASE WHEN ISNULL(j.ProjectNo, '')<>'' THEN j.ProjectNo ELSE j.ProblemNumber END, ''),
			i.Description as InstallerName,
			--Add 3DES/EMV
			Is3DES = 0, 
			IsEMV = 0,
			Require3DES = dbo.fnJobRequireCompliantDevice(j.JobID, 1),
			RequireEMV = dbo.fnJobRequireCompliantDevice(j.JobID, 2),
			j.Priority,
			IsOpen = 0,
			@CompanyName as CompanyName,
			j.DeviceType,
			Survey = @Survey,
			j.Latitude,
			j.Longitude,
			HasChildDepot = @HasChildDepot,
			Phone1 = j.PhoneNumber,
			Phone2 = j.MobileNumber,
			IAmOnSiteDateLocal = null,
			CurrentSiteDateLocal = null,
			HasParentDepot = @HasParentDepot,
			TIDExt = dbo.fnHighlightLetter(j.TerminalID),
			TMSSoftwareVersion = t.SoftwareVersion,
			TMSSerial = t.Serial,
			TMSLastUpdated = t.LastUpdated
		  FROM vwIMSJobHistory j JOIN  #myLocation l ON j.BookedInstaller = l.Location
				LEFT OUTER JOIN IMS_Job_Parts_History je ON j.JobID = je.JobID
				LEFT OUTER JOIN vwIMSPart md ON md.PartID = je.PartID
				LEFT OUTER JOIN CAMS.dbo.vwInstaller i ON i.Location = l.Location
				LEFT OUTER JOIN tblTMSData t ON t.TerminalID = j.TerminalID and t.ClientID = j.ClientID
		 WHERE j.JobID = @JobID	
	 END

  END

/*
EXEC dbo.spWebGetFSPJobSheetData @UserID = 199513, @JobID = 1034929 --531024
select top 10 * from vwIMSJobHistory where bookedinstaller = 3001 order by jobid desc
SELECT * FROM WebCams.dbo.tblUser  WHERE UserID = 199512
*/
GO

Grant EXEC on spWebGetFSPJobSheetData to eCAMS_Role
Go


