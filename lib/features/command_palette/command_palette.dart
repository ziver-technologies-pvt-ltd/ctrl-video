import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';

class CommandItem {
  final String label;
  final String description;
  final IconData icon;
  final String? shortcut;
  final VoidCallback onSelect;

  const CommandItem({
    required this.label,
    required this.description,
    required this.icon,
    this.shortcut,
    required this.onSelect,
  });
}

class CommandPaletteDialog extends StatefulWidget {
  final List<CommandItem> commands;

  const CommandPaletteDialog({super.key, required this.commands});

  static Future<void> show(BuildContext context, List<CommandItem> commands) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => CommandPaletteDialog(commands: commands),
    );
  }

  @override
  State<CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<CommandPaletteDialog> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';
  int _selectedIndex = 0;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = widget.commands.where((cmd) {
      if (_query.isEmpty) return true;
      return cmd.label.toLowerCase().contains(_query.toLowerCase()) ||
          cmd.description.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 420),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColors.accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Type a command or search...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _query = val.trim();
                            _selectedIndex = 0;
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('ESC', style: AppTheme.monoStyle.copyWith(fontSize: 10)),
                    ),
                  ],
                ),
              ),

              // Command List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No matching commands found',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final cmd = filtered[index];
                          final isSelected = index == _selectedIndex;

                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              cmd.onSelect();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              color: isSelected ? AppColors.accent.withValues(alpha: 0.12) : null,
                              child: Row(
                                children: [
                                  Icon(
                                    cmd.icon,
                                    size: 18,
                                    color: isSelected ? AppColors.accent : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cmd.label,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          cmd.description,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (cmd.shortcut != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        cmd.shortcut!,
                                        style: AppTheme.monoStyle.copyWith(fontSize: 10),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
