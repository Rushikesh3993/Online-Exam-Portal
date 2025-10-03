<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Page Language="C#" AutoEventWireup="true" %>

<%
    // 🔒 Redirect if not logged in
    if (Session["Email"] == null)
    {
        Response.Redirect("LoginExam.aspx");
    }

    int subjectID = (int)Session["SubjectID"];
    string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";
    int userID = 0;

    using (SqlConnection con = new SqlConnection(connStr))
    {
        con.Open();

        // Get user ID
        SqlCommand cmdUser = new SqlCommand("SELECT UserID FROM Users WHERE Email=@Email", con);
        cmdUser.Parameters.AddWithValue("@Email", Session["Email"].ToString());
        userID = Convert.ToInt32(cmdUser.ExecuteScalar());

        // Check today's attempts
        SqlCommand cmdAttempts = new SqlCommand(
            "SELECT COUNT(*) FROM TestResults " +
            "WHERE UserID=@UserID AND SubjectID=@SubjectID AND CAST(TestDate AS DATE) = CAST(GETDATE() AS DATE)", con
        );
        cmdAttempts.Parameters.AddWithValue("@UserID", userID);
        cmdAttempts.Parameters.AddWithValue("@SubjectID", subjectID);
        int attemptsToday = Convert.ToInt32(cmdAttempts.ExecuteScalar());

        if (attemptsToday >= 2)
        {
%>
<div class="container mt-5">
    <div class="alert alert-warning text-center">
        ❌ You have already attempted this exam <strong><%= attemptsToday %> times</strong> today.<br />
        You cannot submit again.
    </div>
    <div class="text-center mt-3">
        <a href="dashboard.aspx" class="btn btn-primary">⬅ Back to Dashboard</a>
    </div>
</div>
<%
            return; // Stop further execution
        }
    }

    // ✅ Score calculation
    int score = 0;
    int total = Convert.ToInt32(Request.Form["totalQuestions"]);
    DateTime startTime = (DateTime)Session["ExamStartTime"];
    DateTime endTime = DateTime.Now;

    // Store detailed answers
    List<string> resultDetails = new List<string>();

    using (SqlConnection con = new SqlConnection(connStr))
    {
        con.Open();
        for (int i = 1; i <= total; i++)
        {
            int qid = Convert.ToInt32(Request.Form["qid" + i]);
            string selected = Request.Form["ans" + i];

            SqlCommand cmd = new SqlCommand(
                "SELECT QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption FROM Questions WHERE QuestionID=@qid", con
            );
            cmd.Parameters.AddWithValue("@qid", qid);
            SqlDataReader reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                string question = reader["QuestionText"].ToString();
                string correct = reader["CorrectOption"].ToString();
                string selectedAnswer = (selected == null) ? "Not Answered" : selected;

                string rowClass = "";
                string status = "";

                if (selected == null)
                {
                    rowClass = "table-warning"; // yellow
                    status = "⏳ Not Answered";
                }
                else if (selectedAnswer == correct)
                {
                    rowClass = "table-success"; // green
                    status = "✅ Correct";
                    score++;
                }
                else
                {
                    rowClass = "table-danger"; // red
                    status = "❌ Wrong";
                }

                resultDetails.Add($"<tr class='{rowClass}'><td>{question}</td><td>{selectedAnswer}</td><td>{correct}</td><td>{status}</td></tr>");
            }
            reader.Close();
        }

        // Save result
        SqlCommand saveCmd = new SqlCommand(
            "INSERT INTO TestResults(UserID, SubjectID, TotalQuestions, CorrectAnswers, Score, StartTime, EndTime) " +
            "VALUES(@UserID, @SubjectID, @TotalQ, @Correct, @Score, @Start, @End)", con
        );

        saveCmd.Parameters.AddWithValue("@UserID", userID);
        saveCmd.Parameters.AddWithValue("@SubjectID", subjectID);
        saveCmd.Parameters.AddWithValue("@TotalQ", total);
        saveCmd.Parameters.AddWithValue("@Correct", score);
        saveCmd.Parameters.AddWithValue("@Score", score);
        saveCmd.Parameters.AddWithValue("@Start", startTime);
        saveCmd.Parameters.AddWithValue("@End", endTime);
        saveCmd.ExecuteNonQuery();
    }

    // Build table
    string detailsTable = "<table class='table table-bordered mt-4'>" +
                          "<thead class='table-light'><tr><th>Question</th><th>Your Answer</th><th>Correct Answer</th><th>Status</th></tr></thead><tbody>" +
                          string.Join("", resultDetails) +
                          "</tbody></table>";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Exam Result - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            background-color: #f8f9fa;
            font-family: Arial, sans-serif;
        }
        .result-box {
            background: #fff;
            border-radius: 10px;
            padding: 30px;
            margin-top: 50px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        table td { vertical-align: middle; }
    </style>
</head>
<body>
    <div class="container">
        <div class="result-box">
            <h2 class="mb-3 text-center">📊 Your Exam Score</h2>
            <p class="text-center">You answered <strong><%= score %> / <%= total %></strong> correctly.</p>
            <p class="text-center">⏱ Time Taken: <%= (endTime - startTime).Minutes %> minutes <%= (endTime - startTime).Seconds %> seconds</p>
            
            <%= detailsTable %> <!-- ✅ Color-coded answers table -->

            <div class="text-center mt-3">
                <a href="dashboard.aspx" class="btn btn-primary">⬅ Back to Dashboard</a>
            </div>
        </div>
    </div>
</body>
</html>
