import 'dart:io';
import 'dart:ui';
import 'package:product/Model/product_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExportToPdf {
  Future<void> exportToPDF(List<ProductModel> products) async {
    final PdfDocument document = PdfDocument();
    final PdfGrid grid = PdfGrid();

    grid.columns.add(count: 4);
    grid.headers.add(1);
    grid.headers[0].cells[0].value = 'ID';
    grid.headers[0].cells[1].value = 'Product';
    grid.headers[0].cells[2].value = 'Price';
    grid.headers[0].cells[3].value = 'Stock';

    for (var p in products) {
      grid.rows.add().cells
        ..[0].value = p.productid.toString()
        ..[1].value = p.productname
        ..[2].value = p.price.toString()
        ..[3].value = p.stock.toString();
    }

    grid.draw(
      page: document.pages.add(),
      bounds: const Rect.fromLTWH(0, 0, 500, 800),
    );

    final List<int> bytes = await document.save();
    document.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/products.pdf');
    await file.writeAsBytes(bytes);
    OpenFile.open(file.path);
  }
}
