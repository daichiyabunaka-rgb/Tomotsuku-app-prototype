import 'package:flutter/material.dart';

import 'hub_registry.dart';

/// 募集ジャンル
class Genre {
  final String id;
  final String label;
  final IconData icon;
  const Genre(this.id, this.label, this.icon);
}

/// 募集ジャンル（ハブごとに定義が変わる。総合版は選択中のハブのものを返す）。
List<Genre> get genres => hubRegistry.active.genres;

Genre genreById(String id) => genres.firstWhere((g) => g.id == id);

/// ともつく！シリーズ（趣味特化型マッチングアプリ群）の共通定義。
/// 飯とも！・犬とも！・釣りとも！・ニーアキャット・コスとも！など全アプリと同一のSupabase
/// プロジェクト・アカウントを共有し、このapp_idで各アプリのデータを識別する。
const Map<String, String> tomoTskuAppNames = {
  'meshitomo': '飯とも！',
  'inutomo': '犬とも！',
  'tsuritomo': '釣りとも！',
  'nekotomo': 'ニーアキャット',
  'costomo': 'コスとも！',
  'hashitomo': '走りとも！',
  'campotomo': 'キャンとも！',
  'ototomo': '音とも！',
  'yutomo': '湯とも！',
  'supotomo': 'スポとも！',
  'janotomo': '雀とも！',
  'tomotsuku': 'ともつく！総合',
};

/// 興味カテゴリ。
/// `interestCategories` は初期セット（デフォルト）。ユーザーは自由に
/// カテゴリを追加でき（AppState.categoryRegistry）、Supabase モードでは
/// 全ユーザーに共有される。
class InterestCategory {
  final String id;
  final String label;
  final IconData icon;
  const InterestCategory(this.id, this.label, this.icon);
}

/// 興味カテゴリの初期セット（ハブごとに定義が変わる）。
List<InterestCategory> get interestCategories =>
    hubRegistry.active.interests;

/// カスタムカテゴリのアイコン候補（名前でDB保存するため定数マップ）。
/// 本アプリはゲームに特化するため、アイコンもゲーム系のみとする
/// （その他の趣味は別アプリで展開する方針）。
const Map<String, IconData> categoryIconChoices = {
  'view_module': Icons.view_module,
  'filter_3': Icons.filter_3,
  'timelapse': Icons.timelapse,
  'bolt': Icons.bolt,
  'school': Icons.school,
  'computer': Icons.computer,
  'emoji_events': Icons.emoji_events,
  'psychology': Icons.psychology,
  'menu_book': Icons.menu_book,
  'checkroom': Icons.checkroom,
  'storefront': Icons.storefront,
  'groups': Icons.groups,
  'star': Icons.star,
  'sparkle': Icons.auto_awesome,
};

/// アイコン名から IconData を引く（未登録の名前はデフォルトを返す）
IconData categoryIconByName(String? name) =>
    categoryIconChoices[name] ?? Icons.casino;

/// プロトタイプ用のモック現在地（本開発では端末の GPS + geohash に置き換える）
class MockLocation {
  final String id;
  final String name;
  final double lat;
  final double lng;
  const MockLocation(this.id, this.name, this.lat, this.lng);
}

const List<MockLocation> mockLocations = [
  MockLocation('tokyo', '東京駅', 35.6812, 139.7671),
  MockLocation('yurakucho', '有楽町', 35.6748, 139.7629),
  MockLocation('akiba', '秋葉原', 35.7023, 139.7745),
  MockLocation('shibuya', '渋谷', 35.6580, 139.7016),
  MockLocation('shinjuku', '新宿', 35.6896, 139.7006),
  MockLocation('shinagawa', '品川', 35.6285, 139.7394),
];

/// 近くの施設（「近くの立ち寄り施設を探す」機能:
/// ゲームセンター・公民館・集会所）。
/// 実データは OpenStreetMap（Overpass API）から現在地周辺で取得する。
class CatSpot {
  final String osmId; // 例: 'way/12345'
  final String name;
  final String type; // 種別ラベル（ハブのスポットタグから。例: 「ゲームセンター」）
  final double lat;
  final double lng;
  final double distanceKm; // 現在地からの距離
  final String? openingHours;

