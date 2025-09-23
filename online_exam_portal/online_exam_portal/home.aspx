<%@ Import Namespace="System.Data.SqlClient" %>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="home.aspx.cs" Inherits="online_exam_portal.home" %>


<!DOCTYPE html>
<html>
<head>
    <title>Online Exam Portal - Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-light">

    <div class="container" style="max-width: 400px; margin-top: 100px;">
        <div class="card p-4 shadow">
            <h3 class="text-center mb-3">Student Login</h3>

            <form method="post">
                <div class="mb-3">
                    <label>Email</label>
                    <input type="email" name="email" class="form-control" placeholder="Enter email" required />
                </div>
                <div class="mb-3">
                    <label>Password</label>
                    <input type="password" name="password" class="form-control" placeholder="Enter password" required />
                </div>
                <button type="submit" class="btn btn-primary w-100">Login</button>
            </form>

            <div class="mt-3 text-center text-danger">

                <%
                    if (!String.IsNullOrEmpty(Request.Form["email"]) && !String.IsNullOrEmpty(Request.Form["password"]))
                    {
                        string email = Request.Form["email"];
                        string pass = Request.Form["password"];
                        string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";

                        using (SqlConnection con = new SqlConnection(connStr))
                        {
                            string query = "SELECT FullName FROM Users WHERE Email=@e AND Password=@p";
                            SqlCommand cmd = new SqlCommand(query, con);
                            cmd.Parameters.AddWithValue("@e", email);
                            cmd.Parameters.AddWithValue("@p", pass);
                            con.Open();
                            object name = cmd.ExecuteScalar();

                            if (name != null)
                            {
                                Session["FullName"] = name.ToString();
                                Session["Email"] = email;
                                Response.Redirect("dashboard.aspx");
                            }
                            else
                            {
                                Response.Write("Invalid email or password");
                            }
                        }
                    }
                %>


                
            </div>
        </div>
    </div>

</body>
</html>

