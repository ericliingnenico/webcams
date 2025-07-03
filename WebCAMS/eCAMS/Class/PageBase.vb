#Region "vss"
'<!--$$Revision: 15 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 5/08/16 16:49 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/PageBase.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Option Explicit On 

Imports System
Imports System.Web
Imports System.Web.UI
Imports System.ComponentModel
Imports System.Data
Imports System.Net
Imports System.IO
Imports System.Drawing
Imports Microsoft.VisualBasic
Imports System.Web.UI.WebControls
Imports OfficeOpenXml

Namespace eCAMS

''++++++++++++++++++++++++++++++
'' Page base class: 
''  Initiate datalayer
''++++++++++++++++++++++++++++++
Public Class PageBase
    Inherits System.Web.UI.Page
    Public m_DataLayer As DataLayer
    Protected RestrictModuleName As String
    Protected m_renderingStyle As RenderingStyleType

    '
    ' Exception Logging constant
    '
    Private Const UNHANDLED_EXCEPTION As String = "Unhandled Exception:"
    '
    ' Session Key Constants
    '
    'Private Const KEY_CACHECUSTOMER As String = "Cache:Customer:"

    ' 
    ' SSL
    '
    Private Shared pageSecureUrlBase As String
    Private Shared pageUrlBase As String
    Private Shared urlSuffix As String



    ''ViewState Persist
    Private Const viewStateHiddenFieldName As String = "__ViewStateGuid"
    Private Const viewStateFileExtension As String = ".vs.resource"
        Private Const viewStateFileRelativePath As String = "~/PersistedViewState/"

        Protected Const TooManyPasscodeReties = "Too many passcode retries! Please logoff and try again or contact Ingenico."

        '' 
        ''contructs
        ''
        Protected Enum RenderingStyleType
            DeskTop = 1
            PDA = 2
        End Enum

        Protected Enum RenderingControlType
            Label = 0
            Radio = 1
            Text = 2
            Combo = 3
        End Enum


    '----------------------------------------------------------------
    ' Sub New:
    '   Constructor. Initialize private members.
    '----------------------------------------------------------------
    Public Sub New()
        MyBase.New()

        Try
            m_DataLayer = New DataLayer

            urlSuffix = Context.Request.Url.Host & Context.Request.ApplicationPath
            pageUrlBase = "http://" & urlSuffix
            pageSecureUrlBase = "https://" & urlSuffix

            ''JaveScript Link
            If (Not MyBase.Page.ClientScript.IsClientScriptBlockRegistered("incTool.js")) Then
                MyBase.Page.ClientScript.RegisterClientScriptBlock(Me.GetType, "incTool.js", "<SCRIPT LANGUAGE=""javascript"" SRC=""../Scripts/incTool.js"" TYPE='text/javascript'></SCRIPT>")
            End If
                'If (Not MyBase.Page.ClientScript.IsClientScriptBlockRegistered("wysiwyg.js")) Then
                '    MyBase.Page.ClientScript.RegisterClientScriptBlock(Me.GetType, "wysiwyg.js", "<SCRIPT LANGUAGE=""javascript"" SRC=""../member/scripts/wysiwyg.js"" TYPE='text/javascript'></SCRIPT>")
                'End If
                'If (Not MyBase.Page.ClientScript.IsClientScriptBlockRegistered("wysiwyg-settings.js")) Then
                '    MyBase.Page.ClientScript.RegisterClientScriptBlock(Me.GetType, "wysiwyg-settings.js", "<SCRIPT LANGUAGE=""javascript"" SRC=""../member/scripts/wysiwyg-settings.js"" TYPE='text/javascript'></SCRIPT>")
                'End If

            'If (Not MyBase.Page.ClientScript.IsClientScriptBlockRegistered("ckeditor.js")) Then
            '    MyBase.Page.ClientScript.RegisterClientScriptBlock(Me.GetType, "ckeditor.js", "<SCRIPT LANGUAGE=""javascript"" SRC=""../ckeditor/ckeditor.js"" TYPE='text/javascript'></SCRIPT>")
            'End If
            If (Not MyBase.Page.ClientScript.IsClientScriptBlockRegistered("jsMap.js")) Then
                MyBase.Page.ClientScript.RegisterClientScriptBlock(Me.GetType, "jsMap.js", "<SCRIPT LANGUAGE='javascript' SRC='../Scripts/jsMap.js' TYPE='text/javascript'></SCRIPT>")
            End If

            ''set Page rendering style
            Call SetRenderingStyle()
        Catch
            ' For design time
        End Try
    End Sub

    '----------------------------------------------------------------
    ' Property SecureUrlBase:
    '   Retrieves the Prefix for URLs in the Secure directory.
    '----------------------------------------------------------------
    Public Shared ReadOnly Property SecureUrlBase() As String
        Get
            SecureUrlBase = pageSecureUrlBase
        End Get
    End Property

    '----------------------------------------------------------------
    ' Property UrlBase:
    '   Retrieves the Prefix for URLs.
    '----------------------------------------------------------------
    Public Shared ReadOnly Property UrlBase() As String
        Get
            UrlBase = pageUrlBase
        End Get
    End Property

    '----------------------------------------------------------------
    ' FillCboArray:
    '   Fill a combox with elements in an array
    '----------------------------------------------------------------
    Public Shared Sub FillCboWithArray(ByRef pCbo As DropDownList, ByVal pArray As Array)
        Dim oItem As Object
        Call pCbo.Items.Clear()
        For Each oItem In pArray
            pCbo.Items.Add(oItem.ToString())
        Next
        oItem = Nothing
    End Sub

    '----------------------------------------------------------------
    ' ScrollToCboText:
    '   Scroll a combox to an item with text macthed pData
    '----------------------------------------------------------------
    Public Shared Sub ScrollToCboText(ByRef pCbo As DropDownList, ByVal pData As String)

        Dim I As Integer
        Dim bFound As Boolean
        bFound = False
        For I = 0 To pCbo.Items.Count - 1
            If pCbo.Items(I).Text.ToUpper = pData.ToUpper Then
                pCbo.SelectedIndex = I
                bFound = True
                Exit For
            End If
        Next I
        If Not bFound Then
            pCbo.SelectedIndex = -1
        End If
    End Sub
    '----------------------------------------------------------------
    ' ScrollToCboValue:
    '   Scroll a combox to an item with value macthed pData
    '----------------------------------------------------------------
    Public Shared Sub ScrollToCboValue(ByRef pCbo As DropDownList, ByVal pData As String)

        Dim I As Integer
        Dim bFound As Boolean
        bFound = False
        For I = 0 To pCbo.Items.Count - 1
            If pCbo.Items(I).Value.ToString = pData Then
                pCbo.SelectedIndex = I
                bFound = True
                Exit For
            End If
        Next I
        If Not bFound Then
            pCbo.SelectedIndex = -1
        End If
    End Sub
    '----------------------------------------------------------------
    ' SelectRadioButtonListValue:
    '   Select a radio button list with value macthed pData
    '----------------------------------------------------------------
    Public Shared Sub SelectRadioButtonListValue(ByRef pRadioButtonList As RadioButtonList, ByVal pData As String)

        Dim I As Integer
        Dim bFound As Boolean
        bFound = False
        For I = 0 To pRadioButtonList.Items.Count - 1
            If pRadioButtonList.Items(I).Value.ToString = pData Then
                pRadioButtonList.SelectedIndex = I
                bFound = True
                Exit For
            End If
        Next I
        If Not bFound Then
            pRadioButtonList.SelectedIndex = -1
        End If
    End Sub


    '----------------------------------------------------------------
    ' RefreshPage:
    '   Set timer on page to refesh at the specified second
    '----------------------------------------------------------------
    Public Shared Sub RefreshPage(ByVal pPage As System.Web.UI.Page, ByVal pSecond As Int32)
        '<script language=javascript>
        '	<!-- 
        '	var timer = setTimeout('ReloadMe()',300000); //5 minutes
        '	function ReloadMe() {
        '		window.location.reload();  //reload will cause IE prompt a message box if the page has submited before, so use location.href to avoid this problem
        '       window.location.href="pagetogo.aspx";
        '	}
        '	//-->
        '</script>

        Dim strOut As New System.Text.StringBuilder

        ''<=0, no java script generated
        If pSecond <= 0 Then
            Return
        End If

        If pPage Is Nothing Then
            Throw New ArgumentException("A Page must be passed in before you can use RefreshPage.")
        End If
        If pPage.Request.Browser.EcmaScriptVersion.Major >= 1 Then
            ''Create JavaScript for output
            strOut.Append(vbCrLf)
            strOut.Append("<SCRIPT LANGUAGE='JavaScript'>")
            strOut.Append(vbCrLf)
            strOut.Append("<!--")
            strOut.Append(vbCrLf)

            ''var timer = setTimeout('ReloadMe()',300000); //5 minutes
            ''build up mi-second with second passed in
            strOut.Append("var timer = setTimeout('ReloadMe()',")
            strOut.Append(Convert.ToString(pSecond * 1000))  ''convert to million second
            strOut.Append(");")
            strOut.Append(vbCrLf)
            strOut.Append("function ReloadMe() {")
            strOut.Append(vbCrLf)
            ''strOut.Append("	window.location.reload();")
            strOut.Append("	window.location.href='")
            strOut.Append(pPage.Request.Url.AbsoluteUri)
            strOut.Append("';")
            strOut.Append(vbCrLf)
            strOut.Append("}")
            strOut.Append(vbCrLf)
            strOut.Append("// -->")
            strOut.Append(vbCrLf)
            strOut.Append("</SCRIPT>")
            strOut.Append(vbCrLf)
            ''Register Client Script
            pPage.ClientScript.RegisterClientScriptBlock(pPage.GetType, "RefreshPage", strOut.ToString())

        End If


    End Sub
    ''.Net 2.0 provide new Page.SetFocus method
    ''But it will activeate the current page as active window and can not be used in FSPStockReturned page which needs popup message and keeps message window as active
    ''
    '----------------------------------------------------------------
    ' SetFocusExt:
    '   Set intial focus to specific control
    '----------------------------------------------------------------
    Public Shared Sub SetFocusExt(ByVal pControl As Control)
        Dim strOut As New System.Text.StringBuilder

        If pControl.Page Is Nothing Then
            Throw New ArgumentException("The Control must be added to a Page before you can set the IntialFocus to it.")
        End If
        If pControl.Page.Request.Browser.EcmaScriptVersion.Major >= 1 Then
            ''Create JavaScript for output
            strOut.Append(vbCrLf)
            strOut.Append("<SCRIPT LANGUAGE='JavaScript'>")
            strOut.Append(vbCrLf)
            strOut.Append("<!--")
            strOut.Append(vbCrLf)
            strOut.Append("   document.")
            ''find the form
            Dim p As Control = pControl.Parent
            While Not (TypeOf (p) Is System.Web.UI.HtmlControls.HtmlForm)
                p = p.Parent
            End While
            strOut.Append(p.ClientID)
            strOut.Append("['")
            strOut.Append(pControl.ClientID)
            strOut.Append("'].focus();")
            strOut.Append(vbCrLf)
            strOut.Append("// -->")
            strOut.Append(vbCrLf)
            strOut.Append("</SCRIPT>")
            strOut.Append(vbCrLf)
            ''Register Client Script
            pControl.Page.ClientScript.RegisterStartupScript(pControl.GetType, "InitialFocus", strOut.ToString())

        End If
    End Sub

    '----------------------------------------------------------------
    ' TieButton:
    '   This ties a textbox to a button. When ENTER key pressed in textbox, 
    '   the tied button will be clicked. 
    '----------------------------------------------------------------

    Public Shared Sub TieButton(ByVal TextBoxToTie As Control, ByVal ButtonToTie As Control)
        ''client-side java script: click event of the button if the enter key is pressed.
        Dim jsString As String = "if ((event.which && event.which == 13) || (event.keyCode && event.keyCode == 13)) {document.getElementById('" + ButtonToTie.ClientID + "').click();return false;} else return true; "

        If TypeOf (TextBoxToTie) Is System.Web.UI.HtmlControls.HtmlControl Then
            CType(TextBoxToTie, System.Web.UI.HtmlControls.HtmlControl).Attributes.Add("onkeydown", jsString)
        ElseIf TypeOf (TextBoxToTie) Is System.Web.UI.WebControls.WebControl Then
            CType(TextBoxToTie, System.Web.UI.WebControls.WebControl).Attributes.Add("onkeydown", jsString)
        Else
            Throw New ArgumentException("Control TextBoxToTie should be derived from either System.Web.UI.HtmlControls.HtmlControl or System.Web.UI.WebControls.WebControl", "TextBoxToTie")
        End If
    End Sub
    Public Shared Sub ModifyEnterKeyPressAsTab(ByVal pTextBox As Control, ByVal pNextFocusControl As Control)
        ''client-side java script: click event of the button if the enter key is pressed.
        'Dim jsString As String = "if ((event.which && event.which == 13) || (event.keyCode && event.keyCode == 13)) { alert(event.keyCode) ; event.keyCode = 9; alert(event.keyCode) ;return false;}"
        ''** Safari browser doesn't allow the keyCode be modified, in the above java script, keyCode still display as 13
        ''** to walk around, set the focus to pNextFocusControl
        Dim jsString As String = "if ((event.which && event.which == 13) || (event.keyCode && event.keyCode == 13)) {document.getElementById('" + pNextFocusControl.ClientID + "').focus();return false;} else return true; "

        If TypeOf (pTextBox) Is System.Web.UI.HtmlControls.HtmlControl Then
            CType(pTextBox, System.Web.UI.HtmlControls.HtmlControl).Attributes.Add("onkeydown", jsString)
        ElseIf TypeOf (pTextBox) Is System.Web.UI.WebControls.WebControl Then
            CType(pTextBox, System.Web.UI.WebControls.WebControl).Attributes.Add("onkeydown", jsString)
        Else
            Throw New ArgumentException("Control TextBoxToTie should be derived from either System.Web.UI.HtmlControls.HtmlControl or System.Web.UI.WebControls.WebControl", "TextBoxToTie")
        End If
    End Sub

    '----------------------------------------------------------------
    ' PostData:
    '   Post data to other web site
    '----------------------------------------------------------------
    Public Shared Sub PostData(ByVal urlData As String)

        Dim myReq As HttpWebRequest = CType(WebRequest.Create(urlData), HttpWebRequest)

        ''no proxy server should use
        myReq.Proxy = GlobalProxySelection.GetEmptyWebProxy()

        myReq.GetResponse()

    End Sub
    '----------------------------------------------------------------
        ' ExportToExcelOld:
    '   Export data table to MS EXCEL file
    '----------------------------------------------------------------
        Public Sub ExportToExcelOld(ByVal filename As String, ByVal summary As String, ByVal datatable As DataTable)
            Dim lineText As String


            ''set the http meta tag
            'ContentType specifies the MIME type of this header.
            Response.ContentType = "text/plain"
            'The AddHeader method adds an HTML header with a specified value. 
            'Content-disposition forces the browser to download.
            Response.AddHeader("content-disposition", "attachment; filename=""" & filename & """")

            ''write summary if any
            If summary <> String.Empty Then
                Response.Write(summary & Environment.NewLine)
            End If


            ''write excel column header
            Dim col As DataColumn
            lineText = ""
            For Each col In datatable.Columns
                lineText = lineText & col.ColumnName & Chr(9)
            Next

            Response.Write(lineText & Environment.NewLine)

            ''write excel body
            Dim dr As DataRow
            For Each dr In datatable.Rows
                lineText = ""
                For Each col In datatable.Columns
                    lineText = lineText & Convert.ToString(dr(col.ColumnName)) & Chr(9)
                Next
                Response.Write(lineText & Environment.NewLine)

            Next

            Response.End()


        End Sub
        ' ExportToExcel:
        '   Export data table to MS EXCEL file
        '----------------------------------------------------------------
        Public Sub ExportToExcel(ByVal filename As String, ByVal summary As String, ByVal datatable As DataTable)
            Using pck As New ExcelPackage()
                'Create the worksheet
                Dim ws As ExcelWorksheet = pck.Workbook.Worksheets.Add("Sheet1")

                'Load the datatable into the sheet, starting from cell A1. Print the column names on row 1
                ws.Cells("A1").LoadFromDataTable(datatable, True)

                Dim configurationAppSettings As AppSettingsReader = New AppSettingsReader
                Dim dateFormat As String = configurationAppSettings.GetValue("ExcelExport.DateFormat", GetType(String)).ToString()
                Dim colNumber As Int32 = 1

                For Each col As DataColumn In datatable.Columns
                    If Type.GetTypeCode(col.DataType) = TypeCode.DateTime Then
                        ws.Column(colNumber).Style.Numberformat.Format = dateFormat
                    End If

                    colNumber = colNumber + 1
                Next

                Using memoryStream = New MemoryStream()
                    Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                    Response.AddHeader("content-disposition", "attachment;  filename=" & filename)
                    pck.SaveAs(memoryStream)
                    memoryStream.WriteTo(Response.OutputStream)
                    Response.Flush()
                    Response.End()
                End Using

                ''Format the header for column 1-3
                'Using rng As ExcelRange = ws.Cells("A1:C1")
                '    rng.Style.Font.Bold = True
                '    rng.Style.Fill.PatternType = ExcelFillStyle.Solid
                '    'Set Pattern for the background to Solid
                '    rng.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(79, 129, 189))
                '    'Set color to dark blue
                '    rng.Style.Font.Color.SetColor(Color.White)
                'End Using

                ''Example how to Format Column 1 as numeric 
                'Using col As ExcelRange = ws.Cells(2, 1, 2 + tbl.Rows.Count, 1)
                '    col.Style.Numberformat.Format = "#,##0.00"
                '    col.Style.HorizontalAlignment = ExcelHorizontalAlignment.Right
                'End Using

                ''Write it back to the client
                'Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                'Response.AddHeader("content-disposition", "attachment;  filename=ExcelDemo.xlsx")
                'Response.BinaryWrite(pck.GetAsByteArray())
            End Using


        End Sub
    '----------------------------------------------------------------
    ' DisplayMessageBox:
    '   Display MessageBox on this Page
    '----------------------------------------------------------------
    Protected Sub DisplayMessageBox(ByVal pPage As Page)

        Dim strOut As New System.Text.StringBuilder

        If pPage Is Nothing Then
            Throw New ArgumentException("The Page must be passed in before you can display MessageBox.")
        End If

        If pPage.Request.Browser.EcmaScriptVersion.Major >= 1 Then
            ''Create JavaScript for output
            strOut.Append(vbCrLf)
            strOut.Append("<SCRIPT LANGUAGE='JavaScript'>")
            strOut.Append(vbCrLf)
            strOut.Append("<!--")
            strOut.Append(vbCrLf)
            Select Case m_renderingStyle
                    Case RenderingStyleType.PDA
                        strOut.Append("   alert(stripHTMLTag('" + m_DataLayer.PopupMessage + "'));")
                    Case Else
                        strOut.Append("   popupwindow('../Member/PopupMsgBox.aspx');")
            End Select

            strOut.Append(vbCrLf)
            strOut.Append("// -->")
            strOut.Append(vbCrLf)
            strOut.Append("</SCRIPT>")
            strOut.Append(vbCrLf)
            ''Register Client Script
            pPage.ClientScript.RegisterStartupScript(pPage.GetType, "jvDisplayMessageBox", strOut.ToString())
        End If

    End Sub
    '----------------------------------------------------------------
    ' DisplayMessageBox:
    '   Display MessageBox on this Page
    '----------------------------------------------------------------
    Public Shared Sub PopupPage(ByVal pPage As Page, ByVal pURL As String)
        Dim strOut As New System.Text.StringBuilder

        If pPage Is Nothing Then
            Throw New ArgumentException("The Page must be passed in before you can display PopupPage.")
        End If

        If pPage.Request.Browser.EcmaScriptVersion.Major >= 1 Then
            ''Create JavaScript for output
            strOut.Append(vbCrLf)
            strOut.Append("<SCRIPT LANGUAGE='JavaScript'>")
            strOut.Append(vbCrLf)
            strOut.Append("<!--")
            strOut.Append(vbCrLf)
            strOut.Append("   popupwindow('" & pURL & "');")
            strOut.Append(vbCrLf)
            strOut.Append("// -->")
            strOut.Append(vbCrLf)
            strOut.Append("</SCRIPT>")
            strOut.Append(vbCrLf)
            ''Register Client Script
            pPage.ClientScript.RegisterStartupScript(pPage.GetType, "jvPopupPage", strOut.ToString())
        End If
    End Sub

    '----------------------------------------------------------------
    ' Sub Page_Error:
    '   Handles errors that may be encountered when displaying this 
    '     page.
    '----------------------------------------------------------------
    Protected Overrides Sub OnError(ByVal e As EventArgs)
        '        ApplicationLog.WriteError(ApplicationLog.FormatException(Server.GetLastError(), UNHANDLED_EXCEPTION))
        MyBase.OnError(e)
    End Sub


    Protected Overridable Sub GetContext()

    End Sub
    Protected Overridable Sub Process()

    End Sub
    Protected Overridable Sub AddClientScript()

    End Sub
    Protected Overridable Sub SetRenderingStyle()
        ''set default rendering to DeskTop
        m_renderingStyle = RenderingStyleType.DeskTop
    End Sub

    Protected Overridable Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
        AddClientScript()

        ''Skin related, KYC skin is used, commented out in case for future branding
        ' ''if session timeout, we need to get myMasterPage from hiddenField on MasterPage and recache into session
        'If m_DataLayer.MyMasterPage Is Nothing Then
        '    ''session timeout can reach here
        '    If m_DataLayer.GetSessionLog(Session.SessionID) = DataLayerResult.Success AndAlso Not m_DataLayer.dsTemp Is Nothing Then
        '        If m_DataLayer.dsTemp.Tables(0).Rows.Count > 0 Then
        '            m_DataLayer.MyMasterPage = Convert.ToString(m_DataLayer.dsTemp.Tables(0).Rows(0)("Skin"))
        '        End If
        '    End If
        'End If
    End Sub

    Protected Overrides Sub SavePageStateToPersistenceMedium(ByVal viewState As Object)
        If System.Configuration.ConfigurationManager.AppSettings("ServerSideViewState").ToUpper = "TRUE" Then
            Dim los As New LosFormatter
            Dim writer As StreamWriter
            Dim vsFileName As String
            Dim viewStateGUID As Guid = Guid.NewGuid()
            vsFileName = Server.MapPath(viewStateFileRelativePath + viewStateGUID.ToString + viewStateFileExtension)

            ''open the file
            writer = File.CreateText(vsFileName)

            ''serialise the viewstate to the file
            los.Serialize(writer, viewState)

            ''close the writer
            writer.Close()

            ''render hidden field
            ''---11/02/2008 Bo----
            ''Since we use Ajax to render partial page, we need to register the hidden fields via
            ''ScriptManager which has been added to all the master pages...
            ''If we use ClientScript to register the hidden fields and use Ajax updatepanel
            ''the partial postback won't work properly (such as, dropdownlist won't postback the default selection)
            ''---11/02/2008 Bo----
                ScriptManager.RegisterHiddenField(Page, viewStateHiddenFieldName, viewStateGUID.ToString)
            ''Page.ClientScript.RegisterHiddenField(viewStateHiddenFieldName, viewStateGUID.ToString)
        Else
            MyBase.SavePageStateToPersistenceMedium(viewState)
        End If
    End Sub

    Protected Overrides Function LoadPageStateFromPersistenceMedium() As Object
        If System.Configuration.ConfigurationManager.AppSettings("ServerSideViewState").ToUpper = "TRUE" Then
            Dim vsFileName As String
            vsFileName = Server.MapPath(viewStateFileRelativePath + Request.Item(viewStateHiddenFieldName) + viewStateFileExtension)
            If Not File.Exists(vsFileName) Then
                Throw New Exception("view state file " + Request.Item(viewStateHiddenFieldName) + " does't exist.")
                Return Nothing
            End If

            Dim los As New LosFormatter
            Dim reader As StreamReader
            Dim viewStateData As String
            ''read persisted viewstate data
            reader = File.OpenText(vsFileName)
            viewStateData = reader.ReadToEnd
            reader.Close()
            ''''***Do not delete the cached file, 
            ''''***if do so, user click back button on browser and page would still use old client cookie to retrieve server persisted data file.
            ''''***and causes an error
            ''decode view state
            Return los.Deserialize(viewStateData)
        Else
            Return MyBase.LoadPageStateFromPersistenceMedium
        End If

    End Function
    Protected Function FindChildControl(ByVal objSearchControl As System.Web.UI.Control, ByVal strControlID As String) As System.Web.UI.Control
        ''FindControl : The FindControl method searches only the page's immediate, or top-level, container; it does not recursively search for controls in naming containers contained on the page.
        ''This function will recursively find the control

        Dim objChildControl As System.Web.UI.Control
        Dim objControl As System.Web.UI.Control

        If objSearchControl.ID = strControlID Then
            Return objSearchControl
        End If

        If objSearchControl.Controls.Count = 0 Then
            Return Nothing
        End If

        For Each objChildControl In objSearchControl.Controls
            objControl = FindChildControl(objChildControl, strControlID)
            If Not IsNothing(objControl) Then
                Return objControl
            End If
        Next

        Return Nothing
    End Function
    ''BL 29/09/2011
    ''retired replace by input:focus{background:lightyellow;} textarea:focus{background:lightyellow;}
    'Protected Sub SetInputControlClassName(ByVal ctl As WebControl, ByVal className As String, ByVal focusClassName As String)
    '    ''Append css class defined in css stylesheet to a control
    '    Dim jsOnFocus As String = String.Format("this.className = '{0}';", focusClassName)
    '    Dim jsOnBlur As String = String.Format("this.className = '{0}';", className)
    '    ''amended on 23/01/2008: to append java scriptcode to existing events instead of overwrtitting
    '    ctl.Attributes.Add("onfocus", ctl.Attributes.Item("onfocus") & jsOnFocus)
    '    ctl.Attributes.Add("onblur", ctl.Attributes.Item("onblur") & jsOnBlur)
    'End Sub

    'Protected Sub SetAllInputControlsClassName(ByVal parent As Control, ByVal className As String, ByVal focusClassName As String)
    '    ''Append css class defined in css stylesheet to all control in a parent, it is recrusive function
    '    For Each ctl As Control In parent.Controls
    '      If TypeOf ctl Is TextBox Then
    '        ''OrElse TypeOf ctl Is ListBox OrElse TypeOf ctl Is DropDownList Then
    '         SetInputControlClassName(DirectCast(ctl, WebControl), className, focusClassName)
    '      Else
    '         SetAllInputControlsClassName(ctl, className, focusClassName)
    '      End If
    '    Next
    'End Sub

    Protected Overridable Sub LoginBroker()

        If Request.UserAgent.Contains("iPhone")
            Response.Redirect("../Member/mpLogin.aspx")
        End If
        If Request.UserAgent.Contains("Android")
            Response.Redirect("../Member/mpLogin.aspx")
        End If
        If Request.UserAgent.Contains("Blackberry")
            Response.Redirect("../Member/mpLogin.aspx")
        End If
            'If Request.Browser.IsMobileDevice then
            '        Response.Redirect("../Member/mpLogin.aspx")
            'End If
        'If ("123" & Request.Browser.Type.ToUpper()).IndexOf("MOBILE") > 0 Then
        '    ''it is mobile explorer
        '    Response.Redirect("/mCAMS/Login.aspx")
        'End If

        If (123 & Request.Browser.Platform.ToUpper()).IndexOf("WINCE") > 0 Then
            ''it is from pocket PC
            Response.Redirect("../Member/pLogin.aspx")
        End If

    End Sub

        Private Function Authenticate(ByVal user As String, ByVal pass As String, ByVal pIsFSPOnly As Boolean, ByVal pLogTypeID As Int16, ByRef pLabelErrMsg As Label) As Boolean
            Dim authenticated As Boolean = False

            Try
                Dim dlResult As DataLayerResult = m_DataLayer.Login(user, pass, pLogTypeID)

                If dlResult = DataLayerResult.Success Then
                    If pIsFSPOnly AndAlso m_DataLayer.CurrentUserInformation.IsLoginAsClient Then
                        pLabelErrMsg.Text = "An error has occurred(Your login must be a FSP login). Please contact Ingenico."
                        authenticated = False
                    Else
                        authenticated = True
                    End If
                Else
                    authenticated = False
                    '--Call m_DataLayer.ClearLoginSession()
                    pLabelErrMsg.Text = GetDataLayerErrorMessage(dlResult)
                End If
            Catch exc As Exception
                Call m_DataLayer.HandleException(exc)
            Finally

            End Try
            Return authenticated
        End Function

        Private Function GetDataLayerErrorMessage(ByVal dlResult As DataLayerResult, Optional ByVal contextString As String = "username or password") As String
            '--Call m_DataLayer.ClearLoginSession()
            If dlResult = DataLayerResult.ServiceFailure Then
                Return "An error has occurred. Please contact Ingenico."
            ElseIf dlResult = DataLayerResult.ConnectionFailure Then
                Return "The remote server is unreachable. Please check your connection and try again."
            ElseIf dlResult = DataLayerResult.AuthenticationFailure Then
                Return "The " & contextString & " is incorrect. Please re-type your information."
            Else
                Return "An unknown error has occurred. Please contact Ingenico."
            End If
        End Function


        Protected Overridable Sub Login(ByVal pUser As String, ByVal pPassword As String, ByVal pRememberMe As Boolean, ByVal pSkin As String, ByVal pLogTypeID As Int16, ByVal pMainPage As String, ByVal pIsFSPOnly As Boolean, ByRef pLabelErrMsg As Label)
            If (Authenticate(pUser, pPassword, pIsFSPOnly, pLogTypeID, pLabelErrMsg)) = True Then
                Dim strActionData As String

                Dim rediretPage As String = pMainPage
                ''Skin related, KYC skin is used, commented out in case for future branding            
                ' ''Persist Master page skin into DB and can be used when session time out
                'If pSkin <> "" then
                '    strActionData = "<Skin>" & pSkin & "</Skin><IP>" & HttpContext.Current.Request.UserHostAddress() & "</IP><UserID>" & m_DataLayer.CurrentUserInformation.UserID.ToString & "</UserID>"
                '    Call m_DataLayer.PutSessionLog(Session.SessionID, strActionData)

                'End If

                Try

                    If m_DataLayer.CheckIfCurrentUserIsConfiguredForMFA(m_DataLayer.CurrentUserInformation.UserID) Then
                        Dim returnOTPErrorMessage As String = Nothing
                        Dim bCreateAndEmailOTP As Boolean = CreateAndEmailUsertOTP(returnOTPErrorMessage)
                        pLabelErrMsg.Text = returnOTPErrorMessage

                        If (bCreateAndEmailOTP) Then
                            'Redirect to OTPLogin page for MFA (e.g:CBA)
                            rediretPage = "../member/LoginOTP.aspx"
                            UpdateLoginDetailsInCookie(pRememberMe, pUser, pPassword)
                            Server.Transfer(rediretPage)
                        Else
                            Return
                        End If

                    ElseIf (m_DataLayer.CurrentUserMFAFeatureParam.FeatureName = "" AndAlso
                        m_DataLayer.CurrentUserMFAFeatureParam.UserID = m_DataLayer.CurrentUserInformation.UserID) Then

                        'No need to redirect to page- normal path without MFA
                        ''if remember me is checked, store the encrypted login details in cookie
                        UpdateLoginDetailsInCookie(pRememberMe, pUser, pPassword)
                    End If

                Catch exc As Exception
                    Call m_DataLayer.HandleException(exc)
                Finally

                End Try

                ''Transfer to member page
                Call Response.Redirect(rediretPage)
            Else
                ''Login Error, go to login page
                pLabelErrMsg.Visible = True
            End If

        End Sub

        Private Sub UpdateLoginDetailsInCookie(ByVal pRememberMe As Boolean, ByVal pUser As String, ByVal pPassword As String)
            ''if remember me is checked, store the encrypted login details in cookie
            Dim cookie As New HttpCookie("pcams.dl1")  ''pcams.login
            If pRememberMe Then
                Dim myEncrypt As New Encryption64()
                cookie.Values.Add("p1", myEncrypt.Encrypt(pUser, m_DataLayer.Encrypt_Key_Used))  ''p1: user name
                cookie.Values.Add("p2", myEncrypt.Encrypt(pPassword, m_DataLayer.Encrypt_Key_Used))  ''p2: password
                cookie.Expires = DateTime.Now.AddDays(30)
                HttpContext.Current.Response.Cookies.Add(cookie)
            Else
                cookie.Expires = DateTime.Now.AddDays(-1) ' Set the expiration date to the past
                HttpContext.Current.Response.Cookies.Add(cookie)
            End If
        End Sub



        Private Function VerifyOTP(ByVal passcode As String, ByVal pIsFSPOnly As Boolean, ByVal pLogTypeID As Int16, ByRef pErrorMessage As String) As Boolean
            Dim passcodeVerified As Boolean = False

            Try

                Dim passcodeByte As Byte() = clsTool.EncryptPWD(passcode)

                If m_DataLayer.CurrentUserOTPMaxRetryCounter < m_DataLayer.CurrentUserMFAFeatureParam.OTPMaxNoRetries Then

                    Dim dlResult As DataLayerResult = m_DataLayer.GetValidateUserOTP(passcodeByte, pLogTypeID)

                    m_DataLayer.CurrentUserOTPMaxRetryCounter = m_DataLayer.CurrentUserOTPMaxRetryCounter + 1

                    If dlResult = DataLayerResult.Success Then
                        If pIsFSPOnly AndAlso m_DataLayer.CurrentUserInformation.IsLoginAsClient Then
                            pErrorMessage = "An error has occurred(Your login must be a FSP login). Please contact Ingenico."
                            passcodeVerified = False
                        Else
                            passcodeVerified = True
                        End If
                    Else
                        passcodeVerified = False

                        '--Call m_DataLayer.ClearLoginSession()
                        pErrorMessage = GetDataLayerErrorMessage(dlResult, "passcode")

                        Dim dlUserOTPInfoResult As DataLayerResult = m_DataLayer.GetUserOTPInfo()
                        If (dlUserOTPInfoResult = DataLayerResult.Success) Then

                            If (m_DataLayer.CurrentUserOTPInformation IsNot Nothing AndAlso
                                passcodeByte.SequenceEqual(m_DataLayer.CurrentUserOTPInformation.Passcode) AndAlso m_DataLayer.CurrentUserOTPInformation.ExpiryDateTime < DateTime.Now) Then
                                pErrorMessage = "The passcode has expired. Please click resend passcode"
                            End If
                        Else

                        End If
                    End If
                Else
                    pErrorMessage = TooManyPasscodeReties
                    passcodeVerified = False
                End If
            Catch exc As Exception
                Call m_DataLayer.HandleException(exc)
            Finally

            End Try
            Return passcodeVerified
        End Function

        Protected Overridable Sub OTPLogin(ByVal pPasscode As String, ByVal pRememberMe As Boolean, ByVal pSkin As String, ByVal pLogTypeID As Int16, ByVal pMainPage As String, ByVal pIsFSPOnly As Boolean, ByRef pErrorMessage As String)

            If (m_DataLayer.CurrentUserInformation IsNot Nothing AndAlso
                    m_DataLayer.m_TicketState() = DataLayerBase.TICKET_STATE.PENDING_MFA) Then

                If VerifyOTP(pPasscode, pIsFSPOnly, pLogTypeID, pErrorMessage) Then

                    'Transfer to member page
                    Call Response.Redirect(pMainPage)

                    'Do similar thing to Authentication or Login
                    'Encrypted login details already in cookie
                    'UpdateLoginDetailsInCookie(pRememberMe, userName, password)

                Else
                    'Login Error, go to login page
                    'Logout

                    UpdateLoginDetailsInCookie(False, Nothing, Nothing)

                End If
            Else
                Call m_DataLayer.Logout()
            End If

        End Sub


        Public Function CreateAndEmailUsertOTP(ByRef pErrorMsg As String) As Boolean
            Dim newPasscode As String = Nothing
            Dim errorMessage As String = Nothing
            Dim dlCreateOTPResult As DataLayerResult = m_DataLayer.CreateUserOTP(newPasscode)

            If dlCreateOTPResult = DataLayerResult.Success Then

                Dim hostInfo As String = "<IP>" & HttpContext.Current.Request.UserHostAddress() & "</IP>"

                If (Not String.IsNullOrEmpty(newPasscode)) Then
                    Dim dlOTPEmailResult As DataLayerResult = m_DataLayer.EmailUserOTP(newPasscode, hostInfo, errorMessage)
                    If dlOTPEmailResult = DataLayerResult.Success Then
                        pErrorMsg = "A new passcode is sent to your email account."
                        Return True
                    Else
                        pErrorMsg = "Failed to resend passcode."
                    End If
                Else
                    pErrorMsg = "Failed to create passcode."
                End If
            End If

            Return False
        End Function

        Protected Overridable Sub PositionMsgLabel(ByVal pPlaceHolder As PlaceHolder, ByVal pLblMsg As Label)
            If m_renderingStyle = RenderingStyleType.DeskTop Then
                pLblMsg.BackColor = Color.Yellow
                pLblMsg.ForeColor = Color.Red
                pLblMsg.CssClass = "FormDEError"
            Else
                pLblMsg.CssClass = "errormsg"
            End If
            pPlaceHolder.Controls.Clear()
            pPlaceHolder.Controls.Add(pLblMsg)

            ''this serves the clean up. it has to be done after the label added to placeholder
            pLblMsg.Text = ""
        End Sub

        Protected Overridable Sub DisplayErrorMessage(ByVal pLblMsg As Label, ByVal pMsg As String)
            pLblMsg.Text = "Error: " & pMsg
        End Sub

        Protected Function GetRenderingControlPrefix(ByVal pSection As String, ByVal pType As RenderingControlType) As String
            ''pSection: to guarrantine unique rendering cotnrol name on the page
            Dim prefix As String = pSection
            Select Case pType
                Case RenderingControlType.Label
                    prefix += "LBL_"
                Case RenderingControlType.Radio
                    prefix += "CHK_"
                Case RenderingControlType.Text
                    prefix += "TXT_"
                Case RenderingControlType.Combo
                    prefix += "CBO_"
            End Select
            Return prefix
        End Function
        Public Function getInternetExplorerVersion() As Single
	    ' Returns the version of Internet Explorer or a -1
	    ' (indicating the use of another browser).
	    Dim rv As Single = -1
	    Dim browser As System.Web.HttpBrowserCapabilities = Request.Browser
	    If browser.Browser = "IE" Then
		    rv = CSng(browser.MajorVersion + browser.MinorVersion)
	    End If
	    Return rv
    End Function
        Public Function GetJobViewerHREF(ByVal pJobID As String) As String
            Dim myHREF As String
            If Len(pJobID) = 11 Then
                myHREF = "<A HREF=""#"" onclick=""javascript:popupwindow('../Member/CallView.aspx?CNO=" + pJobID + "')"">here</A>"
            Else
                myHREF = "<A HREF=""#"" onclick=""javascript:popupwindow('../Member/JobView.aspx?JID=" + pJobID + "')"">here</A>"
            End If
            Return myHREF
        End Function

End Class

End Namespace
