import 'package:flutter/material.dart';
import 'package:product/Model/deleteModel.dart';

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
}
