<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
    <title>YOUR NAME Grocery Order List</title>
</head>
<body>
    <h1>Order List</h1>

    <%
    // Load SQL Server driver
    try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
    } catch (ClassNotFoundException e) {
        out.println("<p>ClassNotFoundException: " + e + "</p>");
    }

    // Currency formatter
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();

    // Connection information
    String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
    String uid = "sa"; 
    String pw = "304#sa#pw"; 

    // Database operations
    try (Connection con = DriverManager.getConnection(url, uid, pw);
         Statement stmt = con.createStatement();
         PreparedStatement pst = con.prepareStatement("SELECT productId, quantity, price FROM orderproduct WHERE orderId = ?")) {

        // Retrieve all order summary records
        String sumQuery = "SELECT orderId, orderDate, totalAmount, ordersummary.customerId, firstName, lastName " +
                          "FROM ordersummary LEFT JOIN customer ON ordersummary.customerId = customer.customerId";
        ResultSet sumRecords = stmt.executeQuery(sumQuery);

        // Process each order
        while (sumRecords.next()) {
            int orderID = sumRecords.getInt("orderId");
            Date orderDate = sumRecords.getDate("orderDate");
            double totalAmount = sumRecords.getDouble("totalAmount");
            int customerId = sumRecords.getInt("customerId");
            String firstName = sumRecords.getString("firstName");
            String lastName = sumRecords.getString("lastName");

            // Print order summary information
            out.println("<h2>Order ID: " + orderID + "</h2>");
            out.println("<p>Order Date: " + orderDate + "<br>");
            out.println("Total Amount: " + currFormat.format(totalAmount) + "<br>");
            out.println("Customer Name: " + firstName + " " + lastName + "<br>");
            out.println("Customer ID: " + customerId + "</p>");

            // Retrieve products in the order
            pst.setInt(1, orderID);
            try (ResultSet rst2 = pst.executeQuery()) {
                out.println("<table border='1'>");
                out.println("<tr><th>Product ID</th><th>Quantity</th><th>Price</th></tr>");

                while (rst2.next()) {
                    int productId = rst2.getInt("productId");
                    int quantity = rst2.getInt("quantity");
                    double price = rst2.getDouble("price");

                    out.println("<tr>");
                    out.println("<td>" + productId + "</td>");
                    out.println("<td>" + quantity + "</td>");
                    out.println("<td>" + currFormat.format(price) + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }
        }

    } catch (SQLException ex) {
        out.println("<p>SQLException: " + ex + "</p>");
    }
    %>

</body>
</html>