  const CatSpot({
    required this.osmId,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    this.openingHours,
  });
}

class AppUser {
  final String id;
  final String nickname;
  final String decade; // 例: '20代'。ビジネスユーザーは '経営者'
  final String gender; // 'male' | 'female' | 'undisclosed'
  final String iconCategoryId; // 趣味アイコン（顔画像は禁止）
  final String? iconImagePath; // 端末内に保存した投稿アイコン画像（あれば優先表示）
  final List<String> interestIds;
  final String bio;
  final double lat;
  final double lng;
  final String? websiteUrl; // 公開URL（例: 店のホームページ）
  final String? snsNote; // SNS（例: 'X: @tomotsuku_official / IG: tomotsuku'）
  final String? phone; // ビジネスユーザー（店舗）の電話番号。タップで発信
  final String? appSource; // このプロフィール行の由来アプリ（自分のアプリなら null）
  final bool crossAppVisible; // ともつく！全体に表示する設定（この行の値）

  const AppUser({
    required this.id,
    required this.nickname,
    required this.decade,
    required this.gender,
    required this.iconCategoryId,
    required this.interestIds,
    required this.bio,
    required this.lat,
    required this.lng,
    this.iconImagePath,
    this.websiteUrl,
    this.snsNote,
    this.phone,
    this.appSource,
    this.crossAppVisible = false,
  });

  String get genderLabel => const {'male': '男性', 'female': '女性'}.containsKey(gender)
      ? const {'male': '男性', 'female': '女性'}[gender]!
      : '非公開';

  bool get isBusiness => false;

  /// 他のともつく！アプリ由来のプロフィール行か
  bool get isOtherApp => appSource != null;

  /// 由来アプリの表示名（例: '釣りとも！'）
  String get appSourceLabel =>
      isOtherApp ? (tomoTskuAppNames[appSource] ?? appSource!) : '';

  /// 位置だけ変えたコピーを返す
  AppUser withPosition(double newLat, double newLng) {
    return AppUser(
      id: id,
      nickname: nickname,
      decade: decade,
      gender: gender,
      iconCategoryId: iconCategoryId,
      interestIds: interestIds,
      bio: bio,
      lat: newLat,
      lng: newLng,
      iconImagePath: iconImagePath,
      websiteUrl: websiteUrl,
      snsNote: snsNote,
      phone: phone,
      appSource: appSource,
      crossAppVisible: crossAppVisible,
    );
  }
}

/// ビジネスユーザー（店舗。一般ユーザー登録と分離された登録フローで作られる）
class BusinessUser extends AppUser {
  final String storeType; // 例: 'ゲームセンター'

  const BusinessUser({
    required super.id,
    required super.nickname,
    required super.decade,
    required super.gender,
    required super.iconCategoryId,
    required super.interestIds,
    required super.bio,
    required super.lat,
    required super.lng,
    required this.storeType,
    super.iconImagePath,
    super.websiteUrl,
    super.snsNote,
    super.phone,
    super.appSource,
    super.crossAppVisible,
  });

  @override
  bool get isBusiness => true;

  @override
  AppUser withPosition(double newLat, double newLng) {
    return BusinessUser(
      id: id,
      nickname: nickname,
      decade: decade,
      gender: gender,
      iconCategoryId: iconCategoryId,
      interestIds: interestIds,
      bio: bio,
      lat: newLat,
      lng: newLng,
      storeType: storeType,
      iconImagePath: iconImagePath,
      websiteUrl: websiteUrl,
      snsNote: snsNote,
      phone: phone,
      appSource: appSource,
      crossAppVisible: crossAppVisible,
    );
  }
}

enum RecStatus { active, fulfilled, expired, cancelled }

class Recruitment {
  final String id;
  final String hostId;
  final String genreId;
  final String title;
  final String body;
  final String meetup;
  final int capacity;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> memberIds; // host を含む

  const Recruitment({
    required this.id,
    required this.hostId,
    required this.genreId,
    required this.title,
    required this.body,
    required this.meetup,
    required this.capacity,
    required this.createdAt,
    required this.expiresAt,
    required this.memberIds,
  });

