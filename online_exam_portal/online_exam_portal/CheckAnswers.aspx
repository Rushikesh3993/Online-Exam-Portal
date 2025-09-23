<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CheckAnswers.aspx.cs" Inherits="online_exam_portal.CheckAnswers" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%
int score = 0;
string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";

using (SqlConnection con = new SqlConnection(connStr))
{
    con.Open();
    foreach (string key in Request.Form.Keys)
    {
        int qid = Convert.ToInt32(key.Substring(1)); // e.g., q1, q2 → 1,2
        string selected = Request.Form[key];

        SqlCommand cmd = new SqlCommand("SELECT CorrectOption FROM Questions WHERE QuestionID=@qid", con);
        cmd.Parameters.AddWithValue("@qid", qid);

        string correct = cmd.ExecuteScalar()?.ToString();
        if (correct == selected) score++;
    }
}

Response.Write(score); // This will be displayed in the result div on the dashboard
%>
