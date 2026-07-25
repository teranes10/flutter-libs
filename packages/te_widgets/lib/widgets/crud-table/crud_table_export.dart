part of 'crud_table.dart';

extension _TCrudTableExportExt<T, K, F extends TFormBase> on _TCrudTableState<T, K, F> {
  void handleExportPdf() async {
    final controller = _currentTab == 0 ? _listController : _archiveListController;
    final items = controller.value.displayItems.map((e) => e.data).toList();
    if (items.isEmpty) return;

    final pdf = pw.Document();
    final colors = context.colors;
    final table = await TTableHelper.from(context, widget.headers, items);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          buildBackground: (context) => pw.FullPage(ignoreMargins: true, child: pw.Container(color: colors.surface.toPdfColor())),
        ),
        build: (context) => [
          pw.Text('Exported Data', style: pw.TextStyle(fontSize: 16, color: colors.onSurfaceVariant.toPdfColor())),
          pw.SizedBox(height: 15),
          table,
        ],
      ),
    );

    await pdf.download(fileName: "export_${DateTime.now().millisecondsSinceEpoch}");
  }

  void handleExportCsv() async {
    final controller = _currentTab == 0 ? _listController : _archiveListController;
    final items = controller.value.displayItems.map((e) => e.data).toList();
    if (items.isEmpty) return;

    final effectiveHeaders = widget.headers.where((h) => h.map != null).toList();
    final csvRows = <List<String>>[];

    // Headers
    csvRows.add(effectiveHeaders.map((h) => h.text).toList());

    // Data
    for (var item in items) {
      csvRows.add(effectiveHeaders.map((h) => h.getValue(item)).toList());
    }

    final csvString = csvRows.map((row) => row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(',')).join('\n');
    final bytes = utf8.encode(csvString);

    await FileSaver.instance.saveFile(
      name: "export_${DateTime.now().millisecondsSinceEpoch}",
      bytes: Uint8List.fromList(bytes),
      fileExtension: "csv",
      mimeType: MimeType.csv,
    );
  }
}
