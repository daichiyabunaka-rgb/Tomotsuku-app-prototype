import 'package:flutter/material.dart';

import '../hub_registry.dart';
import '../models.dart';
import '../services/app_state.dart';

/// Phase 3「ハブをつくる」ウィザード。
/// ユーザーが新しい趣味のハブ（＝新しい「〇〇とも！」）を設定ベースで申請できる。
/// 申請は hub_configs に status='pending' で登録され、運営の審査後、
/// 承認されると総合版アプリのハブ一覧に表示される（Roblox型のUGC）。
class HubCreateWizardPage extends StatefulWidget {
  const HubCreateWizardPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const HubCreateWizardPage());

  @override
  State<HubCreateWizardPage> createState() => _HubCreateWizardPageState();
}

class _HubCreateWizardPageState extends State<HubCreateWizardPage> {
  int _step = 0;

  final _name = TextEditingController();
  final _description = TextEditingController();
  final _exchangeLabel = TextEditingController(text: 'グッズ');
  final List<TextEditingController> _genreControllers = [
    TextEditingController(text: '今から誘う'),
    TextEditingController(text: 'イベントに参加'),
    TextEditingController(text: '交流・雑談'),
  ];

  final List<InterestCategory> _interests = [];
  final Set<String> _selectedSpotTags = <String>{};
  final List<String> _storeTypes = <String>[];

  bool _ruleFacePhoto = false;
  bool _ruleMoney = false;
  bool _rulePublic = false;
  bool _submitting = false;

  static const List<SpotTag> _spotTagPresets = [
    SpotTag('leisure', 'amusement_arcade', 'ゲームセンター'),
    SpotTag('leisure', 'park', '公園'),
    SpotTag('leisure', 'sports_centre', 'スポーツ施設'),
    SpotTag('leisure', 'fitness_centre', 'ジム'),
    SpotTag('amenity', 'cafe', 'カフェ'),
    SpotTag('amenity', 'restaurant', 'レストラン'),
    SpotTag('amenity', 'bar', 'バー'),
    SpotTag('amenity', 'food_court', 'フードコート'),
    SpotTag('amenity', 'public_bath', '銭湯'),
    SpotTag('amenity', 'animal_shelter', '動物保護施設'),
    SpotTag('amenity', 'veterinary', '動物病院'),
    SpotTag('leisure', 'fishing', '釣り場'),
    SpotTag('leisure', 'music_venue', 'ライブハウス'),
    SpotTag('leisure', 'escape_game', '謎解き'),
    SpotTag('shop', 'musical_instrument', '楽器店'),
    SpotTag('shop', 'sports', 'スポーツ用品店'),
    SpotTag('shop', 'books', '本屋'),
    SpotTag('shop', 'outdoor', 'アウトドア用品店'),
    SpotTag('shop', 'pet', 'ペットショップ'),
    SpotTag('shop', 'hobby', 'ホビー店'),
  ];

  static const List<InterestCategory> _interestDefaults = [
    InterestCategory('cat-beginner', '初心者歓迎', Icons.school),
    InterestCategory('cat-join', '気軽に参加', Icons.groups),
    InterestCategory('cat-event', 'イベント好き', Icons.celebration),
    InterestCategory('cat-info', '情報共有', Icons.forum),
    InterestCategory('cat-advance', '教え合い', Icons.volunteer_activism),
    InterestCategory('cat-quiet', '静かに楽しむ', Icons.self_improvement),
  ];

  @override
  void initState() {
    super.initState();
    _interests.addAll(_interestDefaults);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _exchangeLabel.dispose();
    for (final c in _genreControllers) {
      c.dispose();
    }
    super.dispose();
  }

  int get _stepCount => 5;

  bool get _canNext {
    switch (_step) {
      case 0:
        return _name.text.trim().isNotEmpty &&
            _description.text.trim().isNotEmpty;
      case 1:
        return _genreControllers.any((c) => c.text.trim().isNotEmpty);
      case 2:
        return _interests.isNotEmpty;
      default:
        return true;
    }
  }

