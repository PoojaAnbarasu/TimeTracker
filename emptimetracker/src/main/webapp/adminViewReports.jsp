<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>
<%@ page import="com.google.gson.Gson" %>

<%
    HttpSession userSession = request.getSession(false);
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View Reports</title>
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
        }
        h1 {
            text-align: center;
            margin-top: 20px;
            font-weight: bold;
            color: #333;
        }
        .form-group {
            margin-bottom: 15px;
            text-align: center;
        }
        .form-group label {
            font-weight: bold;
        }
        .form-group select, .form-group button {
            padding: 10px;
            border-radius: 4px;
            border: 1px solid #ccc;
        }
        .form-group button {
            background-color: #008080;
            color: white;
            cursor: pointer;
        }
        .form-group button:hover {
            background-color: #006666;
        }
        .chart-container {
            width: 80%;
            margin: 20px auto;
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="container">
        <h1>View Reports</h1>
        <form class="form-group" action="adminViewReports.jsp" method="post">
            <label for="reportType">Select Report Type:</label>
            <select id="reportType" name="reportType">
                <option value="daily">Daily</option>
                <option value="weekly">Weekly</option>
                <option value="monthly">Monthly</option>
            </select>
            <button type="submit">View Report</button>
        </form>

        <div class="chart-container">
            <canvas id="reportChart"></canvas>
        </div>

        <%
            String reportType = request.getParameter("reportType");
            if (reportType != null) {
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                List<String> labels = new ArrayList<>();
                List<Integer> data = new ArrayList<>();
                List<String> hoverInfo = new ArrayList<>();

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");

                    String sql = "";
                    switch (reportType) {
                        case "daily":
                            sql = "SELECT date, employee_id, taskCategory, SUM(timeDuration) AS totalHours FROM tasks GROUP BY date, employee_id, taskCategory ORDER BY date";
                            break;
                        case "weekly":
                            sql = "SELECT WEEK(date) AS week, SUM(timeDuration) AS totalHours FROM tasks GROUP BY week ORDER BY week";
                            break;
                        case "monthly":
                            sql = "SELECT MONTH(date) AS month, SUM(timeDuration) AS totalHours FROM tasks GROUP BY month ORDER BY month";
                            break;
                    }

                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();

                    while (rs.next()) {
                        if ("daily".equals(reportType)) {
                            labels.add(rs.getString("date") + " - " + rs.getString("taskCategory"));
                            data.add(rs.getInt("totalHours"));
                            hoverInfo.add(rs.getString("taskCategory") + " (" + rs.getString("totalHours") + " hours)");
                        } else if ("weekly".equals(reportType)) {
                            labels.add("Week " + rs.getInt("week"));
                            data.add(rs.getInt("totalHours"));
                        } else if ("monthly".equals(reportType)) {
                            labels.add("Month " + rs.getInt("month"));
                            data.add(rs.getInt("totalHours"));
                        }
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
        <script>
            var ctx = document.getElementById('reportChart').getContext('2d');
            var chartType = '<%= "daily".equals(reportType) ? "pie" : "bar" %>';
            var labels = <%= new Gson().toJson(labels) %>;
            var data = <%= new Gson().toJson(data) %>;
            var hoverInfo = <%= new Gson().toJson(hoverInfo) %>;

            new Chart(ctx, {
                type: chartType,
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Hours',
                        data: data,
                        backgroundColor: [
                            'rgba(255, 99, 132, 0.2)',
                            'rgba(54, 162, 235, 0.2)',
                            'rgba(255, 206, 86, 0.2)',
                            'rgba(75, 192, 192, 0.2)',
                            'rgba(153, 102, 255, 0.2)',
                            'rgba(255, 159, 64, 0.2)'
                        ],
                        borderColor: [
                            'rgba(255, 99, 132, 1)',
                            'rgba(54, 162, 235, 1)',
                            'rgba(255, 206, 86, 1)',
                            'rgba(75, 192, 192, 1)',
                            'rgba(153, 102, 255, 1)',
                            'rgba(255, 159, 64, 1)'
                        ],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    tooltips: {
                        callbacks: {
                            label: function(tooltipItem, data) {
                                return hoverInfo[tooltipItem.index];
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        </script>
        <%
            }
        %>
    </div>
</body>
</html>