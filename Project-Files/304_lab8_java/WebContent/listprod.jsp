<%@ page import="java.sql.*,java.net.URLEncoder" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Harjot and Moe's Grocery</title>
</head>
<body>

<h1>Search for the products you want to buy:</h1>

<form method="get" action="listprod.jsp">
<input type="text" name="productName" size="50">
<input type="submit" value="Submit"><input type="reset" value="Reset"> (Leave blank for all products)
</form>

<% // Get product name to search for
String name = request.getParameter("productName");
		
//Note: Forces loading of SQL Server driver
try
{	// Load driver class
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
}
catch (java.lang.ClassNotFoundException e)
{
	out.println("ClassNotFoundException: " +e);
}


// Variable name now contains the search string the user entered
// Use it to build a query and print out the resultset.  Make sure to use PreparedStatement!

// Make the connection
String url = "jdbc:sqlserver://cosc304_sqlserver:1433;DatabaseName=orders;TrustServerCertificate=True";
String uid = "sa"; 
String pw = "304#sa#pw"; 

// Useful code for formatting currency values:
NumberFormat currFormat = NumberFormat.getCurrencyInstance();

try (Connection con = DriverManager.getConnection(url, uid, pw);
Statement stmt = con.createStatement();){

        
// if else statement if 

    if (name == null || name.length() == 0){
        // Print out the ResultSet
        String query1 = "SELECT productId, productName, categoryName, productPrice FROM product JOIN category ON product.categoryId = category.categoryId";
        ResultSet rst2 = stmt.executeQuery(query1);
        while(rst2.next()){
            int productId2 = rst2.getInt("productId");
            String productName2 = rst2.getString("productName");
            String categoryName2 = rst2.getString("categoryName");
            double productPrice2 = rst2.getDouble("productPrice");
            // addcart.jsp?id=productId&name=productName&price=productPrice
            out.println("<p>" + productName2 + " - " + categoryName2 + " - " + currFormat.format(productPrice2) + " ");
            out.println("<a href='addcart.jsp?id=" + productId2 
                + "&name=" + productName2 + "&price=" + productPrice2 + "'>Add to Cart</a></p>");
        }
    } else{
        String query = "SELECT productId, productName, categoryName, productPrice FROM product JOIN category ON product.categoryId = category.categoryId WHERE productName LIKE ?";
        PreparedStatement pst = con.prepareStatement(query);
        pst.setString(1, "%" + name + "%");
        ResultSet rst = pst.executeQuery();

        while(rst.next()) {
            int productId = rst.getInt("productId");
            String productName = rst.getString("productName");
            String categoryName = rst.getString("categoryName");
            double productPrice = rst.getDouble("productPrice");


            // For each product create a link of the form
            // addcart.jsp?id=productId&name=productName&price=productPrice
            out.println("<p>" + productName + " - " + categoryName + " - " + currFormat.format(productPrice) + " ");
            out.println("<a href='addcart.jsp?id=" + productId 
                + "&name=" + productName + "&price=" + productPrice + "'>Add to Cart</a></p>");

        }
    }

} catch (SQLException ex)
{
	System.out.println("SQLException: " + ex);
}


// Close connection


// out.println(currFormat.format(5.0);	// Prints $5.00
%>

</body>
</html>