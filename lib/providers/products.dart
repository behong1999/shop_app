import 'dart:convert';

import 'package:NewtypeS/models/http_exception.dart';
import 'package:flutter/material.dart';
import '/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  final String? authToken;
  final String? userId;
  Products(this.authToken, this.userId, this._items);
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'HGCE INFINITE JUSTICE GUNDAM',
    //   description:
    //       'Bandai brings us a new Gunpla kit from "Gundam Seed" of a 1/144 HGCE Infinite Justice Gundam! The internal structure of the model possesses the ability to pose this finished kit in a ton of different ways. Both of the Fatum-01 wings are equipped with movable joints to allow them to warp up and recreate the classic silhouette during aerial battles. Tons of beam-effect parts are also included - order today!',
    //   price: 16.53,
    //   imageUrl:
    //       'https://www.hlj.com/media/catalog/product/cache/acedba8d3f43cedb2fbb4f1aa3b47451/b/a/bans58930_1.png',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'RG GUNDAM FORCE IMPULSE',
    //   description:
    //       'Shin Asuka\'s Force Impulse Gundam, seen in the first half of "Mobile Suit Gundam Seed Destiny," gets a new Real Grade kit from Bandai! It features an internal body frame that can be separated from the runners already assembled, meaning much less work for you to do, and amazingly precise details as well! It\'s molded in color for a screen-accurate appearance. The Force Silhouette\'s gimmicks, texture and details are carefully reproduced, complete with the wings that fold backwards. The forearm can twist on a separate axis from the elbow for a realistic range of motion, and the shoulder armor rotates independently, reducing part interference. The knee armor is also movable in conjunction with the motion of the leg; four pairs of hands are included, as are plenty of weapons. Place your order today and add this legendary Gundam to your lineup!',
    //   price: 25.97,
    //   imageUrl:
    //       'https://www.hlj.com/media/catalog/product/cache/acedba8d3f43cedb2fbb4f1aa3b47451/b/a/bans59228_1.png',
    // ),
  ];

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((element) => element.isFavorite).toList();
    // }

    //! If 'return _items' only, it would return a pointer of _items
    //* Instead, create a copy of that list
    return [..._items];
  }

  // void showFavorites() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product searchById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    //* Retrieve all products of the user whose ID equal to the current $userId
    final String filterString =
        filterByUser ? 'orderBy="userId"&equalTo="$userId"' : '';
    final url =
        'https://shop-b36d5-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';

    try {
      //* get => fetch
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data == {}) {
        return;
      }

      //* Get all favorite data for all products that the login user marked
      final favoriteResponse = await http.get(Uri.parse(
          'https://shop-b36d5-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken'));
      final favoriteData = json.decode(favoriteResponse.body);

      //* Initialize an empty list of Products and insert each product into the list
      //* After that, the local list will be replaced with the abovementioned list
      final List<Product> loadedProducts = [];
      // print(data);
      //! data is a saved Map<id,Map>
      data.forEach((productID, productData) {
        loadedProducts.insert(
            0,
            Product(
              id: productID,
              title: productData['title'],
              description: productData['description'],
              price: productData['price'],
              imageUrl: productData['imageUrl'],
              isFavorite: favoriteData == null
                  ? false
                  //! AVOID "type 'Null' is not a subtype of type 'bool'" error
                  : favoriteData[productID] ?? false,
            ));
      });
      _items = loadedProducts;

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shop-b36d5-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'userId': userId,
          },
        ),
      );

      // print('json.decode(reponse.body) = ${json.decode(response.body)}');

      //* Override the added product objetct conntaining an id
      //* by using a new instance
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      //NOTE: NOT NECESSARY DUE TO THE REFRESH INDICATOR
      //* Add new Product into the LOCAL LIST _items
      // _items.add(newProduct);

      //* Insert new item at the beginning of the LOCAL LIST _items
      _items.insert(0, newProduct);

      print('New Product Added');
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final url = Uri.parse(
          'https://shop-b36d5-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

      await http.patch(
        url,
        body: json.encode(
          {
            'title': updatedProduct.title,
            'description': updatedProduct.description,
            'price': updatedProduct.price,
            'imageUrl': updatedProduct.imageUrl,
          },
        ),
      );
      _items[index] = updatedProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shop-b36d5-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);

    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    print(response.statusCode);

    //* Reinsert the existingProduct to the _item local list
    //* if deleting process fails
    if (response.statusCode >= 400) {
      _items.insert(
        existingProductIndex,
        existingProduct,
      );
      notifyListeners();

      //? Custom Exception to trigger catchError
      throw HttpException('Could Not Delete!!!');
    }

    //? Clean up the reference
    // existingProduct = Product(id: '', title: '', description: '', price: 0.0, imageUrl: '');

    // _items.removeWhere((element) => element.id == id);
  }
}
