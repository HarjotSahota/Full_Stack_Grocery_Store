<%@ page import="java.sql.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>YOUR NAME Grocery Order Processing</title>
</head>
<body>

<%
    // Get customer id from the request
    String custId = request.getParameter("customerId");

    // Get the shopping cart (productList) from the session
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

    // Determine if valid customer id was entered
    if (custId == null || custId.isEmpty() || !custId.matches("\\d+")) {
        out.println("Invalid customer ID. Please enter a valid ID.");
        return;
    }

    // Check if there are products in the shopping cart
    if (productList == null || productList.isEmpty()) {
        out.println("Your shopping cart is empty. Please add some products.");
        return;
    }

    // Database connection details
	String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
	String uid = "sa"; 
	String pw = "304#sa#pw"; 

    Connection connection = null;
    PreparedStatement pstmt = null;
    ResultSet resultSet = null;

    try {
        // Make the connection
        connection = DriverManager.getConnection(url, uid, pw);

        // Insert the order summary into OrderSummary table
        String orderSummarySql = "INSERT INTO OrderSummary (CustomerID, TotalAmount) VALUES (?, ?)";
        pstmt = connection.prepareStatement(orderSummarySql, Statement.RETURN_GENERATED_KEYS);
        
        double totalAmount = 0.0;

        // Traverse through the shopping cart (productList)
        Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, ArrayList<Object>> entry = iterator.next();
            ArrayList<Object> product = entry.getValue();

            String productId = (String) product.get(0); // Product ID
            String productName = (String) product.get(1); // Product Name
			double price = Double.parseDouble(product.get(2).toString());
			int quantity = Integer.parseInt(product.get(3).toString());			

            // Calculate total amount for the order
            totalAmount += price * quantity;
        }

        // Set customer ID and total amount, then execute the INSERT
        pstmt.setString(1, custId);
        pstmt.setDouble(2, totalAmount);
        pstmt.executeUpdate();

        // Retrieve the generated order ID
        resultSet = pstmt.getGeneratedKeys();
        int orderId = 0;
        if (resultSet.next()) {
            orderId = resultSet.getInt(1);
        }

        // Insert each product into OrderProduct table using the generated order ID
        String orderProductSql = "INSERT INTO OrderProduct (OrderID, ProductID, Quantity, Price) VALUES (?, ?, ?, ?)";
        pstmt = connection.prepareStatement(orderProductSql);

        iterator = productList.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, ArrayList<Object>> entry = iterator.next();
            ArrayList<Object> product = entry.getValue();

            String productId = (String) product.get(0);
			double price = Double.parseDouble(product.get(2).toString());
			int quantity = Integer.parseInt(product.get(3).toString());	

            // Insert product details into OrderProduct table
            pstmt.setInt(1, orderId);
            pstmt.setString(2, productId);
            pstmt.setInt(3, quantity);
            pstmt.setDouble(4, price);
            pstmt.executeUpdate();
        }

        // Update the total amount in the OrderSummary table
        String updateTotalAmountSql = "UPDATE OrderSummary SET TotalAmount = ? WHERE OrderID = ?";
        pstmt = connection.prepareStatement(updateTotalAmountSql);
        pstmt.setDouble(1, totalAmount);
        pstmt.setInt(2, orderId);
        pstmt.executeUpdate();

        // Print order summary
        out.println("<h2>Order Summary</h2>");
        out.println("<p>Order ID: " + orderId + "</p>");
        out.println("<p>Customer ID: " + custId + "</p>");
        out.println("<p>Total Amount: " + NumberFormat.getCurrencyInstance().format(totalAmount) + "</p>");

        // Clear the shopping cart after the order is placed
        session.removeAttribute("productList");

        out.println("<p>Your order has been placed successfully. Thank you for shopping with us!</p>");

    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    } finally {
        try {
            if (resultSet != null) resultSet.close();
            if (pstmt != null) pstmt.close();
            if (connection != null) connection.close();
        } catch (SQLException e) {
            out.println("Error closing resources: " + e.getMessage());
        }
    }
%>

</body>
</html>