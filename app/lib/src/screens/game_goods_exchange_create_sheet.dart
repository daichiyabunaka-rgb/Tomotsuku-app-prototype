import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../hub_registry.dart';
import '../models.dart';
import '../services/app_state.dart';
import '../services/icon_service.dart';

/// 投稿ボードの登録シート（FR-7-1相当）。
/// 種別（kind）はハブごとの設定（HubConfig.exchangeKinds）で決まる。
/// 近況報告系: shoot / post / event / art / match / agari、
/// グッズ系（UGCハブ）: give / wanted / trade。
Future<void> showGameGoodsExchangeCreateSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _CreateSheet(),
  );
}

class _CreateSheet extends StatefulWidget {
  const _CreateSheet();

  @override
  State<_CreateSheet> createState() => _CreateSheetState();
}

class _CreateSheetState extends State<_CreateSheet> {
  final _itemDescription = TextEditingController();
  final _areaName = TextEditingController();
  final _detail = TextEditingController();
  String? _kind;
  String? _photoPath; // 選択した投稿写真（null=未選択, ''=解除）
  bool _submitting = false;

  @override
  void dispose() {
    _itemDescription.dispose();
    _areaName.dispose();
    _detail.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final path = await iconService.pickExchangeItemPhoto(source);
    if (path != null) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _submit() async {
    if (!_isValid || _submitting) return;
    setState(() => _submitting = true);
    try {
      await appState.registerGameGoodsExchange(
        kind: _kind!,
        itemDescription: _itemDescription.text.trim(),
        areaName: _areaName.text.trim(),
        detail: _detail.text.trim(),
        photoPath:
            (_photoPath == null || _photoPath!.isEmpty) ? null : _photoPath,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('登録に失敗しました。通信状況を確認してください'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('登録しました。近くのユーザーに表示されます'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hub = hubRegistry.active;
    _kind ??= hub.exchangeKinds.first.$1;
    // 種別の見た目（アイコン）と説明文言
    final isShootBoard = !hub.exchangeKinds.any((k) => k.$1 == 'give');
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${hub.exchangeLabel}を登録する',
                style: theme.textTheme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                for (final k in hub.exchangeKinds)
                  ButtonSegment(
                    value: k.$1,
                    icon: Icon(_kindIcon(k.$1)),
                    label: Text(k.$2),
                  ),
              ],
              selected: {_kind!},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: 4),
            Text(
              exchangeKindNote(_kind!),
              style: theme.textTheme.labelSmall!
                  .copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _itemDescription,
              maxLength: 40,
              decoration: InputDecoration(
                labelText: isShootBoard
                    ? 'タイトル（できごと・作品名など）'
                    : 'グッズの内容',
                hintText: isShootBoard
                    ? '例: 〇〇に行ってきました / 〇〇を撮影しました'
                    : '例: ゲームソフト（中古・箱説明書付き）',
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),

            // ------------------------------ 投稿写真（任意）
            Text('写真（任意。報告・状態のわかる写真を）',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                _photoPreview(theme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined,
                            size: 18),
                        label: const Text('ギャラリーから',
                            style: TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(height: 4),
                      OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.camera),
                        icon:
                            const Icon(Icons.photo_camera_outlined, size: 18),
                        label: const Text('カメラで撮影',
                            style: TextStyle(fontSize: 13)),
                      ),
                      if (_photoPath != null && _photoPath!.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() => _photoPath = ''),
                          child: const Text('写真をはずす',
                              style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _areaName,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: _kind == 'wanted'
                    ? '探している地域・イベント名'
                    : (isShootBoard ? '場所・スポット名' : '受け渡し希望の地域・イベント名'),
                hintText: '例: ○○市周辺 / ○○会場の入口前',
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detail,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: isShootBoard ? '近況・ハイライトなど' : '状態・条件・受け渡し方法など',
                hintText: isShootBoard
                    ? '例: 〇〇が最高でした。今度一緒にどうですか'
                    : '例: 使用済み・揃い済み。○○の入口前で受け渡しできます',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_isValid && !_submitting) ? _submit : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('登録する'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _kindIcon(String kind) {
    switch (kind) {
      case 'shoot':
        return Icons.photo_camera;
      case 'post':
        return Icons.chat_bubble_outline;
      case 'event':
        return Icons.celebration;
      case 'art':
        return Icons.palette;
      case 'match':
        return Icons.emoji_events;
      case 'agari':
        return Icons.casino;
      case 'wanted':
        return Icons.search;
      case 'trade':
        return Icons.swap_horiz;
      default:
        return Icons.redeem;
    }
  }

  /// 「絵」は場所の記入を必須にしない
  bool get _isValid =>
      _itemDescription.text.trim().isNotEmpty &&
      (_kind == 'art' || _areaName.text.trim().isNotEmpty);

  Widget _photoPreview(ThemeData theme) {
    final path = (_photoPath ?? '');
    Widget preview;
    if (path.startsWith('http')) {
      preview = Image.network(path, width: 96, height: 96,
          fit: BoxFit.cover, errorBuilder: (_, _, _) => _emptyPreview());
    } else if (path.isNotEmpty && File(path).existsSync()) {
      preview =
          Image.file(File(path), width: 96, height: 96, fit: BoxFit.cover);
    } else {
      preview = _emptyPreview();
    }
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: preview,
      ),
    );
  }

  Widget _emptyPreview() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 32, color: Colors.grey),
      ),
    );
  }
}
