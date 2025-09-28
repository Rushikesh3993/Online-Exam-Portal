<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<%
    // 🔒 Admin session check
    if (Session["AdminEmail"] == null)
    {
        Response.Redirect("AdminLogin.aspx");
    }

    string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";
    string message = "";

    // Handle Add Exam
    if (Request.Form["btnAdd"] != null)
    {
        string examName = Request.Form["txtExamName"];
        int subjectID = Convert.ToInt32(Request.Form["ddlSubject"]);
        int totalQuestions = Convert.ToInt32(Request.Form["txtTotalQuestions"]);

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlCommand cmd = new SqlCommand(
                "INSERT INTO Exams (ExamName, SubjectID, TotalQuestions) VALUES (@name, @subID, @totalQ)", con
            );
            cmd.Parameters.AddWithValue("@name", examName);
            cmd.Parameters.AddWithValue("@subID", subjectID);
            cmd.Parameters.AddWithValue("@totalQ", totalQuestions);
            cmd.ExecuteNonQuery();
            message = "Exam added successfully!";
        }
    }

    // Handle Delete Exam
    if (Request.QueryString["delete"] != null)
    {
        int examID = Convert.ToInt32(Request.QueryString["delete"]);
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlCommand cmd = new SqlCommand("DELETE FROM Exams WHERE ExamID=@id", con);
            cmd.Parameters.AddWithValue("@id", examID);
            cmd.ExecuteNonQuery();
            message = "Exam deleted successfully!";
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Exams</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .card { margin-top: 30px; }
    </style>
</head>
<body>

<div class="container">
    <h2 class="text-center mt-4">📝 Manage Exams</h2>
    <div class="text-center mb-3">
        <a href="AdminDashboard.aspx" class="btn btn-secondary">⬅ Back to Dashboard</a>
    </div>

    <% if (message != "") { %>
        <div class="alert alert-success text-center"><%= message %></div>
    <% } %>

    <!-- Add Exam Form -->
    <div class="card p-4 shadow-sm">
        <h4>Add New Exam</h4>
        <form method="post">
            <div class="mb-3">
                <input type="text" name="txtExamName" class="form-control" placeholder="Exam Name" required />
            </div>
            <div class="mb-3">
                <select name="ddlSubject" class="form-select" required>
                    <option value="">Select Subject</option>
                    <%
                        using (SqlConnection con = new SqlConnection(connStr))
                        {
                            con.Open();
                            SqlCommand cmd = new SqlCommand("SELECT SubjectID, SubjectName FROM Subjects", con);
                            SqlDataReader reader = cmd.ExecuteReader();
                            while (reader.Read())
                            {
                    %>
                    <option value="<%= reader["SubjectID"] %>"><%= reader["SubjectName"] %></option>
                    <%
                            }
                            reader.Close();
                        }
                    %>
                </select>
            </div>
            <div class="mb-3">
                <input type="number" name="txtTotalQuestions" class="form-control" placeholder="Total Questions" min="1" required />
            </div>
            <button type="submit" name="btnAdd" class="btn btn-primary">Add Exam</button>
        </form>
    </div>

    <!-- Exam List -->
    <div class="card p-4 shadow-sm mt-4">
        <h4>Existing Exams</h4>
        <table class="table table-striped table-bordered mt-3">
            <thead class="table-dark">
                <tr>
                    <th>#</th>
                    <th>Exam Name</th>
                    <th>Subject</th>
                    <th>Total Questions</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    using (SqlConnection con = new SqlConnection(connStr))
                    {
                        con.Open();
                        SqlCommand cmd = new SqlCommand(
                            "SELECT E.ExamID, E.ExamName, E.TotalQuestions, S.SubjectName FROM Exams E INNER JOIN Subjects S ON E.SubjectID = S.SubjectID",
                            con
                        );
                        SqlDataReader reader = cmd.ExecuteReader();
                        int no = 1;
                        while (reader.Read())
                        {
                %>
                <tr>
                    <td><%= no %></td>
                    <td><%= reader["ExamName"] %></td>
                    <td><%= reader["SubjectName"] %></td>
                    <td><%= reader["TotalQuestions"] %></td>
                    <td>
                        <a href="ManageExams.aspx?delete=<%= reader["ExamID"] %>" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure to delete this exam?')">Delete</a>
                    </td>
                </tr>
                <%
                            no++;
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
