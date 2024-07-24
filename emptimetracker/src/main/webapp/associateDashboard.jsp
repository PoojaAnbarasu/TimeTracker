<%@ page import="javax.servlet.http.HttpSession" %>
<%
    HttpSession userSession = request.getSession(false);
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Associate Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .navbar {
            background-color: #333;
            overflow: hidden;
        }
        .navbar a {
            float: left;
            display: block;
            color: #f2f2f2;
            text-align: center;
            padding: 14px 16px;
            text-decoration: none;
        }
        .navbar a:hover {
            background-color: #ddd;
            color: black;
        }
        .container {
            width: 80%;
            margin: 0 auto;
            padding: 20px;
        }
        h1 {
            text-align: center;
            margin-top: 20px;
        }
        .buttons {
            margin-top: 30px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .buttons button {
            background-color: #4CAF50;
            color: white;
            padding: 15px 20px;
            margin: 10px 0;
            border: none;
            cursor: pointer;
            border-radius: 4px;
            font-size: 16px;
            width: 200px;
        }
        .buttons button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <a href="associateDashboard.jsp">Home</a>
        <a href="logout.jsp" style="float:right;">Logout</a>
    </div>
    <div class="container">
        <h1>Welcome, <%= username %></h1>
        <div class="buttons">
            <button onclick="location.href='addTask.jsp'">Add Task</button>
            <button onclick="location.href='viewTasks.jsp'">View Tasks</button>
            <button onclick="location.href='viewReports.jsp'">View Reports</button>
        </div>
    </div>
</body>
</html>