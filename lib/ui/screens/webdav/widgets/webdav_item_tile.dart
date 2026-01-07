import 'package:flutter/material.dart';

import '../../../../data/models/webdav_item.dart';

class WebDavItemTile extends StatelessWidget {
  final WebDavItem item;
  final VoidCallback onTap;

  const WebDavItemTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(
        item.isDirectory ? Icons.folder : Icons.menu_book,
        color: item.isDirectory ? colorScheme.primary : colorScheme.outline,
        size: 32,
      ),
      title: Text(
        item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyLarge,
      ),
      subtitle: item.isDirectory
          ? null
          : Text(
              item.formattedSize,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
      trailing: item.isDirectory
          ? Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            )
          : null,
      onTap: onTap,
    );
  }
}
