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

        // Check today's attempts for this subject
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
            return; // Stop the rest of the page from executing
        }
    }

    // Proceed with score calculation if allowed
    int score = 0;
    int total = Convert.ToInt32(Request.Form["totalQuestions"]);
    DateTime startTime = (DateTime)Session["ExamStartTime"];
    DateTime endTime = DateTime.Now;

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
                string correct = reader["CorrectOption"].ToString();
                if (selected == correct) score++;
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

        .container {
            margin-top: 50px;
        }

        .result-box {
            background: #fff;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="result-box">
            <h2 class="mb-3 text-center">📊 Your Exam Score</h2>
            <p class="text-center">You answered <strong><%= score %> / <%= total %></strong> correctly.</p>
            <p class="text-center">Total Time Taken: <%= (endTime - startTime).Minutes %> minutes <%= (endTime - startTime).Seconds %> seconds</p>
            <div class="text-center mt-3">
                <a href="dashboard.aspx" class="btn btn-primary">⬅ Back to Dashboard</a>
            </div>
        </div>
    </div>
</body>
</html>
