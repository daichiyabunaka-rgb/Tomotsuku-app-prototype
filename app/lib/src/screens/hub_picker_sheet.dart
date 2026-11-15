import 'package:flutter/material.dart';

import '../hub_registry.dart';
import '../services/app_state.dart';
import 'feature_requests_page.dart';
import 'hub_create_wizard_page.dart';
import 'hub_requests_page.dart';

/// ハブ（趣味ドメイン）を選ぶボトムシート。
/// 既存12ハブ + 承認済みのUGCハブから選べるほか、
/// Phase 2/3の「リクエスト」「つくる」への入口もここに置く。
Future<void> showHubPickerSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const HubPickerSheet(),
  );
}

class HubPickerSheet extends StatelessWidget {
  const HubPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = hubRegistry.active;
    final hubs = hubRegistry.available;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.hub, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('ハブを選ぶ', style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: hubs.length,
                itemBuilder: (context, i) {
                  final hub = hubs[i];
                  final selected = hub.appId == active.appId;
                  return ListTile(
                    leading: Icon(
                      hub.icon,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(hub.name),
                    subtitle: Text(
                      hub.tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: selected
                        ? Icon(Icons.check_circle,
                            color: theme.colorScheme.primary)
                        : (!hub.builtin
                            ? const Tooltip(
                                message: 'ユーザーが作ったハブ',
                                child: Icon(Icons.auto_awesome, size: 16),
                              )
                            : null),
                    onTap: selected
                        ? null
                        : () async {
                            Navigator.of(context).pop();
                            await appState.switchHub(hub);
                          },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: const Text('次のハブをリクエスト'),
              subtitle: const Text('欲しい趣味を投稿して賛同を集める'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(HubRequestsPage.route());
              },
            ),
            ListTile(
              leading: const Icon(Icons.construction_outlined),
              title: const Text('機能のリクエスト'),
              subtitle: const Text('欲しい機能を投稿して賛同を集める'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(FeatureRequestsPage.route());
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('ハブをつくる'),
              subtitle: const Text('オリジナルの趣味ハブを申請する（審査制）'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(HubCreateWizardPage.route());
              },
            ),
          ],
        ),
      ),
    );
  }
}
