Use CAMS
Go

ALTER PROCEDURE dbo.spPDAGetFSPJobList 
(
	@UserID int
)
AS
--<!--$$Revision: 59 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/12/10 15:38 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPJobList.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get FSP Open Job List
--		JobTypeID: INSTALL - 1, DEINSTALL - 2, UPGRADE - 3, SWAP - 4
--		JobMethodID: TECH - 1, MERCHANT - 2, SMART - 3, PHONE - 4
--		RegionTypeID: METRO - 1, COUNTRY - 2, PROVINCIAL - 3, REMOTE - 4

DECLARE @InstallerID int,
	@CRLF varchar(2)


 SET NOCOUNT ON

 --init
 SET @CRLF = CHAR(13) + CHAR(10)

 SELECT @InstallerID = InstallerID
   FROM WebCams.dbo.tblUser
  WHERE UserID = @UserID

 --Temporary table to store jobid/callnumber
 --####Make sure the criteria be the same as resultset return

 SELECT j.JobID INTO #Job 
	FROM IMS_Jobs j
	WHERE j.BookedInstaller = @InstallerID
		AND j.AllowPDADownload = 1
		AND j.AgentSLADateTime IS NOT NULL

 SELECT j.CallNumber INTO #Call
	FROM Calls j
	WHERE j.AssignedTo = @InstallerID
		AND j.AllowPDADownload = 1
		AND j.AgentSLADateTime IS NOT NULL

 

 --return resultset
  SELECT 
	A = CAST(j.JobID as BigInt),
	B = JobTypeID,
	C = JobMethodID,
	D = ISNULL(DeviceType, ''),
	E = ISNULL(CASE WHEN ISNULL(ProjectNo, '')<>'' THEN ProjectNo ELSE ProblemNumber END, ''),
	F = ISNULL(j.ClientID, ''), 
	G = ISNULL(MerchantID, ''), 
	H = ISNULL(TerminalID, ''), 
	I = ISNULL(TerminalNumber, ''),
	L = CONVERT(varchar, AgentSLADateTimeLocal, 120),
	M = ISNULL([Name], ''),
	N = ISNULL(Address, ''),
	O = ISNULL(Address2, ''),
	P = ISNULL(City, ''),
	Q = ISNULL(Postcode, ''),
	R = ISNULL(State, ''),
	S = ISNULL(Contact, ''),
	T = ISNULL(PhoneNumber, '') + CASE WHEN ISNULL(MobileNumber, '') = '' THEN '' ELSE ' , ' + MobileNumber END,	--ISNULL(PhoneSTD, '') + 
	U = ISNULL(RegionID, 1),
	V = dbo.fnTrimExtraCharacter(CAST(ISNULL(InstallerNotes, '') as varchar(255))),
	W = CAST(
		CASE WHEN ISNULL(j.OldTerminalID, '') <> '' THEN 'Old T-ID:'+ j.OldTerminalID + ' ' ELSE '' END + 
		CASE WHEN ISNULL(j.CAIC, '') <> '' THEN 'CAIC:'+ j.CAIC + ' ' ELSE '' END   +
		CASE WHEN j.ClientID in ('NAB') AND j.JobTypeID IN (1, 3) THEN
			'SecApp:' +  dbo.fnGetTerminalConfig(j.configXML, 'SecApp') + ' ' + @CRLF +
			CASE WHEN ISNULL(j.BusinessActivity, '') <> '' THEN 'BusinessType:' + j.BusinessActivity + ' ' + @CRLF ELSE '' END +
			CASE WHEN ISNULL(j.TransendID, '') <> '' THEN 'Transend:'+ j.TransendID + ' ' ELSE '' END + 
			CASE WHEN ISNULL(j.CatID, '') <> '' THEN 'CatID:'+ j.CatID + ' ' ELSE '' END + 
							'VAS:' +  dbo.fnGetTerminalConfig(j.configXML, 'VAS') + ' ' +
							'CrEFTPOS:' +  dbo.fnGetTerminalConfig(j.configXML, 'CrEFTPOS') + ' '
							
	   	ELSE '' END +
	   	CASE WHEN j.ClientID in ('WBC') AND j.JobTypeID IN (1, 3) THEN
			CASE WHEN ISNULL(j.BusinessActivity, '') <> '' THEN 'BusinessType:' + j.BusinessActivity + ' ' + @CRLF ELSE '' END +
			CASE WHEN CHARINDEX('<11>', j.ConfigXML) > 0 THEN 'Loyalty ' ELSE '' END +
			CASE WHEN CHARINDEX('<14>', j.ConfigXML) > 0THEN 'Moto ' ELSE '' END 
	   	ELSE '' END +
	   	CASE WHEN j.ClientID in ('CUS') AND j.JobTypeID IN (1, 3) AND j.DeviceType = 'T7PLUS' THEN
			CASE WHEN ISNULL(j.TransendID, '') <> '' THEN 'Term. Init. ID:'+ j.TransendID + ' ' ELSE '' END
	   	ELSE '' END +
		CASE WHEN dbo.fnJobRequireCompliantDevice(j.JobID, 1) = 1 THEN ',Req 3DES Compliance,' ELSE '' END +
		CASE WHEN dbo.fnJobRequireCompliantDevice(j.JobID, 2) = 1 THEN ',Req EMV Compliance,' ELSE '' END


	   as varchar(255))
	
	FROM vwIMSJob j JOIN #Job tj ON j.JobID = tj.JobID

 UNION
  SELECT 
	A = j.CallNumber,
	B = 4,
	C = 1,  --jobmethodid
	D = ISNULL(j.CallType, ''),
	E = ISNULL(CASE WHEN ISNULL(ProjectNo, '')<>'' THEN ProjectNo ELSE ProblemNumber END, ''),
	F = ISNULL(j.ClientID, ''), 
	G = ISNULL(j.MerchantID, ''), 
	H = ISNULL(j.TerminalID, ''), 
	I = ISNULL(j.TerminalNumber, ''),
	L = CONVERT(varchar, j.AgentSLADateTimeLocal, 120),
	M = ISNULL(j.[Name], ''),
	N = ISNULL(j.Address, ''),
	O = ISNULL(j.Address2, ''),
	P = ISNULL(j.City, ''),
	Q = ISNULL(j.Postcode, ''),
	R = ISNULL(j.State, ''),
	S = ISNULL(j.Caller, ''),
	T = ISNULL(j.CallerPhone, ''),		--ISNULL(j.CallerSTD, '') + 
	U = CASE WHEN j.RegionID <> 1 THEN 2 ELSE 1 END, -- regiontypeid	j.Metro = 0  
	V = dbo.fnTrimExtraCharacter(CAST(ISNULL(m.FaultMemo, '') as varchar(255))),

	W = CAST(
		CASE WHEN ISNULL(j.CallType, '') <> '' THEN 'CallType:'+ j.CallType + ' ' ELSE '' END + 
		CASE WHEN ISNULL(j.Symptom, '') <> '' THEN 'Symptom:'+ j.Symptom + ' ' ELSE '' END + 
		CASE WHEN ISNULL(j.Fault, '') <> '' THEN 'Fault:'+ j.Fault + ' ' ELSE '' END + 
		CASE WHEN ISNULL(j.Severity, '') <> '' THEN 'Severity:'+ j.Severity + ' ' ELSE '' END + 
		CASE WHEN ISNULL(sm.NetworkTerminalID, '') <> '' THEN 'Transend:'+ sm.NetworkTerminalID + ' ' ELSE '' END + 
		CASE WHEN ISNULL(sm.Acq1CAIC, '') <> '' THEN 'CAIC:'+ sm.Acq1CAIC + ' ' ELSE '' END +
	   	CASE WHEN j.ClientID in ('CUS') AND j.Calltype = 'CUSCAL T7' THEN
			CASE WHEN ISNULL(sm.NetworkTerminalID, '') <> '' THEN 'Term. Init. ID:'+ sm.NetworkTerminalID + ' ' ELSE '' END
	   	ELSE '' END  +
		CASE WHEN dbo.fnJobRequireCompliantDevice(j.CallNumber, 1) = 1 THEN ',Req 3DES Compliance,' ELSE '' END +
		CASE WHEN dbo.fnJobRequireCompliantDevice(j.CallNumber, 2) = 1 THEN ',Req EMV Compliance,' ELSE '' END
	   as varchar(255))

	FROM vwCalls j JOIN #Call tj ON j.CallNumber = tj.CallNumber
			LEFT OUTER JOIN Call_Memos m ON j.CallNumber = m.CallNumber
			LEFT OUTER JOIN Site_Maintenance sm ON j.ClientID = sm.ClientID
							AND j.TerminalID = sm.TerminalID
							AND j.TerminalNumber = sm.TerminalNumber
							
 Order by L


 -- return multiple recordsets to save times of roundtrip to server

 --job equipment list
 EXEC dbo.spPDAGetFSPJobEquipmentListExt @UserID = @UserID


 --get jobclosure empty table
 SELECT A = Cast(JobID as bigint),
	B = OnSiteDateTime,
	C = OffSiteDateTime,
	D = TechFixID
   FROM IMS_Jobs
  WHERE 1 = 2

 --get MerchantAcceptance empty able for on line cache
 SELECT A = JobID,
	B = SignatureData,
	C = PrintName
   FROM tblMerchantAcceptance
  WHERE 1 = 2


 --get JobNotes empty able for online cache
 SELECT A = CAST(JobID as bigint),
	B = CAST('' as varchar(255))
   FROM IMS_Jobs
  WHERE 1 = 2

 --get pCAMS version
 SELECT A = AttrValue
   FROM WebCAMS.dbo.tblControl
  WHERE Attribute = 'pCAMSVersion'


 --get Survey version
 SELECT A = AttrValue
   FROM CAMS.dbo.tblControl
  WHERE Attribute = 'SurveyVersion'

 --get MMD version
 SELECT A = AttrValue
   FROM CAMS.dbo.tblControl
  WHERE Attribute = 'MMDVersion'

 --get IMS Part version
 SELECT A = AttrValue
   FROM CAMS.dbo.tblControl
  WHERE Attribute = 'IMSPartVersion'


 --get TechFix version
 SELECT A = AttrValue
   FROM CAMS.dbo.tblControl
  WHERE Attribute = 'TechFixVersion'


 --OK, the last thing to do is to update download stamp on jobs/call
 --update LastPDADownload stamp
 UPDATE j
    SET LastPDADownload = GetDate()
   FROM IMS_Jobs j JOIN #Job tj ON j.JobID = tj.JobID

 UPDATE j
    SET LastPDADownload = GetDate()
   FROM Calls j JOIN #Call tj ON j.CallNumber = tj.CallNumber



/*
exec spPDAGetFSPJobList 199611
*/

GO
Grant EXEC on spPDAGetFSPJobList to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spPDAGetFSPJobList 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 10 $-->
--<!--$$Author: Thanh $-->
--<!--$$Date: 30/04/04 5:23p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetFSPJobList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetFSPJobList @UserID = @UserID
/*
spPDAGetFSPJobList 199611
spPDAGetFSPJobList 199513
*/
Go

Grant EXEC on spPDAGetFSPJobList to eCAMS_Role
Go


