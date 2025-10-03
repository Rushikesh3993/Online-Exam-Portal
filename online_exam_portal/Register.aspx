<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<%
    string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";
    string message = "";

    if (Request.HttpMethod == "POST") // check form submission
    {
        string fullName = Request.Form["txtName"];
        string email = Request.Form["txtEmail"];
        string password = Request.Form["txtPassword"];
        string confirmPassword = Request.Form["txtConfirmPassword"];

        if (password != confirmPassword)
        {
            message = "❌ Passwords do not match!";
        }
        else
        {
            using (SqlConnection con = new SqlConnection(connStr))
            {
                con.Open();

                // Check if email exists
                SqlCommand checkCmd = new SqlCommand("SELECT COUNT(*) FROM Users WHERE Email=@Email", con);
                checkCmd.Parameters.AddWithValue("@Email", email);
                int exists = (int)checkCmd.ExecuteScalar();

                if (exists > 0)
                {
                    message = "❌ Email already registered!";
                }
                else
                {
                    SqlCommand cmd = new SqlCommand("INSERT INTO Users (FullName, Email, Password) VALUES (@Name, @Email, @Password)", con);
                    cmd.Parameters.AddWithValue("@Name", fullName);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@Password", password);
                    cmd.ExecuteNonQuery();

                    Response.Redirect("LoginExam.aspx?registered=1");
                }
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Register - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background-color: #f0f2f5; }
        .register-box {
            max-width: 500px;
            margin: 70px auto;
            background: #fff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="register-box">
            <h3 class="text-center mb-4">📝 Student Registration</h3>

            <% if (message != "") { %>
                <div class="alert alert-danger text-center"><%= message %></div>
            <% } %>

            <form method="post">
                <div class="mb-3">
                    <label class="form-label">Full Name</label>
                    <input type="text" name="txtName" class="form-control" required />
                </div>

                <div class="mb-3">
                    <label class="form-label">Email</label>
                    <input type="email" name="txtEmail" class="form-control" required />
                </div>

                <div class="mb-3">
                    <label class="form-label">Password</label>
                    <input type="password" name="txtPassword" class="form-control" required />
                </div>

                <div class="mb-3">
                    <label class="form-label">Confirm Password</label>
                    <input type="password" name="txtConfirmPassword" class="form-control" required />
                </div>

                <div class="d-grid">
                    <button type="submit" class="btn btn-success">Register</button>
                </div>
            </form>

            <div class="text-center mt-3">
                Already have an account? <a href="LoginExam.aspx">Login here</a>
            </div>
        </div>
    </div>
</body>
</html>
