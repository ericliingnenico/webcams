USE CAMS
Go

if object_id('spWebGMapGetFSPJob', 'p') is not null
 drop procedure dbo.spWebGMapGetFSPJob
GO



Create PROC [dbo].[spWebGMapGetFSPJob] (
	@InstallerID 	int,
	@JobViewer varchar(50)
)
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/10/12 11:30 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGMapGetFSPJob.sql $-->
--<!--$$NoKeywords: $-->
AS
/*
 Purpose: Build gmap url string
*/
 SET NOCOUNT ON
 Declare @Seq int,
		@txt varchar(8000),
		@qty int,
		@ret int,
		@DELIMITER char(1),
		@CRLF varchar(10),
		@WebServerURL varchar(500)

 --init
 SELECT @ret = 0,
		@DELIMITER = '|',
		@CRLF = '<br>'

 select @WebServerURL = AttrValue
  from tblControl
  where Attribute = 'WebServerURL'

 CREATE TABLE #myJob(
		Seq int identity,
		Latitude float, 
		Longitude float, 
		txt varchar(8000) collate database_default,
		Qty int,
		Color varchar(2) collate database_default)

 ----get FSP Latitude/Longitude
 --INSERT #myJob (Latitude,
	--	Longitude,
	--	txt,
	--	Qty)
 --SELECT Latitude,
	--	Longitude,
	--	'FSP ' + CAST(@InstallerID as varchar) as txt,
	--	1
 --  FROM Locations_Master WITH (NOLOCK)
 -- WHERE Location = @InstallerID
	--	AND Master.dbo.fnIsValidLatidueLongitude(Latitude, Longitude) = 1
 
 INSERT #myJob (Latitude,
		Longitude,
		txt,
		Qty,
		Color)
 SELECT	 Latitude, 
		Longitude, 
		CAST(JobID as varchar) + @DELIMITER +  ClientID  + ' '+   JobType + @DELIMITER +ISNULL(convert(varchar, AgentSLADateTimeLocal, 3) + ' ' + left(convert(varchar,AgentSLADateTimeLocal, 108), 5), '')
		+ @DELIMITER + '~!' +CAST(JobID as varchar)+'!~'  as txt,
		1,
		dbo.fnGMapColor(AgentSLADateTimeLocal, StatusID)
	FROM CAMS.dbo.vwIMSJob  WITH (NOLOCK)
	 where Master.dbo.fnIsValidLatidueLongitude(Latitude, Longitude) = 1
			AND BookedInstaller = @InstallerID
			AND AllowPDADownload = 1
--			AND convert(varchar, AgentSLADateTime, 112) = convert(varchar, getdate(), 112)
 union
  SELECT	 Latitude, 
		Longitude, 
		CallNumber + @DELIMITER +  ClientID  + ' SWAP'+   @DELIMITER +ISNULL(convert(varchar, AgentSLADateTimeLocal, 3) + ' ' + left(convert(varchar,AgentSLADateTimeLocal, 108), 5), '')
		+ @DELIMITER  + '~!' +CallNumber+'!~' as txt,
		1,
		dbo.fnGMapColor(AgentSLADateTimeLocal, StatusID)
	FROM CAMS.dbo.vwCalls  WITH (NOLOCK) 
	 where Master.dbo.fnIsValidLatidueLongitude(Latitude, Longitude) = 1
			AND AssignedTo = @InstallerID
			AND AllowPDADownload = 1
--			AND convert(varchar, AgentSLADateTime, 112) = convert(varchar, getdate(), 112)
	ORDER By Latitude DESC,	Longitude ASC

 --no jobs found, delete the temp data
 IF @@ROWCOUNT = 0
	DELETE #myJob


 IF EXISTS(SELECT 1 FROM #myJob GROUP BY Latitude,Longitude HAVING COUNT(*)>1)
  BEGIN  --need to merge the duplicated position on map
	SELECT MIN(t1.Seq) as Seq,
			t1.Latitude,
			t1.Longitude,
			(SELECT RTRIM(txt) + @DELIMITER FROM #myJob t2 
							WHERE t2.Latitude = t1.Latitude AND t2.Longitude = t1.Longitude 
							ORDER BY t2.Seq 
							FOR XML PATH('')) as txt,
			SUM(t1.Qty) as Qty
	  INTO #myBuffer
	  FROM #myJob t1 
	 GROUP BY Latitude,Longitude

	--remove the duplicated ones in #myJob
	DELETE j
		FROM #myJob j left OUTER JOIN #myBuffer b ON j.Seq = b.Seq
		WHERE b.Seq IS NULL


	--trim the last comma
	UPDATE j
		SET j.txt = REPLACE(LEFT(b.txt, LEN(b.txt)-LEN(@DELIMITER)), @DELIMITER, @CRLF) ,
			j.Qty = b.Qty
		FROM #myJob j JOIN #myBuffer b ON j.Seq = b.Seq
  END
	--set view job url
  UPDATE j
		SET j.txt = REPLACE(j.txt, '~!', '<a href=' + @WebServerURL + '/eCAMS/Member/' + @JobViewer + '?id=')  --'<a href=http://localhost:3606/eCAMS/Member/mpFSPJob.aspx?id='
		FROM #myJob j

  UPDATE j
		SET j.txt = REPLACE(j.txt, '!~', '&p=1>View Detail</a>')
		FROM #myJob j


 SELECT latitude,
		Longitude,
		txt = LEFT(txt,1000),
		Qty,
		Color
	 FROM #myJob ORDER BY Seq

Go

/*

select * from cams.dbo.tblControl
*/
grant exec on dbo.spWebGMapGetFSPJob to  CAMSApp, eCAMS_Role
go



use WebCAMS
Go

if object_id('spWebGMapGetFSPJob', 'p') is not null
 drop procedure dbo.spWebGMapGetFSPJob
GO



Create PROC [dbo].[spWebGMapGetFSPJob] (
	@UserID 	int,
	@JobViewer varchar(50)

)
--<!--$$Revision: 10 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 8/11/10 9:19 $-->
--<!--$$Logfile: /SQL/SP/CAMS/spWebGMapGetFSPJob.sql $-->
--<!--$$NoKeywords: $-->
AS
/*
 Purpose: Get FSP Job for Google Map Display
*/

 SET NOCOUNT ON

 DECLARE @InstallerID int

 --get installer id form webcams
 SELECT @InstallerID = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID
 

 EXEC Cams.dbo.spWebGMapGetFSPJob @InstallerID = @InstallerID, @JobViewer = @JobViewer

/*
 exec spWebGMapGetFSPJob @UserID = 199649, @JobViewer = 'mpGMapViewer'
*/
GO

Grant EXEC on spWebGMapGetFSPJob to eCAMS_Role
Go
