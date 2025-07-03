Use Master
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[upSendCDOsysMail]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[upSendCDOsysMail]
GO

CREATE PROCEDURE [dbo].[upSendCDOsysMail] 
   @From varchar(200) ,
   @To varchar(500) ,
   @Subject varchar(500)='',
   @Body varchar(7000) =''

--<!--$$Revision: 21 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 18/10/12 14:49 $-->
--<!--$$Logfile: /SQL/Master/upSendCDOsysMail.sql $-->
--<!--$$NoKeywords: $-->


/*********************************************************************

This stored procedure takes the above parameters and sends an e-mail. 
All of the mail configurations are hard-coded in the stored procedure. 
Comments are added to the stored procedure where necessary.
Reference to the CDOSYS objects are at the following MSDN Web site:
http://msdn.microsoft.com/library/default.asp?url=/library/en-us/cdosys/html/_cdosys_messaging.asp

***********************************************************************/ 
   AS
   Declare @iMsg int
   Declare @hr int
   Declare @source varchar(255)
   Declare @description varchar(500)
   Declare @output varchar(1000)
   Declare @SMTPSERVER varchar(50)

   SELECT @SMTPSERVER = '172.16.101.82'  --KCMEL-MX-05

--************* Create the CDO.Message Object ************************
   EXEC @hr = master.dbo.sp_OACreate 'CDO.Message', @iMsg OUT
   IF @hr <>0 
	GOTO Err_H

--***************Configuring the Message Object ******************
-- This is to configure a remote SMTP server.
-- http://msdn.microsoft.com/library/default.asp?url=/library/en-us/cdosys/html/_cdosys_schema_configuration_sendusing.asp
   EXEC @hr = master.dbo.sp_OASetProperty @iMsg, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusing").Value','2'
   IF @hr <>0 
	GOTO Err_H

-- This is to configure the Server Name or IP address. 
-- Replace MailServerName by the name or IP of your SMTP Server.
   EXEC @hr = master.dbo.sp_OASetProperty @iMsg, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserver").Value', @SMTPSERVER 
   IF @hr <>0 
	GOTO Err_H

-- Save the configurations to the message object.
   EXEC @hr = master.dbo.sp_OAMethod @iMsg, 'Configuration.Fields.Update', null
   IF @hr <>0 
	GOTO Err_H

-- Set the e-mail parameters.
   EXEC @hr = master.dbo.sp_OASetProperty @iMsg, 'To', @To
   IF @hr <>0 
	GOTO Err_H

   EXEC @hr = master.dbo.sp_OASetProperty @iMsg, 'From', @From
   IF @hr <>0 
	GOTO Err_H

   EXEC @hr = master.dbo.sp_OASetProperty @iMsg, 'Subject', @Subject
   IF @hr <>0 
	GOTO Err_H

-- If you are using HTML e-mail, use 'HTMLBody' instead of 'TextBody'.
   EXEC @hr = master.dbo.sp_OASetProperty @iMsg, 'TextBody', @Body
   IF @hr <>0 
	GOTO Err_H

   EXEC @hr = master.dbo.sp_OAMethod @iMsg, 'Send', NULL
   IF @hr <>0 
	GOTO Err_H

-- Error handling.
Err_H:
   IF @hr <>0 
     BEGIN
       EXEC @hr = master.dbo.sp_OAGetErrorInfo NULL, @source OUT, @description OUT
       IF @hr = 0
         BEGIN
           SELECT @output = 'upSendCDOsysMail-Source: ' + @source
           SELECT @output = '  Description: ' + @description
	   --log the error
           INSERT tblCDOError(ErrorMsg) Values(@output)
         END
       ELSE
         BEGIN
	   --log the error
           INSERT tblCDOError(ErrorMsg) Values('upSendCDOsysMail-master.dbo.sp_OAGetErrorInfo failed.')
           RETURN
         END
     END

-- Do some error handling after each step if you need to.
-- Clean up the objects created.
   EXEC @hr = master.dbo.sp_OADestroy @iMsg

/*
[dbo].[upSendCDOsysMail] 
   @From varchar(200) ,
   @To varchar(500) ,
   @Subject varchar(500)='',
   @Body varchar(7000) =''

   exec upSendCDOsysMail 
	@From = 'boli@today.com.au', 
	@To = 'bli@eftpos.com.au', 
	@Subject = 'SQL Test of CDOSYS', 
	@Body = 'This is a Test Message'
*/
go 


Grant EXEC on upSendCDOsysMail to public
go

