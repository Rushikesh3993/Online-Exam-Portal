<%@ Page Language="C#" AutoEventWireup="true" %>
 <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />

<%@ Import Namespace="System.Data.SqlClient" %>
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
        attemptsToday = Convert.ToInt32(cmdAttempts.ExecuteScalar());
    }

    if (attemptsToday >= 2)
    {
%>

<div class="d-flex justify-content-center align-items-center vh-100" style="background: #f0f2f5;">
    <div class="card text-center p-5 shadow-lg" 
         style="max-width: 450px; border-radius: 20px; 
                background: linear-gradient(135deg, #ff9a9e 0%, #fad0c4 100%);
                color: #343a40; box-shadow: 0 15px 25px rgba(0,0,0,0.2);">
        
        <!-- Warning Icon -->
        <div class="mb-4" style="font-size: 4rem; color: #ff4c4c;">❌</div>

        <!-- Heading -->
        <h3 class="mb-3" style="font-weight: 700;">Exam Attempt Limit Reached</h3>

        <!-- Message -->
        <p class="mb-4" style="font-size: 1rem; line-height: 1.5; color: #2c2c2c;">
            You have already attempted this exam <strong><%= attemptsToday %> times</strong> today.<br/>
            You cannot attempt again until tomorrow.
        </p>

        <!-- Button -->
        <a href="dashboard.aspx" 
           class="btn btn-lg" 
           style="background: #6a11cb; 
                  background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
                  color: #fff; 
                  border-radius: 50px; 
                  padding: 0.8rem 2.2rem; 
                  font-weight: 600; 
                  text-decoration: none;
                  box-shadow: 0 5px 15px rgba(0,0,0,0.3);
                  transition: all 0.3s ease-in-out;">
           ⬅ Back to Dashboard
        </a>
    </div>
</div>

<style>
    .btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 20px rgba(0,0,0,0.35);
    }
</style>




<%
        return; // Stop rendering questions
    }

    // Set start time for the exam if not already set
    if (Session["ExamStartTime"] == null)
    {
        Session["ExamStartTime"] = DateTime.Now;
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

