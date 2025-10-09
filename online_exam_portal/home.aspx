<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        body { font-family: Arial, sans-serif; }
        .hero { background-color: #007bff; color: white; padding: 100px 0; text-align: center; }
        .hero h1 { font-size: 3rem; }
        .features { padding: 60px 0; }
        .feature-card { border-radius: 10px; padding: 30px; transition: transform 0.3s; }
        .feature-card:hover { transform: scale(1.05); }
        .footer { background-color: #1c1f23; color: #cfd2d6; padding: 20px 0; text-align: center; margin-top: 50px; }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand" href="Home.aspx"><i class="fa-solid fa-graduation-cap"></i> Online Exam</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link" href="LoginExam.aspx"><i class="fa-solid fa-right-to-bracket"></i> Login</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="Dashboard.aspx"><i class="fa-solid fa-gauge"></i> Register</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Hero Section -->
<div class="hero">
    <div class="container">
        <h1>Welcome to Online Exam Portal</h1>
        <p class="lead">Practice and test your skills in ASP.NET, C, Java, SQL, and Web Design</p>
        <a href="LoginExam.aspx" class="btn btn-light btn-lg mt-3"><i class="fa-solid fa-arrow-right"></i> Start Exam</a>
    </div>
</div>

<!-- Features Section -->
<div class="features">
    <div class="container">
        <h2 class="text-center mb-5">Our Features</h2>
        <div class="row g-4">
            <div class="col-md-4">
                <div class="card feature-card text-center bg-primary text-white">
                    <i class="fa-solid fa-book fa-3x mb-3"></i>
                    <h5>Multiple Subjects</h5>
                    <p>Take exams in ASP.NET, C Language, Java, SQL, and Web Design.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card feature-card text-center bg-success text-white">
                    <i class="fa-solid fa-chart-line fa-3x mb-3"></i>
                    <h5>Track Performance</h5>
                    <p>View your previous attempts and monitor your progress over time.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card feature-card text-center bg-warning text-dark">
                    <i class="fa-solid fa-clock fa-3x mb-3"></i>
                    <h5>Time-bound Exams</h5>
                    <p>Practice under real exam conditions with time limits and scoring.</p>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Footer -->
<div class="footer">
    <div class="container">
        <p>&copy; 2025 Online Exam Portal. All Rights Reserved.</p>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
