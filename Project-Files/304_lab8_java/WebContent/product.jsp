<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<%@ include file="jdbc.jsp" %>

<html>
<head>
<title>Ray's Grocery - Product Information</title>
<link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

<%@ include file="header.jsp" %>

<%
// Get product name to search for
// TODO: Retrieve and display info for the product

String productId = request.getParameter("id");                                                                            // product id
NumberFormat currFormat = NumberFormat.getCurrencyInstance();                                                             // Useful code for formatting currency values:                                                                              

if (productId != null){                                                                                                   // if the product exists
    String sql = "SELECT productName, productPrice, productImageURL, productDesc FROM product WHERE productId = ?";
    try {
        PreparedStatement ps = connection.prepareStatement(sql);
        ps.setString(1, productId);
        ResultSet rs = ps.executeQuery();

        if(rs.next()){                                                                                                    // get info of prodct
            String productName = rs.getString("productName");
            Double productPrice = rs.getDouble("productPrice");
            String productImageURL = rs.getString("productImageURL");
            String productDesc = rs.getString("productDesc");

            out.println("<p>" + productName + " - " + productPrice + " - " + currFormat.format(productPrice2) + " ");     // display info of product
            out.println("<p>" + "Description: " +productDesc);
            
            if (productImageURL != null) {
                <img src="<%= productImageURL %>" alt="<%= productName %>" style="max-width:300px;">                      // display the image of the product, if there is an image
            }
        } else {
            out.println("<p>" + "Product Not Found");                                                                     // the pid did not match any product id's
        }
    } catch (SQLException ex) {
        out.println("<p>SQLException: " + ex + "</p>");
    }
} 


String sql = "";

// TODO: If there is a productImageURL, display using IMG tag
		
// TODO: Retrieve any image stored directly in database. Note: Call displayImage.jsp with product id as parameter.
		
// TODO: Add links to Add to Cart and Continue Shopping
%>

</body>
</html>

