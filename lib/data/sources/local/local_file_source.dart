import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/file_utils.dart';
import '../../../core/utils/hash_utils.dart';
import '../../models/comic_book.dart';

class LocalFileSource {
  static LocalFileSource? _instance;

  LocalFileSource._();

  static LocalFileSource get instance {
    _instance ??= LocalFileSource._();
    return _instance!;
  }

  Future<String> _getLocalStorageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final comicsDir = Directory(p.join(appDir.path, 'comics'));
    if (!await comicsDir.exists()) {
      await comicsDir.create(recursive: true);
    }
    return comicsDir.path;
  }

  Future<ComicBook?> pickAndImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'cbz'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final pickedFile = result.files.first;
    if (pickedFile.path == null) {
      return null;
    }

    return await importFile(pickedFile.path!);
  }

  Future<ComicBook> importFile(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw Exception('File not found: $sourcePath');
    }

    final storageDir = await _getLocalStorageDirectory();
    final fileName = p.basename(sourcePath);
    final destinationPath = p.join(storageDir, fileName);

    final destinationFile = File(destinationPath);
    if (!await destinationFile.exists()) {
      await sourceFile.copy(destinationPath);
    }

    final bookId = generateBookId(ComicSource.local, null, destinationPath);
    final title = getTitleFromPath(destinationPath);
    final fileSize = await destinationFile.length();

    return ComicBook(
      id: bookId,
      title: title,
      path: destinationPath,
      source: ComicSource.local,
      fileSize: fileSize,
      addedAt: DateTime.now(),
    );
  }

  Future<List<ComicBook>> getLocalBooks() async {
    final storageDir = await _getLocalStorageDirectory();
    final directory = Directory(storageDir);

    if (!await directory.exists()) {
      return [];
    }

    final books = <ComicBook>[];
    await for (final entity in directory.list()) {
      if (entity is File && isSupportedArchive(entity.path)) {
        final bookId = generateBookId(ComicSource.local, null, entity.path);
        final title = getTitleFromPath(entity.path);
        final stat = await entity.stat();

        books.add(ComicBook(
          id: bookId,
          title: title,
          path: entity.path,
          source: ComicSource.local,
          fileSize: stat.size,
          addedAt: stat.modified,
        ));
      }
    }

    return books;
  }

  Future<void> deleteBook(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
