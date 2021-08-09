import 'dart:convert';

import 'package:NewtypeS/models/http_exception.dart';
import 'package:NewtypeS/providers/cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> setAndFetchOrders() async {
    final url = Uri.parse(
        'https://shop-b36d5-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final data = json.decode(response.body) as Map<String, dynamic>?;

    //* Add Order Items to Each Loaded Orders List
    data!.forEach((id, orderData) {
      loadedOrders.add(OrderItem(
          id: id,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime'])));
    });

    _orders = loadedOrders.reversed.toList();

    // int _elementIndex = 0;
    // _orders.forEach((element) {
    //   print('Order ${_elementIndex + 1} => (${element.dateTime})\n');
    //   _elementIndex++;
    // });

    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shop-b36d5-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'products': cartProducts
              .map((cartProduct) => {
                    'id': cartProduct.id,
                    'title': cartProduct.title,
                    'quantity': cartProduct.quantity,
                    'price': cartProduct.price,
                  })
              .toList(),
          'dateTime': DateTime.now().toIso8601String()
        }));
    if (response.statusCode >= 400) {
      print(response.statusCode.toString());
      throw HttpException('Failed To Add');
    }
    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: DateTime.now(),
        ));
    notifyListeners();
  }
}
