# ともつく！（Tomotsuku・総合版）

**「ともつく！」シリーズ12アプリ＋ユーザー作成ハブを、1本のアプリで横断利用できる総合版（プラットフォーム型）のプロトタイプです。**

ハブ（趣味ドメイン）を切り替えることで、飯とも！/犬とも！/釣りとも！/ニーアキャット/コスとも！/走りとも！/キャンとも！/音とも！/湯とも！/スポとも！/雀とも！/ゲーとも！の**全12ハブを同じUI・同じDB（app_id分離）で使い分け**られます。

本アプリは [提案008「総合版とUGCハブ化」](https://github.com/daichiyabunaka-rgb/tomotsuku-memo/blob/master/proposals/008_%E7%B7%8F%E5%90%88%E7%89%88%E3%81%A8UGC%E3%83%8F%E3%83%96%E5%8C%96.md) の Phase 1〜3 実装です。

| Phase | 内容 | 画面 |
|---|---|---|
| 1 | 内蔵12ハブの横断利用（ハブ切替で募集・興味カテゴリ・施設・業態が全部変わる） | マイページ「現在のハブ」→ ハブを選ぶ |
| 2 | 需要収集: 「次のハブのリクエスト」「機能のリクエスト」ボード（1人1票の賛同制） | ハブを選ぶ → 下部3入口 |
| 3 | UGCハブ制作: 「ハブをつくる」ウィザード（設定ベースで新趣味ハブを申請→運営審査→承認で全ユーザーに即時表示。Roblox型UGC） | ハブを選ぶ → ハブをつくる |

## コンセプト・設計原則

| 原則 | 内容 |
|---|---|
| 本人の顔画像禁止 | アイコンは**趣味に関連する画像のみ**許可。本人の素顔がメインの画像はアップロード不可 |
| 恋愛目的禁止 | 出会い系としての法律が適用されないよう、利用規約で明示的に禁止（UGCハブの申請でも同意必須） |
| 金銭取引禁止 | ゆずりあい・交換は無償の譲り合い・物々交換のみ。売買・賭博は禁止（UGCハブの審査でも排除） |
| 時限性 | 募集は期限付き（1〜3時間）。期限が来たら自動で消える |
| 距離は粗表示 | 位置は「〜1km / 1〜3km」のようなバンド表示のみ。正確な座標は非公開 |
| UGCは審査制 | ユーザー作成ハブは `hub_configs` に pending で登録し、運営が審査して承認（SQL）後に表示 |

## アーキテクチャ（本アプリの核心）

```
lib/src/hub_registry.dart          ハブ設定（HubConfig）のレジストリ。内蔵12ハブ＋DB承認済みUGCハブ。
                                  「どのハブか」で genres/興味カテゴリ/施設タグ/業態/ゆずりあいボードが変わる
lib/src/models.dart                HubRequest / FeatureRequest / HubConfigDraft（UGC用ドメイン）
lib/src/services/app_state.dart    switchHub()・リクエスト/投票・UGC申請（submitHub）・dynamic hub 読込
lib/src/services/supabase_data.dart hub_requests / feature_requests / hub_configs テーブル操作
lib/src/screens/hub_picker_sheet.dart        ハブ選択ボトムシート（Phase 2/3 の入口を兼ねる）
lib/src/screens/hub_requests_page.dart        次のハブのリクエストボード（Phase 2）
lib/src/screens/feature_requests_page.dart   機能のリクエストボード（Phase 2）
lib/src/screens/hub_create_wizard_page.dart  ハブをつくるウィザード（Phase 3・5ステップ）
```

**共通機能**（12アプリと同一）: 会員登録 / 近くの人・募集 / DM / コミュニティ・イベント / 施設検索（Overpass API・ハブごとのタグ） / ゆずりあい・交換（ハブごとのテーブル） / 通報・モデレーション / ともつく！連携（アカウント共有・cross_app_visible）

**注意: モックデータには位置情報が含まれません。** モックユーザーはハブごとに存在し（ゲーム・雀・キャンプ・車・音楽・銭湯など）、現在地からの相対距離で配置されます。Supabase 接続時は Supabase 側のユーザーのみ表示されます。

## 構成

```
docs/
  要件定義書_ともつく総合_v1.md      機能要件（ハブアーキテクチャ・UGC審査含む）
  supabase_multiapp_migration.sql      共有DB化・app_id分離マイグレーション（0002相当）
  supabase_multiapp_v2_cross_app.sql   ともつく！連携（0003相当）
  supabase_tomotsuku_hub_system.sql    総合版・UGCハブ（hub_requests等5テーブル・0014相当）
app/
  lib/src/hub_registry.dart           ハブ設定レジストリ（総合版の核）
  lib/src/screens/                   画面（hub_picker/hub_requests/feature_requests/hub_create_wizard）
  lib/src/util/cat_spots.dart         近くの施設取得（ハブごとのOverpassタグ）
tools/make_icon.py                     ランチャーアイコン生成（中心のハブと6つの仲間ノード）
```

## 起動手順

```powershell
cd app
flutter pub get
flutter run -d chrome          # ブラウザ
flutter run -d <デバイスID>     # Android 端末（flutter devices で確認）
flutter build apk --release     # APK ビルド
```

接続DBは「ともつく！」シリーズ共通の Supabase プロジェクトです（接続情報と鍵の扱いは tomotsuku-memo リポジトリ参照）。

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=https://hlcsuogoghrgqabkaqxm.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=<tomotsuku-memo参照>
```

dart-define を付けない場合はローカルモック（端末内データのみ）で起動します。

静的解析: `flutter analyze` / 自動テスト: `flutter test`

## Supabase 接続の前提

1. **共通DB**: シリーズ全アプリと同じ Supabase プロジェクトを共有します（auth.users 共通、その他のデータは app_id で分離）。本アプリの app_id は `tomotsuku`（ハブ切替で `profiles.app_id = '<ハブのappId>'` のデータを参照）。
2. **事前に適用が必要なマイグレーション**: `docs/supabase_multiapp_migration.sql`（0002相当）と `docs/supabase_multiapp_v2_cross_app.sql`（0003相当）。
3. **総合版・UGCハブ用**: `docs/supabase_tomotsuku_hub_system.sql` を Supabase Dashboard の SQL Editor で適用してください（hub_requests / hub_votes / feature_requests / feature_votes / hub_configs の5テーブル、services マスタへの 'tomotsuku' 登録、delete_my_account の更新）。tomotsuku-memo の 0014 マイグレーションと同一内容です。
4. **UGCハブの承認方法**（運営作業）:
   ```sql
   update hub_configs set status='approved' where app_id='<申請のapp_id>';
   insert into services (id, label, active) values ('<申請のapp_id>', '<表示名>', true)
     on conflict (id) do nothing;
   ```
   承認後、アプリ側は次回起動時に `fetchApprovedHubConfigs` で取得して表示します。
5. **アイコン投稿バケット**: `icons` バケットはシリーズ共通です（ユーザーごとの `UUID/tomotsuku/` 名前空間）。
6. **施設検索**: OpenStreetMap（Overpass API）。ハブごとに定義されたタグのみ検索します。

## 運用

- スキーマ変更は必ず [tomotsuku-memo](https://github.com/daichiyabunaka-rgb/tomotsuku-memo)（Private）の master を先に変更し、そこから SQL Editor へ適用する運用ルールに従う
- クライアントには publishable key のみを埋め込む（`--dart-define` 経由）。secret key は絶対にコミットしない
