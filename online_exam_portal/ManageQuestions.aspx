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

    // Handle Add Question
    if (Request.Form["btnAdd"] != null)
    {
        int subjectID = Convert.ToInt32(Request.Form["ddlSubject"]);
        string questionText = Request.Form["txtQuestion"];
        string optionA = Request.Form["txtOptionA"];
        string optionB = Request.Form["txtOptionB"];
        string optionC = Request.Form["txtOptionC"];
        string optionD = Request.Form["txtOptionD"];
        string correct = Request.Form["ddlCorrect"];

        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlCommand cmd = new SqlCommand(
                "INSERT INTO Questions (SubjectID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption) " +
                "VALUES (@sub, @q, @a, @b, @c, @d, @correct)", con
            );
            cmd.Parameters.AddWithValue("@sub", subjectID);
            cmd.Parameters.AddWithValue("@q", questionText);
            cmd.Parameters.AddWithValue("@a", optionA);
            cmd.Parameters.AddWithValue("@b", optionB);
            cmd.Parameters.AddWithValue("@c", optionC);
            cmd.Parameters.AddWithValue("@d", optionD);
            cmd.Parameters.AddWithValue("@correct", correct);
            cmd.ExecuteNonQuery();
            message = "Question added successfully!";
        }
    }

    // Handle Delete Question
    if (Request.QueryString["delete"] != null)
    {
        int qid = Convert.ToInt32(Request.QueryString["delete"]);
        using (SqlConnection con = new SqlConnection(connStr))
        {
            con.Open();
            SqlCommand cmd = new SqlCommand("DELETE FROM Questions WHERE QuestionID=@id", con);
            cmd.Parameters.AddWithValue("@id", qid);
            cmd.ExecuteNonQuery();
            message = "Question deleted successfully!";
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Questions</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .card { margin-top: 30px; }
    </style>
</head>
<body>
<div class="container">
    <h2 class="text-center mt-4">❓ Manage Questions</h2>
    <div class="text-center mb-3">
        <a href="AdminDashboard.aspx" class="btn btn-secondary">⬅ Back to Dashboard</a>
    </div>

    <% if (message != "") { %>
        <div class="alert alert-success text-center"><%= message %></div>
    <% } %>

    <!-- Add Question Form -->
    <div class="card p-4 shadow-sm">
        <h4>Add New Question</h4>
        <form method="post">
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
                <textarea name="txtQuestion" class="form-control" placeholder="Enter Question" required></textarea>
            </div>
            <div class="row">
                <div class="col-md-6 mb-2">
                    <input type="text" name="txtOptionA" class="form-control" placeholder="Option A" required />
                </div>
                <div class="col-md-6 mb-2">
                    <input type="text" name="txtOptionB" class="form-control" placeholder="Option B" required />
                </div>
                <div class="col-md-6 mb-2">
                    <input type="text" name="txtOptionC" class="form-control" placeholder="Option C" required />
                </div>
                <div class="col-md-6 mb-2">
                    <input type="text" name="txtOptionD" class="form-control" placeholder="Option D" required />
                </div>
            </div>
            <div class="mb-3">
                <select name="ddlCorrect" class="form-select" required>
                    <option value="">Select Correct Answer</option>
                    <option value="A">Option A</option>
                    <option value="B">Option B</option>
                    <option value="C">Option C</option>
                    <option value="D">Option D</option>
                </select>
            </div>
            <button type="submit" name="btnAdd" class="btn btn-primary">Add Question</button>
        </form>
    </div>

    <!-- Questions List -->
    <div class="card p-4 shadow-sm mt-4">
        <h4>Existing Questions</h4>
        <table class="table table-striped table-bordered mt-3">
            <thead class="table-dark">
                <tr>
                    <th>#</th>
                    <th>Subject</th>
                    <th>Question</th>
                    <th>Correct Answer</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    using (SqlConnection con = new SqlConnection(connStr))
                    {
                        con.Open();
                        SqlCommand cmd = new SqlCommand(
                            "SELECT Q.QuestionID, Q.QuestionText, Q.CorrectOption, S.SubjectName " +
                            "FROM Questions Q INNER JOIN Subjects S ON Q.SubjectID = S.SubjectID", con
                        );
                        SqlDataReader reader = cmd.ExecuteReader();
                        int no = 1;
                        while (reader.Read())
                        {
                %>
                <tr>
                    <td><%= no %></td>
                    <td><%= reader["SubjectName"] %></td>
                    <td><%= reader["QuestionText"] %></td>
                    <td><%= reader["CorrectOption"] %></td>
                    <td>
                        <a href="ManageQuestions.aspx?delete=<%= reader["QuestionID"] %>" 
                           class="btn btn-danger btn-sm" 
                           onclick="return confirm('Are you sure to delete this question?')">Delete</a>
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