  bool get isFull => memberIds.length >= capacity;

  bool isActiveAt(DateTime now) =>
      now.isBefore(expiresAt) && !isFull && memberIds.isNotEmpty;

  int get remainingSlots => capacity - memberIds.length;

  RecStatus statusAt(DateTime now) {
    if (isFull) return RecStatus.fulfilled;
    if (!now.isBefore(expiresAt)) return RecStatus.expired;
    return RecStatus.active;
  }
}

enum JoinStatus { pending, accepted, declined }

class JoinApplication {
  final String id;
  final String recruitmentId;
  final String applicantId;
  final String message;
  JoinStatus status;
  final DateTime createdAt;

  JoinApplication({
    required this.id,
    required this.recruitmentId,
    required this.applicantId,
    required this.message,
    required this.status,
    required this.createdAt,
  });
}

class ChatRoom {
  final String id;
  final String recruitmentId; // DM・コミュニティの場合は空文字
  final List<String> memberIds;
  final DateTime createdAt;
  final String type; // 'group' | 'dm' | 'community'
  final String? communityId; // コミュニティチャットの場合

  ChatRoom({
    required this.id,
    required this.recruitmentId,
    required this.memberIds,
    required this.createdAt,
    this.type = 'group',
    this.communityId,
  });

  bool get isDm => type == 'dm';

  bool get isCommunity => type == 'community';
}

/// コミュニティ（クラブ・イベント企画・店舗のファンコミュニティ）。
/// 誰でも作成でき、参加するとコミュニティチャットが開ける（FR-6-1〜6-3）。
class Community {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String? linkedStore; // 店舗ファンコミュニティの場合の店舗名
  final DateTime createdAt;
  final Set<String> memberIds;

  Community({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.linkedStore,
    required this.createdAt,
    required this.memberIds,
  });

  Community copyWith({
    Set<String>? memberIds,
    String? name,
    String? description,
  }) {
    return Community(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      linkedStore: linkedStore,
      createdAt: createdAt,
      memberIds: memberIds ?? this.memberIds,
    );
  }
}

/// コミュニティ内で企画されるイベント・クラブ
class CommunityEvent {
  final String id;
  final String communityId;
  final String hostId;
  final String title;
  final String body;
  final String eventTime; // ベータでは自由記述（例: '3/14 19:00〜'）
  final String locationName;
  final int capacity;
  final DateTime createdAt;
  final Set<String> participantIds;

  CommunityEvent({
    required this.id,
    required this.communityId,
    required this.hostId,
    required this.title,
    required this.body,
    required this.eventTime,
    required this.locationName,
    required this.capacity,
    required this.createdAt,
    required this.participantIds,
  });

  bool get isFull => participantIds.length >= capacity;

  CommunityEvent copyWith({Set<String>? participantIds}) {
    return CommunityEvent(
      id: id,
      communityId: communityId,
      hostId: hostId,
      title: title,
      body: body,
      eventTime: eventTime,
      locationName: locationName,
      capacity: capacity,
      createdAt: createdAt,
      participantIds: participantIds ?? this.participantIds,
    );
  }
}

/// ゲームグッズの「ゆずりあい・交換」掲示板（近隣での情報共有）。
/// 投稿ボード（4つ目のタブ）の1件。ハブごとに種別（kind）が異なる:
///   グッズ系: 'give'(ゆずる) / 'wanted'(探す) / 'trade'(交換)
///   撮影報告系（コスとも！ハブ）: 'shoot'(撮影) / 'spot'(場所) / 'event'(イベント) / 'art'(絵)
class GameGoodsExchange {
  final String id;
  final String posterId;
  final String kind;
  final String itemDescription; // タイトル（グッズ名・キャラ名など）
  final String areaName; // 受け渡し希望地域やイベント名
  final String detail; // 状態・ハイライトなどの自由記述
  final String? photoPath; // 投稿写真（端末内パス or 公開URL）
  final double lat;
  final double lng;
  final DateTime createdAt;
  bool closed; // 完了（受け渡し・交換が成立した等）

