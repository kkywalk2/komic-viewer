import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../data/models/comic_book.dart';

String generateBookId(ComicSource source, String? serverId, String path) {
  final input = '${source.name}:${serverId ?? 'local'}:$path';
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString().substring(0, 16);
}
