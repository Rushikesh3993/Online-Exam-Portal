<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewResultsAdmin.aspx.cs" Inherits="online_exam_portal.ViewResultsAdmin" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<%
    // Admin session check
    if (Session["AdminEmail"] == null)
    {
        Response.Redirect("AdminLogin.aspx");
    }

    String connstr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=onlineExamDB;Trusted_Connection=True;";

%>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>📊 View Results (Admin)</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }

        .card {
            margin-top: 30px;
        }
    </style>
</head>
<body>
    
</body>
</html>
