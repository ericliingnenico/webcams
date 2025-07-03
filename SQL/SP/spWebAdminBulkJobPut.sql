Use CAMS
Go

if object_id('spWebAdminBulkJobPut ') is not null
   drop procedure dbo.spWebAdminBulkJobPut 
GO

create Procedure dbo.spWebAdminBulkJobPut  
	(
		@UserID int,
		@ActionID int,
		@Data varchar(4000) = null
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-03-15 14:52:58$-->
--<!--$ModifiedBy: Bo Li <bo.li@bambora.com>$-->
--<!--$Comment: icm-57$-->

---Admin Bulk Update
--

declare @Action varchar(1000),
	@UserStamp varchar(200),
	@ret int,
	@StartedTransaction bit


 begin try
	 if ISNUMERIC(@UserID) = 1
	  begin
		exec spSetContextInfo @Section = 124, @value = @UserID
	  end

	select @Action = dbo.fnCRLF() + case when @ActionID = 1 then 'Bulk Update FSPQuote:' 
											when @ActionID = 2 then 'Bulk Update ExtraTimeUnit:' 
											when @ActionID = 3 then 'Bulk Update TerminalCollected:' 
											else  ''
									end,
			@UserStamp = dbo.fnGetOperatorStamp(@UserID)

	--CREATE TABLE #tmpJob (JobID bigint, Qty int)

	 --insert into #tmpJob
	select JobID = cast(f1 as bigint),
		Qty=f2
	  into #tmpJob
	  from dbo.fnConvertListToTableWithMultipleField(@Data,',','|')


 	if	@@TRANCOUNT = 0 
	 begin
			BEGIN TRANSACTION
			SET @StartedTransaction = 1
		END


	 if @ActionID = 1
	  begin
		if exists(select 1 from #tmpJob where len(JobID) < 11)
		 begin
			update j
			 set InvoiceNotes = isnull(InvoiceNotes, '')  + @Action + isnull(Qty, '') + @UserStamp,
				FSPQuote = Qty,
				FSPExtraTimeAndQuoteApproved = 1,
				FSPExtraTimeUnitsReq = null
			 from #tmpJob t join IMS_Jobs_History j on t.JobID= j.JobID
		 end
		if exists(select 1 from #tmpJob where len(JobID) = 11)
		 begin
			update j
			 set InvoiceNotes = isnull(InvoiceNotes, '')  + @Action + isnull(Qty, '') + @UserStamp,
				FSPQuote = Qty,
				FSPExtraTimeAndQuoteApproved = 1,
				FSPExtraTimeUnitsReq = null
			 from #tmpJob t join Call_History j on cast(t.JobID as varchar)= j.CallNumber
		 end

	  end 

	 if @ActionID = 2
	  begin
		if exists(select 1 from #tmpJob where len(JobID) < 11)
		 begin
			update j
			 set InvoiceNotes = isnull(InvoiceNotes, '')  + @Action + isnull(Qty, '') + @UserStamp,
				FSPExtraTimeUnitsReq = Qty,
				FSPExtraTimeAndQuoteApproved = 1,
				FSPQuote = null
			 from #tmpJob t join IMS_Jobs_History j on t.JobID= j.JobID
		 end
		if exists(select 1 from #tmpJob where len(JobID) = 11)
		 begin
			update j
			 set InvoiceNotes = isnull(InvoiceNotes, '')  + @Action + isnull(Qty, '') + @UserStamp,
				FSPExtraTimeUnitsReq = Qty,
				FSPExtraTimeAndQuoteApproved = 1,
				FSPQuote = null
			 from #tmpJob t join Call_History j on cast(t.JobID as varchar)= j.CallNumber
		 end

	  end 

	 if @ActionID = 3
	  begin
		update j
		 set --InvoiceNotes = isnull(InvoiceNotes, '')  + @Action + isnull(Qty, '') + @UserStamp,
			Notes = isnull(cast(Notes as varchar(max)), '')  + @Action + isnull(Qty, '') + @UserStamp
		 from #tmpJob t join IMS_Jobs_History j on t.JobID= j.JobID

		delete j
		 from #tmpJob t join IMS_Job_Parts_History j on t.JobID= j.JobID and ActionID = 2 and PartID = 'CBATT'

		insert IMS_Job_Parts_History (JobID,
									PartID,
									ActionID,
									Qty)
			select j.JobID,
					'CBATT',
					2,
					isnull(Qty, 0) 
			  from #tmpJob t join IMS_Jobs_History j on t.JobID= j.JobID and j.ClientID = 'CBA' and j.JobTypeID in (2)



	  end 
  
	  insert tblAuditLog (AuditObjectID,
						AuditData,
						LoggedDateTime)

		select 9,
			'<UserID>' + cast(@UserID as varchar) + '</UserID>' +
			'<ActionID>' + cast(@ActionID as varchar) + '</ActionID>' + 
			'<Data>' + @Data + '</Data>' ,
			getdate()
 	IF @StartedTransaction = 1 	
		COMMIT TRANSACTION	

	return 0
 end try

BEGIN CATCH
	IF @StartedTransaction = 1 
		ROLLBACK TRANSACTION
	
	EXEC master.dbo.upGetErrorInfo
	return -1
END CATCH




GO

Grant EXEC on spWebAdminBulkJobPut  to eCAMS_Role
Go

/*
spWebAdminBulkJobPut  199649, 1, '20160705117|8|,20160725104|19|,20160800615|12|,20160801730|11|,20160803885|11|,20160807456|15|,20160809776|21|,20160810602|15|,20160812158|8|,20160812310|9|,2273447|19|,2303868|20|,2303869|20|,2313457|13|,2322676|19|,2323464|19|,2340973|15|,2358149|14|,2371129|19|,2384818|12|,'

*/


Use WebCAMS
Go

if object_id('spWebAdminBulkJobPut ') is not null
   drop procedure dbo.spWebAdminBulkJobPut 
GO

create Procedure dbo.spWebAdminBulkJobPut  
	(
		@UserID int,
		@ActionID int,
		@Data varchar(4000) = null
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 11:41a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAdminBulkJobPut .sql $-->
--<!--$$NoKeywords: $-->
 declare @ret int

 SET NOCOUNT ON

 --init 
 select @ret = -1


  if not exists(select 1 from tblUserModule where UserID = @UserID and ModuleID = 5)
   begin
	raiserror ('Permission denied. Abort.',16,1)
	goto Exit_Handle
   end

  
 EXEC @ret = Cams.dbo.spWebAdminBulkJobPut  
			@UserID = @UserID, 
			@ActionID = @ActionID, 
			@Data = @Data

--Return
Exit_Handle:
 SELECT @ret 
 RETURN @ret


/*
select * from webcams.dbo.tblUser

spWebAdminBulkJobPut  199649, 1, '20160705117|8|,20160725104|19|,20160800615|12|,20160801730|11|,20160803885|11|,20160807456|15|,20160809776|21|,20160810602|15|,20160812158|8|,20160812310|9|,2273447|19|,2303868|20|,2303869|20|,2313457|13|,2322676|19|,2323464|19|,2340973|15|,2358149|14|,2371129|19|,2384818|12|,'

*/
Go

Grant EXEC on spWebAdminBulkJobPut  to eCAMS_Role
Go
