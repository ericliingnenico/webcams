#Region "vss"
'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:51 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Member/TreeViewVB.aspx.vb $-->
'<!--$$NoKeywords: $-->
#End Region

Option Strict On

Imports System.Data
Imports System.Data.SqlClient
Namespace eCAMS

Partial Class TreeViewVB
    Inherits MemberPageBase

    Protected Overrides Sub Page_Load(ByVal sender As System.Object, ByVal e As System.EventArgs)
        MyBase.Page_Load(sender, e)
        If Not Page.IsPostBack Then
            PopulateRootLevel()
        End If
    End Sub

    Private Sub PopulateRootLevel()

        Dim objConn As New SqlConnection("server=devxp2;Trusted_Connection=true;DATABASE=CAMS")
        Dim objCommand As New SqlCommand("select NodeID,NodeName,(select count(*) FROM tblKBTree " _
        & "WHERE ParentNodeID=sc.NodeID) childnodecount, ArticleID FROM tblKBTree sc where NodeID in (select NodeID from tblKBUserAccess where UserID = 199649)", objConn)

        Dim da As New SqlDataAdapter(objCommand)
        Dim dt As New DataTable()
        da.Fill(dt)

        PopulateNodes(dt, TreeView1.Nodes)

    End Sub

    Private Sub PopulateSubLevel(ByVal parentid As Integer, ByVal parentNode As TreeNode)

        Dim objConn As New SqlConnection("server=devxp2;Trusted_Connection=true;DATABASE=CAMS")
        Dim objCommand As New SqlCommand("select NodeID,NodeName,(select count(*) FROM tblKBTree " _
        & "WHERE ParentNodeID=sc.NodeID) childnodecount, ArticleID FROM tblKBTree sc where ParentNodeID=@parentID", objConn)
        objCommand.Parameters.Add("@parentID", SqlDbType.Int).Value = parentid

        Dim da As New SqlDataAdapter(objCommand)
        Dim dt As New DataTable()
        da.Fill(dt)

        PopulateNodes(dt, parentNode.ChildNodes)

    End Sub

    Private Sub PopulateNodes(ByVal dt As DataTable, ByVal nodes As TreeNodeCollection)

        For Each dr As DataRow In dt.Rows
            Dim tn As New TreeNode()
            tn.Text = dr("NodeName").ToString()
            tn.Value = dr("NodeID").ToString()
            ''
            ''may need to embed the docreader engine in eCAMS for security reason
            ''
            Dim keyUsed As String = "$#@!%^7A"
            Dim myEncrypt As New Encryption64()
            Dim myURL As String
            myURL = "http://localhost:4247/ReadDoc.aspx?t=987654321&obj="
''            myURL += System.Web.HttpUtility.UrlEncode(myEncrypt.Encrypt(m_DataLayer.CurrentUserInformation.UserID.ToString() & "|" & clsTool.NullToValue(dr("ArticleID"), 0).ToString & "|1", keyUsed))
            myURL += myEncrypt.Encrypt(m_DataLayer.CurrentUserInformation.UserID.ToString() & "|" & clsTool.NullToValue(dr("ArticleID"), 0).ToString & "|1", keyUsed)


            tn.NavigateUrl = myURL
            tn.Target = "ifmMyDoc" ''"_self" ''"_top" ''"_search" ''"_blank" 
            nodes.Add(tn)

            'If node has child nodes, then enable on-demand populating
            tn.PopulateOnDemand = (CInt(dr("childnodecount")) > 0)
        Next

    End Sub

    ''when tn.NavigateUrl specified, the belwo event won't be fired
    Protected Sub TreeView1_SelectedNodeChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles TreeView1.SelectedNodeChanged
        Label1.Text = TreeView1.SelectedNode.Value

    End Sub
    Protected Sub TreeView1_TreeNodePopulate(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.TreeNodeEventArgs) Handles TreeView1.TreeNodePopulate
        PopulateSubLevel(CInt(e.Node.Value), e.Node)
    End Sub

End Class
End Namespace
