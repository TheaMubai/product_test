import 'package:flutter/material.dart';
import 'package:product/model/deleteModel.dart';
import 'package:product/model/product_model.dart';
import 'package:product/provider/pagination.dart';

class MainPageProvider extends ChangeNotifier {
  final proNameController = TextEditingController();
  final proPriceController = TextEditingController();
  final proStockController = TextEditingController();
  final List<Deletemodel> _isSelect = [];
  List<Deletemodel> get isSelect => _isSelect;
  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;
  String _currentSortBy = 'price'; // or 'stock'
  bool _isAscending = true;

  String get currentSortBy => _currentSortBy;
  bool get isAscending => _isAscending;

  void setSelectionMode(bool set) {
    _isSelectionMode = set;
    notifyListeners();
  }

  void addSelect(Deletemodel d) {
    if (_isSelect.contains(d)) {
      _isSelect.remove(d);
    } else {
      _isSelect.add(d);
    }
    notifyListeners();
  }

  void removeIndex(int index) {
    _isSelect.removeAt(index);
    notifyListeners();
  }

  void get removeAllIndex {
    _isSelect.clear();
    notifyListeners();
  }

  void setProNameController(String text) {
    proNameController.text = text;
    notifyListeners();
  }

  void setProPriceController(String text) {
    proPriceController.text = text;
    notifyListeners();
  }

  void setProStockController(String text) {
    proStockController.text = text;
    notifyListeners();
  }

  String get getProNameController {
    return proNameController.text.trim();
  }

  double get getProPriceController {
    return double.parse(proPriceController.text.trim());
  }

  int get getProStockController {
    return int.parse(proStockController.text.trim());
  }

  void sortProductList(List productList, String by, bool ascending) {
    _currentSortBy = by;
    _isAscending = ascending;

    productList.sort((a, b) {
      final aVal = by == 'price' ? a.price : a.stock;
      final bVal = by == 'price' ? b.price : b.stock;
      return ascending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
    });

    notifyListeners();
  }

  //// This is for Pagination /////
  List<ProductModel> _products = [];
  int _currentPage = 1;
  final int _limit = 10;
  bool _isFetching = false;
  bool _hasMore = true;

  List<ProductModel> get products => _products;
  bool get isFetching => _isFetching;
  bool get hasMore => _hasMore;

  Future<void> fetchNextPage() async {
    if (_isFetching || !_hasMore) return;
    _isFetching = true;
    notifyListeners();
    try {
      final apiService = ApiService();
      final newProducts = await apiService.getProductPageagination(
        _currentPage,
        _limit,
      );
      if (newProducts.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(List<ProductModel>.from(newProducts));
        _currentPage++;
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }

    _isFetching = false;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    _products = [];
    _currentPage = 1;
    _hasMore = true;
    await fetchNextPage();
  }
}
