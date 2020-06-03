import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product_provider.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts() async {
    const url = 'https://flutter-update-2df8a.firebaseio.com/products.json';

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            price: prodData['price'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            isFavorite: prodData['isFavorite']));
      });

      _items = loadedProducts;

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    const url = 'https://flutter-update-2df8a.firebaseio.com/products.json';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          },
        ),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      final url =
          'https://flutter-update-2df8a.firebaseio.com/products/${product.id}.json';

      await http.patch(url,
          body: json.encode(
            {
              'title': product.title,
              'price': product.price,
              'description': product.description,
              'imageUrl': product.imageUrl
            },
          ));

      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://flutter-update-2df8a.firebaseio.com/products/$id.json';
    final index = _items.indexWhere((prod) => prod.id == id);
    var product = _items[index];

    _items.removeAt(index);

    var response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(index, product);
      throw HttpException(
          'Could not delete product. ERR ${response.statusCode}');
    } else {
      product = null;
    }

    notifyListeners();
  }

  Product findById(String productId) {
    return _items.firstWhere((item) => item.id == productId);
  }
}
