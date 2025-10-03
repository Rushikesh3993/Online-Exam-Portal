<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />

<%
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
    int attemptsToday = 0;

    using (SqlConnection con = new SqlConnection(connStr))
    {
        con.Open();

        SqlCommand cmdUser = new SqlCommand("SELECT UserID FROM Users WHERE Email=@Email", con);
        cmdUser.Parameters.AddWithValue("@Email", Session["Email"].ToString());
        userID = Convert.ToInt32(cmdUser.ExecuteScalar());

        SqlCommand cmdAttempts = new SqlCommand(
            "SELECT COUNT(*) FROM TestResults WHERE UserID=@UserID AND SubjectID=@SubjectID AND CAST(TestDate AS DATE)=CAST(GETDATE() AS DATE)", con
        );
        cmdAttempts.Parameters.AddWithValue("@UserID", userID);
        cmdAttempts.Parameters.AddWithValue("@SubjectID", subjectID);
        attemptsToday = Convert.ToInt32(cmdAttempts.ExecuteScalar());
    }

    if (attemptsToday >= 2)
    {
%>

<div class="d-flex justify-content-center align-items-center vh-100 bg-light">
    <div class="card text-center shadow-lg border-0 p-5"
         style="max-width: 480px; border-radius: 20px; background: #fff;">
        
        <div class="mb-4" style="font-size: 3.5rem; color: #ff4c4c;">🚫</div>
        <h3 class="fw-bold text-danger">Attempt Limit Reached</h3>
        <p class="mt-3 text-muted">
            You have already attempted this exam <b><%= attemptsToday %></b> times today. <br>
            Please try again tomorrow.
        </p>

        <a href="dashboard.aspx" class="btn btn-primary btn-lg mt-3 px-4 py-2 rounded-pill shadow">
            ⬅ Back to Dashboard
        </a>
    </div>
</div>

<%
        return;
    }

    if (Session["ExamStartTime"] == null)
    {
        Session["ExamStartTime"] = DateTime.Now;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Exam - Online Exam Portal</title>
    <style>
        body {
            background: #f0f2f5;
            font-family: 'Segoe UI', sans-serif;
        }
        .exam-header {
            background: linear-gradient(135deg, #2575fc, #6a11cb);
            color: white;
            padding: 20px;
            border-radius: 15px;
            text-align: center;
            margin-bottom: 20px;
        }
        .timer-box {
            font-size: 1.3rem;
            font-weight: bold;
            background: #fff3cd;
            color: #856404;
            border: 2px dashed #ffc107;
            border-radius: 10px;
            padding: 10px 20px;
            display: inline-block;
            margin-top: 10px;
        }
        .question-card {
            background: #fff;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid #eee;
            transition: all 0.3s ease;
        }
        .question-card:hover {
            box-shadow: 0 6px 15px rgba(0,0,0,0.1);
            transform: translateY(-3px);
        }
        .btn-submit {
            background: linear-gradient(135deg, #28a745, #20c997);
            border: none;
            padding: 12px 35px;
            border-radius: 50px;
            font-weight: 600;
            color: #fff;
            transition: 0.3s;
        }
        .btn-submit:hover {
            background: linear-gradient(135deg, #20c997, #28a745);
            transform: scale(1.05);
            box-shadow: 0 8px 20px rgba(0,0,0,0.25);
        }
    </style>
</head>
<body>
    <div class="container py-4">

        <!-- Exam Header -->
        <div class="exam-header shadow">
            <h2 class="fw-bold">📘 Online Exam</h2>
            <div class="timer-box" id="timer">⏳ Time Left: 15:00</div>
        </div>

        <form id="examForm" method="post" action="CheckAnswers.aspx">
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

            <div class="question-card shadow-sm">
                <h6 class="fw-bold mb-3"><%= qNo %>. <%= Server.HtmlEncode(reader["QuestionText"].ToString()) %></h6>

                <input type="hidden" name="qid<%= qNo %>" value="<%= reader["QuestionID"] %>" />

                <div class="form-check mb-2">
                    <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="A" id="q<%= qNo %>A" required>
                    <label class="form-check-label" for="q<%= qNo %>A"><%= Server.HtmlEncode(reader["OptionA"].ToString()) %></label>
                </div>
                <div class="form-check mb-2">
                    <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="B" id="q<%= qNo %>B" required>
                    <label class="form-check-label" for="q<%= qNo %>B"><%= Server.HtmlEncode(reader["OptionB"].ToString()) %></label>
                </div>
                <div class="form-check mb-2">
                    <input class="form-check-input" type="radio" name="ans<%= qNo %>" value="C" id="q<%= qNo %>C" required>
                    <label class="form-check-label" for="q<%= qNo %>C"><%= Server.HtmlEncode(reader["OptionC"].ToString()) %></label>
                </div>
                <div class="form-check">
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

            <input type="hidden" name="totalQuestions" value="<%= totalQuestions %>" />

            <div class="text-center">
                <button type="submit" class="btn-submit mt-3">✅ Submit Exam</button>
            </div>
        </form>
    </div>

    <script>
        // 15 minutes countdown
        var totalTime = 15 * 60; // 15 minutes in seconds
        var timerDisplay = document.getElementById("timer");
        var examForm = document.getElementById("examForm");

        function startTimer() {
            var countdown = setInterval(function () {
                var minutes = Math.floor(totalTime / 60);
                var seconds = totalTime % 60;

                timerDisplay.innerHTML = "⏳ Time Left: " + 
                    (minutes < 10 ? "0" + minutes : minutes) + ":" + 
                    (seconds < 10 ? "0" + seconds : seconds);

                totalTime--;

                if (totalTime < 0) {
                    clearInterval(countdown);
                    alert("⏰ Time is up! Submitting your exam.");
                    examForm.submit();
                }
            }, 1000);
        }

        startTimer();
    </script>
</body>
</html>