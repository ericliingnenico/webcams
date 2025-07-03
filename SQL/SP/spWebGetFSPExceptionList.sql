
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPExceptionList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPExceptionList]
GO

CREATE Procedure dbo.spWebGetFSPExceptionList 
	(
		@UserID int,
		@FSPID int,
		@From tinyint
	)
	AS
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 1/04/09 1:15p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPExceptionList.sql $-->
--<!--$$NoKeywords: $-->
---Get all open jobs with status = 'FSP Exception' for a given FSP
DECLARE @InstallerID int

DECLARE @STATUS_PDA_EXCEPTION tinyint,
	@STATUS_FSP_EXCEPTION tinyint



 SET NOCOUNT ON

	
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


 --init
 SELECT @STATUS_PDA_EXCEPTION = 6, --'PDA EXCEPTION',
	@STATUS_FSP_EXCEPTION = 7 --'FSP EXCEPTION'


 SELECT @InstallerID = InstallerID 
   FROM WebCams.dbo.tblUser
  WHERE UserID = @UserID

 SELECT * INTO #myLoc
    FROM dbo.fnGetLocationChildrenExt(@InstallerID)


 IF @From = 1  --from desk top web
  BEGIN
	--return resultset
 	SELECT 
		'<A HREF="../Member/FSPJobException.aspx?JID=' + cast(j.JobID as varchar) + '">' + cast(j.JobID as varchar) + '</A>' as JobID,
		j.BookedInstaller as [To],
		j.ClientID, 
		j.JobType,
	     	AgentSLADateTimeLocal AS RequiredBy,
		[Name] as MerchantName,
		City,
		j.Status
		FROM vwIMSJob j JOIN #myLoc l ON j.BookedInstaller = l.Location
	   	WHERE j.StatusID IN (@STATUS_PDA_EXCEPTION, @STATUS_FSP_EXCEPTION)
	UNION
	SELECT 
		'<A HREF="../Member/FSPJobException.aspx?JID=' + CallNumber + '">' + CallNumber + '</A>' as JobID,
		AssignedTo as [To],
 		 j.ClientID, 
		'SWAP' as JobType,
	     	AgentSLADateTimeLocal AS RequiredBy,
		[Name] as MerchantName,
		City,
		j.Status
		FROM vwCalls j JOIN #myLoc l ON j.AssignedTo = l.Location
		WHERE j.StatusID IN (@STATUS_PDA_EXCEPTION, @STATUS_FSP_EXCEPTION)
	Order by RequiredBy


  END --from desktop web
 ELSE
  --from PDA web
  BEGIN
	--no fsp passed in, only return user's jobs
 	SELECT 
		'<A HREF="../Member/FSPJobException.aspx?JID=' + cast(j.JobID as varchar) + '">' + cast(j.JobID as varchar) + '</A>' as JobID,
		j.ClientID as CID, 
		CASE j.JobType WHEN 'INSTALL' THEN 'I'
				WHEN 'DEINSTALL' THEN 'D'
				ELSE 'U' END as T,
	     	dbo.fnConvertShortDateTime(AgentSLADateTimeLocal) AS RequiredBy,
		City
		FROM vwIMSJob j JOIN #myLoc l on j.BookedInstaller = l.Location
		WHERE j.StatusID IN (@STATUS_PDA_EXCEPTION, @STATUS_FSP_EXCEPTION)
	UNION
	SELECT 
		'<A HREF="../Member/FSPJobException.aspx?JID=' + CallNumber + '">' + CallNumber + '</A>' as JobID,
 		 j.ClientID as CID, 
		'S' as T,
	     	dbo.fnConvertShortDateTime(AgentSLADateTimeLocal) AS RequiredBy,
		City

		FROM vwCalls j JOIN #myLoc l on j.AssignedTo = l.Location
		WHERE j.StatusID IN (@STATUS_PDA_EXCEPTION, @STATUS_FSP_EXCEPTION)
	Order by RequiredBy

  END


GO

Grant EXEC on spWebGetFSPExceptionList to eCAMS_Role
Go

Use WebCAMS
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPExceptionList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetFSPExceptionList]
GO


Create Procedure dbo.spWebGetFSPExceptionList 
	(
		@UserID int,
		@FSPID int,
		@From tinyint
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 11:41a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPExceptionList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPExceptionList 
			@UserID = @UserID, 
			@FSPID = @FSPID, 
			@From = @From

/*
select * from webcams.dbo.tblUser

spWebGetFSPExceptionList 199512, 3001, 1


spWebGetFSPExceptionList 199649, 3003, 1
*/
Go

Grant EXEC on spWebGetFSPExceptionList to eCAMS_Role
Go
