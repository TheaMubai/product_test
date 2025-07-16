import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/Export_to_pdf/export_to_pdf.dart';
import 'package:product/Model/deleteModel.dart';
import 'package:product/Model/product_model.dart';
import 'package:product/page/main_page/main_page_provider.dart';
import 'package:product/page/search_page/search_page_screen.dart';
import 'package:product/provider/crud_provider.dart';
import 'package:provider/provider.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  final _formKey = GlobalKey<FormState>();
  void _confirmDeleteSelected(
    ProductProvider provider,
    MainPageProvider mainPro,
  ) {
    final rootContext = context;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete all selected products?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              for (var item in mainPro.isSelect) {
                await provider.deleteProduct(item.productID);
              }
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(content: Text("Product updated successfully")),
              );
              await provider.fetchAllProduct();
              mainPro.removeAllIndex;
              mainPro.setSelectionMode(false);
            },
            child: Text("Delete All"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchAllProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final provider = Provider.of<ProductProvider>(context);
    final mainPro = Provider.of<MainPageProvider>(context);
    final export = ExportToPdf();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: mainPro.isSelect.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  mainPro.removeAllIndex;
                  mainPro.setSelectionMode(false);
                },
                icon: Icon(Icons.close),
              ),
        title: mainPro.isSelect.isEmpty
            ? Text(
                "Product Shop",
                style: GoogleFonts.robotoSlab(
                  textStyle: TextStyle(color: Colors.white),
                ),
              )
            : Text(
                "Selected Product",
                style: GoogleFonts.robotoSlab(
                  textStyle: TextStyle(color: Colors.white),
                ),
              ),
        flexibleSpace: _buildAppBar(mainPro),
        actions: [
          IconButton(
            onPressed: () => export.exportToPDF(provider.products),
            icon: mainPro.isSelect.isEmpty
                ? Icon(
                    Icons.download_for_offline_outlined,
                    color: Colors.white,
                    size: 30,
                  )
                : SizedBox(),
          ),
          mainPro.isSelect.isEmpty
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPageScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.search, size: 30, color: Colors.white),
                )
              : IconButton(
                  onPressed: () => _confirmDeleteSelected(provider, mainPro),
                  icon: Icon(Icons.delete, size: 30, color: Colors.redAccent),
                ),

          SizedBox(width: width / 15),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: mainPro.currentSortBy,
                    dropdownColor: Colors.blueGrey[900],
                    items: ['price', 'stock'].map((val) {
                      return DropdownMenuItem(
                        value: val,
                        child: Text(
                          "Sort by $val",
                          style: GoogleFonts.robotoSlab(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        mainPro.sortProductList(
                          provider.products,
                          val,
                          mainPro.isAscending,
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      mainPro.isAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      mainPro.sortProductList(
                        provider.products,
                        mainPro.currentSortBy,
                        !mainPro.isAscending,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: provider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => provider.fetchAllProduct(),
                      child: ListView.builder(
                        itemCount: provider.products.length,
                        itemBuilder: (context, index) => _buildCard(
                          index,
                          provider.products[index],
                          provider,
                          mainPro,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: mainPro.isSelectionMode
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: () => _buildDialog(
                mainpro: mainPro,
                word: "add",
                ProductModel(productid: 0, productname: "", price: 0, stock: 0),
                provider,
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildAppBar(MainPageProvider pro) {
    return Container(
      decoration: BoxDecoration(
        color: pro.isSelect.isEmpty ? Colors.blue[900] : Colors.blue.shade700,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(100)),
      ),
    );
  }

  Widget _buildCard(
    int index,
    ProductModel p,
    ProductProvider pro,
    MainPageProvider mainPro,
  ) {
    final isSelected = mainPro.isSelect.any((e) => e.productID == p.productid);

    return GestureDetector(
      onLongPress: () {
        if (!mainPro.isSelectionMode) {
          mainPro.setSelectionMode(true);
          mainPro.addSelect(Deletemodel(index: index, productID: p.productid));
        }
      },
      onTap: () {
        if (mainPro.isSelectionMode) {
          mainPro.addSelect(Deletemodel(index: index, productID: p.productid));
          if (mainPro.isSelect.isEmpty) {
            mainPro.setSelectionMode(false);
          }
        }
      },
      child: Card(
        color: isSelected ? Colors.blue.shade100 : Colors.white,
        child: Container(
          padding: const EdgeInsets.only(bottom: 7),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.productname,
                  style: GoogleFonts.robotoSlab(fontSize: 20),
                ),
                Text(""),
              ],
            ),
            subtitle: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "  Price: ${p.price} \$  ",
                    style: GoogleFonts.robotoSlab(fontSize: 17),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "  Stock: ${p.stock}  ",
                    style: GoogleFonts.robotoSlab(fontSize: 17),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                _buildDialog(p, pro, word: "update", mainpro: mainPro);
              },
              icon: !mainPro.isSelectionMode
                  ? Icon(Icons.edit, color: Colors.blue)
                  : SizedBox(),
            ),
          ),
        ),
      ),
    );
  }

  void _buildDialog(
    ProductModel pro,
    ProductProvider provider, {
    required String word,
    required MainPageProvider mainpro,
  }) {
    if (word == "add") {
      mainpro.setProNameController("");
      mainpro.setProPriceController("");
      mainpro.setProStockController("");
    } else {
      mainpro.setProNameController(pro.productname);
      mainpro.setProPriceController(pro.price.toString());
      mainpro.setProStockController(pro.stock.toString());
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 1.3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextFormField(
                          controller: mainpro.proNameController,
                          decoration: InputDecoration(
                            labelText: 'Product name',
                            hint: Text("Please input product name"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter product name';
                            }
                            return null;
                          },
                          onChanged: (value) =>
                              mainpro.setProNameController(value),
                        ),

                        TextFormField(
                          controller: mainpro.proPriceController,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            hint: Text("Please input price (\$)"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter price';
                            } else if (double.parse(value) <= 0) {
                              return 'Price must be bigger than 0';
                            }
                            return null;
                          },
                          onChanged: (value) =>
                              mainpro.setProPriceController(value),
                          onSaved: (value) {},
                        ),

                        TextFormField(
                          controller: mainpro.proStockController,
                          decoration: InputDecoration(
                            labelText: 'Stock',
                            hint: Text("Please input stock"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter stock';
                            } else if (double.parse(value) <= 0) {
                              return 'Stock must be bigger than 0';
                            }
                            return null;
                          },
                          onChanged: (value) =>
                              mainpro.setProStockController(value),
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) =>
                                Center(child: CircularProgressIndicator()),
                          );
                          try {
                            if (word == "add") {
                              await provider.addProduct(
                                context: context,
                                product: ProductModel(
                                  productid: pro.productid,
                                  productname: mainpro.getProNameController,
                                  price: mainpro.getProPriceController,
                                  stock: mainpro.getProStockController,
                                ),
                              );
                              mainpro.setProNameController("");
                              mainpro.setProStockController("");
                              mainpro.setProPriceController("");
                              Navigator.pop(context);
                              Navigator.pop(context);
                            } else {
                              await provider.update(
                                context: context,
                                product: ProductModel(
                                  productid: pro.productid,
                                  productname: mainpro.getProNameController,
                                  price: mainpro.getProPriceController,
                                  stock: mainpro.getProStockController,
                                ),
                              );
                              mainpro.setProNameController("");
                              mainpro.setProStockController("");
                              mainpro.setProPriceController("");
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Something went wrong: $e"),
                              ),
                            );
                          }
                        }
                      },
                      child: word == "add"
                          ? Text("Add new product")
                          : Text("Update"),
                    ),
                  ),
                  Expanded(flex: 1, child: SizedBox()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
