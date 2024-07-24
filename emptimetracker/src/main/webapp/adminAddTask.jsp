<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>

<%
    HttpSession userSession = request.getSession(false);
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<String> employees = new ArrayList<>();
    List<String> projects = new ArrayList<>();
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");

        // Fetch employees
        pstmt = conn.prepareStatement("SELECT id, name FROM employees");
        rs = pstmt.executeQuery();
        while (rs.next()) {
            employees.add(rs.getString("id") + "-" + rs.getString("name"));
        }
        rs.close();
        pstmt.close();

        // Fetch projects
        pstmt = conn.prepareStatement("SELECT id, name FROM projects");
        rs = pstmt.executeQuery();
        while (rs.next()) {
            projects.add(rs.getString("id") + "-" + rs.getString("name"));
        }
        rs.close();
        pstmt.close();

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
    <title>Add Task</title>
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
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            font-weight: bold;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            border-radius: 4px;
            border: 1px solid #ccc;
        }
        .form-group button {
            padding: 15px;
            margin-top: 10px;
            width: 100%;
            border-radius: 4px;
            border: none;
            background-color: #008080;
            color: white;
            cursor: pointer;
            font-size: 16px;
        }
        .form-group button:hover {
            background-color: #006666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Add Task</h1>
        <form action="adminAddTask.jsp" method="post">
            <div class="form-group">
                <label for="employee">Employee:</label>
                <select id="employee" name="employee">
                    <% for (String employee : employees) { %>
                        <option value="<%= employee.split("-")[0] %>"><%= employee.split("-")[1] %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label for="project">Project:</label>
                <select id="project" name="project">
                    <% for (String project : projects) { %>
                        <option value="<%= project.split("-")[0] %>"><%= project.split("-")[1] %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label for="date">Date:</label>
                <input type="date" id="date" name="date" required>
            </div>
            <div class="form-group">
                <label for="timeDuration">Time Duration:</label>
                <input type="text" id="timeDuration" name="timeDuration" required>
            </div>
            <div class="form-group">
                <label for="taskCategory">Task Category:</label>
                <input type="text" id="taskCategory" name="taskCategory" required>
            </div>
            <div class="form-group">
                <label for="description">Description:</label>
                <textarea id="description" name="description" rows="4" required></textarea>
            </div>
            <div class="form-group">
                <button type="submit">Add Task</button>
            </div>
        </form>

        <%
            if (request.getMethod().equalsIgnoreCase("post")) {
                String employeeId = request.getParameter("employee");
                String projectId = request.getParameter("project");
                String date = request.getParameter("date");
                String timeDuration = request.getParameter("timeDuration");
                String taskCategory = request.getParameter("taskCategory");
                String description = request.getParameter("description");

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");

                    String sql = "INSERT INTO tasks (employee_id, project_id, date, timeDuration, taskCategory, description) VALUES (?, ?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, Integer.parseInt(employeeId));
                    pstmt.setInt(2, Integer.parseInt(projectId));
                    pstmt.setDate(3, java.sql.Date.valueOf(date));
                    pstmt.setString(4, timeDuration);
                    pstmt.setString(5, taskCategory);
                    pstmt.setString(6, description);
                    pstmt.executeUpdate();

                    out.println("<p>Task added successfully!</p>");
                } catch (SQLException | ClassNotFoundException e) {
                    e.printStackTrace();
                    out.println("<p>Error adding task.</p>");
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