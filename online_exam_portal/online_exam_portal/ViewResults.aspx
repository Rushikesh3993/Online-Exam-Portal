<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<%
    // 🔒 Redirect if not logged in
    if (Session["Email"] == null)
    {
        Response.Redirect("LoginExam.aspx");
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Results - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            background-color: #f8f9fa;
            font-family: Arial, sans-serif;
            padding: 30px;
        }
        .result-box {
            background: #fff;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0px 4px 10px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="result-box">
            <h3 class="mb-4 text-center">📊 My Exam Results</h3>
            <table class="table table-striped table-bordered">
                <thead class="table-dark">
                    <tr>
                        <th>#</th>
                        <th>Subject</th>
                        <th>Score</th>
                        <th>Total Questions</th>
                        <th>Percentage</th>
                        <th>Time Taken</th>
                        <th>Attempt Date</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        int userID = 0;
                        string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";
                        bool hasResults = false;

                        using (SqlConnection con = new SqlConnection(connStr))
                        {
                            con.Open();
                            SqlCommand cmdUser = new SqlCommand("SELECT UserID FROM Users WHERE Email=@Email", con);
                            cmdUser.Parameters.AddWithValue("@Email", Session["Email"].ToString());
                            userID = Convert.ToInt32(cmdUser.ExecuteScalar());

                            SqlCommand cmd = new SqlCommand(
                                "SELECT TR.Score, TR.TotalQuestions, TR.StartTime, TR.EndTime, S.SubjectName " +
                                "FROM TestResults TR INNER JOIN Subjects S ON TR.SubjectID = S.SubjectID " +
                                "WHERE TR.UserID=@UserID ORDER BY TR.TestDate DESC", con
                            );
                            cmd.Parameters.AddWithValue("@UserID", userID);
                            SqlDataReader reader = cmd.ExecuteReader();
                            int no = 1;
                            while (reader.Read())
                            {
                                hasResults = true;
                                int score = Convert.ToInt32(reader["Score"]);
                                int totalQ = Convert.ToInt32(reader["TotalQuestions"]);
                                double percentage = ((double)score / totalQ) * 100;

                                TimeSpan duration = (DateTime)reader["EndTime"] - (DateTime)reader["StartTime"];
                                string durationFormatted = duration.Hours > 0
                                    ? $"{duration.Hours} hr {duration.Minutes} min {duration.Seconds} sec"
                                    : $"{duration.Minutes} min {duration.Seconds} sec";
                    %>
                    <tr>
                        <td><%= no %></td>
                        <td><%= reader["SubjectName"].ToString() %></td>
                        <td><%= score %></td>
                        <td><%= totalQ %></td>
                        <td><%= percentage.ToString("0.00") %>%</td>
                        <td><%= durationFormatted %></td>
                        <td><%= Convert.ToDateTime(reader["StartTime"]).ToString("dd-MM-yyyy HH:mm") %></td>
                    </tr>
                    <%
                                no++;
                            }
                            reader.Close();
                        }

                        if (!hasResults)
                        {
                    %>
                    <tr>
                        <td colspan="7" class="text-center text-muted">No exam attempts yet.</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>

            <div class="text-center mt-3">
                <a href="dashboard.aspx" class="btn btn-primary">⬅ Back to Dashboard</a>
            </div>
        </div>
    </div>
</body>
</html>
