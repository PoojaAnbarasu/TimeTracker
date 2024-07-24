<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>

<%
    HttpSession userSession = request.getSession(false);
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Map<String, Object>> tasks = new ArrayList<>();
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");

        String sql = "SELECT t.id, e.name AS employee_name, p.name AS project_name, t.date, t.timeDuration, t.taskCategory, t.description " +
                     "FROM tasks t " +
                     "JOIN employees e ON t.employee_id = e.id " +
                     "JOIN projects p ON t.project_id = p.id";

        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> task = new HashMap<>();
            task.put("id", rs.getInt("id"));
            task.put("employee_name", rs.getString("employee_name"));
            task.put("project_name", rs.getString("project_name"));
            task.put("date", rs.getDate("date"));
            task.put("timeDuration", rs.getString("timeDuration"));
            task.put("taskCategory", rs.getString("taskCategory"));
            task.put("description", rs.getString("description"));
            tasks.add(task);
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
    <title>View Tasks</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .container {
            width: 80%;
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
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        table, th, td {
            border: 1px solid #ccc;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .actions {
            display: flex;
            gap: 10px;
        }
        .actions button {
            padding: 10px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .edit-btn {
            background-color: #008080;
            color: white;
        }
        .delete-btn {
            background-color: #e74c3c;
            color: white;
        }
        .edit-btn:hover {
            background-color: #006666;
        }
        .delete-btn:hover {
            background-color: #c0392b;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>View Tasks</h1>
        <table>
            <thead>
                <tr>
                    <th>Employee</th>
                    <th>Project</th>
                    <th>Date</th>
                    <th>Time Duration</th>
                    <th>Task Category</th>
                    <th>Description</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String, Object> task : tasks) { %>
                    <tr>
                        <td><%= task.get("employee_name") %></td>
                        <td><%= task.get("project_name") %></td>
                        <td><%= task.get("date") %></td>
                        <td><%= task.get("timeDuration") %></td>
                        <td><%= task.get("taskCategory") %></td>
                        <td><%= task.get("description") %></td>
                        <td class="actions">
                            <button class="edit-btn" onclick="editTask(<%= task.get("id") %>)">Edit</button>
                            <button class="delete-btn" onclick="deleteTask(<%= task.get("id") %>)">Delete</button>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <script>
        function editTask(taskId) {
            window.location.href = 'adminEditTask.jsp?id=' + taskId;
        }

        function deleteTask(taskId) {
            if (confirm('Are you sure you want to delete this task?')) {
                window.location.href = 'adminDeleteTask.jsp?id=' + taskId;
            }
        }
    </script>
</body>
</html>