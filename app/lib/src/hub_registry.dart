import 'package:flutter/material.dart';

import 'models.dart';
import 'services/app_config.dart';

/// 近くの施設を検索するOSMタグ（例: leisure=amusement_arcade）。
/// [label] はUI上の種別名（例: 「ゲームセンター」）。
class SpotTag {
  final String key;
  final String value;
  final String label;
  const SpotTag(this.key, this.value, this.label);
}

/// ハブ = 「ともつく！」シリーズの1アプリ相当の趣味ドメイン。
/// 総合版（このアプリ）はこの設定を切り替えることで、
/// 同じUI・同じDBをハブごとに使い分ける。

/// 近況報告ボードの基本種別（撮影/つぶやき/イベント）。
/// 2026-11-18: 全ハブの旧「ゆずりあい・交換」を近況報告に統一した。
const List<(String, String)> recentReportKinds = [
  ('shoot', '撮影'),
  ('post', 'つぶやき'),
  ('event', 'イベント'),
];

class HubConfig {
  final String appId;
  final String name;
  final String tagline;
  final IconData icon;
  final List<Genre> genres;
  final List<InterestCategory> interests;
  final List<String> storeTypes;
  final List<SpotTag> spotTags;
  final String? exchangeTable;
  final String exchangeLabel;

  /// 投稿ボード（4つ目のタブ）の投稿種別。`(id, 表示ラベル)` のリスト。
  /// 既定はグッズのゆずりあい3種（UGCハブ向け）。内蔵ハブは
  /// 「近況報告」（shoot/撮影・post/つぶやき・event/イベント等）に統一。
  final List<(String, String)> exchangeKinds;
  final bool builtin;

  const HubConfig({
    required this.appId,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.genres,
    required this.interests,
    required this.storeTypes,
    this.spotTags = const [],
    this.exchangeTable,
    this.exchangeLabel = 'グッズ',
    this.exchangeKinds = const [
      ('give', 'ゆずります'),
      ('wanted', '探してます'),
      ('trade', '交換'),
    ],
    this.builtin = true,
  });

  /// 施設検索対応ハブか
  bool get hasSpots => spotTags.isNotEmpty;

  /// ゆずりあい・交換ボード対応ハブか
  bool get hasExchange => exchangeTable != null;

  /// 近況報告系ボードか（種別に give を含まない）
  bool get isRecentReportBoard => !exchangeKinds.any((k) => k.$1 == 'give');

  /// 種別idの表示ラベル（未知のidはそのまま返す）
  String exchangeKindLabel(String id) {
    for (final k in exchangeKinds) {
      if (k.$1 == id) return k.$2;
    }
    return id;
  }

  /// 種別idの設定内での位置（カードの色分けに使う。未知は0）
  int exchangeKindIndex(String id) {
    for (var i = 0; i < exchangeKinds.length; i++) {
      if (exchangeKinds[i].$1 == id) return i;
    }
    return 0;
  }
}

/// Phase 3（UGCハブ）でユーザーが作った設定をDB（hub_configs）から復元する型。
class RemoteHubRow {
  final String appId;
  final String displayName;
  final String description;
  final String status;
  final List<Genre> genres;
  final List<InterestCategory> interests;
  final List<String> storeTypes;
  final List<SpotTag> spotTags;
  final String createdBy;
  const RemoteHubRow({
    required this.appId,
    required this.displayName,
    required this.description,
    required this.status,
    required this.genres,
    required this.interests,
    required this.storeTypes,
    required this.spotTags,
    required this.createdBy,
  });
}

