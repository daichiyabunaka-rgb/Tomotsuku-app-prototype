import 'dart:math' as math;

import '../hub_registry.dart';
import '../models.dart';

/// モックユーザーは「anchor（中心点）からの相対距離」で配置する。
/// anchor には実 GPS で取得した現在地が入り、どこにいても近くの候補が並ぶ。
/// 総合版では各モックユーザーが hub（所属ハブの app_id）を持つ。
/// ホーム（'tomotsuku'）を表示中は全ハブのユーザーが混在する。
class _MockSpec {
  final String id;
  final String hub;
  final String nickname;
  final String decade;
  final String gender;
  final String iconCategoryId;
  final List<String> interestIds;
  final String bio;
  final double northKm; // anchor からの北方向距離
  final double eastKm; // anchor からの東方向距離

  const _MockSpec(this.id, this.hub, this.nickname, this.decade, this.gender,
      this.iconCategoryId, this.interestIds, this.bio, this.northKm,
      this.eastKm);
}

const List<_MockSpec> _specs = [
  // ---- ゲーとも！ハブ
  _MockSpec(
    'u-shooter-ken',
    'gametomo',
    'FPSのけん',
    '30代',
    'male',
    'shooter',
    ['shooter', 'action', 'strategy'],
    'FPS歴5年。エイム練習とランク戦が日課です。一緒に遊ぶ仲間を探しています。',
    0.6,
    0.2,
  ),
  _MockSpec(
    'u-goods-hina',
    'gametomo',
    'グッズ集めのひな',
    '30代',
    'female',
    'goods',
    ['goods', 'retro', 'gamekai'],
    'フィギュアやサントラなどのグッズを集めています。情報交換歓迎です。',
    0.9,
    0.35,
  ),
  // ---- 雀とも！ハブ
  _MockSpec(
    'u-riichi-ken',
    'janotomo',
    'リーチ麻雀のけん',
    '30代',
    'male',
    'riichi',
    ['riichi', 'east', 'tactics'],
    'リアル麻雀週1。テンパイ即リーチが信条です。',
    -0.3,
    -0.1,
  ),
  _MockSpec(
    'u-beginner-nana',
    'janotomo',
    '雀荘デビュー目指すなな',
    '20代',
    'female',
    'beginner',
    ['beginner', 'riichi', 'janvic'],
    '麻雀教室に通い始めました。丁寧に教えてくれる方を探しています。',
    0.15,
    -0.4,
  ),
  // ---- 湯とも！ハブ
  _MockSpec(
    'u-sauna-takumi',
    'yutomo',
    'ととのいたくみ',
    '30代',
    'male',
    'sauna',
    ['sauna', 'loyly', 'onsen'],
    '週3でサウナ。ロウリュ企画には必ず参加します。',
    -0.7,
    0.5,
  ),
  _MockSpec(
    'u-sento-mio',
    'yutomo',
    '銭湯めぐりみお',
    '20代',
    'female',
    'sento',
    ['sento', 'saunameal', 'super'],
    '都内の銭湯を制覇中。サウナ飯の情報交換歓迎です。',
    1.2,
    -0.9,
  ),
  // ---- キャンとも！ハブ
  _MockSpec(
    'u-camp-daiki',
    'campotomo',
    '焚き火だいき',
    '40代',
    'male',
    'fire',
    ['fire', 'cook', 'tent'],
    '月1でソロキャン。焚き火を見ながらのコーヒーが至福です。',
    -1.1,
    1.0,
  ),
  _MockSpec(
    'u-camp-rika',
    'campotomo',
    'グルキャンりか',
    '30代',
    'female',
    'group',
    ['group', 'bbq', 'star'],
    'ファミキャン歴3年。子連れでも安心なキャンプ場に詳しいです。',
    0.45,
    -1.3,
  ),
  // ---- 走りとも！ハブ
  _MockSpec(
    'u-touge-akira',
    'hashitomo',
    '峠のあきら',
    '30代',
    'male',
    'touge',
    ['touge', 'jdm', 'photo'],
    '週末は朝4時に起きて峠へ。安全第一で走っています。',
    0.8,
    0.9,
  ),
  // ---- 音とも！ハブ
  _MockSpec(
    'u-band-sora',
    'ototomo',
    'ギターのそら',
    '20代',
    'undisclosed',
    'guitar',
    ['guitar', 'band', 'live'],
    'コピーから始めてオリジナル曲製作中。バンドメンバー募集中です。',
    -1.4,
    -0.8,
  ),
  // ---- コスとも！ハブ
  _MockSpec(
    'u-anime-rei',
    'costomo',
    'コス歴2年のれい',
    '20代',
    'female',
    'anime',
    ['anime', 'photo', 'event'],
    'アニメのキャラを中心にやっています。撮影仲間を探しています。',
    -0.7,
    1.2,
  ),
  _MockSpec(
    'u-comic-nana',
    'costomo',
    '漫画好きのなな',
    '30代',
    'female',
    'comic',
    ['comic', 'photo', 'edit'],
    '漫画原作のキャラをよくやります。加工も自分でやっています。',
    1.1,
    -0.9,
  ),
  // ---- スポとも！ハブ
  _MockSpec(
    'u-futsal-taiga',
    'supotomo',
    'フットサルのたいが',
    '20代',
    'male',
    'futsal',
    ['futsal', 'watch'],
    '平日夜にフットサルしています。体験歓迎のメンバー募集中です。',
    0.4,
    1.4,
  ),
];

