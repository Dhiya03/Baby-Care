import 'package:flutter/foundation.dart' show kIsWeb;
import 'storage_service.dart';
import 'file_storage_service.dart';
import 'web_storage_service.dart';

StorageService getStorageService() {
  if (kIsWeb) {
    return WebStorageService();
  } else {
    return FileStorageService();
  }
}
