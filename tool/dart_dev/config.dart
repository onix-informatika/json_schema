import 'package:dart_dev/dart_dev.dart';
import 'package:glob/glob.dart';

final config = {
  'analyze': AnalyzeTool(),
  'format': FormatTool()..formatterArgs = ['--line-length=120'],
  'serve': WebdevServeTool()..webdevArgs = ['web:9000'],
  'test': TestTool(),
};
