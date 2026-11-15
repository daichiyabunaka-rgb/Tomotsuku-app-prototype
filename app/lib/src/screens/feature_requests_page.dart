import 'package:flutter/material.dart';

import '../hub_registry.dart';
import '../models.dart';
import '../services/app_state.dart';

/// 「機能のリクエスト」ボード（Phase 2・課題2の解決）。
/// ユーザーが「この機能が欲しい」を投稿し、賛同を集める。
/// hubId が null のものは全ハブ共通の要望。
class FeatureRequestsPage extends StatefulWidget {
  const FeatureRequestsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const FeatureRequestsPage());

  @override
  State<FeatureRequestsPage> createState() => _FeatureRequestsPageState();
}

class _FeatureRequestsPageState extends State<FeatureRequestsPage> {
  @override
  void initState() {
    super.initState();
    appState.loadFeatureRequests();
    appState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    appState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openCreateSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _FeatureRequestCreateSheet(),
    );
    if (created == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requests = appState.featureRequests;
    return Scaffold(
      appBar: AppBar(
        title: const Text('機能のリクエスト'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSheet,
        icon: const Icon(Icons.add),
        label: const Text('リクエスト'),
      ),
      body: RefreshIndicator(
        onRefresh: () => appState.loadFeatureRequests(),
        child: requests.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 64),
                  Icon(Icons.construction,
                      size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'まだリクエストがありません。\n「こんな機能が欲しい！」を最初に投稿してみませんか？',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: requests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _RequestCard(
                  request: requests[i],
                  onVote: () => appState.toggleFeatureVote(requests[i].id),
                ),
              ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final FeatureRequest request;
  final VoidCallback onVote;

  const _RequestCard({required this.request, required this.onVote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hubLabel = _hubLabel(request.hubId);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hubLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        hubLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  Text(request.featureName,
                      style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  if (request.description.isNotEmpty)
                    Text(
                      request.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _statusLabel(request.status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _statusColor(request.status, theme),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onVote,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: request.myVote
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      request.myVote
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
                      color: request.myVote
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    Text('${request.voteCount}',
                        style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _hubLabel(String? hubId) {
    if (hubId == null) return '全体';
    try {
      return hubRegistry.byId(hubId).name;
    } catch (_) {
      return hubId;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'planned':
        return '開発を検討しています';
      case 'shipped':
        return '実装されました';
      case 'rejected':
        return '見送り';
      default:
        return '賛同を募集中';
    }
  }

  Color _statusColor(String status, ThemeData theme) {
    switch (status) {
      case 'planned':
        return theme.colorScheme.primary;
      case 'shipped':
        return theme.colorScheme.primary;
      case 'rejected':
        return theme.colorScheme.outline;
      default:
        return theme.colorScheme.outline;
    }
  }
}

class _FeatureRequestCreateSheet extends StatefulWidget {
  const _FeatureRequestCreateSheet();

  @override
  State<_FeatureRequestCreateSheet> createState() =>
      _FeatureRequestCreateSheetState();
}

class _FeatureRequestCreateSheetState extends State<_FeatureRequestCreateSheet> {
  final _featureName = TextEditingController();
  final _description = TextEditingController();
  String? _hubId; // null = 全体
  bool _submitting = false;

  @override
  void dispose() {
    _featureName.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _featureName.text.trim();
    if (name.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await appState.createFeatureRequest(
        hubId: _hubId,
        featureName: name,
        description: _description.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登録できませんでした。もう一度お試しください')),
        );
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hubs = hubRegistry.available;
    return Padding(
      padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('機能のリクエストを投稿', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '「こんな機能が欲しい！」を投稿すると、他のユーザーが賛同できるようになります。'
            '賛同の多かったものから優先的に開発します。',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: _hubId,
            decoration: const InputDecoration(
              labelText: '対象のハブ',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('全体')),
              for (final hub in hubs)
                DropdownMenuItem<String?>(
                  value: hub.appId,
                  child: Text(hub.name),
                ),
            ],
            onChanged: (v) => setState(() => _hubId = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _featureName,
            maxLength: 30,
            decoration: const InputDecoration(
              labelText: '機能の名前（例: 募集の定期開催）',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: '詳しく教えてください（任意）',
              hintText: '例: コミュニティで定例会を完結できるようにしてほしい',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('投稿する'),
          ),
        ],
      ),
    );
  }
}
