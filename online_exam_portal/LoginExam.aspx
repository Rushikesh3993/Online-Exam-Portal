<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>
<html>
<head>
    <title>Login - Online Exam Portal</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />

    <style>
        body {
            background: url('image/img.jpg') no-repeat center center fixed;
            background-size: cover;
            font-family: 'Segoe UI', sans-serif;
            height: 100vh;
            margin: 0;
        }

        .card {
            background: rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            padding: 30px;
        }
    </style>
</head>
<body>

    <!-- Flex container to center content -->
    <div class="d-flex justify-content-center align-items-center vh-100">
        <div class="col-md-4">
            <div class="card shadow">
                <h3 class="text-center mb-4">Login to Online Exam Portal</h3>

                <!-- ✅ Show success message after registration -->
                <% 
                    if (Request.QueryString["registered"] == "1") 
                    { 
                %>
                    <div class="alert alert-success text-center">✅ Registration successful! Please login.</div>
                <% 
                    } 
                %>

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

                                Session["UserID"] = userID;
                                Session["Email"] = email;
                                Session["FullName"] = fullName;

                                Response.Redirect("dashboard.aspx");
                            }
                            else
                            {
                                Response.Write("<div class='alert alert-danger mt-3'>❌ Invalid email or password.</div>");
                            }
                        }
                    }
                %>

                <div class="text-center mt-3">
                    <a href="Register.aspx">📝 New student? Register here</a>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
