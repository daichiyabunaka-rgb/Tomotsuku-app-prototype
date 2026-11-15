import '../models.dart';

/// AI接客のデモ応答ロジック（プロトタイプ用のモック）。
/// 本開発では LLM API に置き換える。このロジックは店舗業態と
/// ユーザーの興味カテゴリからおすすめを案内する最低限のルールベース。
class AiConcierge {
  /// 最初の挨拶（店舗の口調 + ユーザーの興味を踏まえる）
  String greeting(AppUser me, BusinessUser store) {
    final interest = me.interestIds.isNotEmpty ? me.interestIds.first : null;
    final label = interest == null ? null : _categoryLabel(interest);
    final base = '${_opener(store)}'
        '${me.nickname}さん、${store.nickname}（${store.storeType}）のAI接客です。';
    if (label == null) {
      return '$base ゲームのことなら何でも聞いてください。';
    }
    return '$base $labelがお好みなんですね。'
        'うちの${_recommend(store)}がおすすめです。';
  }

  /// 店舗タイプごとの口調（本開発では LLM に店舗キャラ設定を渡して生成する）
  String _opener(BusinessUser store) {
    switch (store.storeType) {
      case 'ゲームセンター':
        return 'いらっしゃい！対戦もフリーも大歓迎です。';
      case 'ゲームショップ・ホビー店':
        return 'いらっしゃいませ。おすすめタイトルもご案内できます。';
      case 'eスポーツ施設運営':
        return 'いらっしゃい。試合観戦も対戦も楽しめます。';
      case 'カードゲーム・ボードゲーム店':
        return 'ようこそ。ソフト選びもお手伝いします。';
      case 'ゲームカフェ':
        return 'いらっしゃいませ。ドリンクを片手にまったりどうぞ。';
      default:
        return 'いらっしゃいませ。';
    }
  }

  /// ユーザー発話への応答
  String reply(String input, AppUser me, BusinessUser store) {
    final text = input.replaceAll(RegExp(r'\s'), '');
    if (text.contains('予約') || text.contains('来店') || text.contains('利用')) {
      return 'ありがとうございます。土日は混み合うため、'
          '平日の午前中でしたらゆっくりご案内できます。'
          'ご希望の時間をメモしておきますね。'
          '（デモのため実際の予約機能は本開発で提供します）';
    }
    if (text.contains('おすすめ') || text.contains('オススメ')) {
      return '今回は${_recommend(store)}がおすすめです。'
          'プレイの予定があれば教えてください。';
    }
    if (text.contains('ゲーム') || text.contains('FPS') ||
        text.contains('コントローラー') || text.contains('攻略')) {
      return '初めての方も歓迎しています。'
          '攻略のご相談も一緒に承ります。';
    }
    if (text.contains('料金') || text.contains('いくら') ||
        text.contains('価格')) {
      return 'ご利用内容によって変わりますが、まずは一度お試しいただけます。'
          '詳しいプランは店舗ページをご確認ください（デモの固定値です）。';
    }
    if (text.contains('何時') || text.contains('営業時間')) {
      return '本日は10:00〜18:00で営業しております。'
          '混雑しやすいのは土曜午前です。（デモの固定値です）';
    }
    if (text.contains('駐車場') || text.contains('アクセス')) {
      return '近隣にコインパーキングがあります。'
          '大きな荷物がある場合は事前にご相談ください。';
    }
    return '承知しました。「おすすめ」「料金」「営業時間」「予約」「ゲーム」など、'
        '気になることを聞いていただければ答えます。';
  }

  String _recommend(BusinessUser store) {
    switch (store.storeType) {
      case 'ゲームセンター':
        return '平日の対戦台予約枠';
      case 'ゲームショップ・ホビー店':
        return '初心者向け体験レッスン';
      case 'eスポーツ施設運営':
        return '大会観戦イベント';
      case 'カードゲーム・ボードゲーム店':
        return '中古ソフトと周辺機器の整理セール品';
      case 'ゲームカフェ':
        return 'ドリンク付きプレイパック';
      default:
        return 'おすすめサービス';
    }
  }

  String _categoryLabel(String id) {
    const labels = {
      'shooter': 'FPS・TPS',
      'rpg': 'RPG',
      'action': 'アクション',
      'fight': '格闘・レース',
      'beginner': '初心者・教え合い',
      'netgame': 'ネット対戦',
      'esports': 'eスポーツ・大会',
      'strategy': '攻略・検証',
      'retro': 'レトロ・クラシック',
      'goods': 'ゲームグッズ',
      'arcade': 'ゲームセンターめぐり',
      'gamekai': 'ゲームサークル',
    };
    return labels[id] ?? 'ゲームのこと';
  }
}

/// グローバルインスタンス（本開発では DI / LLM API クライアントに置き換える）
final AiConcierge aiConcierge = AiConcierge();
