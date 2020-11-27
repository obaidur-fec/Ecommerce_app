import 'dart:convert';
import 'package:ecommerceapp/constants/payment.dart';
import 'package:ecommerceapp/controllers/auth_controller.dart';
import 'package:ecommerceapp/models/cart_item.dart';
import 'package:ecommerceapp/models/order.dart';
import 'package:ecommerceapp/models/shipping_details.dart';
import 'package:ecommerceapp/services/order_service.dart';
import 'package:flutter/foundation.dart';

class OrderController extends ChangeNotifier {
  final _orderService = OrderService();
  var shippingCost;
  var tax;
  Order singleOrder;
  final _authContoller = AuthController();
  var orders = List<Order>();
  bool isLoadingOrders = true;

  void setShippingCost(String country) async {
    try {
      shippingCost = await _orderService.getShippingCost(country);
    } catch (e) {
      print('Order controller ${e.toString()}');
    }
  }

  void setTax(String country) async {
    try {
      tax = await _orderService.getTax(country);
    } catch (e) {
      print('Order controller ${e.toString()}');
    }
  }

  void registerOrderWithStripePayment(
    ShippingDetails shippingDetails,
    String shippingCost,
    String tax,
    String total,
    String totalItemPrice,
    String userId,
    String paymentMethod,
    List<CartItem> cart,
  ) async {
    try {
      var userType = userId != null ? USER_TYPE_RESGISTERED : USER_TYPE_GUEST;
      var order = Order(
        shippingDetails: shippingDetails,
        shippingCost: shippingCost,
        tax: tax,
        total: total,
        totalItemPrice: totalItemPrice,
        userId: userId,
        paymentMethod: paymentMethod,
        userType: userType,
        dateOrdered: DateTime.now(),
        cartItems: cart,
      );
      var orderToJson = order.toJson();
      var response = await _orderService.saveOrder(json.encode(orderToJson));
      if (response.statusCode == 200) {
        var jsonD = json.decode(response.body);
        singleOrder = orderFromJson(json.encode(jsonD['data']));
      } else {
        print("error");
      }
    } catch (e) {
      print('Order controller Error: $e');
    }
  }

  void processOrderWithPaypal(
    ShippingDetails shippingDetails,
    String shippingCost,
    String tax,
    String total,
    String totalItemPrice,
    String userId,
    String paymentMethod,
    List<CartItem> cart,
    String nonce,
  ) async {
    try {
      var userType = userId != null ? USER_TYPE_RESGISTERED : USER_TYPE_GUEST;
      var order = Order(
          shippingDetails: shippingDetails,
          shippingCost: shippingCost,
          tax: tax,
          total: total,
          totalItemPrice: totalItemPrice,
          userId: userId,
          paymentMethod: paymentMethod,
          userType: userType,
          dateOrdered: DateTime.now(),
          cartItems: cart);
      var orderToJson = order.toJson();
      var response = await _orderService.sendPayPalRequest(
          json.encode(orderToJson), nonce);

      if (response.statusCode == 200) {
        var jsonD = json.decode(response.body);
        singleOrder = orderFromJson(json.encode(jsonD['data']));
      } else {
        print("paypal error");
      }
    } catch (e) {
      print('Order controller Error: $e');
    }
  }

  void getOrders() async {
    try {
      isLoadingOrders = true;
      var data = await _authContoller.getUserDataAndLoginStatus();
      var response = await _orderService.getOrders(data[0], data[2]);
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        orders = ordersFromJson(json.encode(decodedResponse['data']['orders']));
        isLoadingOrders = false;
        notifyListeners();
      } else {
        orders = [];
        isLoadingOrders = false;
        notifyListeners();
      }
    } catch (e) {
      print('error fetchign orders ${e.toString()}');
      isLoadingOrders = false;
      notifyListeners();
    }
  }

  void setSingleOrder(Order order) {
    this.singleOrder = order;
  }
}