class _BusinessSpec {
  final String id;
  final String hub;
  final String nickname;
  final String iconCategoryId;
  final String storeType;
  final String bio;
  final double northKm;
  final double eastKm;

  const _BusinessSpec(this.id, this.hub, this.nickname, this.iconCategoryId,
      this.storeType, this.bio, this.northKm, this.eastKm);
}

const List<_BusinessSpec> _businessSpecs = [
  _BusinessSpec(
    'b-arcade-sakura',
    'gametomo',
    'ゲームセンター 桜荘',
    'arcade',
    'ゲームセンター',
    '対戦台と最新タイトルを多数設置。初心者歓迎のゲーム教室もやっています。',
    0.8,
    0.9,
  ),
  _BusinessSpec(
    'b-jansou-miyako',
    'janotomo',
    '雀荘 都',
    'riichi',
    '雀荘',
    'セットとフリーが両方ある老舗雀荘。初心者歓迎の麻雀教室もやっています。',
    -0.5,
    1.1,
  ),
  _BusinessSpec(
    'b-sento-yumegaoka',
    'yutomo',
    '銭湯 ゆめが丘',
    'sento',
    '銭湯',
    '天然温泉と平日ロウリュ企画が自慢。休憩処も充実しています。',
    1.5,
    -0.6,
  ),
  _BusinessSpec(
    'b-camp-foresight',
    'campotomo',
    'キャンプ場 フォーサイト',
    'tent',
    'キャンプ場・グランピング',
    '区画サイトとフリーサイトがあり、初心者向けレンタルギアもあります。',
    -0.2,
    0.8,
  ),
];

/// 各モックユーザー（一般・ビジネス）の所属ハブ。
/// 近く・探すの表示をハブごとに切り替えるのに使う（ホームは全ハブ混合）。
const Map<String, String> mockUserHubs = {
  'u-shooter-ken': 'gametomo',
  'u-goods-hina': 'gametomo',
  'u-riichi-ken': 'janotomo',
  'u-beginner-nana': 'janotomo',
  'u-sauna-takumi': 'yutomo',
  'u-sento-mio': 'yutomo',
  'u-camp-daiki': 'campotomo',
  'u-camp-rika': 'campotomo',
  'u-touge-akira': 'hashitomo',
  'u-band-sora': 'ototomo',
  'u-anime-rei': 'costomo',
  'u-comic-nana': 'costomo',
  'u-futsal-taiga': 'supotomo',
  'b-arcade-sakura': 'gametomo',
  'b-jansou-miyako': 'janotomo',
  'b-sento-yumegaoka': 'yutomo',
  'b-camp-foresight': 'campotomo',
};

const double _kmPerDegLat = 111.32;

