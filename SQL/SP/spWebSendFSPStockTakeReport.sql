Use CAMS
Go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebSendFSPStockTakeReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebSendFSPStockTakeReport]
GO


Create Procedure dbo.spWebSendFSPStockTakeReport 
	(
		@UserID int,
		@BatchID int
	)
	AS
--<!--$$Revision: 4 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 23/04/13 14:02 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebSendFSPStockTakeReport.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Send FSP StockTake Report for the batch specified
DECLARE @ret int,
	@FSPLocation int,
	@FSPStockAddress varchar(500),
	@Count int,
	@CRLF varchar(2),
	@TAB varchar(1),
	@Subject varchar(200),	
	@SQL nvarchar(2000),
	@StockTakeDate datetime,
	@Body varchar(max)

 --init
 SELECT @CRLF = CHAR(13) + CHAR(10),
	@TAB = CHAR(9)

 --verify user
 IF NOT EXISTS(SELECT 1 FROM tblFSPStockTake WHERE UserID = @UserID AND BatchID = @BatchID)
  BEGIN
	--the batch is not belong to this user, return
	RETURN 
  END
  
 --Get Location for the user
 SELECT @FSPLocation = r.Depot,
	@StockTakeDate = r.StockTakeDate,
	@FSPStockAddress = 'FSPStockTakeScan@keycorp.net;' + 
				CASE WHEN Master.dbo.fnIsValidEmail(ISNULL(l.StockAddress, '')) = 1 THEN l.StockAddress ELSE '' END,
	@Subject = 'FSP StockTake Report (' + CASE WHEN r.SourceID = 'P' THEN 'PDA' ELSE 'Web' END + ' Scanned by ' + CAST(@FSPLocation as varchar) + '-' + u.UserName + ')'
   FROM tblFSPStockTake r JOIN Locations_Master l ON r.Depot = l.Location
				JOIN WebCAMS.dbo.tblUser u ON u.UserID = r.UserID
  WHERE r.BatchID = @BatchID



 IF EXISTS(SELECT 1 FROM tblControl WHERE Attribute = 'IsLiveDB' AND AttrValue = 'YES')
  BEGIN
	SELECT @FSPStockAddress = @FSPStockAddress 
  END
 ELSE
  BEGIN
	SELECT @FSPStockAddress = 'bli@keycorp.net'
  END



 SELECT @Body = 'StockTake Report Summary as below, for details refer to the file as attached.' + @CRLF  + @CRLF

 --cache StockTakeLog
 SELECT c.CaseDescription,
	Qty = COUNT(*)
   INTO #myLog
  FROM tblFSPStockTakeLog l join tblFSPStockTakeCase c on l.CaseID = c.CaseID
 WHERE BatchID = @BatchID
 group by c.CaseDescription
 
 insert #myLog
 select 'zzNot Scanned',
	Qty = COUNT(ei.Serial)
  from Equipment_Inventory ei left outer join tblFSPStockTakeLog l on ei.Serial = l.Serial and ei.MMD_ID = l.MMD_ID
  where ei.Location in (select depot from tblFSPStockTake where BatchID = @BatchID)
	and (ei.MMD_ID in (select MMD_ID from tblStockTakeDevice where StockTakeDate = @StockTakeDate)
			or exists(select 1 from tblStockTakeDevice where StockTakeDate = @StockTakeDate and MMD_ID = 'ALL')
		)
	and l.Serial is null

  
  select @Body = @Body + (select CaseDescription + char(9) + cast(Qty as varchar) + CHAR(10) from #myLog order by CaseDescription for xml path(''))
  
 set @SQL = 'EXEC msdb.dbo.sp_send_dbmail
		@profile_name = ''SQLMail'',
		@recipients = ''' + @FSPStockAddress + ''',
		@query = '' select 
				l.Serial,
				l.MMD_ID,
				c.CaseDescription,
				l.ScannedDateTime
			  from CAMS.dbo.tblFSPStockTakeLog l join CAMS.dbo.tblFSPStockTakeCase c on l.CaseID = c.CaseID
			  where l.BatchID = ' + CAST(@BatchID as varchar) + '
			 union
			 select 
			   ei.Serial,
			   ei.MMD_ID,
			   ''''zzNot Scanned'''',
			   null
			  from CAMS.dbo.Equipment_Inventory ei left outer join CAMS.dbo.tblFSPStockTakeLog l on ei.Serial = l.Serial and ei.MMD_ID = l.MMD_ID
			  where ei.Location in (select depot from CAMS.dbo.tblFSPStockTake where BatchID = ' + CAST(@BatchID as varchar) + ')
				and (
						ei.MMD_ID in (select MMD_ID from CAMS.dbo.tblStockTakeDevice where StockTakeDate =''''' + CONVERT(varchar, @StockTakeDate, 106) + ''''')
						or exists(select 1 from CAMS.dbo.tblStockTakeDevice where StockTakeDate = ''''' + CONVERT(varchar, @StockTakeDate, 106) + ''''' and MMD_ID = ''''ALL'''')
					)
				and l.Serial is null
			 order by c.CaseDescription
	'' ,
		@subject = ''' +  @Subject + ''',
		@body = ''' +  @body + ''',
		@attach_query_result_as_file = 1 ;'


	--print @SQL
	exec sp_executesql @SQL


 RETURN @@ERROR

GO

Grant EXEC on spWebSendFSPStockTakeReport to eCAMS_Role
Go


Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebSendFSPStockTakeReport]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebSendFSPStockTakeReport]
GO


Create Procedure dbo.spWebSendFSPStockTakeReport 
	(
		@UserID int,
		@BatchID int
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDACloseJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON

 EXEC Cams.dbo.spWebSendFSPStockTakeReport 
		@UserID = @UserID,
		@BatchID = @BatchID

/*


spWebSendFSPStockTakeReport @UserID = 201222,
		@BatchID = 5

*/
Go

Grant EXEC on spWebSendFSPStockTakeReport to eCAMS_Role
Go

use msdb
Go

Grant EXEC on sp_send_dbmail to public
Go