/// 内蔵ハブ（既存12アプリ + 総合版ホーム）。
/// 各ドメインのジャンル・カテゴリ・業態は各アプリの実装から転記している。
const List<HubConfig> builtinHubs = [
  HubConfig(
    appId: 'tomotsuku',
    name: 'ともつく！ホーム',
    tagline: '全ハブを横断して使える総合版ホーム',
    icon: Icons.hub,
    genres: [
      Genre('game', '今から誘う', Icons.wb_incandescent),
      Genre('event', 'イベントに参加', Icons.celebration),
      Genre('talk', '交流・雑談', Icons.groups),
    ],
    interests: [
      InterestCategory('meshitomo', '飯・グルメ', Icons.dinner_dining),
      InterestCategory('inutomo', '犬', Icons.pets),
      InterestCategory('tsuritomo', '釣り', Icons.phishing),
      InterestCategory('nekotomo', '猫', Icons.cruelty_free),
      InterestCategory('costomo', 'コスプレ', Icons.photo_camera),
      InterestCategory('hashitomo', '車・バイク', Icons.directions_car),
      InterestCategory('campotomo', 'キャンプ', Icons.forest),
      InterestCategory('ototomo', '音楽', Icons.music_note),
      InterestCategory('yutomo', '銭湯・サウナ', Icons.hot_tub),
      InterestCategory('supotomo', 'スポーツ', Icons.directions_run),
      InterestCategory('janotomo', '麻雀', Icons.casino),
      InterestCategory('gametomo', 'ゲーム', Icons.sports_esports),
    ],
    storeTypes: ['飲食店', '物販', 'サービス業', '施設運営', 'その他'],
    spotTags: [],
  ),
  HubConfig(
    appId: 'meshitomo',
    name: '飯とも！',
    tagline: 'ご飯・飲みの誘い合い',
    icon: Icons.dinner_dining,
    genres: [
      Genre('meshi', 'ご飯', Icons.dinner_dining),
      Genre('nomi', '飲み', Icons.local_bar),
      Genre('cafe', 'カフェ', Icons.local_cafe),
    ],
    interests: [
      InterestCategory('izakaya', '居酒屋', Icons.local_bar),
      InterestCategory('yakiniku', '焼肉', Icons.outdoor_grill),
      InterestCategory('ramen', 'ラーメン', Icons.ramen_dining),
      InterestCategory('cafe', 'カフェ', Icons.local_cafe),
      InterestCategory('sweets', 'スイーツ', Icons.cake),
      InterestCategory('sushi', '寿司・魚介', Icons.set_meal),
      InterestCategory('pasta', 'パスタ・イタリアン', Icons.dinner_dining),
      InterestCategory('pizza', 'ピザ', Icons.local_pizza),
      InterestCategory('burger', 'ハンバーガー', Icons.lunch_dining),
      InterestCategory('spicy', '激辛', Icons.local_fire_department),
      InterestCategory('ethnic', 'エスニック・アジア', Icons.rice_bowl),
      InterestCategory('brunch', '朝食・ブランチ', Icons.brunch_dining),
    ],
    storeTypes: ['居酒屋', 'ラーメン店', '焼肉店', 'カフェ', 'そば・うどん', '寿司', 'イタリアン', '中華', 'その他'],
    exchangeTable: 'meal_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: recentReportKinds,
  ),
  HubConfig(
    appId: 'inutomo',
    name: '犬とも！',
    tagline: '犬の飼い主同士の交流',
    icon: Icons.pets,
    genres: [
      Genre('sanpo', 'お散歩', Icons.directions_walk),
      Genre('dogrun', 'ドッグラン', Icons.pets),
      Genre('dogcafe', 'ドッグカフェ', Icons.local_cafe),
    ],
    interests: [
      InterestCategory('sanpo', 'お散歩', Icons.directions_walk),
      InterestCategory('dogrun', 'ドッグラン', Icons.pets),
      InterestCategory('dogcafe', 'ドッグカフェ', Icons.local_cafe),
      InterestCategory('training', 'しつけ・トレーニング', Icons.school),
      InterestCategory('sports', 'アジリティ・ドッグスポーツ', Icons.sports),
      InterestCategory('photo', '愛犬撮影', Icons.camera_alt),
      InterestCategory('goods', 'グッズ・おやつ研究', Icons.shopping_basket),
      InterestCategory('travel', 'お出かけ・旅行', Icons.luggage),
      InterestCategory('health', '健康・動物病院', Icons.medical_services),
      InterestCategory('grooming', 'トリミング・お手入れ', Icons.content_cut),
      InterestCategory('rescue', '保護犬・里親活動', Icons.volunteer_activism),
      InterestCategory('wanko', '犬友達・多頭飼い', Icons.diversity_1),
    ],
    storeTypes: ['ドッグラン', 'ドッグカフェ', 'ペットサロン・トリミング', '動物病院', 'ペットホテル', 'しつけ教室', 'ペット用品店', '保護犬・譲渡会運営', 'その他'],
    exchangeTable: 'dog_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: recentReportKinds,
  ),
  HubConfig(
    appId: 'tsuritomo',
    name: '釣りとも！',
    tagline: '釣り仲間・釣果の共有',
    icon: Icons.phishing,
    genres: [
      Genre('shore', '堤防・陸っぱり', Icons.phishing),
      Genre('surf', '投げ・サーフ', Icons.waves),
      Genre('boat', '船・釣り堀', Icons.directions_boat),
    ],
    interests: [
      InterestCategory('sabiki', 'サビキ・堤防釣り', Icons.phishing),
      InterestCategory('surf', '投げ・サーフ釣り', Icons.waves),
      InterestCategory('lure', 'ルアー・エギング', Icons.set_meal),
      InterestCategory('fly', 'フライ・渓流釣り', Icons.air),
      InterestCategory('pond', '管理釣り場・淡水', Icons.pool),
      InterestCategory('boat', '船釣り', Icons.directions_boat),
      InterestCategory('night', '夜釣り', Icons.dark_mode),
      InterestCategory('cook', '釣った魚を食べる', Icons.restaurant),
      InterestCategory('tackle', '釣り具・自作仕掛け', Icons.handyman),
      InterestCategory('photo', '釣果・風景撮影', Icons.camera_alt),
      InterestCategory('travel', '遠征・釣行旅行', Icons.luggage),
      InterestCategory('cleanup', '釣り場の清掃・環境保護', Icons.volunteer_activism),
    ],
    storeTypes: ['釣具店', '乗り合い船・渡船', '釣り堀・管理釣り場', 'ボート・カヤックレンタル', 'フィッシングカフェ・飲食', 'ロッド・リール修理工房', 'アウトドア・キャンプ用品店', 'その他'],
  ),
  HubConfig(
    appId: 'nekotomo',
    name: 'ニーアキャット（猫とも）',
    tagline: '猫の飼い主同士の交流',
    icon: Icons.cruelty_free,
    genres: [
      Genre('catcafe', 'ねこカフェ', Icons.local_cafe),
      Genre('mofukai', 'もふもふ会', Icons.pets),
      Genre('sanpo', 'お散歩・お出かけ', Icons.directions_walk),
    ],
    interests: [
      InterestCategory('catcafe', 'ねこカフェ', Icons.local_cafe),
      InterestCategory('photo', '愛猫撮影', Icons.camera_alt),
      InterestCategory('goods', 'グッズ・おやつ研究', Icons.shopping_basket),
      InterestCategory('play', '遊び・おもちゃ研究', Icons.toys),
      InterestCategory('grooming', 'お手入れ・ブラッシング', Icons.content_cut),
      InterestCategory('health', '健康・動物病院', Icons.medical_services),
      InterestCategory('training', 'しつけ・トイレトレーニング', Icons.school),
      InterestCategory('travel', 'お出かけ・旅行', Icons.luggage),
      InterestCategory('rescue', '保護猫・里親活動', Icons.volunteer_activism),
      InterestCategory('tnr', 'のら猫・TNR活動', Icons.pets),
      InterestCategory('multicat', '多頭飼い・猫友達', Icons.diversity_1),
    ],
    storeTypes: ['ねこカフェ', 'ペットショップ', 'ペットサロン・トリミング', '動物病院', 'ペットホテル', 'しつけ教室', 'ペット用品店', '保護猫・譲渡会運営', 'その他'],
    spotTags: [
      SpotTag('amenity', 'animal_shelter', '動物愛護施設'),
      SpotTag('amenity', 'veterinary', '動物病院'),
    ],
    exchangeTable: 'cat_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: recentReportKinds,
  ),
  HubConfig(
    appId: 'costomo',
    name: 'コスとも！',
    tagline: 'コスプレ友達・撮影仲間',
    icon: Icons.photo_camera,
    genres: [
      Genre('shooting', '撮影会', Icons.photo_camera),
      Genre('event', 'イベント', Icons.celebration),
      Genre('exchange', '交流・雑談', Icons.groups),
    ],
    interests: [
      InterestCategory('anime', 'アニメ', Icons.live_tv),
      InterestCategory('game', 'ゲーム', Icons.sports_esports),
      InterestCategory('comic', '漫画・ラノベ', Icons.book),
      InterestCategory('tokusatsu', '特撮', Icons.movie),
      InterestCategory('vtuber', 'VTuber', Icons.record_voice_over),
      InterestCategory('vocaloid', 'ボカロ・音楽', Icons.music_note),
      InterestCategory('photo', 'コスプレ撮影', Icons.camera_alt),
      InterestCategory('edit', '加工・動画編集', Icons.edit),
      InterestCategory('event', 'イベント参加', Icons.celebration),
      InterestCategory('wigmaking', 'ウィッグ・衣装制作', Icons.content_cut),
      InterestCategory('dance', 'ダンス・コラボ', Icons.directions_run),
    ],
    storeTypes: ['フォトスタジオ', 'イベント会場', '衣装・ウィッグ店', '撮影・レタッチ代行', 'ホール・劇場', 'ダンススタジオ', 'コスプレ用品店', '小物・道具工房', 'その他'],
    spotTags: [
      SpotTag('leisure', 'park', '公園'),
      SpotTag('amenity', 'place_of_worship', '神社・お寺'),
      SpotTag('amenity', 'events_venue', 'イベント会場'),
    ],
    exchangeTable: 'shoot_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: [
      ('shoot', '撮影'),
      ('post', 'つぶやき'),
      ('event', 'イベント'),
      ('art', '絵'),
    ],
  ),
  HubConfig(
    appId: 'hashitomo',
    name: '走りとも！',
    tagline: '車・バイクの走り仲間',
    icon: Icons.directions_car,
    genres: [
      Genre('run', '走行会・サーキット', Icons.flag),
      Genre('touring', 'ツーリング・ドライブ', Icons.motorcycle),
      Genre('meet', 'オフ会・ミーティング', Icons.groups),
    ],
    interests: [
      InterestCategory('jdm', '国産車', Icons.directions_car),
      InterestCategory('import', '外車・輸入車', Icons.language),
      InterestCategory('classic', '旧車・レストア', Icons.history),
      InterestCategory('sports', 'スポーツカー', Icons.speed),
      InterestCategory('drift', 'ドリフト', Icons.loop),
      InterestCategory('circuit', 'サーキット・走行会', Icons.flag),
      InterestCategory('touge', '峠・ワインディング', Icons.terrain),
      InterestCategory('touring', 'ツーリング・ドライブ', Icons.map),
      InterestCategory('bike', 'バイク', Icons.two_wheeler),
      InterestCategory('maint', '整備・メンテ', Icons.build),
      InterestCategory('wash', '洗車・ケア', Icons.local_car_wash),
      InterestCategory('photo', '走り・カー撮影', Icons.camera_alt),
    ],
    storeTypes: ['ガソリンスタンド', 'カーショップ・整備工場', 'カー用品店', 'ドライブイン・道の駅', 'サーキット・走行会場', 'バイクショップ', 'レンタカー・レンタルバイク', '洗車場', 'その他'],
    spotTags: [
      SpotTag('amenity', 'fuel', 'ガソリンスタンド'),
      SpotTag('highway', 'services', '道の駅/SA/PA'),
      SpotTag('tourism', 'viewpoint', '展望台'),
    ],
    exchangeTable: 'run_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: recentReportKinds,
  ),
  HubConfig(
    appId: 'campotomo',
    name: 'キャンとも！',
    tagline: 'キャンプ仲間・ギア自慢',
    icon: Icons.forest,
    genres: [
      Genre('daycamp', 'デイキャン・焚き火', Icons.local_fire_department),
      Genre('overnight', '泊まりキャンプ', Icons.nights_stay),
      Genre('gearmeet', 'ギア自慢・オフ会', Icons.groups),
    ],
    interests: [
      InterestCategory('tent', 'テント・タープ', Icons.night_shelter),
      InterestCategory('fire', '焚き火・薪', Icons.local_fire_department),
      InterestCategory('cook', 'キャンプ飯', Icons.rice_bowl),
      InterestCategory('bbq', 'BBQ・網焼き', Icons.outdoor_grill),
      InterestCategory('coffee', 'コーヒー・休憩', Icons.coffee),
      InterestCategory('gear', 'アウトドアギア', Icons.backpack),
      InterestCategory('solo', 'ソロキャン', Icons.person),
      InterestCategory('group', 'グルキャン・ファミキャン', Icons.groups),
      InterestCategory('bikecamp', 'ツーリングキャンプ', Icons.two_wheeler),
      InterestCategory('winter', '冬キャンプ', Icons.ac_unit),
      InterestCategory('star', '星空・天体観察', Icons.nightlight),
      InterestCategory('photo', 'キャンプ写真', Icons.camera_alt),
    ],
    storeTypes: ['キャンプ場・グランピング', 'アウトドア用品店', 'レンタルギア・アウトドア', 'キャンプ飯カフェ・食堂', '薪・燃料・雑貨', 'ツアー・アウトドアガイド', 'その他'],
    spotTags: [
      SpotTag('tourism', 'camp_site', 'キャンプ場'),
      SpotTag('tourism', 'caravan_site', 'キャラバンサイト'),
      SpotTag('tourism', 'alpine_hut', '山小屋'),
    ],
    exchangeTable: 'camp_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: recentReportKinds,
  ),
  HubConfig(
    appId: 'ototomo',
    name: '音とも！',
    tagline: '音楽仲間・セッション相手',
    icon: Icons.music_note,
    genres: [
      Genre('session', 'セッション・合奏', Icons.music_note),
      Genre('live', 'ライブ・イベント参戦', Icons.mic),
      Genre('talk', '交流・オフ会', Icons.groups),
    ],
    interests: [
      InterestCategory('guitar', 'ギター', Icons.music_note),
      InterestCategory('bass', 'ベース', Icons.graphic_eq),
      InterestCategory('drums', 'ドラム・パーカッション', Icons.album),
      InterestCategory('vocal', 'ボーカル', Icons.mic),
      InterestCategory('band', 'バンド活動', Icons.groups),
      InterestCategory('jpop', 'J-POP・ロック', Icons.favorite),
      InterestCategory('anime', 'アニメ・ボカロ', Icons.auto_awesome),
      InterestCategory('jazz', 'ジャズ', Icons.piano),
      InterestCategory('classic', 'クラシック', Icons.piano),
      InterestCategory('dtm', 'DTM・作曲', Icons.computer),
      InterestCategory('live', 'ライブ参戦', Icons.celebration),
      InterestCategory('karaoke', 'カラオケ', Icons.headset),
    ],
    storeTypes: ['ライブハウス', '音楽スタジオ', '楽器店', 'レコード・CD・楽譜店', 'ライブカフェ・バー', '録音・DTMスタジオ', '音楽教室・講師', 'その他'],
    spotTags: [
      SpotTag('amenity', 'music_venue', 'ライブハウス'),
      SpotTag('amenity', 'concert_hall', 'コンサートホール'),
      SpotTag('amenity', 'studio', '音楽スタジオ'),
    ],
    exchangeTable: 'music_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: recentReportKinds,
  ),
  HubConfig(
    appId: 'yutomo',
    name: '湯とも！',
    tagline: '銭湯・サウナ仲間',
    icon: Icons.hot_tub,
    genres: [
      Genre('tour', '銭湯・サウナめぐり', Icons.hot_tub),
      Genre('event', 'イベント・湯めぐり会', Icons.celebration),
      Genre('talk', '交流・オフ会（ととのい）', Icons.groups),
    ],
    interests: [
      InterestCategory('sento', '銭湯', Icons.hot_tub),
      InterestCategory('super', 'スーパー銭湯', Icons.storefront),
      InterestCategory('sauna', 'サウナ', Icons.local_fire_department),
      InterestCategory('loyly', 'ロウリュ・アウフグース', Icons.air),
      InterestCategory('mizuburo', '水風呂', Icons.water_drop),
      InterestCategory('onsen', '日帰り温泉', Icons.spa),
      InterestCategory('ganban', '岩盤浴', Icons.whatshot),
      InterestCategory('spaland', 'スパ・健康ランド', Icons.pool),
      InterestCategory('saunameal', 'サウナ飯', Icons.restaurant),
      InterestCategory('totonoi', 'ととのい', Icons.self_improvement),
      InterestCategory('repeat', 'リピート制サウナ', Icons.replay),
      InterestCategory('goods', 'サウナグッズ', Icons.checkroom),
    ],
    storeTypes: ['銭湯', 'スーパー銭湯', '日帰り温泉', 'スパ・健康ランド', 'サウナ専門店', '岩盤浴施設', 'サウナグッズ店', 'その他'],
    spotTags: [
      SpotTag('amenity', 'public_bath', '銭湯'),
      SpotTag('leisure', 'water_park', 'スパ・健康ランド'),
      SpotTag('leisure', 'sauna', 'サウナ施設'),
    ],
    exchangeTable: 'bath_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: recentReportKinds,
  ),
  HubConfig(
    appId: 'supotomo',
    name: 'スポとも！',
    tagline: 'スポーツ仲間・種目ソート付き',
    icon: Icons.directions_run,
    genres: [
      Genre('play', '一緒に練習・ゲームをしよう', Icons.sports_basketball),
      Genre('event', '大会・イベント参戦', Icons.emoji_events),
      Genre('talk', '交流・オフ会', Icons.groups),
    ],
    interests: [
      InterestCategory('running', 'ランニング・ジョギング', Icons.directions_run),
      InterestCategory('walking', 'ウォーキング', Icons.nordic_walking),
      InterestCategory('soccer', 'サッカー・フットサル', Icons.sports_soccer),
      InterestCategory('baseball', '野球・ソフトボール', Icons.sports_baseball),
      InterestCategory('tennis', 'テニス', Icons.sports_tennis),
      InterestCategory('basketball', 'バスケットボール', Icons.sports_basketball),
      InterestCategory('volleyball', 'バレーボール', Icons.sports_volleyball),
      InterestCategory('tabletennis', '卓球・バドミントン', Icons.sports_tennis),
      InterestCategory('golf', 'ゴルフ', Icons.golf_course),
      InterestCategory('swimming', '水泳', Icons.pool),
      InterestCategory('gym', '筋トレ・ジム', Icons.fitness_center),
      InterestCategory('cycling', 'サイクリング', Icons.directions_bike),
    ],
    storeTypes: ['スポーツジム', '体育館・スポーツ施設運営', 'スポーツ教室・スクール', 'スポーツ用品店', 'ゴルフ練習場', 'ランニングシューズ店', 'その他'],
    spotTags: [
      SpotTag('leisure', 'sports_centre', 'スポーツセンター'),
      SpotTag('leisure', 'fitness_centre', 'ジム'),
      SpotTag('leisure', 'stadium', '競技場'),
      SpotTag('leisure', 'pitch', 'グラウンド・コート'),
      SpotTag('leisure', 'track', '陸上トラック'),
    ],
    exchangeTable: 'sports_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: [
      ('match', '試合'),
      ('post', 'つぶやき'),
      ('event', 'イベント'),
    ],
  ),
  HubConfig(
    appId: 'janotomo',
    name: '雀とも！',
    tagline: '麻雀の半荘仲間',
    icon: Icons.casino,
    genres: [
      Genre('game', '今から一勝負', Icons.casino),
      Genre('event', '大会・イベント参戦', Icons.emoji_events),
      Genre('talk', '交流・オフ会', Icons.groups),
    ],
    interests: [
      InterestCategory('riichi', 'リーチ麻雀', Icons.view_module),
      InterestCategory('sanma', '三人麻雀（三麻）', Icons.filter_3),
      InterestCategory('east', '東南戦', Icons.timelapse),
      InterestCategory('tonpu', '東風戦', Icons.bolt),
      InterestCategory('beginner', '初心者・教え合い', Icons.school),
      InterestCategory('netgame', 'ネット麻雀', Icons.computer),
      InterestCategory('league', 'Mリーグ・観戦', Icons.emoji_events),
      InterestCategory('tactics', '打ち方・戦術', Icons.psychology),
      InterestCategory('rule', 'ローカルルール', Icons.menu_book),
      InterestCategory('goods', '麻雀グッズ', Icons.checkroom),
      InterestCategory('janvic', '雀荘めぐり', Icons.storefront),
      InterestCategory('mahjongkai', '麻雀サークル', Icons.groups),
    ],
    storeTypes: ['雀荘', '麻雀スクール・教室', 'ゲームセンター', '麻雀グッズ店', 'カフェ雀荘', 'レンタルスペース運営', 'その他'],
    spotTags: [
      SpotTag('leisure', 'amusement_arcade', 'ゲームセンター・雀荘'),
      SpotTag('amenity', 'community_centre', '公民館・集会所'),
    ],
    exchangeTable: 'mahjong_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: [
      ('agari', '上がり'),
      ('post', 'つぶやき'),
      ('event', 'イベント'),
    ],
  ),
  HubConfig(
    appId: 'gametomo',
    name: 'ゲーとも！',
    tagline: 'ゲーム仲間・対戦相手',
    icon: Icons.sports_esports,
    genres: [
      Genre('game', '今から一緒にプレイ', Icons.sports_esports),
      Genre('event', '大会・イベント参加', Icons.emoji_events),
      Genre('talk', '交流・オフ会', Icons.groups),
    ],
    interests: [
      InterestCategory('shooter', 'FPS・TPS', Icons.view_module),
      InterestCategory('rpg', 'RPG', Icons.filter_3),
      InterestCategory('action', 'アクション', Icons.timelapse),
      InterestCategory('fight', '格闘・レース', Icons.bolt),
      InterestCategory('beginner', '初心者・教え合い', Icons.school),
      InterestCategory('netgame', 'ネット対戦', Icons.computer),
      InterestCategory('esports', 'eスポーツ・大会', Icons.emoji_events),
      InterestCategory('strategy', '攻略・検証', Icons.psychology),
      InterestCategory('retro', 'レトロ・クラシック', Icons.menu_book),
      InterestCategory('goods', 'ゲームグッズ', Icons.checkroom),
      InterestCategory('arcade', 'ゲームセンターめぐり', Icons.storefront),
      InterestCategory('gamekai', 'ゲームサークル', Icons.groups),
    ],
    storeTypes: ['ゲームセンター', 'ゲームショップ・ホビー店', 'eスポーツ施設運営', 'カードゲーム・ボードゲーム店', 'ゲームカフェ', 'レンタルスペース運営', 'その他'],
    spotTags: [
      SpotTag('leisure', 'amusement_arcade', 'ゲームセンター'),
      SpotTag('amenity', 'community_centre', '公民館・集会所'),
    ],
    exchangeTable: 'game_reports',
    exchangeLabel: '近況報告',
    exchangeKinds: recentReportKinds,
  ),
];

