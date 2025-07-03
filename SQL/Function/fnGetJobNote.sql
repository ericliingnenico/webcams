USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetJobNote]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetJobNote]
GO

CREATE FUNCTION dbo.fnGetJobNote(
	@ClientID varchar(3),
	@Note varchar(max),
	@CloseDateTime datetime
) RETURNS varchar(max)
--'<!--$$Revision: 6 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 29/07/09 4:54p $-->
--'<!--$$Logfile: /SQL/Function/CAMS/fnGetJobNote.sql $-->
--'<!--$$NoKeywords: $-->
/*
 Purpose: Retrieve JobNote according to the setup in webCAMS.dbo.tblControl ("ViewAllJobNote", "CTX,HIC")
          If the clientID is not in tblControl, just show xml value of '<WebJobNote>'
		  check the ViewAllJobNote expiry date  in webCAMS.dbo.tblControl ("ViewAllJobNoteExpiryMonth.CTX", 6)
*/
AS
BEGIN
 Declare @ViewAllJobNote bit,
		@CRLF varchar(2),
		@ViewAllJobNoteExpiryMonth int,
		@ViewAllJobNoteExpiryDate datetime


 --init
 select @ViewAllJobNote = 0,
		@CRLF = CHAR(13) + CHAR(10)

 IF Exists(select 1 from webCAMS.dbo.tblControl with (nolock) where Attribute = 'ViewAllJobNote' AND AttrValue like '%' + @ClientID + '%')
	select @ViewAllJobNote = 1


 IF @ViewAllJobNote = 1
  BEGIN
	--check if there is expirymonth specified for this client
	 IF Exists(select 1 from webCAMS.dbo.tblControl with (nolock) where Attribute = 'ViewAllJobNoteExpiryMonth.' + @ClientID AND CAST(AttrValue as int)>0)
	  BEGIN
		select @ViewAllJobNoteExpiryMonth = CAST(AttrValue as int)
			from webCAMS.dbo.tblControl with (nolock) where Attribute = 'ViewAllJobNoteExpiryMonth.' + @ClientID

		--check if the closedatetime is alreay expired in terms of viewing full job notes
		IF @CloseDateTime < DateAdd(month, -@ViewAllJobNoteExpiryMonth, getdate())
			select @ViewAllJobNote = 0
	  END

  END

 RETURN CASE WHEN @ViewAllJobNote = 1 THEN Replace(dbo.fnFormatXMLConcisely(@Note),@CRLF+@CRLF, @CRLF) 
				ELSE dbo.fnGetXMLValue(@Note, 'WebJobNote')
			 END
END

/*
delete webCAMS.dbo.tblControl
 where Attribute = 'ViewAllJobNote'

 insert webCAMS.dbo.tblControl values('ViewAllJobNote', 'CTX')
 select dbo.fnGetJobNote ('NAB', 'dwed   21321453543<>#@$@# t')
 select dbo.fnGetJobNote ('HIC', 'dwed   21321453543<>#@$@# t')

*/

Go

