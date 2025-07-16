import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:product/model/deleteModel.dart';
import 'package:product/model/product_model.dart';
import 'package:product/page/search_page/search_page_provider.dart';
import 'package:product/provider/product_provider.dart';
import 'package:provider/provider.dart';

class SearchPageScreen extends StatefulWidget {
  const SearchPageScreen({super.key});

  @override
  State<SearchPageScreen> createState() => _SearchPageScreenState();
}

class _SearchPageScreenState extends State<SearchPageScreen> {
  final _formKey = GlobalKey<FormState>();
  void _confirmDeleteSelected(
    ProductProvider provider,
    SearchPageProvider searchPro,
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
              for (var item in searchPro.isSelect) {
                await provider.deleteProduct(item.productID);
              }
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(content: Text("Product updated successfully")),
              );
              await provider.fetchAllProduct();
              searchPro.removeAllIndex;
              searchPro.setSelectionMode(false);
            },
            child: Text("Delete All"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    final pro = Provider.of<ProductProvider>(context);
    final searchPro = Provider.of<SearchPageProvider>(context);
    return SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  searchPro.clearproduct;
                  searchPro.removeAllIndex;
                  searchPro.setSelectionMode(false);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.red),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10, top: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    autofocus: true,
                    controller: searchPro.searchController,
                    onChanged: (value) {
                      searchPro.setSearchController(value.trim());
                      searchPro.setProduct(searchPro.searchValue, pro.products);
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, size: 30),
                      hint: Text("Search Products"),
                      suffixIcon: searchPro.isSelectionMode
                          ? IconButton(
                              onPressed: () {
                                _confirmDeleteSelected(pro, searchPro);
                              },
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                            )
                          : IconButton(
                              onPressed: () {
                                searchPro.clearSearch();
                              },
                              icon: Icon(Icons.close),
                            ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchPro.getProduct.isEmpty
                  ? pro.products.length
                  : searchPro.getProduct.length,
              itemBuilder: (context, index) {
                if (searchPro.getProduct.isEmpty) {
                  return _buildCard(index, pro.products[index], pro, searchPro);
                }
                return _buildCard(
                  index,
                  searchPro.getProduct[index],
                  pro,
                  searchPro,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    int index,
    ProductModel p,
    ProductProvider pro,
    SearchPageProvider searchPro,
  ) {
    final isSelected = searchPro.isSelect.any(
      (e) => e.productID == p.productid,
    );

    return GestureDetector(
      onLongPress: () {
        if (!searchPro.isSelectionMode) {
          searchPro.setSelectionMode(true);
          searchPro.addSelect(
            Deletemodel(index: index, productID: p.productid),
          );
        }
      },
      onTap: () {
        if (searchPro.isSelectionMode) {
          searchPro.addSelect(
            Deletemodel(index: index, productID: p.productid),
          );
          if (searchPro.isSelect.isEmpty) {
            searchPro.setSelectionMode(false);
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
                _buildDialog(p, pro, searchPro: searchPro);
              },
              icon: !searchPro.isSelectionMode
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
    required SearchPageProvider searchPro,
  }) {
    searchPro.setProNameController(pro.productname);
    searchPro.setProPriceController(pro.price.toString());
    searchPro.setProStockController(pro.stock.toString());
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
                          controller: searchPro.proNameController,
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
                              searchPro.setProNameController(value),
                        ),

                        TextFormField(
                          controller: searchPro.proPriceController,
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
                              searchPro.setProPriceController(value),
                          onSaved: (value) {},
                        ),

                        TextFormField(
                          controller: searchPro.proStockController,
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
                              searchPro.setProStockController(value),
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
                            await provider.update(
                              context: context,
                              product: ProductModel(
                                productid: pro.productid,
                                productname: searchPro.getProNameController,
                                price: searchPro.getProPriceController,
                                stock: searchPro.getProStockController,
                              ),
                            );
                            searchPro.setProNameController("");
                            searchPro.setProStockController("");
                            searchPro.setProPriceController("");
                            Navigator.pop(context);
                            Navigator.pop(context);
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
                      child: Text("Update"),
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
