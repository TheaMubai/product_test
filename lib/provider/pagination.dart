import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:product/model/product_model.dart';

class ApiService {
  static const String _baseUrl = "http://10.0.2.2:3000/products";

  Future<List<ProductModel>> getProductPageagination(
    int page,
    int limit,
  ) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final allProducts = data
            .map((item) => ProductModel.fromJson(item))
            .toList();

        final start = (page - 1) * limit;
        final end = start + limit;
        if (start >= allProducts.length) return [];

        final paginatedProducts = allProducts.sublist(
          start,
          end > allProducts.length ? allProducts.length : end,
        );
        return paginatedProducts;
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception("Error loading products: $e");
    }
  }
}
