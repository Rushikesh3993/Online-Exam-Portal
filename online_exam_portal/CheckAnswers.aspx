<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Text" %>

<%
    // ensure logged in
    if (Session["Email"] == null)
    {
        Response.Redirect("LoginExam.aspx");
    }

    int subjectID = (Session["SubjectID"] != null) ? (int)Session["SubjectID"] : 0;
    string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";

    // resolve user id
    int userID = 0;
    using (SqlConnection con = new SqlConnection(connStr))
    {
        con.Open();
        SqlCommand cmdUser = new SqlCommand("SELECT UserID FROM Users WHERE Email=@Email", con);
        cmdUser.Parameters.AddWithValue("@Email", Session["Email"].ToString());
        object o = cmdUser.ExecuteScalar();
        if (o == null) { Response.Redirect("LoginExam.aspx"); }
        userID = Convert.ToInt32(o);
    }

    // OPTIONAL: re-check attempts (defense in depth)
    using (SqlConnection con = new SqlConnection(connStr))
    {
        con.Open();
        SqlCommand cmdAttempts = new SqlCommand(
            "SELECT COUNT(*) FROM TestResults WHERE UserID=@UserID AND SubjectID=@SubjectID AND CAST(TestDate AS DATE) = CAST(GETDATE() AS DATE)",
            con
        );
        cmdAttempts.Parameters.AddWithValue("@UserID", userID);
        cmdAttempts.Parameters.AddWithValue("@SubjectID", subjectID);
        int attemptsToday = Convert.ToInt32(cmdAttempts.ExecuteScalar());
        if (attemptsToday >= 2)
        {
            // user circumvented front-end — show friendly message and stop
            Response.Write("<div style='padding:40px;text-align:center;font-family:Arial,sans-serif;'><h3>Attempt limit reached</h3><p>You have already attempted this exam today.</p><a href='dashboard.aspx'>Back to Dashboard</a></div>");
            Response.End();
        }
    }

    // compute score + prepare detailed table
    int total = Convert.ToInt32(Request.Form["totalQuestions"]);
    DateTime startTime = (Session["ExamStartTime"] != null) ? (DateTime)Session["ExamStartTime"] : DateTime.Now;
    DateTime endTime = DateTime.Now;
    int score = 0;
    StringBuilder sb = new StringBuilder();

    sb.Append("<table class='table table-bordered mt-4'><thead class='table-light'><tr><th>Question</th><th>Your Answer</th><th>Correct Answer</th><th>Status</th></tr></thead><tbody>");

    using (SqlConnection con = new SqlConnection(connStr))
    {
        con.Open();
        for (int i = 1; i <= total; i++)
        {
            // qid hidden field was added in GetQuestions.aspx
            object qidObj = Request.Form["qid" + i];
            if (qidObj == null) continue;
            int qid = Convert.ToInt32(qidObj);
            string selected = Request.Form["ans" + i]; // may be null if not answered (but inputs are required in form)
            
            SqlCommand cmd = new SqlCommand("SELECT QuestionText, CorrectOption FROM Questions WHERE QuestionID=@qid", con);
            cmd.Parameters.AddWithValue("@qid", qid);
            SqlDataReader reader = cmd.ExecuteReader();
            if (reader.Read())
            {
                string qtext = reader["QuestionText"].ToString();
                string correct = reader["CorrectOption"].ToString();
                string selectedText = (selected == null) ? "Not Answered" : selected;
                string rowClass = "";
                string status = "";

                if (selected == null)
                {
                    rowClass = "table-warning";
                    status = "Not Answered";
                }
                else if (selected == correct)
                {
                    rowClass = "table-success";
                    status = "Correct";
                    score++;
                }
                else
                {
                    rowClass = "table-danger";
                    status = "Wrong";
                }

                sb.AppendFormat("<tr class='{0}'><td>{1}</td><td>{2}</td><td>{3}</td><td>{4}</td></tr>",
                                rowClass,
                                Server.HtmlEncode(qtext),
                                Server.HtmlEncode(selectedText),
                                Server.HtmlEncode(correct),
                                status);
            }
            reader.Close();
        }

        sb.Append("</tbody></table>");

        // Save result to DB
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

    // store final html snippet to emit below
    string detailsTableHtml = sb.ToString();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Exam Result - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background:#f8f9fa; font-family: Arial, sans-serif; }
        .result-box { background:#fff; border-radius:10px; padding:30px; margin-top:40px; box-shadow:0 4px 10px rgba(0,0,0,0.08); }
    </style>
</head>
<body>
    <div class="container">
        <div class="result-box">
            <h2 class="text-center mb-3">📊 Your Exam Score</h2>
            <p class="text-center">You answered <strong><%= score %> / <%= total %></strong> correctly.</p>
            <p class="text-center">⏱ Time Taken: <%= (endTime - startTime).Minutes %> minutes <%= (endTime - startTime).Seconds %> seconds</p>

            <%-- write the detailed table safely using Response.Write to avoid inline expression issues --%>
            <%
                Response.Write(detailsTableHtml);
            %>

            <div class="text-center mt-3">
                <a href="dashboard.aspx" class="btn btn-primary">⬅ Back to Dashboard</a>
            </div>
        </div>
    </div>
</body>
</html>
