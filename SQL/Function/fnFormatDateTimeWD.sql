USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnFormatDateTimeWD]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fnFormatDateTimeWD]
GO

create function dbo.fnFormatDateTimeWD(@TheDate DateTime)
Returns varchar(40) as
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 23/05/03 14:08 $-->
--<!--$$Logfile: /eCAMSSource/SQL/Function/fnFormatDateTimeWD.sql $-->
--<!--$$NoKeywords: $-->
begin
--Purpose: Format DateTime to AUS format dd/mm/yyyy HH:mm:ss
 RETURN Left(datename(dw, @TheDate), 3) + ' ' +  convert(varchar, @TheDate, 103) + ' ' + convert(varchar, @TheDate, 108) 
end 

/*
select dbo.fnFormatDateTimeWD(getdate())

*/


