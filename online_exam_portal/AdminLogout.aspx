<%@ Page Language="C#" AutoEventWireup="true" %>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Logout - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            background: #f0f2f5;
            font-family: 'Segoe UI', sans-serif;
            height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .logout-box {
            max-width: 450px;
            width: 90%;
            padding: 30px;
            background: #fff;
            border-radius: 15px;
            box-shadow: 0px 8px 25px rgba(0,0,0,0.1);
            text-align: center;
        }

        .logout-icon {
            font-size: 3rem;
            color: #dc3545;
            margin-bottom: 15px;
        }

        .btn-login {
            display: inline-block;
            background: linear-gradient(135deg, #6a11cb, #2575fc);
            color: #fff;
            font-weight: 600;
            border-radius: 50px;
            padding: 10px 25px;
            text-decoration: none;
            transition: 0.3s;
            margin-top: 15px;
        }

        .btn-login:hover {
            background: linear-gradient(135deg, #2575fc, #6a11cb);
            transform: scale(1.05);
        }
    </style>
</head>
<body>
    <div class="logout-box">
        <div class="logout-icon">👋</div>
        <h3>Admin Logged Out Successfully!</h3>
        <p class="text-muted">Thank you for managing the Online Exam Portal.</p>
        <a href="AdminLogin.aspx" class="btn-login">🔑 Admin Login</a>
    </div>

    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
        }
    </script>
</body>
</html>
