use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebIsTelstraFSP' and type = 'p')
	drop proc spWebIsTelstraFSP
go

create proc spWebIsTelstraFSP (
	@FSPID int,
	@IsTelstraFSP bit OUTPUT)
as
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 11/04/06 4:23p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebIsTelstraFSP.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 IF EXISTS(SELECT 1 FROM dbo.fnGetLocationChildrenExt(4100) WHERE Location = @FSPID)
	SELECT @IsTelstraFSP = 1
 ELSE
	SELECT @IsTelstraFSP = 0

 RETURN @@ERROR
 

/*
 declare @IsTelstraFSP bit
 EXEC dbo.spWebIsTelstraFSP 
	@FSPID = 1351, --3100,
	@IsTelstraFSP = @IsTelstraFSP OUTPUT
 select @IsTelstraFSP

*/
go

grant exec on spWebIsTelstraFSP to eCAMS_Role
go

use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebIsTelstraFSP' and type = 'p')
	drop proc spWebIsTelstraFSP
go

create proc spWebIsTelstraFSP (
	@FSPID int,
	@IsTelstraFSP bit OUTPUT)
as
declare @ret int

 SET NOCOUNT ON
 EXEC @ret = CAMS.dbo.spWebIsTelstraFSP
	@FSPID = @FSPID,
	@IsTelstraFSP = @IsTelstraFSP OUTPUT

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
go

grant exec on spWebIsTelstraFSP to eCAMS_Role
go

