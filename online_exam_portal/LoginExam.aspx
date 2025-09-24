<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>
<html>
<head>
    <title>Login - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card shadow p-4">
                <h3 class="text-center mb-4">Login to Online Exam Portal</h3>
                <form method="post">
                    <div class="mb-3">
                        <label>Email</label>
                        <input type="email" name="email" class="form-control" required />
                    </div>
                    <div class="mb-3">
                        <label>Password</label>
                        <input type="password" name="password" class="form-control" required />
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Login</button>
                </form>

                <%
                    if(Request.HttpMethod == "POST") 
                    {
                        string email = Request.Form["email"];
                        string password = Request.Form["password"];
                        string cs = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";

                        using(SqlConnection con = new SqlConnection(cs))
                        {
                            con.Open();
                            SqlCommand cmd = new SqlCommand("SELECT UserID, FullName FROM Users WHERE Email=@e AND Password=@p", con);
                            cmd.Parameters.AddWithValue("@e", email);
                            cmd.Parameters.AddWithValue("@p", password);
                            SqlDataReader reader = cmd.ExecuteReader();

                            if(reader.Read())
                            {
                                int userID = Convert.ToInt32(reader["UserID"]);
                                string fullName = reader["FullName"].ToString();
                                reader.Close();

                                // ✅ Set session variables
                                Session["UserID"] = userID;
                                Session["Email"] = email;
                                Session["FullName"] = fullName;

                                Response.Redirect("dashboard.aspx"); // go to dashboard
                            }
                            else
                            {
                                Response.Write("<div class='alert alert-danger mt-3'>Invalid email or password.</div>");
                            }
                        }
                    }
                %>
            </div>
        </div>
    </div>
</div>
</body>
</html>