  bool get _rulesOk => _ruleFacePhoto && _ruleMoney && _rulePublic;

  Future<void> _submit() async {
    if (!_rulesOk || _submitting) return;
    setState(() => _submitting = true);
    final draft = HubConfigDraft(
      name: _name.text.trim(),
      description: _description.text.trim(),
      genres: [
        for (var i = 0; i < _genreControllers.length; i++)
          Genre(
            'g$i',
            _genreControllers[i].text.trim().isEmpty
                ? '募集${i + 1}'
                : _genreControllers[i].text.trim(),
            _genreIcon(i),
          ),
      ],
      interests: List.of(_interests),
      spotTags: [
        for (final preset in _spotTagPresets)
          if (_selectedSpotTags.contains('${preset.key}=${preset.value}'))
            preset,
      ],
      storeTypes: List.of(_storeTypes),
      exchangeLabel: _exchangeLabel.text.trim(),
      interestsExtra: _interests.length - _interestDefaults.length,
    );
    try {
      await appState.submitHub(draft);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('申請を受け付けました'),
          content: const Text(
            'ご応募ありがとうございます。運営の審査後、承認されるとハブ一覧に表示されます。'
            '承認までは少しお時間をいただく場合があります。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('申請できませんでした。もう一度お試しください')),
        );
        setState(() => _submitting = false);
      }
    }
  }

  IconData _genreIcon(int i) {
    const icons = [
      Icons.wb_incandescent,
      Icons.celebration,
      Icons.groups,
      Icons.chat_bubble,
    ];
    return icons[i % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ハブをつくる'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${_step + 1}/$_stepCount',
                  style: theme.textTheme.labelMedium),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
              value: (_step + 1) / _stepCount, minHeight: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStep(theme),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('戻る'),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _nextEnabled ? _onNext : null,
                      child: Text(_step == _stepCount - 1 ? '申請する' : '次へ'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _nextEnabled =>
      _step == _stepCount - 1 ? (_rulesOk && !_submitting) : _canNext;

  void _onNext() {
    if (_step < _stepCount - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  Widget _buildStep(ThemeData theme) {
    switch (_step) {
      case 0:
        return _buildBasicsStep(theme);
      case 1:
        return _buildGenresStep(theme);
      case 2:
        return _buildInterestsStep(theme);
      case 3:
        return _buildSpotsStep(theme);
      default:
        return _buildConfirmStep(theme);
    }
  }

  // ------------------------------------------------------------ step 0: 基本

  Widget _buildBasicsStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('どんなハブを作りたいですか？', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '作ったハブは審査のうえ、承認されると全ユーザーのハブ一覧に登場します。'
          '例: 「古着とも！」「映画とも！」',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _name,
          maxLength: 16,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'ハブの名前（例: 古着とも！）',
            border: OutlineInputBorder(),
            counterText: '',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _description,
          maxLines: 4,
          maxLength: 300,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'このハブでどんな仲間探しをしたいか',
            hintText: '例: 古着屋巡りを一緒に回れる仲間を探したい',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ step 1: ジャンル

  Widget _buildGenresStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('募集のかたち（ジャンル）', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '「今から誘う」「イベントに参加」のような、募集のしかたを決めます。'
          '初期値をそのまま使っても、書きかえても構いません。',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _genreControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _genreControllers[i],
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'ジャンル${i + 1}',
                prefixIcon: Icon(_genreIcon(i)),
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
          ),
        OutlinedButton.icon(
          onPressed: _genreControllers.length >= 4
              ? null
              : () => setState(() => _genreControllers.add(
                  TextEditingController(
                      text: '募集${_genreControllers.length + 1}'))),
          icon: const Icon(Icons.add),
          label: const Text('ジャンルを追加'),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ step 2: 興味

  Widget _buildInterestsStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('興味カテゴリ', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'プロフィールで選べる興味のタグです。初期値から消したり、'
          '自由に追加したりできます（最低1つ）。',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _interests.length; i++)
              InputChip(
                avatar: Icon(_interests[i].icon, size: 18),
                label: Text(_interests[i].label),
                onDeleted: () => setState(() => _interests.removeAt(i)),
              ),
          ],
        ),
        const SizedBox(height: 20),
        _AddLabelField(
          label: '追加する興味（例: 時計）',
          onAdded: (label) => setState(
            () => _interests.add(InterestCategory(
              'cat-custom-${_interests.length}',
              label,
              Icons.label,
            )),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ step 3: 施設/業態

  Widget _buildSpotsStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('近くの施設で探せるもの', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'ハブのユーザーが「近く」で探せる施設の種類を選びます（任意）。'
          '1つも選ばなければ施設検索は非表示になります。',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in _spotTagPresets)
              FilterChip(
                label: Text(tag.label),
                selected:
                    _selectedSpotTags.contains('${tag.key}=${tag.value}'),
                onSelected: (v) {
                  setState(() {
                    final key = '${tag.key}=${tag.value}';
                    if (v) {
                      _selectedSpotTags.add(key);
                    } else {
                      _selectedSpotTags.remove(key);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('ビジネスユーザーの業態（任意）',
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'このハブで登録できるお店・施設の業種です。自由に追加できます。',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (_storeTypes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _storeTypes.length; i++)
                  InputChip(
                    label: Text(_storeTypes[i]),
                    onDeleted: () => setState(() => _storeTypes.removeAt(i)),
                  ),
              ],
            ),
          ),
        _AddLabelField(
          label: '追加する業態（例: 古着屋）',
          onAdded: (label) => setState(() => _storeTypes.add(label)),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ step 4: 確認

  Widget _buildConfirmStep(ThemeData theme) {
    final spotLabels = _spotTagPresets
        .where((t) => _selectedSpotTags.contains('${t.key}=${t.value}'))
        .map((t) => t.label)
        .join(' / ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('確認して申請', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        _confirmRow('ハブの名前', _name.text.trim()),
        _confirmRow('説明', _description.text.trim()),
        _confirmRow(
            'ジャンル',
            _genreControllers
                .map((c) => c.text.trim())
                .where((t) => t.isNotEmpty)
                .join(' / ')),
        _confirmRow(
            '興味カテゴリ', _interests.map((c) => c.label).join(' / ')),
        _confirmRow('施設タグ', spotLabels.isEmpty ? 'なし' : spotLabels),
        _confirmRow(
            '業態', _storeTypes.isEmpty ? 'なし' : _storeTypes.join(' / ')),
        const SizedBox(height: 16),
        Text('審査のルール', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        CheckboxListTile(
          dense: true,
          value: _ruleFacePhoto,
          onChanged: (v) => setState(() => _ruleFacePhoto = v ?? false),
          title: const Text('顔写真・本人特定が目的のハブではありません'),
        ),
        CheckboxListTile(
          dense: true,
          value: _ruleMoney,
          onChanged: (v) => setState(() => _ruleMoney = v ?? false),
          title: const Text('金銭取引や賭博を誘導するハブではありません'),
        ),
        CheckboxListTile(
          dense: true,
          value: _rulePublic,
          onChanged: (v) => setState(() => _rulePublic = v ?? false),
          title: const Text('公序良俗に反する内容を含みません'),
        ),
        const SizedBox(height: 8),
        Text(
          '申請後、運営が内容を確認し、問題がなければ承認します。'
          '承認されると全ユーザーのハブ一覧に表示されるようになります。',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _confirmRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '（未入力）' : value,
                style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

/// 興味カテゴリ・業態の自由追加フィールド。
class _AddLabelField extends StatefulWidget {
  final String? label;
  final void Function(String label) onAdded;

  const _AddLabelField({this.label, required this.onAdded});

  @override
  State<_AddLabelField> createState() => _AddLabelFieldState();
}

class _AddLabelFieldState extends State<_AddLabelField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final label = _controller.text.trim();
    if (label.isEmpty) return;
    widget.onAdded(label);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: widget.label,
              border: const OutlineInputBorder(),
              counterText: '',
            ),
            onSubmitted: (_) => _add(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _add,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
