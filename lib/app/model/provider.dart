import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';

class DataProvider {
  Future<File> _getProviderFile() async {
    final folder = await getApplicationDocumentsDirectory();
    return new File("${folder.path}/data.json");
  }

  Future<File> saveFileContents(String data) async {
    final file = await _getProviderFile();
    /*if(!(await file.exists())){
      await file.create();
    }*/
    return file.writeAsString(data);
  }

  Future<String> getFileContents() async {
    final file = await _getProviderFile();
    return file.readAsString();
  }
}
