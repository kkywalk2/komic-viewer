import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/server_config.dart';
import '../../../providers/webdav_provider.dart';

class ServerFormScreen extends ConsumerStatefulWidget {
  final ServerConfig? server;

  const ServerFormScreen({super.key, this.server});

  @override
  ConsumerState<ServerFormScreen> createState() => _ServerFormScreenState();
}

class _ServerFormScreenState extends ConsumerState<ServerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _rootPathController;
  late bool _allowSelfSigned;
  bool _isPasswordVisible = false;
  bool _isTesting = false;
  bool _isSaving = false;

  bool get isEditing => widget.server != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.server?.name ?? '');
    _urlController = TextEditingController(text: widget.server?.url ?? '');
    _usernameController =
        TextEditingController(text: widget.server?.username ?? '');
    _passwordController =
        TextEditingController(text: widget.server?.password ?? '');
    _rootPathController =
        TextEditingController(text: widget.server?.rootPath ?? '/');
    _allowSelfSigned = widget.server?.allowSelfSigned ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _rootPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '서버 편집' : '서버 추가'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '표시 이름',
                hintText: '내 NAS',
                border: OutlineInputBorder(),
              ),
              validator: _validateName,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: '서버 URL',
                hintText: 'https://nas.example.com',
                border: OutlineInputBorder(),
              ),
              validator: _validateUrl,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '사용자명',
                border: OutlineInputBorder(),
              ),
              validator: _validateRequired,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
              validator: _validateRequired,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rootPathController,
              decoration: const InputDecoration(
                labelText: '루트 경로 (선택)',
                hintText: '/Comics',
                border: OutlineInputBorder(),
              ),
              validator: _validateRootPath,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('자체 서명 인증서 허용'),
              subtitle: const Text('보안 경고: 신뢰할 수 있는 서버에만 사용하세요'),
              value: _allowSelfSigned,
              onChanged: (value) {
                setState(() {
                  _allowSelfSigned = value;
                });
              },
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _isTesting ? null : _testConnection,
              icon: _isTesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_find),
              label: Text(_isTesting ? '테스트 중...' : '연결 테스트'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '표시 이름을 입력하세요';
    }
    if (value.length > 50) {
      return '최대 50자까지 입력 가능합니다';
    }
    return null;
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return '서버 URL을 입력하세요';
    }
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasScheme ||
        !['http', 'https'].contains(uri.scheme)) {
      return '올바른 URL 형식이 아닙니다 (http:// 또는 https://)';
    }
    return null;
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return '필수 항목입니다';
    }
    return null;
  }

  String? _validateRootPath(String? value) {
    if (value != null && value.isNotEmpty && !value.startsWith('/')) {
      return '경로는 /로 시작해야 합니다';
    }
    return null;
  }

  ServerConfig _buildConfig() {
    return ServerConfig(
      id: widget.server?.id ?? '',
      name: _nameController.text.trim(),
      url: _urlController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      rootPath: _rootPathController.text.trim().isEmpty
          ? '/'
          : _rootPathController.text.trim(),
      allowSelfSigned: _allowSelfSigned,
      createdAt: widget.server?.createdAt ?? DateTime.now(),
    );
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isTesting = true;
    });

    try {
      final config = _buildConfig();
      final success =
          await ref.read(serverConfigsProvider.notifier).testConnection(config);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '연결 성공!' : '연결 실패'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final config = _buildConfig();
      if (isEditing) {
        await ref.read(serverConfigsProvider.notifier).updateServer(config);
      } else {
        await ref.read(serverConfigsProvider.notifier).addServer(config);
      }

      if (!mounted) return;
      context.pop();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
