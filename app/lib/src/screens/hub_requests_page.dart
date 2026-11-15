import 'package:flutter/material.dart';

import '../models.dart';
import '../services/app_state.dart';

/// 「次のハブ（趣味アプリ）のリクエスト」ボード（Phase 2・提案008）。
/// ユーザーが欲しい趣味のともつく！を投稿し、賛同（1人1票）を集める。
/// 賛同の多かったリクエストが次に作るハブの候補になる。
class HubRequestsPage extends StatefulWidget {
  const HubRequestsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const HubRequestsPage());

  @override
  State<HubRequestsPage> createState() => _HubRequestsPageState();
}

class _HubRequestsPageState extends State<HubRequestsPage> {
  @override
  void initState() {
    super.initState();
    appState.loadHubRequests();
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
      builder: (context) => const _HubRequestCreateSheet(),
    );
    if (created == true && mounted) {
      await appState.loadHubRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requests = appState.hubRequests;
    return Scaffold(
      appBar: AppBar(
        title: const Text('次のハブのリクエスト'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateSheet,
        icon: const Icon(Icons.add),
        label: const Text('リクエスト'),
      ),
      body: RefreshIndicator(
        onRefresh: () => appState.loadHubRequests(),
        child: requests.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 64),
                  Icon(Icons.lightbulb_outline,
                      size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'まだリクエストがありません。\n「この趣味のともつく！が欲しい！」を最初に投稿してみませんか？',
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
                  onVote: () => appState.toggleHubVote(requests[i].id),
                ),
              ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final HubRequest request;
  final VoidCallback onVote;

  const _RequestCard({required this.request, required this.onVote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  Text(request.hobbyName,
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
                      color: request.status == 'open'
                          ? theme.colorScheme.outline
                          : theme.colorScheme.primary,
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

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return '採用が決まりました';
      case 'launched':
        return '登場済み';
      case 'rejected':
        return '見送り';
      default:
        return '賛同を募集中';
    }
  }
}

class _HubRequestCreateSheet extends StatefulWidget {
  const _HubRequestCreateSheet();

  @override
  State<_HubRequestCreateSheet> createState() =>
      _HubRequestCreateSheetState();
}

class _HubRequestCreateSheetState extends State<_HubRequestCreateSheet> {
  final _hobbyName = TextEditingController();
  final _description = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _hobbyName.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _hobbyName.text.trim();
    if (name.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await appState.createHubRequest(
        hobbyName: name,
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
    return Padding(
      padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('リクエストを投稿', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '「この趣味のともつく！が欲しい」を投稿すると、'
            '他のユーザーが賛同できるようになります。'
            '賛同が集まったものから順に正式なハブとして作られます。',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hobbyName,
            maxLength: 20,
            decoration: const InputDecoration(
              labelText: '趣味の名前（例: 古着とも！）',
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
              labelText: 'どんな仲間を探したいか（任意）',
              hintText: '例: 古着屋巡りを一緒にできる仲間を探したい',
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
