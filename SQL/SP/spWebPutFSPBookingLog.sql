
Use CAMS
Go
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spWebPutFSPBookingLog]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spWebPutFSPBookingLog]
GO

Create Procedure dbo.spWebPutFSPBookingLog 
	(
		@FSPID int,
		@JobIDs varchar(4000),
		@BookInstaller int,
		@BookForDateTime datetime,
		@Notes varchar(4000)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/01/16 9:44 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPBookingLog.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: FSP escalate Job to EE operator via Web

DECLARE @ret int

 SET NOCOUNT ON
--log the booking
 insert tblFSPJobBookingLog(JobID,	
				BookInstaller,	
				BookForDateTime, 
				Notes,	
				LoggedDateTime,	
				LoggedBy)
  select f,
  		@BookInstaller,
		@BookForDateTime,
		@Notes,
		getdate(),
		@FSPID
   from dbo.fnConvertListToTable(@JobIDs)

  RETURN @ret
GO

Grant EXEC on spWebPutFSPBookingLog to eCAMS_Role
Go

