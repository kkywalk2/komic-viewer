import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/server_config.dart';
import '../../../providers/webdav_provider.dart';

class ServerListScreen extends ConsumerWidget {
  const ServerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serversState = ref.watch(serverConfigsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebDAV 서버'),
      ),
      body: serversState.when(
        data: (servers) {
          if (servers.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildServerList(context, ref, servers);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('오류: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(serverConfigsProvider.notifier).loadServers();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/servers/add'),
        icon: const Icon(Icons.add),
        label: const Text('서버 추가'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'WebDAV 서버가 없습니다',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '서버를 추가하여 원격 만화를 탐색하세요',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerList(
    BuildContext context,
    WidgetRef ref,
    List<ServerConfig> servers,
  ) {
    return ListView.builder(
      itemCount: servers.length,
      itemBuilder: (context, index) {
        final server = servers[index];
        return _ServerListTile(server: server);
      },
    );
  }
}

class _ServerListTile extends ConsumerWidget {
  final ServerConfig server;

  const _ServerListTile({required this.server});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          Icons.dns,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(server.name),
      subtitle: Text(
        server.url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/servers/${server.id}/browse', extra: server),
      onLongPress: () => _showContextMenu(context, ref),
    );
  }

  void _showContextMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('편집'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/servers/${server.id}/edit', extra: server);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('삭제'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('서버 삭제'),
          content: Text('"${server.name}" 서버를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(serverConfigsProvider.notifier).deleteServer(server.id);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
