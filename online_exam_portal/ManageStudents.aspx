<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<%
    // 🔒 Admin login check
    if (Session["AdminEmail"] == null)
    {
        Response.Redirect("AdminLogin.aspx");
    }

    string connStr = @"Data Source=LAPTOP-J203V7TL\SQLEXPRESS;Initial Catalog=OnlineExamDB;Trusted_Connection=True;";
    SqlConnection con = new SqlConnection(connStr);
    con.Open();

    // Handle Delete
    if(Request.QueryString["delete"] != null)
    {
        int deleteId = Convert.ToInt32(Request.QueryString["delete"]);
        SqlCommand cmdDel = new SqlCommand("DELETE FROM Users WHERE UserID=@UserID", con);
        cmdDel.Parameters.AddWithValue("@UserID", deleteId);
        cmdDel.ExecuteNonQuery();
        Response.Redirect("ManageStudents.aspx");
    }

    // Handle Add/Edit form submission
    if(Request.HttpMethod == "POST")
    {
        string fullName = Request.Form["FullName"];
        string email = Request.Form["Email"];
        string password = Request.Form["Password"];
        string userId = Request.Form["UserID"];

        if(!string.IsNullOrEmpty(userId) && userId != "0") // Edit
        {
            SqlCommand cmdUpdate = new SqlCommand(
                "UPDATE Users SET FullName=@FullName, Email=@Email, Password=@Password WHERE UserID=@UserID", con
            );
            cmdUpdate.Parameters.AddWithValue("@FullName", fullName);
            cmdUpdate.Parameters.AddWithValue("@Email", email);
            cmdUpdate.Parameters.AddWithValue("@Password", password);
            cmdUpdate.Parameters.AddWithValue("@UserID", Convert.ToInt32(userId));
            cmdUpdate.ExecuteNonQuery();
        }
        else // Add
        {
            SqlCommand cmdInsert = new SqlCommand(
                "INSERT INTO Users (FullName, Email, Password, RegistrationDate) VALUES (@FullName, @Email, @Password, GETDATE())", con
            );
            cmdInsert.Parameters.AddWithValue("@FullName", fullName);
            cmdInsert.Parameters.AddWithValue("@Email", email);
            cmdInsert.Parameters.AddWithValue("@Password", password);
            cmdInsert.ExecuteNonQuery();
        }

        Response.Redirect("ManageStudents.aspx");
    }

    // Handle Edit
    int editId = 0;
    string editName = "";
    string editEmail = "";
    string editPassword = "";

    if(Request.QueryString["edit"] != null)
    {
        editId = Convert.ToInt32(Request.QueryString["edit"]);
        SqlCommand cmdEdit = new SqlCommand("SELECT * FROM Users WHERE UserID=@UserID", con);
        cmdEdit.Parameters.AddWithValue("@UserID", editId);
        SqlDataReader reader = cmdEdit.ExecuteReader();
        if(reader.Read())
        {
            editName = reader["FullName"].ToString();
            editEmail = reader["Email"].ToString();
            editPassword = reader["Password"].ToString();
        }
        reader.Close();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Students - Admin Panel</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
<div class="container py-4">

    <h2 class="mb-4">👨‍🎓 Manage Students</h2>

    <!-- Add/Edit Student Form -->
    <div class="card mb-4 shadow-sm p-3">
        <form method="post">
            <input type="hidden" name="UserID" value="<%= editId %>" />
            <div class="row g-2">
                <div class="col-md-4">
                    <input type="text" name="FullName" class="form-control" placeholder="Full Name" value="<%= editName %>" required />
                </div>
                <div class="col-md-4">
                    <input type="email" name="Email" class="form-control" placeholder="Email" value="<%= editEmail %>" required />
                </div>
                <div class="col-md-3">
                    <input type="text" name="Password" class="form-control" placeholder="Password" value="<%= editPassword %>" required />
                </div>
                <div class="col-md-1 d-grid">
                    <button type="submit" class="btn btn-success"><%= editId > 0 ? "Update" : "Add" %></button>
                </div>
            </div>
        </form>
    </div>

    <!-- Students Table -->
    <table class="table table-bordered table-hover shadow-sm">
        <thead class="table-dark">
            <tr>
                <th>#</th>
                <th>Full Name</th>
                <th>Email</th>
                <th>Password</th>
                <th>Registration Date</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
                SqlCommand cmdUsers = new SqlCommand("SELECT * FROM Users ORDER BY UserID DESC", con);
                SqlDataReader rdr = cmdUsers.ExecuteReader();
                int sr = 1;
                while(rdr.Read())
                {
            %>
            <tr>
                <td><%= sr++ %></td>
                <td><%= rdr["FullName"] %></td>
                <td><%= rdr["Email"] %></td>
                <td><%= rdr["Password"] %></td>
                <td><%= Convert.ToDateTime(rdr["RegistrationDate"]).ToString("yyyy-MM-dd") %></td>
                <td>
                    <a href="ManageStudents.aspx?edit=<%= rdr["UserID"] %>" class="btn btn-sm btn-primary">Edit</a>
                    <a href="ManageStudents.aspx?delete=<%= rdr["UserID"] %>" onclick="return confirm('Are you sure?');" class="btn btn-sm btn-danger">Delete</a>
                </td>
            </tr>
            <%
                }
                rdr.Close();
                con.Close();
            %>
        </tbody>
    </table>
</div>
</body>
</html>
