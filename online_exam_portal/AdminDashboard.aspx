<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<%
    // 🔒 Admin session check
    if (Session["AdminEmail"] == null)
    {
        Response.Redirect("AdminLogin.aspx");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f4f6f9; }
        .card { cursor: pointer; transition: transform 0.2s; }
        .card:hover { transform: scale(1.05); }
        .welcome { margin-top: 20px; }
    </style>
</head>
<body>

<div class="container">
    <h2 class="text-center mt-4">🛠️ Admin Dashboard</h2>

    <div class="text-end mb-3">
        <a href="AdminLogout.aspx" class="btn btn-danger">Logout</a>
    </div>

    <div class="alert alert-info welcome text-center">
        Welcome, <strong><%= Session["AdminName"] %></strong>!
    </div>

    <div class="row g-4 mt-4">

        <!-- Manage Subjects -->
        <div class="col-md-3">
            <a href="ManageSubjects.aspx" style="text-decoration:none;">
                <div class="card text-center p-4 shadow-sm">
                    <h4>📚 Manage Subjects</h4>
                    <p class="text-muted">Add, edit or delete subjects</p>
                </div>
            </a>
        </div>

        <!-- Manage Exams -->
        <div class="col-md-3">
            <a href="ManageExams.aspx" style="text-decoration:none;">
                <div class="card text-center p-4 shadow-sm">
                    <h4>📝 Manage Exams</h4>
                    <p class="text-muted">Create and manage exams</p>
                </div>
            </a>
        </div>

        <!-- Manage Questions -->
        <div class="col-md-3">
            <a href="ManageQuestions.aspx" style="text-decoration:none;">
                <div class="card text-center p-4 shadow-sm">
                    <h4>❓ Manage Questions</h4>
                    <p class="text-muted">Add, delete questions for exams</p>
                </div>
            </a>
        </div>

        <!-- View Results -->
        <div class="col-md-3">
            <a href="ViewResultsAdmin.aspx" style="text-decoration:none;">
                <div class="card text-center p-4 shadow-sm">
                    <h4>📊 View Results</h4>
                    <p class="text-muted">Check student exam results</p>
                </div>
            </a>
        </div>

        <!-- Manage Users -->
        <div class="col-md-3">
            <a href="ManageStudents.aspx" style="text-decoration:none;">
                <div class="card text-center p-4 shadow-sm">
                    <h4>👥 Manage Students</h4>
                    <p class="text-muted">View or delete student accounts</p>
                </div>
            </a>
        </div>

    </div>
</div>

</body>
</html>
