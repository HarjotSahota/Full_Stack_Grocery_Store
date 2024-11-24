<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8"%>
<!DOCTYPE html>
<html>
<head>
<title>Your Shopping Cart</title>
</head>
<body>

<%
    // Get the current list of products
    @SuppressWarnings({"unchecked"})
    HashMap<String, ArrayList<Object>> productList = (HashMap<String, ArrayList<Object>>) session.getAttribute("productList");

    if (productList == null || productList.isEmpty()) {
        out.println("<h1>Your shopping cart is empty!</h1>");
        return;
    }

    // Process actions (update or remove)
    String action = request.getParameter("action");
    if (action != null) {
        String productId = request.getParameter("productId");

        if ("update".equals(action)) {
            int newQuantity = Integer.parseInt(request.getParameter("quantity"));
            if (newQuantity > 0) {
                productList.get(productId).set(3, newQuantity); // Update quantity
            } else {
                productList.remove(productId); // Remove item if quantity is zero
            }
        } else if ("remove".equals(action)) {
            productList.remove(productId); // Remove item
        }

        // Update session with modified cart
        session.setAttribute("productList", productList);
    }

    // Display the shopping cart
    NumberFormat currFormat = NumberFormat.getCurrencyInstance();
    out.println("<h1>Your Shopping Cart</h1>");
    out.print("<form method='post'><table border='1'><tr><th>Product Id</th><th>Product Name</th><th>Quantity</th>");
    out.println("<th>Price</th><th>Subtotal</th><th>Actions</th></tr>");

    double total = 0;
    Iterator<Map.Entry<String, ArrayList<Object>>> iterator = productList.entrySet().iterator();
    while (iterator.hasNext()) {
        Map.Entry<String, ArrayList<Object>> entry = iterator.next();
        ArrayList<Object> product = entry.getValue();
        String productId = (String) product.get(0);
        String productName = (String) product.get(1);
        double price = Double.parseDouble(product.get(2).toString());
        int quantity = Integer.parseInt(product.get(3).toString());
        double subtotal = price * quantity;
        total += subtotal;

        out.println("<tr>");
        out.println("<td>" + productId + "</td>");
        out.println("<td>" + productName + "</td>");
        out.println("<td><input type='number' name='quantity' value='" + quantity + "' min='0'></td>");
        out.println("<td>" + currFormat.format(price) + "</td>");
        out.println("<td>" + currFormat.format(subtotal) + "</td>");
        out.println("<td>");
        out.println("<button type='submit' name='action' value='update'>Update</button>");
        out.println("<button type='submit' name='action' value='remove'>Remove</button>");
        out.println("<input type='hidden' name='productId' value='" + productId + "'>");
        out.println("</td>");
        out.println("</tr>");
    }
    out.println("</table></form>");
    out.println("<p><strong>Total: " + currFormat.format(total) + "</strong></p>");
	
%>
<form action="checkout.jsp" method="post">
    <button type="submit">Proceed to Checkout</button>
</form>
<form action="listprod.jsp" method="post">
    <button type="submit">Continue Shopping</button>
</form>

</body>
</html>
