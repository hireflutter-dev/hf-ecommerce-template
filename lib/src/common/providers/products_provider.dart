import 'dart:convert';
import 'package:ecom/src/common/models/http_exception.dart';
import 'package:ecom/src/common/providers/individual_product_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsProvider extends ChangeNotifier {
  ProductsProvider(this.authToken, this.userId, this._items);

  final String authToken;
  final String userId;
  List<IndividualProduct> _items = <IndividualProduct>[];

  List<IndividualProduct> get items => <IndividualProduct>[..._items];

  List<IndividualProduct> get favoriteItems => _items
      .where((IndividualProduct prodItem) => prodItem.isFavorite)
      .toList();

  IndividualProduct findById(String id) =>
      _items.firstWhere((IndividualProduct prod) => prod.id == id);

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    // final bla = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final String filterString =
        filterByUser ? 'orderBy="sellerId"&equalTo="$userId"' : '';
    String url =
        'https://ecomproject-daeb7.firebaseio.com/products.json?auth=$authToken&$filterString';

    try {
      final http.Response response = await http.get(url);

      final Map<String, dynamic> extractedData =
          json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      url =
          'https://ecomproject-daeb7.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final http.Response favoriteResponse = await http.get(url);
      final dynamic favoriteData = json.decode(favoriteResponse.body);
      final List<IndividualProduct> loadedProducts = <IndividualProduct>[];
      extractedData.forEach((String prodId, dynamic prodData) {
        loadedProducts.add(IndividualProduct(
          id: prodId,
          title: prodData['title'] as String,
          description: prodData['description'] as String,
          price: prodData['price'] as double,
          isFavorite: (favoriteData == null)
              ? false
              : favoriteData[prodId] as bool ?? false,
          imageUrl: prodData['imageUrl'] as String,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<void> addProduct(IndividualProduct product) async {
    final String url =
        'https://ecomproject-daeb7.firebaseio.com/products.json?auth=$authToken';

    final http.Response response = await http.post(
      url,
      body: json.encode(
        <String, dynamic>{
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'sellerId': userId,
        },
      ),
    );

    final IndividualProduct newProduct = IndividualProduct(
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      id: json.decode(response.body)['name'] as String,
    );
    _items.add(newProduct);

    notifyListeners();
  }

  Future<void> updateProduct(String id, IndividualProduct newProduct) async {
    final int prodIndex =
        _items.indexWhere((IndividualProduct prod) => prod.id == id);

    if (prodIndex >= 0) {
      final String url =
          'https://ecomproject-daeb7.firebaseio.com/products/$id.json?auth=$authToken';

      http.patch(
        url,
        body: json.encode(
          <String, dynamic>{
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          },
        ),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  ///deleting product from db
  ///optimistic updating pattern to roll back if product delete fails.
  Future<void> deleteProduct(String id) async {
    final String url =
        'https://ecomproject-daeb7.firebaseio.com/products/$id.json?auth=$authToken';

    final int existingProductIndex =
        _items.indexWhere((IndividualProduct prod) => prod.id == id);
    IndividualProduct existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final http.Response response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw const HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
