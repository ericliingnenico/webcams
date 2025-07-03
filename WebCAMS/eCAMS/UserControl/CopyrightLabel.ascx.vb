Imports System.Reflection


Partial Public Class CopyrightLabel
        Inherits System.Web.UI.UserControl

        Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            If Not IsPostBack Then
                LoadCopyrightText()
            End If
        End Sub

        Private Sub LoadCopyrightText()
            Try
                ' Assuming the copyright text is stored in an assembly attribute
                Dim assembly As Assembly = Assembly.GetExecutingAssembly()
                Dim copyrightAttribute As AssemblyCopyrightAttribute =
                    DirectCast(Attribute.GetCustomAttribute(assembly, GetType(AssemblyCopyrightAttribute)), AssemblyCopyrightAttribute)

                If copyrightAttribute IsNot Nothing Then
                    lblCopyright.Text = copyrightAttribute.Copyright
                Else
                lblCopyright.Text = "© INGENICO INTERNATIONAL (PACIFIC) PTY LTD"
            End If
            Catch ex As Exception
            lblCopyright.Text = "© INGENICO INTERNATIONAL (PACIFIC) PTY LTD"
        End Try
        End Sub
    End Class

