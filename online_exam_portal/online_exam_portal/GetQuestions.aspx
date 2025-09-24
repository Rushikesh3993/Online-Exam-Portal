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
    <title>Exam - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background-color: #f9f9f9; font-family: Arial, sans-serif; }
        .container { max-width: 700px; margin-top: 30px; }
        .question-card { border: 1px solid #ddd; border-radius: 6px; padding: 15px; margin-bottom: 15px; background-color: #fff; }
        .timer { font-weight: bold; color: #fff; background-color: #0d6efd; padding: 6px 12px; border-radius: 4px; }
        .score-box { font-weight: bold; color: #198754; }
        .fixed-submit { position: fixed; bottom: 20px; right: 20px; }
    </style>
    <script>
        let totalSeconds = 300; // 5 minutes
        function startTimer() {
            const timerEl = document.getElementById("timer");
            const interval = setInterval(() => {
                let min = Math.floor(totalSeconds / 60);
                let sec = totalSeconds % 60;
                timerEl.innerText = min.toString().padStart(2, '0') + ":" + sec.toString().padStart(2, '0');
                totalSeconds--;
                if (totalSeconds < 0) {
                    clearInterval(interval);
                    alert("Time's up! Submitting exam...");
                    document.getElementById("examForm").submit();
                }
            }, 1000);
        }
        window.onload = startTimer;
    </script>
</head>
<body>
<div class="container">

    <div class="d-flex justify-content-between align-items-center mb-4">
        <div class="timer" id="timer">05:00</div>
        <div class="score-box">
            <%
                if(Session["ScoreMessage"] != null)
                {
                    Response.Write(Session["ScoreMessage"]);
                    Session["ScoreMessage"] = null;
                }
            %>
        </div>
    </div>

<%
    string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";
    int userID = 0;
    int subjectID = Convert.ToInt32(Request.QueryString["SubjectID"]);

    using(SqlConnection con = new SqlConnection(connStr))
    {
        con.Open();
        SqlCommand cmdUser = new SqlCommand("SELECT UserID FROM Users WHERE Email=@Email", con);
        cmdUser.Parameters.AddWithValue("@Email", Session["Email"].ToString());
        userID = Convert.ToInt32(cmdUser.ExecuteScalar());
    }

    int attempts = 0;
    using(SqlConnection con = new SqlConnection(connStr))
    {
        con.Open();
        SqlCommand cmd = new SqlCommand(
            "SELECT COUNT(*) FROM TestResults WHERE UserID=@UserID AND SubjectID=@SubjectID AND StartTime >= DATEADD(HOUR, -24, GETDATE())", con
        );
        cmd.Parameters.AddWithValue("@UserID", userID);
        cmd.Parameters.AddWithValue("@SubjectID", subjectID);
        attempts = Convert.ToInt32(cmd.ExecuteScalar());
    }

    if(attempts >= 2)
    {
%>
        <div class="alert alert-danger text-center">
            You have already attempted this exam 2 times in the last 24 hours. Please try again later.
        </div>
<%
        return;
    }
    else
    {
        Session["ExamStartTime"] = DateTime.Now;
    }

    using(SqlConnection con = new SqlConnection(connStr))
    {
        string query = "SELECT QuestionID, QuestionText, OptionA, OptionB, OptionC, OptionD FROM Questions WHERE SubjectID=@sid";
        SqlCommand cmd = new SqlCommand(query, con);
        cmd.Parameters.AddWithValue("@sid", subjectID);
        con.Open();
        SqlDataReader reader = cmd.ExecuteReader();

        int qNo = 1;
%>

<form method="post" action="CheckAnswers.aspx" id="examForm">
<%
        while(reader.Read())
        {
%>
    <div class="question-card">
        <h6><%= qNo %>. <%= Server.HtmlEncode(reader["QuestionText"].ToString()) %></h6>
        <div class="form-check my-1">
            <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="A" id="q<%= qNo %>A" required>
            <label class="form-check-label" for="q<%= qNo %>A"><%= Server.HtmlEncode(reader["OptionA"].ToString()) %></label>
        </div>
        <div class="form-check my-1">
            <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="B" id="q<%= qNo %>B">
            <label class="form-check-label" for="q<%= qNo %>B"><%= Server.HtmlEncode(reader["OptionB"].ToString()) %></label>
        </div>
        <div class="form-check my-1">
            <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="C" id="q<%= qNo %>C">
            <label class="form-check-label" for="q<%= qNo %>C"><%= Server.HtmlEncode(reader["OptionC"].ToString()) %></label>
        </div>
        <div class="form-check my-1">
            <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="D" id="q<%= qNo %>D">
            <label class="form-check-label" for="q<%= qNo %>D"><%= Server.HtmlEncode(reader["OptionD"].ToString()) %></label>
        </div>
    </div>
<%
            qNo++;
        }
        reader.Close();
%>
    <input type="hidden" name="totalQuestions" value="<%= qNo - 1 %>" />
    <button type="submit" class="btn btn-primary fixed-submit">Submit</button>
</form>
<%
    }
%>

</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
