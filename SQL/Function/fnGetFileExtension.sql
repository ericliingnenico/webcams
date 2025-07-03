USE WebCAMS
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetFileExtension]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetFileExtension]
GO

create function dbo.fnGetFileExtension(@TheFile varchar(500))
Returns varchar(20) as
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/09/13 11:13 $-->
--<!--$$Logfile: /eCAMSSource/SQL/Function/fnGetFileExtension.sql $-->
--<!--$$NoKeywords: $-->
begin
--Purpose: return file extension of a download
 declare @FileExtension varchar(800)
 select @FileExtension = case when @TheFile like '%.%' then  reverse(left(reverse(@TheFile), charindex('.', reverse(@TheFile))  - 1))
								else '' end
 return (case when  @FileExtension like '%^%' then 'video'
				else @FileExtension	end)
end 

/*
select dbo.fnGetFileExtension('1234')
select dbo.fnGetFileExtension('1234.pdf')

*/
Go

Grant EXEC on fnGetFileExtension to eCAMS_Role
Go


