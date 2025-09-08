import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:te_widgets/te_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  List<Map<String, dynamic>> userMaps = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'Admin',
      'createdAt': DateTime.now(),
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 3,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 4,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 5,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 6,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 7,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 8,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
    {
      'id': 9,
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'User',
      'createdAt': DateTime.now(),
    },
  ];

  void generatePdfWithTable() async {
    final lexendData = await rootBundle.load('packages/te_widgets/fonts/Lexend-Regular.ttf');
    final lexendBoldData = await rootBundle.load('packages/te_widgets/fonts/Lexend-Medium.ttf');
    final lexend = pw.Font.ttf(lexendData.buffer.asByteData());
    final lexendBold = pw.Font.ttf(lexendBoldData.buffer.asByteData());

    final pdf = pw.Document();

    final headers = ['ID', 'Name', 'Age'];
    final data = [
      ['1', 'Alice', '24'],
      ['2', 'Bob', '27'],
      ['3', 'Charlie', '31'],
    ];

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        build: (context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(
            'Table 1: List of Participants',
            style: pw.TextStyle(font: lexendBold, fontSize: 16, color: PdfColor.fromHex('#8EAEC6')),
          ),
          pw.SizedBox(height: 15),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data,
            border: pw.TableBorder.all(color: PdfColor.fromHex('#E9F3F6'), width: 0.1),
            headerStyle: pw.TextStyle(font: lexend, fontWeight: pw.FontWeight.normal, fontSize: 10, color: PdfColor.fromHex('#7393B3')),
            headerAlignment: pw.Alignment.centerLeft,
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: pw.TextStyle(font: lexend, fontSize: 10, color: PdfColor.fromHex('#3b3b3f')),
            cellPadding: const pw.EdgeInsets.all(5),
          ),
        ]),
      ),
    );

    // Save and download on Web
    final bytes = await pdf.save();
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'table.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        runSpacing: 50,
        children: [
          TButton(text: 'Print', onPressed: (_) => generatePdfWithTable()),
          TTable<Product>(
            headers: [
              TTableHeader.map("Name", (x) => x.name),
              TTableHeader.map("Price", (x) => x.price),
              TTableHeader.map("Stock", (x) => x.stock),
            ],
            items: products,
          ),
          TDataTable<Product>(
            headers: [
              TTableHeader.map("Name", (x) => x.name),
              TTableHeader.map("Price", (x) => x.price),
              TTableHeader.chip("Stock", (x) => x.stock, color: AppColors.info),
              TTableHeader.actions(
                (x) => [
                  TButtonGroupItem(tooltip: 'View', icon: Icons.remove_red_eye, color: AppColors.success, onPressed: (_) => {}),
                  TButtonGroupItem(tooltip: 'Edit', icon: Icons.edit, color: AppColors.info, onPressed: (_) => {}),
                  TButtonGroupItem(tooltip: 'Restore', icon: Icons.unarchive, color: AppColors.info, onPressed: (_) => {}),
                  TButtonGroupItem(tooltip: 'Archive', icon: Icons.archive, color: AppColors.warning, onPressed: (_) => {}),
                  TButtonGroupItem(tooltip: 'Delete', icon: Icons.delete_forever, color: AppColors.danger, onPressed: (_) => {}),
                ],
                maxWidth: 45 * 5,
              ),
            ],
            items: products,
          ),
        ],
      ),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });
}

class Product {
  final String id;
  final String name;
  final double price;
  final int stock;

  Product(this.id, this.name, this.price, this.stock);
}

final List<Product> products = List.generate(
  3,
  (index) => Product(
    'ID-${index + 1}',
    'Product Description ${index + 1}',
    10.0 + (index * 0.5),
    100 - index,
  ),
);
