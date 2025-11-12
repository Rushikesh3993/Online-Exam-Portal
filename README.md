# Online Exam Portal

## Overview  
This web-based exam platform lets students register, log in, take exams, and view their results. Administrators can create and manage exams and questions.

## Tech Stack  
- ASP.NET (C#)  
- ADO.NET  
- SQL Server  
- Bootstrap (for UI styling)  

## Features  
- Student registration and login with session handling  
- Admin module to manage Exams, Questions, and Results  
- CRUD operations implemented using ADO.NET and parameterized SQL queries  
- Responsive UI built with Bootstrap  
- Secure login using session variables  
- Relational database design with tables for Users, Exams, Questions, Results  

## Database Schema (simplified)  
- Users (UserID, FullName, Email, Password, Role, etc.)  
- Exams (ExamID, Title, Description, TimeLimit, etc.)  
- Questions (QuestionID, ExamID, Text, Option1, Option2, Option3, Option4, CorrectOption)  
- Results (ResultID, UserID, ExamID, Score, DateTaken, etc.)  

## How to Run  
1. Clone the repository:  
   ```bash  
   git clone https://github.com/Rushikesh3993/Online-Exam-Portal.git  
