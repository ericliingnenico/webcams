

Use CAMS
Go

Alter Procedure dbo.spAutoEscalateFSPException 
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 24/10/06 3:20p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spAutoEscalateFSPException.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: This is an auto task procedure to escalate FSP exception jobs to PDA exception for EE operators to handle.
--Rules: if jobs stay at FSP Exception for more than 48 hours, escalate to PDA exception

DECLARE @STATUS_PDA_EXCEPTION tinyint,
	@STATUS_FSP_EXCEPTION tinyint



 SET NOCOUNT ON

 --init
 SELECT @STATUS_PDA_EXCEPTION = 6, --'PDA EXCEPTION',
	@STATUS_FSP_EXCEPTION = 7 --'FSP EXCEPTION'
	


 --cache FSP Exception jobs
 CREATE TABLE #myJobs (JobID bigint, ExceptionDate datetime)

 --get job IDs
 INSERT INTO #myJobs (JobID) 
 SELECT  JobID
   FROM IMS_Jobs
  WHERE StatusID = @STATUS_FSP_EXCEPTION

 INSERT INTO #myJobs (JobID)
 SELECT CallNumber
   FROM Calls 
  WHERE StatusID = @STATUS_FSP_EXCEPTION

 --get exception date
 UPDATE t
    SET t.ExceptionDate = p.UpdateDateTime
   FROM #myJobs t JOIN tblPDAException p on t.JobID = p.JobID


 --delete exception less than 48 hours
 DELETE #myJobs
  WHERE ExceptionDate > DateAdd(hh, -48, GetDate())


 
 --update ims jobs
 UPDATE j
    SET j.StatusID = @STATUS_PDA_EXCEPTION
   FROM IMS_Jobs j JOIN #myJobs t ON j.JobID = t.JobID
  WHERE j.StatusID = @STATUS_FSP_EXCEPTION

 UPDATE j
    SET j.StatusID = @STATUS_PDA_EXCEPTION
   FROM Calls j JOIN #myJobs t ON j.CallNumber = t.JobID
  WHERE j.StatusID = @STATUS_FSP_EXCEPTION


 

/*

 EXEC spAutoEscalateFSPException
*/
    
GO



