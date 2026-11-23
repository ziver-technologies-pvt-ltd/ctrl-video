import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'app/theme.dart';
import 'data/database.dart';
import 'features/command_palette/command_palette.dart';
import 'features/history/history_screen.dart';
import 'features/home/download_screen.dart';
import 'features/queue/queue_screen.dart';
import 'features/settings/settings_screen.dart';
import 'services/download_execution_service.dart';
import 'services/download_manager.dart';
import 'services/engine_manager.dart';

// Riverpod singletons
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final engineManagerProvider = Provider<EngineManager>((ref) {
  return EngineManager();
});

final downloadManagerProvider = ChangeNotifierProvider<DownloadManager>((ref) {
  final db = ref.watch(databaseProvider);
  final execution = ref.watch(downloadExecutionServiceProvider);
  return DownloadManager(db: db, executionService: execution);
});

final engineStatusFutureProvider = FutureProvider<bool>((ref) async {
  final manager = ref.watch(engineManagerProvider);
  return manager.ensureEngineReady();
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const ProviderScope(child: CtrlVideoApp()));
}

class CtrlVideoApp extends StatelessWidget {
  const CtrlVideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ctrl+video',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainShellScreen(),
    );
  }
}

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _selectedIndex = 0;

  void _showCommandPalette() {
    CommandPaletteDialog.show(context, [
      CommandItem(
        label: 'Switch to Download',
        description: 'Open the download and URL paste workspace',
        icon: Icons.download_rounded,
        shortcut: '1',
        onSelect: () => setState(() => _selectedIndex = 0),
      ),
      CommandItem(
        label: 'Switch to Queue',
        description: 'View active and pending download tasks',
        icon: Icons.queue_rounded,
        shortcut: '2',
        onSelect: () => setState(() => _selectedIndex = 1),
      ),
      CommandItem(
        label: 'Switch to History',
        description: 'Browse local completed downloads',
        icon: Icons.history_rounded,
        shortcut: '3',
        onSelect: () => setState(() => _selectedIndex = 2),
      ),
      CommandItem(
        label: 'Open Settings',
        description: 'Configure download folder and preferences',
        icon: Icons.settings_rounded,
        shortcut: '4',
        onSelect: () => setState(() => _selectedIndex = 3),
      ),
      CommandItem(
        label: 'Update Engine',
        description: 'Check GitHub releases for yt-dlp update',
        icon: Icons.sync_rounded,
        shortcut: 'U',
        onSelect: () {
          ref.read(engineManagerProvider).ensureEngineReady();
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final engineReadyAsync = ref.watch(engineStatusFutureProvider);
    final queue = ref.watch(downloadManagerProvider).queue;
    final activeDownloads = queue.where((q) => q.status == DownloadStatus.downloading).length;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): _showCommandPalette,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): _showCommandPalette,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
              child: Image.asset(
                'lib/assets/logo.png',
                width: 36,
                height: 36,
              ),
            ),
            destinations: [
              const NavigationRailDestination(
                icon: Icon(Icons.download_outlined),
                selectedIcon: Icon(Icons.download),
                label: Text('Download'),
              ),
              NavigationRailDestination(
                icon: Badge(
                  isLabelVisible: activeDownloads > 0,
                  label: Text('$activeDownloads'),
                  child: const Icon(Icons.queue_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: activeDownloads > 0,
                  label: Text('$activeDownloads'),
                  child: const Icon(Icons.queue),
                ),
                label: Text('Queue'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: Text('History'),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // Main Area
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'ctrl+video',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(width: 12),
                      // Command Palette hint pill
                      InkWell(
                        onTap: _showCommandPalette,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_rounded, size: 14, color: Theme.of(context).colorScheme.outline),
                              const SizedBox(width: 4),
                              Text('Ctrl+K', style: AppTheme.monoStyle.copyWith(fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Engine Status Indicator
                      engineReadyAsync.when(
                        data: (ready) {
                          final manager = ref.watch(engineManagerProvider);
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                ready ? Icons.check_circle : Icons.warning_amber_rounded,
                                size: 16,
                                color: ready
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 160),
                                child: Text(
                                  ready
                                      ? 'Engine ready (${manager.ytDlpVersion ?? "local"})'
                                      : 'Engine missing binaries',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Initializing...',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        error: (err, _) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 16, color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 6),
                            Text('Engine error',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // View Selection
                Expanded(
                  child: _buildCurrentView(_selectedIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildCurrentView(int index) {
    switch (index) {
      case 0:
        return const DownloadScreen();
      case 1:
        return const QueueScreen();
      case 2:
        return const HistoryScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
