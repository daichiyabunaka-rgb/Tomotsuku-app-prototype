-- ============================================================
-- 0014_tomotsuku_hub_system: ともつく！総合版（ハブ横断＋UGCハブ）
-- 対象: 共有Supabaseプロジェクト（追加のみ・非破壊・トランザクション）
--
-- 内容:
--   1. services マスタへ総合版 'tomotsuku' を追加
--   2. hub_requests / hub_votes
--      （Phase 2: 次に作るハブの需要を1人1票の賛同で集めるボード）
--   3. feature_requests / feature_votes
--      （Phase 2: 機能リクエストの要望ボード。hub_id=nullは全ハブ共通）
--   4. hub_configs
--      （Phase 3: ユーザー作成ハブの設定。status='pending' で申請され、
--        運営が審査して 'approved' にすると全ユーザーのハブ一覧へ表示）
--   5. delete_my_account() へ新5テーブルの削除を追加
--
-- 前提: 0001_init 〜 0013_gametomo が適用済みであること。
--       番号順に適用する運用（提案006）に従うこと。
--
-- UGCハブの承認方法（運営作業・SQL Editorで実行）:
--   update public.hub_configs set status='approved'
--     where app_id='<申請のapp_id>';
--   insert into public.services (id, label, active)
--     values ('<申請のapp_id>', '<表示名>', true)
--     on conflict (id) do nothing;
-- ============================================================

begin;

-- ------------------------------------------------------------
-- 0. updated_at 自動更新のヘルパー（他テーブルでも再利用可）
-- ------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ------------------------------------------------------------
-- 1. services マスタへ総合版を追加
-- ------------------------------------------------------------
insert into public.services (id, label) values
  ('tomotsuku', 'ともつく！総合')
on conflict (id) do update set label = excluded.label, active = true;

-- ------------------------------------------------------------
-- 2. hub_requests（次のハブのリクエスト）
-- ------------------------------------------------------------
create table if not exists public.hub_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references auth.users(id) on delete cascade,
  hobby_name text not null,
  description text not null default '',
  status text not null default 'open'
    check (status in ('open', 'approved', 'launched', 'rejected')),
  created_at timestamptz not null default now()
);

alter table public.hub_requests enable row level security;

drop policy if exists "ハブリクエストは誰でも閲覧可" on public.hub_requests;
drop policy if exists "ハブリクエストの登録は本人のみ" on public.hub_requests;
drop policy if exists "ハブリクエストの更新は本人のみ" on public.hub_requests;
drop policy if exists "ハブリクエストの削除は本人のみ" on public.hub_requests;

create policy "ハブリクエストは誰でも閲覧可" on public.hub_requests
  for select using (true);
create policy "ハブリクエストの登録は本人のみ" on public.hub_requests
  for insert with check (auth.uid() = requester_id);
-- 自分の投稿で status='open' の間だけ更新・削除（取り下げ）できる
create policy "ハブリクエストの更新は本人のみ" on public.hub_requests
  for update using (auth.uid() = requester_id and status = 'open')
  with check (auth.uid() = requester_id);
create policy "ハブリクエストの削除は本人のみ" on public.hub_requests
  for delete using (auth.uid() = requester_id and status = 'open');

-- ------------------------------------------------------------
-- 3. hub_votes（賛同。1人1票・PKで重複排除）
-- ------------------------------------------------------------
create table if not exists public.hub_votes (
  request_id uuid not null references public.hub_requests(id) on delete cascade,
  voter_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (request_id, voter_id)
);

alter table public.hub_votes enable row level security;

drop policy if exists "ハブへの賛同は誰でも閲覧可" on public.hub_votes;
drop policy if exists "ハブへの賛同は本人のみ登録可" on public.hub_votes;
drop policy if exists "ハブへの賛同は本人のみ取消可" on public.hub_votes;

create policy "ハブへの賛同は誰でも閲覧可" on public.hub_votes
  for select using (true);
create policy "ハブへの賛同は本人のみ登録可" on public.hub_votes
  for insert with check (auth.uid() = voter_id);
create policy "ハブへの賛同は本人のみ取消可" on public.hub_votes
  for delete using (auth.uid() = voter_id);

-- ------------------------------------------------------------
-- 4. feature_requests（機能のリクエスト）
-- ------------------------------------------------------------
create table if not exists public.feature_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references auth.users(id) on delete cascade,
  hub_id text,                                -- null = 全ハブ共通の要望
  feature_name text not null,
  description text not null default '',
  status text not null default 'open'
    check (status in ('open', 'planned', 'shipped', 'rejected')),
  created_at timestamptz not null default now()
);

alter table public.feature_requests enable row level security;

drop policy if exists "機能リクエストは誰でも閲覧可" on public.feature_requests;
drop policy if exists "機能リクエストの登録は本人のみ" on public.feature_requests;
drop policy if exists "機能リクエストの更新は本人のみ" on public.feature_requests;
drop policy if exists "機能リクエストの削除は本人のみ" on public.feature_requests;

create policy "機能リクエストは誰でも閲覧可" on public.feature_requests
  for select using (true);
create policy "機能リクエストの登録は本人のみ" on public.feature_requests
  for insert with check (auth.uid() = requester_id);
-- 自分の投稿で status='open' の間だけ更新・削除（取り下げ）できる
create policy "機能リクエストの更新は本人のみ" on public.feature_requests
  for update using (auth.uid() = requester_id and status = 'open')
  with check (auth.uid() = requester_id);
