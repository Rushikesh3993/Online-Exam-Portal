<%@ Page Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="System.Data.SqlClient" %>

<%
    // 🔒 Redirect if not logged in
    if (Session["Email"] == null)
    {
        Response.Redirect("LoginExam.aspx");
    }

    int subjectID = 0;
    if (Request.QueryString["SubjectID"] != null)
    {
        subjectID = Convert.ToInt32(Request.QueryString["SubjectID"]);
        Session["SubjectID"] = subjectID;
    }
    else if (Session["SubjectID"] != null)
    {
        subjectID = (int)Session["SubjectID"];
    }

    string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";
    int userID = 0;

    using (SqlConnection con = new SqlConnection(connStr))
    {
        con.Open();

        // Get UserID from email
        SqlCommand cmdUser = new SqlCommand("SELECT UserID FROM Users WHERE Email=@Email", con);
        cmdUser.Parameters.AddWithValue("@Email", Session["Email"].ToString());
        userID = Convert.ToInt32(cmdUser.ExecuteScalar());

        // Check today's attempts for this subject
        SqlCommand cmdAttempts = new SqlCommand(
            "SELECT COUNT(*) FROM TestResults " +
            "WHERE UserID=@UserID AND SubjectID=@SubjectID AND CAST(TestDate AS DATE) = CAST(GETDATE() AS DATE)",
            con
        );
        cmdAttempts.Parameters.AddWithValue("@UserID", userID);
        cmdAttempts.Parameters.AddWithValue("@SubjectID", subjectID);
        int attemptsToday = Convert.ToInt32(cmdAttempts.ExecuteScalar());

        if (attemptsToday >= 2) // max 2 attempts per day
        {
%>
<div class="container mt-5">
    <div class="alert alert-warning text-center">
        ❌ You have already attempted this exam <strong><%= attemptsToday %> times</strong> today.<br />
        You cannot attempt again until tomorrow.
    </div>
    <div class="text-center mt-3">
        <a href="dashboard.aspx" class="btn btn-primary">⬅ Back to Dashboard</a>
    </div>
</div>
<%
            return; // stop rendering exam
        }

        // Start exam timer if not already
        if (Session["ExamStartTime"] == null)
        {
            Session["ExamStartTime"] = DateTime.Now;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Exam - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            background-color: #f8f9fa;
        }

        .question-card {
            background: #fff;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 3px 6px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <h2 class="text-center mt-4">📘 Exam</h2>

        <form method="post" action="CheckAnswers.aspx">
            <%
                int qNo = 1;
                int totalQuestions = 0;

                using (SqlConnection con = new SqlConnection(connStr))
                {
                    SqlCommand cmd = new SqlCommand("SELECT * FROM Questions WHERE SubjectID=@SubjectID", con);
                    cmd.Parameters.AddWithValue("@SubjectID", subjectID);
                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        totalQuestions++;
            %>
            <div class="question-card">
                <h6><%= qNo %>. <%= Server.HtmlEncode(reader["QuestionText"].ToString()) %></h6>

                <!-- Hidden QuestionID -->
                <input type="hidden" name="qid<%= qNo %>" value="<%= reader["QuestionID"] %>" />

                <div class="form-check my-1">
                    <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="A" id="q<%= qNo %>A" required>
                    <label class="form-check-label" for="q<%= qNo %>A"><%= Server.HtmlEncode(reader["OptionA"].ToString()) %></label>
                </div>
                <div class="form-check my-1">
                    <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="B" id="q<%= qNo %>B" required>
                    <label class="form-check-label" for="q<%= qNo %>B"><%= Server.HtmlEncode(reader["OptionB"].ToString()) %></label>
                </div>
                <div class="form-check my-1">
                    <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="C" id="q<%= qNo %>C" required>
                    <label class="form-check-label" for="q<%= qNo %>C"><%= Server.HtmlEncode(reader["OptionC"].ToString()) %></label>
                </div>
                <div class="form-check my-1">
                    <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="D" id="q<%= qNo %>D" required>
                    <label class="form-check-label" for="q<%= qNo %>D"><%= Server.HtmlEncode(reader["OptionD"].ToString()) %></label>
                </div>
            </div>
            <%
                        qNo++;
                    }
                    reader.Close();
                }
            %>

            <!-- Total questions -->
            <input type="hidden" name="totalQuestions" value="<%= totalQuestions %>" />

            <div class="text-center">
                <button type="submit" class="btn btn-success btn-lg">Submit Exam</button>
            </div>
        </form>
    </div>
</body>
</html>
