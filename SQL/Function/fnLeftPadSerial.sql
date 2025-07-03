USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnLeftPadSerial]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fnLeftPadSerial]
GO

create function dbo.fnLeftPadSerial(@TheSerial varchar(32))
Returns varchar(32) as
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 23/05/03 14:08 $-->
--<!--$$Logfile: /eCAMSSource/SQL/Function/fnLeftPadSerial.sql $-->
--<!--$$NoKeywords: $-->
begin
--Purpose: Left pad serial
-- CAMS-559: Remove serial padding
 RETURN @TheSerial
end 

/*
select dbo.fnLeftPadSerial('1234')

*/


