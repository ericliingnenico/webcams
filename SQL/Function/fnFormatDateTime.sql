USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnFormatDateTime]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fnFormatDateTime]
GO

create function dbo.fnFormatDateTime(@TheDate DateTime)
Returns varchar(20) as
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/04/03 10:14 $-->
--<!--$$Logfile: /eCAMSSource/SQL/Function/fnFormatDateTime.sql $-->
--<!--$$NoKeywords: $-->
begin
--Purpose: Format DateTime to AUS format dd/mm/yyyy HH:mm:ss
 RETURN convert(varchar, @TheDate, 103) + ' ' + convert(varchar, @TheDate, 108) 
end 

/*
select dbo.fnFormatDateTime(getdate())

*/


