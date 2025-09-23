<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GetQuestions.aspx.cs" Inherits="online_exam_portal.GetQuestions" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%
    int subjectID = 0;
    if (!string.IsNullOrEmpty(Request.QueryString["SubjectID"]))
    {
        subjectID = Convert.ToInt32(Request.QueryString["SubjectID"]);
    }

    string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";
    using (SqlConnection con = new SqlConnection(connStr))
    {
        string query = "SELECT QuestionID, QuestionText, OptionA, OptionB, OptionC, OptionD FROM Questions WHERE SubjectID=@sid";
        SqlCommand cmd = new SqlCommand(query, con);
        cmd.Parameters.AddWithValue("@sid", subjectID);
        con.Open();
        SqlDataReader reader = cmd.ExecuteReader();

        int qNo = 1;
        while (reader.Read())
        {
%>
    <div class="card mb-3 p-3">
        <h5><%= qNo %>. <%= Server.HtmlEncode(reader["QuestionText"].ToString()) %></h5>
        <div class="form-check">
            <input class="form-check-input" type="radio" name="q<%= reader["QuestionID"] %>" value="A" id="q<%= reader["QuestionID"] %>A">
            <label class="form-check-label" for="q<%= reader["QuestionID"] %>A"><%= Server.HtmlEncode(reader["OptionA"].ToString()) %></label>
        </div>
        <div class="form-check">
            <input class="form-check-input" type="radio" name="q<%= reader["QuestionID"] %>" value="B" id="q<%= reader["QuestionID"] %>B">
            <label class="form-check-label" for="q<%= reader["QuestionID"] %>B"><%= Server.HtmlEncode(reader["OptionB"].ToString()) %></label>
        </div>
        <div class="form-check">
            <input class="form-check-input" type="radio" name="q<%= reader["QuestionID"] %>" value="C" id="q<%= reader["QuestionID"] %>C">
            <label class="form-check-label" for="q<%= reader["QuestionID"] %>C"><%= Server.HtmlEncode(reader["OptionC"].ToString()) %></label>
        </div>
        <div class="form-check">
            <input class="form-check-input" type="radio" name="q<%= reader["QuestionID"] %>" value="D" id="q<%= reader["QuestionID"] %>D">
            <label class="form-check-label" for="q<%= reader["QuestionID"] %>D"><%= Server.HtmlEncode(reader["OptionD"].ToString()) %></label>
        </div>
    </div>
<%
            qNo++;
        }
        reader.Close();
    }
%>
