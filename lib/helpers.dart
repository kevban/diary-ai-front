import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Handles local storage. Use Shared preferences for web, file io for mobile
class LocalStorage {
  static dynamic getLocalStorage(String key, [bool? json]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object? item = prefs.get(key);
    if (item != null) {
      if (json == true) {
        Map<String, dynamic> map = jsonDecode(item as String);
        return map;
      } else {
        return item;
      }
    } else {
      return null;
    }
  }

  static void setLocalStorage(String key, dynamic item, String type,
      {String? identifier}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (type) {
      case 'string':
        prefs.setString(key, item);
        break;
      case 'int':
        prefs.setInt(key, item);
        break;
      case 'bool':
        prefs.setBool(key, item);
        break;
      case 'double':
        prefs.setDouble(key, item);
        break;
      case 'list':
        prefs.setStringList(key, item);
        break;
      case 'addToList': // This is to add an item to a string list
        List<String>? curList = await getLocalStorage(key);
        curList ??= <String>[];
        if (identifier != null) {
          List<String> newList = [];
          // If identifier is passed in, we are editting the item
          for (String listItem in curList) {
            if (listItem.contains(identifier)) {
              newList.add(item);
            } else {
              newList.add(listItem);
            }
          }
          prefs.setStringList(key, newList);
        } else {
          curList.add(item);
          prefs.setStringList(key, curList);
        }

        break;
      case 'image':
        prefs.setString(key, base64Encode(item));
        break;
      default:
        String json = jsonEncode(item);
        prefs.setString(key, json);
        break;
    }
  }

  /// read item from local file as string
  /// create it if it does not exist
  static Future<String?> getLocalFile(String relativePath) async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      var file = File('$path$relativePath');
      if (!file.existsSync()) {
        // creating the file if it does not exist
        file = await File('$path$relativePath').create(recursive: true);
      }
      final entries = await file.readAsString();
      return entries;
    } else {
      final item = await getLocalStorage(relativePath);
      if (item == null) {
        return null;
      } else if (item is String?) {
        return item;
      } else {
        return item.join('');
      }
    }
  }

  /// Get list of all file names in a directory, or a StringList from shared preferences
  /// create the directory if it does not exist
  static Future<List<String>> getLocalFiles(String relativePath) async {
    if (!kIsWeb) {
      final documentPath = (await getApplicationDocumentsDirectory()).path;
      var directory = Directory('$documentPath$relativePath');
      List<String> fileNames = [];
      if (!directory.existsSync()) {
        // creating the file if it does not exist
        directory = await Directory('$documentPath$relativePath')
            .create(recursive: true);
      }
      directory.listSync().forEach((FileSystemEntity entity) {
        if (entity is File) {
          fileNames.add(entity.path.split('/').last);
        }
      });
      return fileNames;
    } else {
      var item = await getLocalStorage(relativePath);
      if (item == null) {
        return [];
      }
      return item;
    }
  }

  static Future<void> saveLocalFile(String relativePath, String content,
      {String? fileName, String? identifier}) async {
    print('saveLocalFile ran');
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      var file = File('$path$relativePath/$fileName');
      if (!file.existsSync()) {
        // creating the file if it does not exist
        file = await File('$path$relativePath').create(recursive: true);
      }
      await file.writeAsString(content, mode: FileMode.write);
    } else {
      setLocalStorage(relativePath, content, 'addToList',
          identifier: identifier);
    }
    print('saveLocalFile finished');
  }
}

///Return the meta data header for content
String serializeMetaData(Map<String, String> data) {
  String serialized = '';
  data.forEach((key, value) {
    serialized = '$serialized$key:$value\n';
  });
  return '$serialized---\n';
}

///extract meta data object from content
Map<String, String> decodeMetaData(String content) {
  final lines = content.split('\n');
  Map<String, String> metadata = {};
  for (String line in lines) {
    if (line.contains('---')) {
      break;
    } else {
      final data = line.split(':');
      metadata[data[0]] = data[1];
    }
  }
  return metadata;
}