AppUser _specToUser(_MockSpec s, double anchorLat, double anchorLng) {
  final cos =
      math.cos(anchorLat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  return AppUser(
    id: s.id,
    nickname: s.nickname,
    decade: s.decade,
    gender: s.gender,
    iconCategoryId: s.iconCategoryId,
    interestIds: s.interestIds,
    bio: s.bio,
    lat: anchorLat + s.northKm / _kmPerDegLat,
    lng: anchorLng + s.eastKm / (_kmPerDegLat * cos),
  );
}

BusinessUser _specToBusiness(
    _BusinessSpec s, double anchorLat, double anchorLng) {
  final cos =
      math.cos(anchorLat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  return BusinessUser(
    id: s.id,
    nickname: s.nickname,
    decade: '経営者',
    gender: 'undisclosed',
    iconCategoryId: s.iconCategoryId,
    interestIds: const [],
    bio: s.bio,
    lat: anchorLat + s.northKm / _kmPerDegLat,
    lng: anchorLng + s.eastKm / (_kmPerDegLat * cos),
    storeType: s.storeType,
  );
}

/// 現在地を中心にモックユーザー（一般 + ビジネス）を配置する。
/// 全ハブぶんを返すので、呼び出し側（AppState）がハブでフィルタする。
List<AppUser> buildMockUsers(double anchorLat, double anchorLng) {
  return [
    for (final s in _specs) _specToUser(s, anchorLat, anchorLng),
    for (final s in _businessSpecs) _specToBusiness(s, anchorLat, anchorLng),
  ];
}

/// シード募集（起動時刻からの残り時間で作るので、いつ開いても「今から」感が出る）。
/// host は generalUsers（モック一般ユーザー）から id で引く。
List<Recruitment> seedRecruitments(DateTime now, List<AppUser> generalUsers) {
  Recruitment make({
    required String hostId,
    required String genreId,
    required String title,
    required String body,
    required String meetup,
    required int capacity,
    required int minutesLeft,
  }) {
    return Recruitment(
      id: 'r-$hostId',
      hostId: hostId,
      genreId: genreId,
      title: title,
      body: body,
      meetup: meetup,
      capacity: capacity,
      createdAt: now.subtract(const Duration(minutes: 15)),
      expiresAt: now.add(Duration(minutes: minutesLeft)),
      memberIds: [hostId],
    );
  }

  return [
    make(
      hostId: 'u-shooter-ken',
      genreId: 'game',
      title: '今夜、ゲームセンターで一戦しませんか',
      body: '対戦台を予約しました。あと1人を探しています。初心者も歓迎です。',
      meetup: 'ゲームセンター 桜荘 2F 受付',
      capacity: 4,
      minutesLeft: 105,
    ),
    make(
      hostId: 'u-goods-hina',
      genreId: 'talk',
      title: 'グッズ自慢のオフ会、参加者募集',
      body: 'お気に入りのソフトやコレクションを見せ合う会です。',
      meetup: 'ゲームセンター 桜荘 1F ロビー',
      capacity: 3,
      minutesLeft: 45,
    ),
    make(
      hostId: 'u-riichi-ken',
      genreId: 'game',
      title: '今夜、半荘を立ち上げませんか',
      body: 'セット雀荘の卓を予約しました。4人目を探しています。初心者も歓迎です。',
      meetup: '雀荘 都 2F 受付',
      capacity: 4,
      minutesLeft: 105,
    ),
    make(
      hostId: 'u-sauna-takumi',
      genreId: 'tour',
      title: '今夜、新規オープンのスーパー銭湯に行きませんか',
      body: '高温サウナと仰向け水風呂が自慢の新店へ。夜22時集合です。',
      meetup: '銭湯 ゆめが丘 入口',
      capacity: 3,
      minutesLeft: 70,
    ),
    make(
      hostId: 'u-camp-daiki',
      genreId: 'daycamp',
      title: '今週末、デイキャンプしませんか',
      body: '焚き火を囲んでまったりコーヒー。初心者も装備レンタルできます。',
      meetup: 'キャンプ場 フォーサイト 管理棟前',
      capacity: 5,
      minutesLeft: 160,
    ),
    make(
      hostId: 'u-touge-akira',
      genreId: 'touring',
      title: '日曜の早朝ツーリングに行きます',
      body: '近所の峠と道の駅を回る2時間コース。安全第一で走ります。',
      meetup: '道の駅 駐車場 コンビニ前',
      capacity: 4,
      minutesLeft: 130,
    ),
  ];
}

class _ExchangeSeedSpec {
  final String id;
  final String posterId;
  final String kind;
  final String itemDescription;
  final String areaName;
  final String detail;
  final double northKm;
  final double eastKm;
  final Duration age;
  const _ExchangeSeedSpec(this.id, this.posterId, this.kind,
      this.itemDescription, this.areaName, this.detail, this.northKm,
      this.eastKm, this.age);
}

const List<_ExchangeSeedSpec> _exchangeSeedSpecs = [
  // ---- ゲーとも！ハブ（グッズのゆずりあい）
  _ExchangeSeedSpec(
    'cx-seed-1',
    'u-goods-hina',
    'give',
    'ゲームソフト（中古・箱説明書付き）',
    'ゲームセンター 桜荘 周辺',
    '新しいソフトを買ったので、'
        '使ってくださる方にゆずります。手渡し前提です。',
    0.3,
    -0.6,
    Duration(hours: 2),
  ),
  _ExchangeSeedSpec(
    'cx-seed-2',
    'u-shooter-ken',
    'wanted',
    '中古のアーケードスティックを探しています',
    'ゲームセンター 桜荘 周辺',
    '格ゲー対策用に練習したいので探しています。'
        '不要グッズとの交換の対応も可能です。',
    -0.5,
    1.0,
    Duration(hours: 9),
  ),
  // ---- 雀とも！ハブ
  _ExchangeSeedSpec(
    'cx-seed-3',
    'u-beginner-nana',
    'wanted',
    '中古の麻雀牌セットを探しています',
    '駅前広場 周辺',
    '使い方の練習用に探しています。不要グッズとの'
        '交換の対応も可能です。DMお待ちしています。',
    -0.2,
    0.8,
    Duration(hours: 5),
  ),
  // ---- 湯とも！ハブ
  _ExchangeSeedSpec(
    'cx-seed-4',
    'u-sento-mio',
    'trade',
    'サウナハット（未使用）と バスマットを交換します',
    '市役所裏の公園 周辺',
    '買い替えで余ったため交換希望です。状態は写真で'
        '送ります。公共の場所で受け渡しできます。',
    -0.9,
    -0.3,
    Duration(hours: 26),
  ),
  // ---- 走りとも！ハブ
  _ExchangeSeedSpec(
    'cx-seed-5',
    'u-touge-akira',
    'give',
    '中古のフルフェイスヘルメットをゆずります',
    '市役所裏の公園 周辺',
    'サイズが合わなくなったためゆずります。'
        '人目のある場所で手渡しします。',
    0.9,
    1.1,
    Duration(hours: 4),
  ),
  // ---- キャンとも！ハブ
  _ExchangeSeedSpec(
    'cx-seed-6',
    'u-camp-daiki',
    'trade',
    '焚き火台（小）とランタンを交換します',
    'キャンプ場 フォーサイト 周辺',
    '買い替えで余ったため交換希望です。'
        'キャンプ場の管理棟前で受け渡しできます。',
    -0.6,
    -0.7,
    Duration(hours: 12),
  ),
  // ---- 音とも！ハブ
  _ExchangeSeedSpec(
    'cx-seed-7',
    'u-band-sora',
    'wanted',
    '中古のエレキギターの練習用アンプを探しています',
    '市役所裏の公園 周辺',
    '自宅練習用に探しています。状態は問いません。'
        '公共の場所での受け渡し希望です。',
    -1.2,
    0.6,
    Duration(hours: 30),
  ),
  // ---- スポとも！ハブ
  _ExchangeSeedSpec(
    'cx-seed-8',
    'u-futsal-taiga',
    'trade',
    'サッカーボール（使用済み・状態良好）と交換します',
    '区民体育館 周辺',
    '練習球が増えたため交換希望です。'
        '体育館の入口前で受け渡しできます。',
    0.7,
    -1.2,
    Duration(hours: 18),
  ),
  // ---- コスとも！ハブ（撮影報告）
  _ExchangeSeedSpec(
    'cx-seed-9',
    'u-anime-rei',
    'shoot',
    '○○の学生服を撮影してきました',
    '中央公園 周辺',
    '夕方の斜光で綺麗に撮れました。撮影同伴の'
        'コス友達と一緒に撮影した報告です。',
    -0.7,
    1.2,
    Duration(hours: 2),
  ),
  _ExchangeSeedSpec(
    'cx-seed-10',
    'u-comic-nana',
    'spot',
    '駅東側のレンガ倉庫がおすすめ',
    '駅東側のイベント会場横',
    '平日は人が少なく撮りやすいです。手前の路地も'
        '雰囲気が出ます。朝の光がおすすめ。',
    1.1,
    -0.9,
    Duration(hours: 5),
  ),
  _ExchangeSeedSpec(
    'cx-seed-11',
    'u-anime-rei',
    'art',
    '○○のキャラを描いてみました',
    '',
    'コス衣装の参考にした塗り方を試してみました。'
        '同じ作品好きの人と交流したいです。',
    -0.4,
    -0.2,
    Duration(hours: 16),
  ),
];

List<GameGoodsExchange> buildSeedGameGoodsExchanges(
    DateTime now, double anchorLat, double anchorLng) {
  final cos = (anchorLat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  // シードは「投稿者が表示中ハブのユーザー」のものだけ出す
  // （ハブ違いの投稿者はカード表示時にユーザーが引けなくなるため）
  final hubId = hubRegistry.active.appId;
  return [
    for (final s in _exchangeSeedSpecs)
      if (mockUserHubs[s.posterId] == hubId)
        GameGoodsExchange(
        id: s.id,
        posterId: s.posterId,
        kind: s.kind,
        itemDescription: s.itemDescription,
        areaName: s.areaName,
        detail: s.detail,
        lat: anchorLat + s.northKm / _kmPerDegLat,
        lng: anchorLng + s.eastKm / (_kmPerDegLat * cos),
        createdAt: now.subtract(s.age),
      ),
  ];
}

/// モックの返信候補（デモの自動応答に使う。本開発では Supabase Realtime に置換）
const List<String> mockReplies = [
  'よろしくお願いします！',
  '次のセッション、楽しみですね。',
  '先に着いて席を確保しておきますね。',
  '初心者も大歓迎です。気軽にどうぞ。',
];

/// モックの応募メッセージ
const List<String> mockApplyMessages = [
  '参加したいです！仲間を探していました。',
  '同じ趣味でよく集まっています。',
  'この近くでよく活動しています。',
];