create policy "機能リクエストの削除は本人のみ" on public.feature_requests
  for delete using (auth.uid() = requester_id and status = 'open');

-- ------------------------------------------------------------
-- 5. feature_votes（賛同。1人1票）
-- ------------------------------------------------------------
create table if not exists public.feature_votes (
  feature_id uuid not null references public.feature_requests(id) on delete cascade,
  voter_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (feature_id, voter_id)
);

alter table public.feature_votes enable row level security;

drop policy if exists "機能への賛同は誰でも閲覧可" on public.feature_votes;
drop policy if exists "機能への賛同は本人のみ登録可" on public.feature_votes;
drop policy if exists "機能への賛同は本人のみ取消可" on public.feature_votes;

create policy "機能への賛同は誰でも閲覧可" on public.feature_votes
  for select using (true);
create policy "機能への賛同は本人のみ登録可" on public.feature_votes
  for insert with check (auth.uid() = voter_id);
create policy "機能への賛同は本人のみ取消可" on public.feature_votes
  for delete using (auth.uid() = voter_id);

-- ------------------------------------------------------------
-- 6. hub_configs（Phase 3: ユーザー作成ハブの設定）
--    app_id はクライアントから 'hub<タイムスタンプ36進>' で登録される
-- ------------------------------------------------------------
create table if not exists public.hub_configs (
  app_id text primary key,
  display_name text not null,
  description text not null default '',
  icon_path text,
  genres jsonb not null default '[]'::jsonb,
  spot_types jsonb not null default '[]'::jsonb,
  store_types jsonb not null default '[]'::jsonb,
  default_interests jsonb not null default '[]'::jsonb,
  exchange_label text not null default 'グッズ',
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected', 'archived')),
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.hub_configs enable row level security;

drop trigger if exists set_hub_configs_updated_at on public.hub_configs;
create trigger set_hub_configs_updated_at
  before update on public.hub_configs
  for each row execute function public.set_updated_at();

-- 閲覧: 承認済みは全員に。申請者には自分のpendingも見える（申請状況の確認用）
drop policy if exists "承認済みハブ設定は誰でも閲覧可" on public.hub_configs;
drop policy if exists "自分の申請中ハブ設定は本人のみ閲覧可" on public.hub_configs;
drop policy if exists "ハブ設定の申請は本人のみ登録可" on public.hub_configs;
drop policy if exists "申請中ハブ設定の更新は本人のみ" on public.hub_configs;
drop policy if exists "申請中ハブ設定の削除は本人のみ" on public.hub_configs;

create policy "承認済みハブ設定は誰でも閲覧可" on public.hub_configs
  for select using (status = 'approved' or created_by = auth.uid());
create policy "ハブ設定の申請は本人のみ登録可" on public.hub_configs
  for insert with check (
    created_by = auth.uid()
    and status = 'pending'
    and app_id like 'hub%'
  );
-- 申請者は自分の pending の間だけ修正・取り下げができる（審査後は不可）
create policy "申請中ハブ設定の更新は本人のみ" on public.hub_configs
  for update using (created_by = auth.uid() and status = 'pending')
  with check (created_by = auth.uid() and status = 'pending');
create policy "申請中ハブ設定の削除は本人のみ" on public.hub_configs
  for delete using (created_by = auth.uid() and status = 'pending');

create index if not exists hub_configs_status_idx on public.hub_configs (status);

-- ------------------------------------------------------------
-- 7. delete_my_account() へ新テーブルを追加
--    （過去全テーブル + hub系5テーブルを列挙。ASC/DESC順は保証されないため、
--      投票→本体の順に削除する。FKのON DELETE CASCADEでも消えるが、
--      明示的に列挙して冪等にしておく）
-- ------------------------------------------------------------
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  -- Phase 2/3 のハブ系テーブル（総合版・UGCハブ）
  delete from public.hub_votes where voter_id = auth.uid();
  delete from public.feature_votes where voter_id = auth.uid();
  delete from public.hub_requests where requester_id = auth.uid();
  delete from public.feature_requests where requester_id = auth.uid();
  delete from public.hub_configs where created_by = auth.uid();

  -- 既存のシリーズ共通テーブル
  delete from public.community_members where user_id = auth.uid();
  delete from public.event_participants where user_id = auth.uid();
  delete from public.chat_room_members where user_id = auth.uid();
  delete from public.join_applications where applicant_id = auth.uid();
  delete from public.recruitments where host_id = auth.uid();
  delete from public.communities where owner_id = auth.uid();
  delete from public.categories where created_by = auth.uid();
  delete from public.blocks where blocker_id = auth.uid() or blocked_id = auth.uid();
  delete from public.reports where reporter_id = auth.uid();
  delete from public.catch_reports where reporter_id = auth.uid();
  delete from public.protected_dogs where reporter_id = auth.uid();
  delete from public.protected_cats where reporter_id = auth.uid();
  delete from public.costume_exchanges where poster_id = auth.uid();
  delete from public.parts_exchanges where poster_id = auth.uid();
  delete from public.gear_exchanges where poster_id = auth.uid();
  delete from public.instrument_exchanges where poster_id = auth.uid();
  delete from public.bath_goods_exchanges where poster_id = auth.uid();
  delete from public.sports_goods_exchanges where poster_id = auth.uid();
  delete from public.game_goods_exchanges where poster_id = auth.uid();
  delete from public.profiles where id = auth.uid();

  delete from auth.users where id = auth.uid();
end;
$$;

revoke execute on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

commit;
