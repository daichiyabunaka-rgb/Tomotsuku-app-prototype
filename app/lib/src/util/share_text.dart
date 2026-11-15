/// アプリ招待メッセージの組み立て。
/// 純関数として切り出してテストできるようにしている。
/// リリース後は URL をストアの配布ページ（Google Play / App Store）に差し替え、
/// 招待コード（?ref=userId）を付けて、招待経由の登録で両者を繋げる予定（v2）。
library;

import '../hub_registry.dart';

const String kAppUrl =
    'https://github.com/daichiyabunaka-rgb/Tomotsuku-app-prototype';

/// 現在選択中のハブの名称（ホームハブなら「ともつく！」）。
String _hubName() {
  final hub = hubRegistry.active;
  return hub.appId == 'tomotsuku' ? 'ともつく！' : 'ともつく！（${hub.name}）';
}

String inviteText(String nickname) {
  return '一緒に「$_hubName」を使いませんか？\n'
      '趣味を介して近くの仲間を探せるアプリ。顔ではなく中身で、'
      '同じ趣味の人と一緒に楽しめるよ。\n'
      '$nicknameも参加しています。一般利用は完全無料です。\n'
      '$kAppUrl';
}

/// 特定の募集に誘う共有文（「この募集に参加しませんか」でも SNS 共有できる）
String recruitmentShareText(String title, String meetup) {
  return '一緒に参加しませんか？「$_hubName」で募集しています。\n'
      '「$title」（集合: $meetup）\n'
      '$kAppUrl';
}

/// ビジネスユーザーが他のビジネスユーザー（同業の店舗経営者）に送る紹介・招待文。
/// ビジネスユーザー同士のつながり（同業者との情報交換）を生むための共有。
String businessInviteText(String myStoreName, String myStoreType) {
  return '近くの趣味仲間や同業者と直接つながれるアプリ「ともつく！」を'
      '使いませんか？\n'
      '$myStoreType「$myStoreName」も参加しています。\n'
      '一般ユーザーもビジネスユーザーも、ベータ期間中は無料でご利用いただけます。\n'
      '$kAppUrl';
}