  GameGoodsExchange({
    required this.id,
    required this.posterId,
    required this.kind,
    required this.itemDescription,
    required this.areaName,
    required this.detail,
    required this.lat,
    required this.lng,
    required this.createdAt,
    this.photoPath,
    this.closed = false,
  });

  /// ゆずります（グッズ系）
  bool get isGive => kind == 'give';

  /// 探しています（グッズ系）
  bool get isWanted => kind == 'wanted';

  /// 交換します（グッズ系）
  bool get isTrade => kind == 'trade';

  /// 撮影報告（コスとも！ハブ）
  bool get isShootReportKind =>
      kind == 'shoot' || kind == 'spot' || kind == 'event' || kind == 'art';
}

/// 投稿ボードの種別ごとの注意文言（登録シートで使う）。
String exchangeKindNote(String kind) {
  switch (kind) {
    case 'shoot':
      return '撮ってきたコスプレ写真の報告です。\n'
          '※本人が写る画像は本人・撮影者の許諾を得たものだけ投稿してください。';
    case 'spot':
      return 'おすすめの撮影スポット・状況の報告です。\n'
          '※私有地・撮影禁止場所の無断撮影はやめましょう。';
    case 'event':
      return 'イベント会場での撮影報告です。\n'
          '※会場の撮影規約・参加者の許諾を守ってください。';
    case 'art':
      return '描いた絵・ファンアートの投稿です。\n'
          '※他人の作品の無断転載・トレースは禁止です。成人向けの画像も投稿できません。';
    case 'wanted':
      return '探しているものの登録です。\n'
          '※個人の住所・連絡先は記入しないでください。DMでやりとりしましょう。';
    case 'trade':
      return '交換の登録です。\n'
          '※金銭のやりとりは禁止です。条件はDMで相談してください。';
    default: // 'give' ほか
      return '使わなくなったグッズをゆずる場合の登録です。\n'
          '※金銭のやりとりは禁止です。受け渡しは公共の場・人目のある場所で行ってください。';
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId; // system の場合 'system'
  final String body;
  final DateTime sentAt;
  final bool isSystem;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.body,
    required this.sentAt,
    this.isSystem = false,
  });
}

/// 「次のハブ（趣味アプリ）のリクエスト」ボードの1件（Phase 2・課題1の解決）。
/// ユーザーが欲しい趣味のともつく！を投稿し、他のユーザーが賛同する。
class HubRequest {
  final String id;
  final String requesterId;
  final String hobbyName;
  final String description;
  final int voteCount;
  final bool myVote;
  final String status; // open / approved / launched / rejected
  final DateTime createdAt;

  const HubRequest({
    required this.id,
    required this.requesterId,
    required this.hobbyName,
    required this.description,
    required this.voteCount,
    required this.myVote,
    required this.status,
    required this.createdAt,
  });
}

/// 「機能のリクエスト」ボードの1件（Phase 2・課題2の解決）。
class FeatureRequest {
  final String id;
  final String requesterId;
  final String? hubId; // null = 全ハブ共通の要望
  final String featureName;
  final String description;
  final int voteCount;
  final bool myVote;
  final String status; // open / planned / shipped / rejected
  final DateTime createdAt;

  const FeatureRequest({
    required this.id,
    required this.requesterId,
    required this.hubId,
    required this.featureName,
    required this.description,
    required this.voteCount,
    required this.myVote,
    required this.status,
    required this.createdAt,
  });
}

/// Phase 3の「ハブをつくる」ウィザードで組み立てる申請内容。
class HubConfigDraft {
  final String name; // 表示名（例: 古着とも！）
  final String description;
  final List<Genre> genres; // 募集ジャンル3種
  final List<InterestCategory> interests; // 興味カテゴリ
  final List<SpotTag> spotTags; // 施設検索タグ（任意）
  final List<String> storeTypes; // 業態（任意）
  final String exchangeLabel; // ゆずりあいボードの語（任意運用）
  final int interestsExtra; // AI/ユーザーが自由に増やせる分

  const HubConfigDraft({
    required this.name,
    required this.description,
    required this.genres,
    required this.interests,
    required this.spotTags,
    required this.storeTypes,
    required this.exchangeLabel,
    this.interestsExtra = 0,
  });
}
