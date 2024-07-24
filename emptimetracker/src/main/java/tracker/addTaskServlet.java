package tracker;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/addTaskServlet")
public class addTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String date = request.getParameter("date");
        String timeDurationStr = request.getParameter("timeDuration");
        String taskCategory = request.getParameter("taskCategory");
        String description = request.getParameter("description");

        System.out.println("Received Date: " + date);
        System.out.println("Received Time Duration: " + timeDurationStr);
        System.out.println("Received Task Category: " + taskCategory);
        System.out.println("Received Description: " + description);

        int timeDuration = 0;
        try {
            timeDuration = Integer.parseInt(timeDurationStr);
        } catch (NumberFormatException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Invalid time duration.");
            request.getRequestDispatcher("addTask.jsp").forward(request, response);
            return;
        }

        // Back-end validation for time duration
        if (timeDuration < 1 || timeDuration > 8) {
            request.setAttribute("errorMessage", "Time duration must be between 1 and 8 hours.");
            request.getRequestDispatcher("addTask.jsp").forward(request, response);
            return; // Stop processing
        }

        // Database connection and insert logic
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/time_tracker", "root", "Mav#123");
            String sql = "INSERT INTO tasks (date, timeDuration, taskCategory, description) VALUES (?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, date);
            pstmt.setInt(2, timeDuration);
            pstmt.setString(3, taskCategory);
            pstmt.setString(4, description);

            int rowsAffected = pstmt.executeUpdate();
            System.out.println("Rows affected: " + rowsAffected);

            if (rowsAffected > 0) {
                response.sendRedirect("dashboard.jsp");
            } else {
                request.setAttribute("errorMessage", "Failed to add task.");
                request.getRequestDispatcher("addTask.jsp").forward(request, response);
            }

            pstmt.close();
            conn.close();

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Database error: " + e.getMessage());
            request.getRequestDispatcher("addTask.jsp").forward(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}