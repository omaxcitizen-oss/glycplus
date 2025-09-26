import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/timeline_item.dart';

class CsvExportService {
  Future<String> exportTimelineToCsv(List<TimelineItem> timelineItems) async {
    final List<List<dynamic>> rows = [];
    // Headers
    rows.add(['Date', 'Time', 'Type', 'Value', 'Unit/Description']);

    for (var item in timelineItems) {
      final List<dynamic> row = [];
      row.add(item.date);
      row.add(item.time);
      row.add(item.type);
      row.add(item.value);
      row.add(item.unit);
      rows.add(row);
    }

    final String csv = const ListToCsvConverter().convert(rows);

    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/diabetes_export.csv';
      final file = File(path);
      await file.writeAsString(csv);
      return path;
    } else {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Veuillez sélectionner un emplacement pour enregistrer le fichier CSV',
        fileName: 'diabetes_export.csv',
        allowedExtensions: ['csv'],
      );
      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(csv);
        return outputFile;
      } else {
        return "Enregistrement annulé";
      }
    }
  }
}
