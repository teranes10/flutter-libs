import 'dart:io';
import 'package:yaml/yaml.dart';

void main() {
  final dir = Directory('packages/te_map');
  for (final file in dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.yaml'))) {
    try {
      loadYaml(file.readAsStringSync());
    } catch (e) {
      print('Error in ${file.path}: $e');
    }
  }
}
