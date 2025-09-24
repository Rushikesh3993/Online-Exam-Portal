<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Page Language="C#" AutoEventWireup="true" %>
<%
    if (Session["Email"] == null)
    {
        Response.Redirect("LoginExam.aspx");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Exam Result - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background-color: #f8f9fa; font-family: Arial, sans-serif; }
        .container { margin-top: 50px; }
        .result-box { background: #fff; border-radius: 10px; padding: 30px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        .correct { color: green; font-weight: bold; }
        .wrong { color: red; font-weight: bold; }
    </style>
</head>
<body>
<div class="container">
    <div class="result-box">
<%
    int score = 0;
    int total = Convert.ToInt32(Request.Form["totalQuestions"]);
    string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";
    int userID = 0;
    int subjectID = (int)Session["SubjectID"];
    DateTime startTime = (DateTime)Session["ExamStartTime"];
    DateTime endTime = DateTime.Now;

    using(SqlConnection con = new SqlConnection(connStr))
    {
        SqlCommand cmdUser = new SqlCommand("SELECT UserID FROM Users WHERE Email=@Email", con);
        cmdUser.Parameters.AddWithValue("@Email", Session["Email"].ToString());
        con.Open();
        userID = Convert.ToInt32(cmdUser.ExecuteScalar());
    }

    using(SqlConnection con = new SqlConnection(connStr))
    {
        con.Open();
        for(int i=1; i<=total; i++)
        {
            int qid = Convert.ToInt32(Request.Form["qid" + i]);
            string selected = Request.Form["ans" + i];

            SqlCommand cmd = new SqlCommand("SELECT QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectOption FROM Questions WHERE QuestionID=@qid", con);
            cmd.Parameters.AddWithValue("@qid", qid);
            SqlDataReader reader = cmd.ExecuteReader();
            if(reader.Read())
            {
                string correct = reader["CorrectOption"].ToString();
                if(selected == correct) score++;

%>
    <div class="mb-3 p-3 border rounded <%=(selected==reader["CorrectOption"].ToString() ? "border-success" : "border-danger")%>">
        <h5><%= i %>. <%= reader["QuestionText"].ToString() %></h5>
        <p>Your Answer: <span class="<%=(selected==correct ? "correct" : "wrong")%>"><%= selected %></span> | Correct Answer: <span class="correct"><%= correct %></span></p>
    </div>
<%
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

        <h2 class="mb-3">Your Score: <span class="text-success"><%= score %> / <%= total %></span></h2>
        <p>Total Time Taken: <%= (endTime - startTime).Minutes %> minutes <%= (endTime - startTime).Seconds %> seconds</p>
        <p>
            <a href="dashboard.aspx" class="btn btn-primary">Go Back to Dashboard</a>
        </p>
    </div>
</div>
</body>
</html>
