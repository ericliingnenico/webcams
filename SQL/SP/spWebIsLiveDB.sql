use WebCAMS
go

if exists(select 1 from sysobjects where name = 'spWebIsLiveDB' and type = 'p')
	drop proc spWebIsLiveDB
go

create proc spWebIsLiveDB (
	@IsLiveDB bit OUTPUT)
as
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 18/02/09 2:12p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebIsLiveDB.sql $-->
--<!--$$NoKeywords: $-->
declare @ret int

 SET NOCOUNT ON
 IF EXISTS(SELECT 1 FROM tblControl WHERE Attribute = 'IsLiveDB' and AttrValue = 'YES')
	SELECT @IsLiveDB = 1
 ELSE
	SELECT @IsLiveDB = 0

 SELECT @ret = @@ERROR
 SELECT @ret    --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
 

/*
 declare @IsLiveDB bit
 EXEC dbo.spWebIsLiveDB 
	@IsLiveDB = @IsLiveDB OUTPUT
 select @IsLiveDB

*/
go

grant exec on spWebIsLiveDB to eCAMS_Role
go


