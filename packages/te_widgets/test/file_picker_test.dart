import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:te_widgets/te_widgets.dart';

class MockFilePicker extends FilePicker with MockPlatformInterfaceMixin {
  final List<PlatformFile> filesToReturn;

  MockFilePicker(this.filesToReturn);

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    dynamic onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = true,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    return FilePickerResult(filesToReturn);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = TAppTheme.defaultTheme().lightTheme.copyWith(platform: TargetPlatform.macOS);

  testWidgets('TFilePicker onRemove provides List<TFile> when individual file is removed', (WidgetTester tester) async {
    final file1 = TFile(name: 'document.pdf', bytes: Uint8List.fromList([1, 2, 3]));
    final file2 = TFile(name: 'image.png', bytes: Uint8List.fromList([4, 5, 6]));

    List<TFile>? removedFiles;
    List<TFile>? changedFiles;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TFilePicker(
            label: 'Test Picker',
            value: [file1, file2],
            allowMultiple: true,
            onRemove: (files) {
              removedFiles = files;
            },
            onValueChanged: (files) {
              changedFiles = files;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('document.pdf'), findsOneWidget);
    expect(find.text('image.png'), findsOneWidget);

    // Find the close icon on the first tag and tap it
    final closeIcons = find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedCancel01);
    expect(closeIcons, findsNWidgets(2));

    await tester.tap(closeIcons.first);
    await tester.pumpAndSettle();

    expect(removedFiles, isNotNull);
    expect(removedFiles!.length, 1);
    expect(removedFiles!.first.name, 'document.pdf');
    expect(changedFiles?.length, 1);
    expect(changedFiles?.first.name, 'image.png');
  });

  testWidgets('TFilePicker onRemove provides List<TFile> when clear is tapped', (WidgetTester tester) async {
    final file1 = TFile(name: 'doc1.pdf', bytes: Uint8List.fromList([1, 2]));
    final file2 = TFile(name: 'doc2.pdf', bytes: Uint8List.fromList([3, 4]));

    List<TFile>? removedFiles;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TFilePicker(
            label: 'Test Picker',
            value: [file1, file2],
            clearable: true,
            allowMultiple: true,
            onRemove: (files) {
              removedFiles = files;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final clearButton = find.byWidgetPredicate((widget) => widget is TIcon && widget.onTap != null);
    expect(clearButton, findsOneWidget);

    await tester.tap(clearButton);
    await tester.pumpAndSettle();

    expect(removedFiles, isNotNull);
    expect(removedFiles!.length, 2);
    expect(removedFiles!.map((f) => f.name).toList(), ['doc1.pdf', 'doc2.pdf']);
  });

  testWidgets('TFilePicker onRemove provides List<TFile> in gallery mode', (WidgetTester tester) async {
    final file = TFile(name: 'photo.png', bytes: Uint8List.fromList([1, 2, 3]));
    List<TFile>? removedFiles;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TFilePicker(
            label: 'Gallery Picker',
            value: [file],
            isGalleryMode: true,
            onRemove: (files) => removedFiles = files,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final closeIcon = find.byWidgetPredicate((w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedCancel01);
    expect(closeIcon, findsOneWidget);

    await tester.tap(closeIcon);
    await tester.pumpAndSettle();

    expect(removedFiles, isNotNull);
    expect(removedFiles!.length, 1);
    expect(removedFiles!.first.name, 'photo.png');
  });

  testWidgets('TFilePicker onAdd provides List<TFile> when files are picked', (WidgetTester tester) async {
    final newPlatformFile = PlatformFile(
      name: 'picked_image.png',
      size: 5,
      bytes: Uint8List.fromList([10, 20, 30, 40, 50]),
    );
    FilePicker.platform = MockFilePicker([newPlatformFile]);

    List<TFile>? addedFiles;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TFilePicker(
            label: 'Upload',
            allowMultiple: true,
            onAdd: (files) => addedFiles = files,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the picker to trigger picking
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(addedFiles, isNotNull);
    expect(addedFiles!.length, 1);
    expect(addedFiles!.first.name, 'picked_image.png');
    expect(find.text('picked_image.png'), findsOneWidget);
  });

  testWidgets('TFilePicker onAdd and onRemove when single file selection replaces existing file', (WidgetTester tester) async {
    final oldFile = TFile(name: 'old.png', bytes: Uint8List.fromList([1, 2, 3]));
    final newPlatformFile = PlatformFile(
      name: 'new.png',
      size: 3,
      bytes: Uint8List.fromList([4, 5, 6]),
    );
    FilePicker.platform = MockFilePicker([newPlatformFile]);

    List<TFile>? addedFiles;
    List<TFile>? removedFiles;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: TFilePicker(
            label: 'Single File',
            value: [oldFile],
            allowMultiple: false,
            onAdd: (files) => addedFiles = files,
            onRemove: (files) => removedFiles = files,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the picker (not the close button on the tag)
    await tester.tap(find.text('old.png'));
    await tester.pumpAndSettle();

    expect(removedFiles, isNotNull);
    expect(removedFiles!.length, 1);
    expect(removedFiles!.first.name, 'old.png');

    expect(addedFiles, isNotNull);
    expect(addedFiles!.length, 1);
    expect(addedFiles!.first.name, 'new.png');
  });

  testWidgets('TFormField.filePicker supports onAdd and onRemove', (WidgetTester tester) async {
    final prop = TFieldProp<List<TFile>>([]);
    List<TFile>? added;
    List<TFile>? removed;

    final field = TFormField.filePicker(
      prop,
      'Files',
      onAdd: (files) => added = files,
      onRemove: (files) => removed = files,
    );

    expect(field, isNotNull);
    expect(added, isNull);
    expect(removed, isNull);
  });
}
