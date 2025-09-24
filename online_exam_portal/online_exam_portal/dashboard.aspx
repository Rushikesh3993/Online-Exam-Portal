<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Page Language="C#" AutoEventWireup="true" %>

<%
    // 🔒 Ensure user is logged in
    if (Session["Email"] == null)
    {
        Response.Redirect("LoginExam.aspx");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        body { font-family: Arial, sans-serif; background-color: #f8f9fa; }
        .sidebar { height: 100vh; background-color: #1c1f23; color: white; padding: 20px; position: fixed; top: 0; left: 0; width: 220px; }
        .sidebar a { color: #cfd2d6; text-decoration: none; display: block; padding: 10px; margin: 5px 0; border-radius: 5px; }
        .sidebar a:hover { background-color: #007bff; color: white; }
        .sidebar i { margin-right: 10px; }
        .main { margin-left: 240px; padding: 20px; }
        .card-custom { border-radius: 10px; transition: transform 0.2s; min-height: 150px; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; color: white; cursor: pointer; }
        .card-custom:hover { transform: scale(1.05); }
    </style>
</head>
<body>
    <div class="sidebar">
        <h5 class="mb-4"><i class="fa-solid fa-user"></i><%= Session["FullName"] != null ? Session["FullName"].ToString() : "User" %></h5>
        <a href="#"><i class="fa-solid fa-gauge"></i>Dashboard</a>
        <a href="ViewResults.aspx"><i class="fa-solid fa-chart-line"></i>View My Results</a>
        <a href="logout.aspx"><i class="fa-solid fa-right-from-bracket"></i>Logout</a>
    </div>

    <div class="main">
        <h3>Dashboard</h3>
        <div class="row g-3 mt-3">
            <!-- All 5 subjects -->
            <div class="col-md-4">
                <a href="GetQuestions.aspx?SubjectID=1" style="text-decoration: none;">
                    <div class="card card-custom bg-danger p-3">
                        <i class="fa-solid fa-code fa-2x mb-2"></i>
                        <h5>ASP.NET</h5>
                        <p>Click to start exam</p>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="GetQuestions.aspx?SubjectID=2" style="text-decoration: none;">
                    <div class="card card-custom bg-primary p-3">
                        <i class="fa-solid fa-database fa-2x mb-2"></i>
                        <h5>C Language</h5>
                        <p>Click to start exam</p>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="GetQuestions.aspx?SubjectID=3" style="text-decoration: none;">
                    <div class="card card-custom bg-success p-3">
                        <i class="fa-solid fa-laptop-code fa-2x mb-2"></i>
                        <h5>Java</h5>
                        <p>Click to start exam</p>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="GetQuestions.aspx?SubjectID=4" style="text-decoration: none;">
                    <div class="card card-custom bg-warning p-3">
                        <i class="fa-solid fa-database fa-2x mb-2"></i>
                        <h5>SQL</h5>
                        <p>Click to start exam</p>
                    </div>
                </a>
            </div>
            <div class="col-md-4">
                <a href="GetQuestions.aspx?SubjectID=5" style="text-decoration: none;">
                    <div class="card card-custom bg-info p-3">
                        <i class="fa-solid fa-code fa-2x mb-2"></i>
                        <h5>Web Design</h5>
                        <p>Click to start exam</p>
                    </div>
                </a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
