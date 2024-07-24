<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>

<%
    HttpSession userSession = request.getSession(false);
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int taskId = Integer.parseInt(request.getParameter("id"));
    Map<String, Object> task = new HashMap<>();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");

        String sql = "SELECT * FROM tasks WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, taskId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            task.put("id", rs.getInt("id"));
            task.put("employee_id", rs.getInt("employee_id"));
            task.put("project_id", rs.getInt("project_id"));
            task.put("date", rs.getDate("date"));
            task.put("timeDuration", rs.getString("timeDuration"));
            task.put("taskCategory", rs.getString("taskCategory"));
            task.put("description", rs.getString("description"));
        }
    } catch (SQLException | ClassNotFoundException e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Task</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .container {
            width: 50%;
            margin: 0 auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            text-align: center;
            margin-bottom: 20px;
        }
        form {
            display: flex;
            flex-direction: column;
        }
        label {
            margin: 10px 0 5px;
        }
        input, select, textarea {
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
            padding: 10px;
            border: none;
            border-radius: 4px;
            background-color: #008080;
            color: white;
            cursor: pointer;
        }
        button:hover {
            background-color: #006666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Edit Task</h1>
        <form method="post">
            <input type="hidden" name="id" value="<%= task.get("id") %>">
            <label for="employee">Employee</label>
            <select name="employee_id" id="employee">
                <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");
                        String sql = "SELECT id, name FROM employees";
                        pstmt = conn.prepareStatement(sql);
                        rs = pstmt.executeQuery();
                        while (rs.next()) {
                            int empId = rs.getInt("id");
                            String empName = rs.getString("name");
                            boolean selected = empId == (Integer) task.get("employee_id");
                %>
                            <option value="<%= empId %>" <%= selected ? "selected" : "" %>><%= empName %></option>
                <%
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        try { if (rs != null) rs.close(); if (pstmt != null) pstmt.close(); if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            </select>
            
            <label for="project">Project</label>
            <select name="project_id" id="project">
                <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");
                        String sql = "SELECT id, name FROM projects";
                        pstmt = conn.prepareStatement(sql);
                        rs = pstmt.executeQuery();
                        while (rs.next()) {
                            int projId = rs.getInt("id");
                            String projName = rs.getString("name");
                            boolean selected = projId == (Integer) task.get("project_id");
                %>
                            <option value="<%= projId %>" <%= selected ? "selected" : "" %>><%= projName %></option>
                <%
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        try { if (rs != null) rs.close(); if (pstmt != null) pstmt.close(); if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                %>
            </select>

            <label for="date">Date</label>
            <input type="date" name="date" id="date" value="<%= task.get("date") %>">
            
            <label for="timeDuration">Time Duration</label>
            <input type="text" name="timeDuration" id="timeDuration" value="<%= task.get("timeDuration") %>">

            <label for="taskCategory">Task Category</label>
            <input type="text" name="taskCategory" id="taskCategory" value="<%= task.get("taskCategory") %>">

            <label for="description">Description</label>
            <textarea name="description" id="description"><%= task.get("description") %></textarea>

            <button type="submit">Update Task</button>
        </form>
    </div>
<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        int employeeId = Integer.parseInt(request.getParameter("employee_id"));
        int projectId = Integer.parseInt(request.getParameter("project_id"));
        String date = request.getParameter("date");
        String timeDuration = request.getParameter("timeDuration");
        String taskCategory = request.getParameter("taskCategory");
        String description = request.getParameter("description");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");

            String sql = "UPDATE tasks SET employee_id = ?, project_id = ?, date = ?, timeDuration = ?, taskCategory = ?, description = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, employeeId);
            pstmt.setInt(2, projectId);
            pstmt.setString(3, date);
            pstmt.setString(4, timeDuration);
            pstmt.setString(5, taskCategory);
            pstmt.setString(6, description);
            pstmt.setInt(7, taskId);
            pstmt.executeUpdate();
            response.sendRedirect("adminViewTasks.jsp");
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            try { if (pstmt != null) pstmt.close(); if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
</body>
</html>