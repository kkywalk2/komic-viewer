import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/file_utils.dart';
import '../../../providers/preferences_provider.dart';
import '../../../services/thumbnail_service.dart';
import '../../../services/download_manager.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _thumbnailCacheSize = 0;
  bool _isLoadingCacheSize = true;
  bool _isClearingCache = false;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    setState(() => _isLoadingCacheSize = true);
    try {
      final thumbnailSize = await ThumbnailService.instance.getThumbnailCacheSize();
      setState(() {
        _thumbnailCacheSize = thumbnailSize;
        _isLoadingCacheSize = false;
      });
    } catch (e) {
      setState(() => _isLoadingCacheSize = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final readerPrefs = ref.watch(readerPreferencesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // Reading Section
          _buildSectionHeader('읽기'),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('읽기 방향'),
            subtitle: Text(readerPrefs.direction.displayName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReadingDirectionDialog(context),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_high),
            title: const Text('화면 켜짐 유지'),
            subtitle: const Text('읽는 동안 화면이 꺼지지 않습니다'),
            value: readerPrefs.keepScreenOn,
            onChanged: (value) {
              ref
                  .read(readerPreferencesNotifierProvider.notifier)
                  .setKeepScreenOn(value);
            },
          ),
          const Divider(),

          // WebDAV Section
          _buildSectionHeader('WebDAV 서버'),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('서버 관리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/servers'),
          ),
          const Divider(),

          // Storage Section
          _buildSectionHeader('저장소'),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('썸네일 캐시'),
            subtitle: Text(
              _isLoadingCacheSize
                  ? '계산 중...'
                  : formatFileSize(_thumbnailCacheSize),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('썸네일 캐시 비우기'),
            onTap: _isClearingCache ? null : () => _clearThumbnailCache(context),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('다운로드 캐시 비우기'),
            subtitle: const Text('다운로드한 WebDAV 파일 삭제'),
            onTap: _isClearingCache ? null : () => _clearDownloadCache(context),
          ),
          const Divider(),

          // Info Section
          _buildSectionHeader('정보'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('버전'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showReadingDirectionDialog(BuildContext context) {
    final currentDirection = ref.read(readerPreferencesNotifierProvider).direction;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('읽기 방향'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ReadingDirection.values.map((direction) {
              return RadioListTile<ReadingDirection>(
                title: Text(direction.displayName),
                value: direction,
                groupValue: currentDirection,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(readerPreferencesNotifierProvider.notifier)
                        .setReadingDirection(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _clearThumbnailCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('썸네일 캐시 비우기'),
        content: const Text('모든 썸네일 캐시를 삭제하시겠습니까?\n다음에 책을 열 때 다시 생성됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isClearingCache = true);
      try {
        await ThumbnailService.instance.clearAllThumbnails();
        await _loadCacheSize();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('썸네일 캐시가 삭제되었습니다')),
          );
        }
      } finally {
        setState(() => _isClearingCache = false);
      }
    }
  }

  Future<void> _clearDownloadCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('다운로드 캐시 비우기'),
        content: const Text('다운로드한 WebDAV 파일을 모두 삭제하시겠습니까?\n다시 열 때 재다운로드가 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isClearingCache = true);
      try {
        await DownloadManager.instance.clearCache();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('다운로드 캐시가 삭제되었습니다')),
          );
        }
      } finally {
        setState(() => _isClearingCache = false);
      }
    }
  }
}
