class ServerConfig {
  final String id;
  final String name;
  final String url;
  final String username;
  final String password;
  final String rootPath;
  final bool allowSelfSigned;
  final DateTime createdAt;

  const ServerConfig({
    required this.id,
    required this.name,
    required this.url,
    required this.username,
    required this.password,
    this.rootPath = '/',
    this.allowSelfSigned = false,
    required this.createdAt,
  });

  ServerConfig copyWith({
    String? id,
    String? name,
    String? url,
    String? username,
    String? password,
    String? rootPath,
    bool? allowSelfSigned,
    DateTime? createdAt,
  }) {
    return ServerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      rootPath: rootPath ?? this.rootPath,
      allowSelfSigned: allowSelfSigned ?? this.allowSelfSigned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'username': username,
      'password_encrypted': password,
      'root_path': rootPath,
      'allow_self_signed': allowSelfSigned ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ServerConfig.fromMap(Map<String, dynamic> map) {
    return ServerConfig(
      id: map['id'] as String,
      name: map['name'] as String,
      url: map['url'] as String,
      username: map['username'] as String,
      password: map['password_encrypted'] as String,
      rootPath: map['root_path'] as String? ?? '/',
      allowSelfSigned: (map['allow_self_signed'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerConfig &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
