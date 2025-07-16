import 'package:flutter/material.dart';
import 'package:product/model/deleteModel.dart';
import 'package:product/model/product_model.dart';

class SearchPageProvider extends ChangeNotifier {
  final proNameController = TextEditingController();
  final proPriceController = TextEditingController();
  final proStockController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final List<Deletemodel> _isSelect = [];
  List<Deletemodel> get isSelect => _isSelect;
  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;
  String _searchValue = "";
  String get searchValue => _searchValue;
  List<ProductModel> _product = [];
  List<ProductModel> get getProduct => _product;
  

  void setProduct(String text, List<ProductModel> p) {
    _product = p
        .where(
          (element) =>
              element.productname.toLowerCase().contains(text.toLowerCase()),
        )
        .toList();
    notifyListeners();
  }

  void get clearproduct {
    _product.clear();
    notifyListeners();
  }

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

  void setSearchController(String text) {
    _searchValue = text;
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _searchValue = "";
    notifyListeners();
  }

  String get getSearchController {
    return searchController.text.trim();
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
}
