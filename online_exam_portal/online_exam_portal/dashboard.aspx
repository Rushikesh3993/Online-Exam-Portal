<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="dashboard.aspx.cs" Inherits="online_exam_portal.dashboard" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard - Online Exam Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        body { font-family: Arial, sans-serif; background-color: #f8f9fa; }
        .sidebar { height: 100vh; background-color: #1c1f23; color: white; padding: 20px; position: fixed; top: 0; left: 0; width: 220px; }
        .sidebar a { color: #cfd2d6; text-decoration: none; display: block; padding: 10px; margin: 5px 0; border-radius: 5px; }
        .sidebar a:hover { background-color: #007bff; color: white; }
        .sidebar i { margin-right: 10px; }
        .main { margin-left: 240px; padding: 20px; }
        .card-custom { border-radius: 10px; transition: transform 0.2s; min-height: 150px; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; color: white; cursor: pointer; }
        .card-custom:hover { transform: scale(1.05); }
        #questionsContainer .card { background-color: #fff; color: #000; }
    </style>
</head>
<body>

<div class="sidebar">
    <h5 class="mb-4"><i class="fa-solid fa-user"></i> <%= Session["FullName"] != null ? Session["FullName"].ToString() : "User" %></h5>
    <a href="#"><i class="fa-solid fa-gauge"></i> Dashboard</a>
    <a href="#"><i class="fa-solid fa-file-pen"></i> Exam</a>
    <a href="#"><i class="fa-solid fa-calendar-check"></i> Attendance</a>
    <a href="logout.aspx"><i class="fa-solid fa-right-from-bracket"></i> Logout</a>
</div>

<div class="main">
    <h3>Dashboard</h3>
    <div class="row g-3 mt-3">
        <!-- Subject cards -->
        <div class="col-md-4"><div class="card card-custom bg-danger p-3 subject-card" data-subjectid="1"><i class="fa-solid fa-code fa-2x mb-2"></i><h5>ASP.NET</h5><p>Click to load questions</p></div></div>
        <div class="col-md-4"><div class="card card-custom bg-primary p-3 subject-card" data-subjectid="2"><i class="fa-solid fa-database fa-2x mb-2"></i><h5>C Language</h5><p>Click to load questions</p></div></div>
        <div class="col-md-4"><div class="card card-custom bg-success p-3 subject-card" data-subjectid="3"><i class="fa-solid fa-laptop-code fa-2x mb-2"></i><h5>Java</h5><p>Click to load questions</p></div></div>
        <div class="col-md-4"><div class="card card-custom bg-warning p-3 subject-card" data-subjectid="4"><i class="fa-solid fa-terminal fa-2x mb-2"></i><h5>SQL</h5><p>Click to load questions</p></div></div>
        <div class="col-md-4"><div class="card card-custom bg-info p-3 subject-card" data-subjectid="5"><i class="fa-solid fa-cubes fa-2x mb-2"></i><h5>Web Designing</h5><p>Click to load questions</p></div></div>
    </div>

    <hr />
    <h4>Questions</h4>
    <form id="questionsForm">
        <div id="questionsContainer"></div>
        <button type="button" class="btn btn-success mt-3" id="submitBtn" style="display:none;">Submit Answers</button>
    </form>

    <div id="result" class="mt-3"></div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const cards = document.querySelectorAll('.subject-card');
    const container = document.getElementById('questionsContainer');
    const submitBtn = document.getElementById('submitBtn');
    const resultDiv = document.getElementById('result');

    cards.forEach(card => {
        card.addEventListener('click', () => {
            const subjectID = card.dataset.subjectid;
            fetch(`GetQuestions.aspx?SubjectID=${subjectID}`)
                .then(res => res.text())
                .then(html => {
                    container.innerHTML = html;
                    submitBtn.style.display = 'block';
                    resultDiv.innerHTML = '';
                })
                .catch(err => { container.innerHTML = '<p class="text-danger">Error loading questions</p>'; });
        });
    });

    submitBtn.addEventListener('click', () => {
        const formData = new FormData(document.getElementById('questionsForm'));
        let score = 0;

        // Loop over each question and compare answer
        fetch('CheckAnswers.aspx', {
            method: 'POST',
            body: formData
        })
            .then(res => res.text())
            .then(scoreText => {
                resultDiv.innerHTML = `<h5>Your Score: ${scoreText}</h5>`;
            })
            .catch(err => {
                resultDiv.innerHTML = '<p class="text-danger">Error submitting answers</p>';
            });
    });
</script>
</body>
</html>
