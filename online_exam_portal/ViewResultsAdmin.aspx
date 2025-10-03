<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<%
    // 🔒 Admin session check
    if (Session["AdminEmail"] == null)
    {
        Response.Redirect("AdminLogin.aspx");
    }

    string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";
%>

<!DOCTYPE html>
<html>
<head>
    <title>View Test Results - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .card { margin-top: 30px; }
        .table thead { background-color: #343a40; color: #fff; }
        .table-hover tbody tr:hover { background-color: #f1f1f1; }
    </style>
</head>
<body>

<div class="container">
    <h2 class="text-center mt-4">📊 All Test Results</h2>
    <div class="text-end mb-3">
        <a href="AdminDashboard.aspx" class="btn btn-secondary">⬅ Back to Dashboard</a>
    </div>

    <div class="card p-4 shadow-sm">
        <table class="table table-striped table-bordered table-hover">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Student Name</th>
                    <th>Email</th>
                    <th>Subject</th>
                    <th>Total Questions</th>
                    <th>Correct Answers</th>
                    <th>Score</th>
                    <th>Start Time</th>
                    <th>End Time</th>
                    <th>Test Date</th>
                </tr>
            </thead>
            <tbody>
                <%
                    using(SqlConnection con = new SqlConnection(connStr))
                    {
                        con.Open();
                        string query = @"
                            SELECT 
                                TR.Id, U.FullName, U.Email, S.SubjectName, 
                                TR.TotalQuestions, TR.CorrectAnswers, TR.Score, 
                                TR.StartTime, TR.EndTime, TR.TestDate
                            FROM TestResults TR
                            INNER JOIN Users U ON TR.UserID = U.UserID
                            INNER JOIN Subjects S ON TR.SubjectID = S.SubjectID
                            ORDER BY TR.TestDate DESC";

                        SqlCommand cmd = new SqlCommand(query, con);
                        SqlDataReader reader = cmd.ExecuteReader();

                        int count = 1;
                        while(reader.Read())
                        {
                %>
                <tr>
                    <td><%= count %></td>
                    <td><%= reader["FullName"] %></td>
                    <td><%= reader["Email"] %></td>
                    <td><%= reader["SubjectName"] %></td>
                    <td><%= reader["TotalQuestions"] %></td>
                    <td><%= reader["CorrectAnswers"] %></td>
                    <td><%= reader["Score"] %></td>
                    <td><%= Convert.ToDateTime(reader["StartTime"]).ToString("g") %></td>
                    <td><%= Convert.ToDateTime(reader["EndTime"]).ToString("g") %></td>
                    <td><%= Convert.ToDateTime(reader["TestDate"]).ToString("dd MMM yyyy") %></td>
                </tr>
                <%
                            count++;
                        }
                        reader.Close();
                    }
                %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>
