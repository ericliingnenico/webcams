
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebFSPGetTaskJobPostData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebFSPGetTaskJobPostData]
GO

CREATE PROC dbo.spWebFSPGetTaskJobPostData (
	@UserID 		int,
	@TaskID 		int
)
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/10/12 11:29 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebFSPGetTaskJobPostData.sql $-->
--<!--$$NoKeywords: $-->
AS
/*
 Purpose: Get Task's job post Stock/Note data
*/
 SET NOCOUNT ON
 DECLARE 
	@ret 			int,
	@SourceID		tinyint,
	@JobID			bigint,
	@PICKPACK_TASK		tinyint


 --Telstra web post related variables
 DECLARE @Job varchar(4000),
	@Customer varchar(4000),
	@Stock varchar(4000),
	@Note varchar(4000)
 SELECT @Job = '',
	@Customer = '',
	@Stock = '',
	@Note = ''


 SELECT @PICKPACK_TASK = 1

 CREATE TABLE #PostData (Data varchar(4000) collate database_default)

 --Get Task's info
 SELECT 
	@SourceID = t.SourceID,
	@JobID = t.JobID
   FROM vwTask  t JOIN WebCams.dbo.tblUser u ON t.AssignedTo = u.InstallerID
  WHERE u.UserID = @UserID
	AND t.TaskID = @TaskID


 IF @SourceID = 1 --IMS Job
  BEGIN
	IF EXISTS(SELECT 1 FROM vwIMSJob 
				WHERE JobID = @JobID
					AND CallMethod = 'TCWDB')
	 BEGIN
		--it is Telstra pickpack depot, then post strock & notes
		EXEC dbo.spGetIMSJobPostDataByJobID 
				@JobID = @JobID,
				@Job = @Job output,
				@Customer = @Customer output,
				@Stock = @Stock output,
				@Note = @Note output
		
		
		INSERT #PostData VALUES(@Stock)
		INSERT #PostData VALUES(@Note)

	 END


 END

 IF @SourceID = 2 --Call
  BEGIN
	IF EXISTS(SELECT 1 FROM vwCalls 
				WHERE CallNumber = CAST(@JobID as varchar(11))
					AND CallMethod = 'TCWDB')
	 BEGIN
		--it is Telstra pickpack depot, then post strock & notes
		EXEC dbo.spGetCallPostDataByCallNo 
				@CallNumber = @JobID,
				@Job = @Job output,
				@Customer = @Customer output,
				@Stock = @Stock output,
				@Note = @Note output
		

		INSERT #PostData VALUES(@Stock)
		INSERT #PostData VALUES(@Note)

	 END


 END

 SELECT * FROM #PostData 

/*
exec spWebFSPGetTaskJobPostData
	@UserID = 199611,
	@TaskID = 1546


*/
GO


Grant EXEC on spWebFSPGetTaskJobPostData to eCAMS_Role
Go

Use WebCAMS
Go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebFSPGetTaskJobPostData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebFSPGetTaskJobPostData]
GO

Create Procedure dbo.spWebFSPGetTaskJobPostData 
	(
		@UserID int,
		@TaskID int
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 2:47p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebFSPGetTaskJobPostData.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebFSPGetTaskJobPostData @UserID = @UserID, 
					@TaskID = @TaskID

/*


spWebFSPGetTaskJobPostData 199512, 3001

*/
Go

Grant EXEC on spWebFSPGetTaskJobPostData to eCAMS_Role
Go
