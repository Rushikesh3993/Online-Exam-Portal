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

    // Handle Add Subject
    if (Request.Form["btnAdd"] != null)
    {
        string subjectName = Request.Form["txtSubject"];
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlCommand cmd = new SqlCommand("INSERT INTO Subjects (SubjectName) VALUES (@name)", con);
            cmd.Parameters.AddWithValue("@name", subjectName);
            cmd.ExecuteNonQuery();
            message = "✅ Subject added successfully!";
        }
    }

    // Handle Delete Subject (with related exams)
    if (Request.QueryString["delete"] != null)
    {
        int subID = Convert.ToInt32(Request.QueryString["delete"]);
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();

            // 1. Delete Exams linked to this subject
            SqlCommand cmdExams = new SqlCommand("DELETE FROM Exams WHERE SubjectID=@id", con);
            cmdExams.Parameters.AddWithValue("@id", subID);
            cmdExams.ExecuteNonQuery();

            // 2. Delete Subject
            SqlCommand cmd = new SqlCommand("DELETE FROM Subjects WHERE SubjectID=@id", con);
            cmd.Parameters.AddWithValue("@id", subID);
            cmd.ExecuteNonQuery();

            message = "🗑 Subject and related exams deleted successfully!";
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Subjects</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .card { margin-top: 30px; }
    </style>
</head>
<body>

<div class="container">
    <h2 class="text-center mt-4">📚 Manage Subjects</h2>
    <div class="text-center mb-3">
        <a href="AdminDashboard.aspx" class="btn btn-secondary">⬅ Back to Dashboard</a>
    </div>

    <% if (message != "") { %>
        <div class="alert alert-success text-center"><%= message %></div>
    <% } %>

    <!-- Add Subject Form -->
    <div class="card p-4 shadow-sm">
        <h4>Add New Subject</h4>
        <form method="post">
            <div class="mb-3">
                <input type="text" name="txtSubject" class="form-control" placeholder="Subject Name" required />
            </div>
            <button type="submit" name="btnAdd" class="btn btn-primary">Add Subject</button>
        </form>
    </div>

    <!-- Subject List -->
    <div class="card p-4 shadow-sm mt-4">
        <h4>Existing Subjects</h4>
        <table class="table table-striped table-bordered mt-3">
            <thead class="table-dark">
                <tr>
                    <th>#</th>
                    <th>Subject Name</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    using (SqlConnection con = new SqlConnection(connStr))
                    {
                        con.Open();
                        SqlCommand cmd = new SqlCommand("SELECT SubjectID, SubjectName FROM Subjects", con);
                        SqlDataReader reader = cmd.ExecuteReader();
                        int no = 1;
                        while (reader.Read())
                        {
                %>
                <tr>
                    <td><%= no %></td>
                    <td><%= reader["SubjectName"].ToString() %></td>
                    <td>
                        <a href="ManageSubjects.aspx?delete=<%= reader["SubjectID"] %>" 
                           class="btn btn-danger btn-sm" 
                           onclick="return confirm('⚠ Deleting this subject will also delete related exams. Continue?')">
                           Delete
                        </a>
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