/// ハブの選択状態と、DB由来（Phase 3のUGCハブ）の設定を管理する。
/// アプリ全体はグローバルインスタンス [hubRegistry] を通じて使う。
class HubRegistry {
  HubRegistry._();

  /// 選択中のハブ（未選択ならホーム）。
  HubConfig get active => _active ?? home;

  /// 総合版ホーム。
  HubConfig get home =>
      builtinHubs.firstWhere((h) => h.appId == AppConfig.appId);

  /// 選択可能なすべてのハブ（内蔵 + DB承認済みUGC）。
  List<HubConfig> get available => [...builtinHubs, ..._dynamic];

  final List<HubConfig> _dynamic = [];
  HubConfig? _active;

  HubConfig byId(String appId) {
    for (final h in available) {
      if (h.appId == appId) return h;
    }
    return home;
  }

  /// ハブを切り替える。AppConfig.activeAppId も同期する
  /// （データアクセス層は activeAppId を見るため）。
  void select(HubConfig hub) {
    _active = hub.appId == home.appId ? null : hub;
    AppConfig.activeAppId = hub.appId;
  }

  /// DBに登録済みのUGCハブ（承認済み）を追加・更新する。
  void upsertDynamic(HubConfig hub) {
    _dynamic.removeWhere((h) => h.appId == hub.appId);
    _dynamic.add(hub);
  }

