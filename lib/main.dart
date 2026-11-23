import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme.dart';
import 'features/home/download_screen.dart';
import 'services/engine_manager.dart';

// Riverpod providers for core singletons
final engineManagerProvider = Provider<EngineManager>((ref) {
  return EngineManager();
});

final engineStatusFutureProvider = FutureProvider<bool>((ref) async {
  final manager = ref.watch(engineManagerProvider);
  return manager.ensureEngineReady();
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  @override
  Widget build(BuildContext context) {
    final engineReadyAsync = ref.watch(engineStatusFutureProvider);

    return Scaffold(
      body: Row(
        children: [
          // Desktop Navigation Rail
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
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.download_outlined),
                selectedIcon: Icon(Icons.download),
                label: Text('Download'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.queue_outlined),
                selectedIcon: Icon(Icons.queue),
                label: Text('Queue'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: Text('History'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),

          // Main Screen Area
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                      const Spacer(),
                      // Engine Status Indicator
                      engineReadyAsync.when(
                        data: (ready) {
                          final manager = ref.watch(engineManagerProvider);
                          return Row(
                            children: [
                              Icon(
                                ready ? Icons.check_circle : Icons.warning_amber_rounded,
                                size: 16,
                                color: ready
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                ready
                                    ? 'Engine ready (${manager.ytDlpVersion ?? "local"})'
                                    : 'Engine missing binaries',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          );
                        },
                        loading: () => Row(
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Initializing engine...',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        error: (err, _) => Row(
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

                // Content View according to selected tab
                Expanded(
                  child: _buildCurrentView(_selectedIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(int index) {
    switch (index) {
      case 0:
        return const DownloadScreen();
      case 1:
        return _buildPlaceholderView('No active downloads in queue', Icons.inbox_outlined);
      case 2:
        return _buildPlaceholderView('No download history yet', Icons.history_rounded);
      case 3:
        return _buildPlaceholderView('Settings and configurations', Icons.tune_rounded);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPlaceholderView(String label, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
