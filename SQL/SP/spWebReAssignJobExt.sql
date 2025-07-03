
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebReAssignJobExt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebReAssignJobExt]
GO


Create Procedure dbo.spWebReAssignJobExt 
	(
		@UserID int,
		@JobIDList varchar(2000),
		@ReAssignTo int
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 21/07/05 5:25p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebReAssignJobExt.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Bulk re-assign jobs to FSP, @JobIDList is a list of JobIDs with comma delimited
 SET NOCOUNT ON

 DECLARE @i int,
	@j int,
	@JobID bigint,
	@ret int

 --trim the space
 SELECT @JobIDList = RTRIM(LTRIM(@JobIDList))

 --empty string
 IF RTRIM(@JobIDList) = ''
	GOTO Exit_Handle

 --append last comma if not exist
 IF RIGHT(@JobIDList, 1) <> ','
	SELECT @JobIDList = @JobIDList + ','

 --parse serial list into temp table
 SELECT @j = 0
 SELECT @i = CHARINDEX(',', @JobIDList, @j)
 WHILE (@i > 0)
  BEGIN
	SELECT @JobID = SUBSTRING(@JobIDList, @j, @i-@j)

	EXEC @ret = dbo.spWebReAssignJob 
			@UserID = @UserID,
			@JobID = @JobID,
			@ReAssignTo = @ReAssignTo

	SELECT @j = @i + 1
	SELECT @i = CHARINDEX(',', @JobIDList, @j)
  END


Exit_Handle:
 --return
  RETURN @@ERROR
GO

Grant EXEC on spWebReAssignJobExt to eCAMS_Role
Go

Use WebCAMS
Go
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebReAssignJobExt]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebReAssignJobExt]
GO


Create Procedure dbo.spWebReAssignJobExt 
	(
		@UserID int,
		@JobIDList varchar(2000),
		@ReAssignTo int
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebReAssignJobExt.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebReAssignJobExt @UserID = @UserID,
		@JobIDList = @JobIDList,
		@ReAssignTo = @ReAssignTo

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*

spWebReAssignJobExt @UserID = 199649,
		@JobIDList = '354539,346253',
		@ReAssignTo = 2582

*/
Go

Grant EXEC on spWebReAssignJobExt to eCAMS_Role
Go
