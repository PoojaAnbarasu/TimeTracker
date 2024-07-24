<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.HttpSession" %>
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
    <meta charset="UTF-8">
    <title>Add Task</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .container {
            width: 80%;
            margin: auto;
            padding: 20px;
            text-align: center;
        }
        form {
            background-color: #f2f2f2;
            padding: 20px;
            border-radius: 10px;
        }
        label {
            font-weight: bold;
            display: block;
            width: 100%;
            margin-top: 10px;
        }
        input[type="text"], input[type="number"], input[type="date"], textarea {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border-radius: 5px;
            border: 1px solid #ccc;
            box-sizing: border-box;
        }
        input[type="submit"] {
            background-color: #008080;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            width: 100%;
        }
        input[type="submit"]:hover {
            background-color: #006666;
        }
        .error {
            color: red;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Add Task</h1>
        <form action="addTask.jsp" method="post">
            <label for="date">Date:</label>
            <input type="date" id="date" name="date" required>

            <label for="timeDuration">Time Duration (hours):</label>
            <input type="number" id="timeDuration" name="timeDuration" min="1" max="8" required>

            <label for="taskCategory">Task Category:</label>
            <input type="text" id="taskCategory" name="taskCategory" required>

            <label for="description">Description:</label>
            <textarea id="description" name="description" rows="4" required></textarea>

            <input type="submit" value="Add Task">
        </form>
        <%
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String date = request.getParameter("date");
                String timeDurationStr = request.getParameter("timeDuration");
                String taskCategory = request.getParameter("taskCategory");
                String description = request.getParameter("description");

                int timeDuration = 0;
                try {
                    timeDuration = Integer.parseInt(timeDurationStr);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                    out.println("<p class='error'>Invalid time duration.</p>");
                    return;
                }

                // Back-end validation for time duration
                if (timeDuration < 1 || timeDuration > 8) {
                    out.println("<p class='error'>Time duration must be between 1 and 8 hours.</p>");
                    return; // Stop processing
                }

                Connection conn = null;
                PreparedStatement pstmt = null;

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");
                    String sql = "INSERT INTO tasks (date, timeDuration, taskCategory, description, username) VALUES (?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, date);
                    pstmt.setInt(2, timeDuration);
                    pstmt.setString(3, taskCategory);
                    pstmt.setString(4, description);
                    pstmt.setString(5, username);

                    int rowsAffected = pstmt.executeUpdate();

                    if (rowsAffected > 0) {
                        out.println("<p>Task added successfully!</p>");
                    } else {
                        out.println("<p class='error'>Failed to add task.</p>");
                    }

                } catch (SQLException | ClassNotFoundException e) {
                    e.printStackTrace();
                    out.println("<p class='error'>Database error: " + e.getMessage() + "</p>");
                } finally {
                    try {
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        %>
    </div>
</body>
</html>