  void clearDynamic() => _dynamic.clear();

  /// hub_configs の1行から HubConfig を組み立てる（jsonb設定の復元）。
  HubConfig fromRemoteRow(Map<String, dynamic> row) {    final genres = <Genre>[];
    for (final g in (row['genres'] as List? ?? const [])) {
      final m = g as Map<String, dynamic>;
      genres.add(Genre(
        m['id'] as String? ?? 'game',
        m['label'] as String? ?? '誘う',
        categoryIconByName(m['icon'] as String?),
      ));
    }
    final interests = <InterestCategory>[];
    for (final c in (row['default_interests'] as List? ?? const [])) {
      final m = c as Map<String, dynamic>;
      interests.add(InterestCategory(
        m['id'] as String? ?? 'cat-${interests.length}',
        m['label'] as String? ?? '',
        categoryIconByName(m['icon'] as String?),
      ));
    }
    final storeTypes = ((row['store_types'] as List?) ?? const [])
        .map((s) => s as String)
        .toList();
    final spotTags = <SpotTag>[];
    for (final t in (row['spot_types'] as List? ?? const [])) {
      final m = t as Map<String, dynamic>;
      final k = m['k'] as String?;
      final v = m['v'] as String?;
      if (k == null || v == null) continue;
      spotTags.add(SpotTag(k, v, m['label'] as String? ?? '$k=$v'));
    }
    return HubConfig(
      appId: row['app_id'] as String,
      name: row['display_name'] as String? ?? '',
      tagline: row['description'] as String? ?? '',
      icon: Icons.auto_awesome,
      genres: genres,
      interests: interests,
      storeTypes: storeTypes,
      spotTags: spotTags,
      exchangeTable: null,
      exchangeLabel: row['exchange_label'] as String? ?? 'グッズ',
      builtin: false,
    );
  }
}

/// グローバルインスタンス（appState / authService と同じ形）。
final HubRegistry hubRegistry = HubRegistry._();
