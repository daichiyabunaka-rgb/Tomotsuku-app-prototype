import 'package:flutter/material.dart';

import '../hub_registry.dart';
import '../services/app_state.dart';
import 'communities_page.dart';
import 'explore_page.dart';
import 'game_goods_exchanges_page.dart';
import 'hub_picker_sheet.dart';
import 'my_page.dart';
import 'near_page.dart';
import 'rooms_page.dart';

/// ホーム: 近く / 部屋 / コミュニティ / ゆずりあい / 探す / マイページ（仕様書 8 章参照）
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final hub = hubRegistry.active;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const NearPage(),
          const RoomsPage(),
          const CommunitiesPage(),
          ListenableBuilder(
            listenable: appState,
            builder: (context, _) {
              final current = hubRegistry.active;
              return current.hasExchange
                  ? const GameGoodsExchangesPage()
                  : const _NoExchangeView();
            },
          ),
          const ExplorePage(),
          const MyPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.near_me_outlined),
            selectedIcon: Icon(Icons.near_me),
            label: '近く',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: '部屋',
          ),
          const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'コミュニティ',
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz_outlined),
            selectedIcon: const Icon(Icons.swap_horiz),
            label: hub.hasExchange ? hub.exchangeLabel : 'ゆずりあい',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search),
            label: '探す',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'マイページ',
          ),
        ],
      ),
    );
  }
}

/// ゆずりあいボードをもたないハブで表示する案内。
class _NoExchangeView extends StatelessWidget {
  const _NoExchangeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(hubRegistry.active.exchangeLabel)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz,
                  size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text(
                'このハブにはゆずりあいボードがありません。\n'
                '他のハブに切り替えると使えます。',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => showHubPickerSheet(context),
                icon: const Icon(Icons.hub_outlined),
                label: const Text('ハブを選ぶ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
