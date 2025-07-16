import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:product/Model/product_model.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String baseUrl = "http://10.0.2.2:3000/products";
  Future<void> fetchAllProduct() async {
    _isLoading = true;
    notifyListeners();
    try {
      final repos = await http.get(Uri.parse(baseUrl));
      if (repos.statusCode == 200) {
        _products = productModelFromJson(repos.body);
      } else if (repos.statusCode == 500) {
        throw Exception("Failed to fetch profuct!");
      } else {
        throw Exception("Sometthing went wrong!");
      }
    } catch (e) {
      throw Exception(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<ProductModel?> fetchByID({required int id}) async {
    try {
      final url = Uri.parse("$baseUrl/$id");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ProductModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception("Product not found!");
      } else if (response.statusCode == 500) {
        throw Exception("Failed to fetch profuct!");
      } else {
        throw Exception("Something went wrong!");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> addProduct({
    required ProductModel product,
    required BuildContext context,
  }) async {
    final respon = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "PRODUCTNAME": product.productname,
        "PRICE": product.price,
        "STOCK": product.stock,
      }),
    );
    if (respon.statusCode == 201) {
      fetchAllProduct();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Product added successfully")));
    } else if (respon.statusCode == 400) {
      throw Exception(
        "Invalid input: name, price, and stock are required with valid values!",
      );
    } else if (respon.statusCode == 500) {
      throw Exception("Failed to add profuct!");
    } else {
      throw Exception("Something went wrong!");
    }
  }

  Future<void> update({
    required ProductModel product,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/${product.productid}");
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "PRODUCTNAME": product.productname,
          "PRICE": product.price,
          "STOCK": product.stock,
        }),
      );
      if (response.statusCode == 200) {
        fetchAllProduct();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Product updated successfully")));
      } else if (response.statusCode == 400) {
        throw Exception(
          "Invalid input: name, price, and stock are required with valid values!",
        );
      } else if (response.statusCode == 404) {
        throw Exception("Product not found!");
      } else if (response.statusCode == 500) {
        throw Exception("Failed to update profuct!");
      } else {
        throw Exception("Something went wrong!");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/$id'));
      if (res.statusCode == 200) {
        _products.removeWhere((p) => p.productid == id);
        notifyListeners();
      } else if (res.statusCode == 404) {
        throw Exception("Product not found!");
      } else if (res.statusCode == 500) {
        throw Exception("Failed to delete profuct!");
      } else {
        throw Exception("Something went wrong!");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
