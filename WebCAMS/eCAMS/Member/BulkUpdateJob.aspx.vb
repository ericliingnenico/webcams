#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/01/2018 11:07 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/BulkUpdateJob.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On
Imports System.Drawing
Namespace eCAMS

	Public Class BulkUpdateJob
		Inherits MemberPageBase

		Private lblMsg As New Label

		Protected Overrides Sub GetContext()
			With Request
				''m_jobID = Convert.ToInt64(.Item("JID"))
			End With
		End Sub

		Protected Overrides Sub Process()
			SetDE()
		End Sub
		Protected Overrides Sub AddClientScript()
			btnBulkUpdate.Attributes.Add("onclick", "return ConfirmWithValidation('Are you sure to submit this request?');")
		End Sub
		Private Sub SetDE()
			Me.PageTitle = "Bulk Update Jobs"
			Me.RestrictModuleName = "AdminBulkUpdate"
			Call SetFocusExt(txtPasteData)

		End Sub
		Private Sub DisplayFullPage()
			Call HidePanels(1)  ''hide top level
			panelFullPage.Visible = True

			PositionMsgLabel(placeholderMsg, lblMsg)

		End Sub

		Private Sub DisplayAcknowledgePage()
			Call HidePanels(1)  ''hide top level
			panelAcknowledge.Visible = True
			lblAcknowledge.Text = "BulkUpdate has been logged successfully. "

		End Sub

		Private Sub HidePanels(ByVal pLevel As Int16)
			Select Case pLevel
				Case 1  ''top level
					panelFullPage.Visible = False
					panelAcknowledge.Visible = False
				Case 2  ''second level
					panelAcknowledge.Visible = False
			End Select
		End Sub

		Protected Sub btnBulkUpdate_ServerClick(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnBulkUpdate.ServerClick
			Dim copiedData As String
			Dim copiedString As String = ""

			PositionMsgLabel(placeholderMsg, lblMsg) ''reposition the error message label

			copiedData = txtPasteData.Text

			Try


				If Not IsDataOk(copiedData) Then
					DisplayErrorMessage(lblMsg, "Invalid data pasted. Please try again.")
					Exit Sub
				End If

				For Each row As String In copiedData.Split(ControlChars.CrLf.ToCharArray(), StringSplitOptions.RemoveEmptyEntries)
					If Not String.IsNullOrEmpty(row) Then
						For Each cell As String In row.Split(ControlChars.Tab)
							copiedString += cell + "|"
						Next
						copiedString += ","
					End If
				Next
				''Debug.Print(copiedString)
				''txtPasteData.Text = copiedString
				BindGrid(copiedString)
				panelPasteData.Visible = False
				panelDoUpdateButton.Visible = True
				''PasteToGridView()
			Catch ex As Exception
				DisplayErrorMessage(lblMsg, ex.Message)
				lblMsg.BackColor = Color.Yellow
				lblMsg.ForeColor = Color.Red
			End Try





		End Sub
		Private Function IsDataOk(ByVal pData As String) As Boolean
			Dim temp As Decimal
			For Each row As String In pData.Split(ControlChars.CrLf.ToCharArray(), StringSplitOptions.RemoveEmptyEntries)
				If Not String.IsNullOrEmpty(row) Then
					For Each cell As String In row.Split(ControlChars.Tab)
						If Not Decimal.TryParse(cell, temp) Then
							Return False
						End If
					Next
				End If
			Next
			Return True
		End Function
		Protected Sub PasteToGridView()
			Dim dt As New DataTable()
			dt.Columns.AddRange(New DataColumn(2) {New DataColumn("Id", GetType(Long)), New DataColumn("Name", GetType(String)), New DataColumn("Country", GetType(String))})

			Dim copiedContent As String = txtPasteData.Text
			For Each row As String In copiedContent.Split(ControlChars.CrLf.ToCharArray(), StringSplitOptions.RemoveEmptyEntries)
				If Not String.IsNullOrEmpty(row) Then
					dt.Rows.Add()
					Dim i As Integer = 0
					For Each cell As String In row.Split(ControlChars.Tab)
						dt.Rows(dt.Rows.Count - 1)(i) = cell
						i += 1
					Next
				End If
			Next
			GridView1.DataSource = dt
			GridView1.DataBind()
			''txtPasteData.Text = ""
		End Sub
		Private Sub BindGrid(ByVal pData As String)
			Dim dlResult As DataLayerResult
			Dim ds As DataSet
			Dim dv As DataView
			txtActionTypeID.Value = cboType.SelectedValue
			lblBulkUpdteTitle.Text = "Bulk Update - " & cboType.SelectedItem.Text
			dlResult = m_DataLayer.GetAdminBulkJob(CShort(cboType.SelectedValue), pData)
			If dlResult = DataLayerResult.Success Then
				ds = m_DataLayer.dsTemp

				Try
					''using dataview for sorting on column purpose
					dv = New DataView(ds.Tables(0))
					If m_DataLayer.SelectedSortOrder <> String.Empty Then
						dv.Sort = m_DataLayer.SelectedSortOrder
					End If
					grdJob.DataSource = dv
					grdJob.DataBind()
				Catch ex As Exception
					DisplayErrorMessage(lblMsg, ex.Message)
				Finally
				End Try

			End If

		End Sub
		Private Sub btnDoUpdate_ServerClick(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnDoUpdate.ServerClick
			Dim ret As DataLayerResult
			Dim jobIDList As String
			jobIDList = Request.Item("chkBulk")
			Try
				ret = m_DataLayer.PutAdminBulkJob(CShort(txtActionTypeID.Value), jobIDList)
				'If ret = DataLayerResult.Success Then
				'End If

				Call DisplayAcknowledgePage()
			Catch ex As Exception
				DisplayErrorMessage(lblMsg, ex.Message)
			End Try

		End Sub
		'Private Sub grdJob_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataGridItemEventArgs) Handles grdJob.ItemDataBound
		'	''why do we choose ItemDataBound event? We can access Action and DeviceName column in this event to display confirmation message.
		'	''The values of these columns are not available at grd_ItemCreated event.
		'	Dim itemType As ListItemType = e.Item.ItemType
		'	If ((itemType = ListItemType.Pager) Or (itemType = ListItemType.Header) Or (itemType = ListItemType.Footer)) Then
		'		Return
		'	Else
		'		Try
		'			''Dim chk As CheckBox = CType(e.Item.Cells(9).Controls(0), CheckBox)

		'			If e.Item.Cells(9).Text.Contains("checked>") Then
		'				e.Item.BackColor = Color.FromName("#fff4c2")
		'			End If
		'		Catch ex As Exception
		'			''silence the error
		'		End Try
		'	End If
		'End Sub
	End Class
End Namespace