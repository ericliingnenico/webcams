Use WebCAMS
Go

if exists(select 1 from sys.procedures where name = 'spWebGetFSPJobDetailForBooking')
 drop proc spWebGetFSPJobDetailForBooking
Go

create PROCEDURE dbo.spWebGetFSPJobDetailForBooking 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 18/02/16 10:15 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobDetailForBooking.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPJobDetailForBooking @UserID = @UserID, @JobID = @JobID
/*
spWebGetFSPJob 199649, 20110610270


*/
GO

Grant EXEC on spWebGetFSPJobDetailForBooking to eCAMS_Role
Go


Use CAMS
Go

if exists(select 1 from sys.procedures where name = 'spWebGetFSPJobDetailForBooking')
 drop proc spWebGetFSPJobDetailForBooking
Go

create Procedure dbo.spWebGetFSPJobDetailForBooking 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/01/16 9:44 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetFSPJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @FSPID int

 --Get FSPID
 SELECT @FSPID = InstallerID 
   FROM WebCams.dbo.tblUser
   WHERE UserID = @UserID
   
 --cache the FSP location
 select * into #FSP
	from dbo.fnGetLocationChildrenExt(@FSPID)

 if CAMS.dbo.fnIsSwapCall(@JobID) = 1
  begin
		SELECT 
		JobID = j.CallNumber,
		j.ClientID,
		JobType = 'SWAP',
		j.DeviceType,
		j.Name,
		j.Address,
		j.City,
		j.Postcode,
		Contact = j.Caller,
		PhoneNumber = j.CallerPhone,
		MobileNumber = '',
		Notes = dbo.fnEscapeXMLChar(dbo.fnFormatXMLConcisely(m.CallMemo))

		From CAMS.dbo.vwCalls j left outer join Call_Memos m on j.CallNumber = m.CallNumber
		WHERE j.CallNumber = cast(@JobID as varchar) and (AssignedTo in (select Location from  #FSP))


  end
 else
  begin
		SELECT 
		j.JobID,
		j.ClientID,
		j.JobType,
		j.DeviceType,
		j.Name,
		j.Address,
		j.City,
		j.Postcode,
		j.Contact,
		j.PhoneNumber,
		j.MobileNumber,
		Notes = dbo.fnEscapeXMLChar(dbo.fnFormatXMLConcisely(j.Notes))
		FROM CAMS.dbo.vwIMSJob j
		WHERE  JobID = @JobID and (BookedInstaller in (select Location from  #FSP) or ProposedInstaller in (select Location from  #FSP))

  end  
GO

Grant EXEC on spWebGetFSPJobDetailForBooking to eCAMS_Role
Go


