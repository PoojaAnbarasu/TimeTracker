<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="javax.servlet.RequestDispatcher" %>

<%
    // Database connection details
    String dbURL = "jdbc:mysql://localhost:3306/time_tracker";
    String dbUser = "root";
    String dbPassword = "Mav#123";

    // Initialize database connection
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // Get the username and password from the request
    String inputUsername = request.getParameter("username");
    String inputPassword = request.getParameter("password");

    if (inputUsername != null && inputPassword != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // Load JDBC driver
            conn = DriverManager.getConnection(dbURL, dbUser, dbPassword); // Establish connection

            // SQL query to retrieve user details and role
            String sql = "SELECT u.*, r.role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.username = ? AND u.password = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, inputUsername);
            pstmt.setString(2, inputPassword);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String role = rs.getString("role_name");
                System.out.println("User role: " + role); // Debugging line
                HttpSession userSession = request.getSession();
                userSession.setAttribute("username", inputUsername);
                userSession.setAttribute("role", role);

                if ("ADMIN".equalsIgnoreCase(role)) {
                    System.out.println("Redirecting to Admin Dashboard"); // Debugging line
                    response.sendRedirect("adminDashboard.jsp");
                } else if ("ASSOCIATE".equalsIgnoreCase(role)) {
                    System.out.println("Redirecting to Associate Dashboard"); // Debugging line
                    response.sendRedirect("associateDashboard.jsp");
                } else {
                    System.out.println("Unknown role: " + role); // Debugging line for unknown roles
                    request.setAttribute("errorMessage", "Unknown role");
                    RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                    rd.forward(request, response);
                }
            } else {
                System.out.println("Invalid username or password"); // Debugging line
                request.setAttribute("errorMessage", "Invalid username or password");
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                rd.forward(request, response);
            }
        } catch (Exception e) {
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
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #f4f4f4;
            font-family: Arial, sans-serif;
        }
        .login-container {
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            text-align: center;
            width: 300px;
        }
        h2 {
            color: #333;
            margin-bottom: 20px;
        }
        label {
            font-weight: bold;
            display: block;
            margin: 10px 0 5px;
        }
        input {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
            background-color: #5cb85c;
            color: white;
            border: none;
            padding: 10px;
            border-radius: 4px;
            cursor: pointer;
            width: 100%;
        }
        button:hover {
            background-color: #4cae4c;
        }
        .error {
            color: red;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Login</h2>
        <form action="login.jsp" method="post">
            <div>
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div>
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div>
                <button type="submit">Login</button>
            </div>
        </form>
        <div>
            <% if (request.getAttribute("errorMessage") != null) { %>
                <p class="error"><%= request.getAttribute("errorMessage") %></p>
            <% } %>
        </div>
    </div>
</body>
</html>