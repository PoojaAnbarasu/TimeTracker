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
    String username = (String) session.getAttribute("username");
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
        <form class="form-group" action="viewReports.jsp" method="post">
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
                List<String> colors = new ArrayList<>();
                Random random = new Random();

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");

                    String sql = "";
                    switch (reportType) {
                        case "daily":
                            sql = "SELECT date, taskCategory, SUM(timeDuration) AS totalHours FROM tasks WHERE username = ? GROUP BY date, taskCategory ORDER BY date";
                            break;
                        case "weekly":
                            sql = "SELECT WEEK(date) AS week, SUM(timeDuration) AS totalHours FROM tasks WHERE username = ? GROUP BY week ORDER BY week";
                            break;
                        case "monthly":
                            sql = "SELECT MONTH(date) AS month, SUM(timeDuration) AS totalHours FROM tasks WHERE username = ? GROUP BY month ORDER BY month";
                            break;
                    }

                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, username);
                    rs = pstmt.executeQuery();

                    while (rs.next()) {
                        String label = "";
                        if ("daily".equals(reportType)) {
                            label = rs.getString("taskCategory") + " (" + rs.getString("date") + ")";
                        } else if ("weekly".equals(reportType)) {
                            label = "Week " + rs.getInt("week");
                        } else if ("monthly".equals(reportType)) {
                            label = "Month " + rs.getInt("month");
                        }
                        labels.add(label);
                        data.add(rs.getInt("totalHours"));
                        
                        // Generate a random color
                        String color = "rgba(" + random.nextInt(256) + "," + random.nextInt(256) + "," + random.nextInt(256) + ",0.6)";
                        colors.add(color);
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
            var labels = <%= new com.google.gson.Gson().toJson(labels) %>;
            var data = <%= new com.google.gson.Gson().toJson(data) %>;
            var colors = <%= new com.google.gson.Gson().toJson(colors) %>;

            new Chart(ctx, {
                type: chartType,
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Hours',
                        data: data,
                        backgroundColor: colors,
                        borderColor: 'rgba(0, 128, 128, 1)',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    tooltips: {
                        callbacks: {
                            label: function(tooltipItem, data) {
                                var dataset = data.datasets[tooltipItem.datasetIndex];
                                var label = data.labels[tooltipItem.index];
                                var value = dataset.data[tooltipItem.index];
                                return label + ': ' + value + ' hours';
                            }
                        }
                    },
                    scales: {
                        yAxes: [{
                            ticks: {
                                beginAtZero: true
                            }
                        }]
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