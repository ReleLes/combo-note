-- =============================================================================
-- Migration: 024_official_character_order_and_yasmine.sql
-- 目的: 全32キャラクターの並び順（sort_order 1〜32）をストリートファイター6
--       公式実装順へ統一し、ヤスミンの英語表記（name_en）を公式表記 'Yasmine'
--       へ冪等に更新する（既存 id / slug および外部キー参照は一切変更しない）
-- =============================================================================

update public.characters set sort_order = 1 where id = 'luke';
update public.characters set sort_order = 2 where id = 'jamie';
update public.characters set sort_order = 3 where id = 'manon';
update public.characters set sort_order = 4 where id = 'kimberly';
update public.characters set sort_order = 5 where id = 'marisa';
update public.characters set sort_order = 6 where id = 'lily';
update public.characters set sort_order = 7 where id = 'jp';
update public.characters set sort_order = 8 where id = 'juri';
update public.characters set sort_order = 9 where id = 'deejay';
update public.characters set sort_order = 10 where id = 'cammy';
update public.characters set sort_order = 11 where id = 'ryu';
update public.characters set sort_order = 12 where id = 'ehonda';
update public.characters set sort_order = 13 where id = 'blanka';
update public.characters set sort_order = 14 where id = 'guile';
update public.characters set sort_order = 15 where id = 'ken';
update public.characters set sort_order = 16 where id = 'chun-li';
update public.characters set sort_order = 17 where id = 'zangief';
update public.characters set sort_order = 18 where id = 'dhalsim';
update public.characters set sort_order = 19 where id = 'rashid';
update public.characters set sort_order = 20 where id = 'aki';
update public.characters set sort_order = 21 where id = 'ed';
update public.characters set sort_order = 22 where id = 'akuma';
update public.characters set sort_order = 23 where id = 'vega';
update public.characters set sort_order = 24 where id = 'terry';
update public.characters set sort_order = 25 where id = 'mai';
update public.characters set sort_order = 26 where id = 'elena';
update public.characters set sort_order = 27 where id = 'sagat';
update public.characters set sort_order = 28 where id = 'c-viper';
update public.characters set sort_order = 29 where id = 'alex';
update public.characters set sort_order = 30 where id = 'ingrid';
update public.characters set sort_order = 31, name_en = 'Yasmine' where id = 'yasmine';
update public.characters set sort_order = 32 where id = 'arjun';
