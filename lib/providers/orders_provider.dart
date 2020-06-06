import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart_provider.dart' show CartItem;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class OrdersProvider with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const url = 'https://flutter-update-2df8a.firebaseio.com/orders.json';

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];

      extractedData.forEach((key, orderItem) {
        var products = (orderItem['products'] as List<dynamic>)
            .map((item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  price: item['price'],
                  quantity: item['quantity'],
                ))
            .toList();

        loadedOrders.add(OrderItem(
          id: key,
          amount: orderItem['amount'],
          products: products,
          dateTime: DateTime.parse(orderItem['dateTime']),
        ));
      });

      _orders = loadedOrders;

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://flutter-update-2df8a.firebaseio.com/orders.json';

    try {
      final currentDate = DateTime.now();

      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'products': cartProducts.map((item) {
            return {
              'id': item.id,
              'title': item.title,
              'quantity': item.quantity,
              'price': item.price
            };
          }).toList(),
          'dateTime': currentDate.toIso8601String(),
        }),
      );

      _orders.add(
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: currentDate,
        ),
      );

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
