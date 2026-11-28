-- 立ち通常技・立ち始動TCのテンキー表記（notation_numpad）から立ちニュートラル「5」を省略する
-- 対象: category が normal / unique で、先頭・角括弧直後・'>' 直後に「5弱 / 5中 / 5強」を含む行のみ
-- 注意: moves.id・既存コンボデータ・方向入れ技（2/4/6等）・ジャンプ技・数値表記（5F等）は一切変更しない
-- 冪等: 再実行時は WHERE 句に一致する行が 0 件となり安全にスキップされる

UPDATE public.moves
SET notation_numpad = regexp_replace(
  notation_numpad,
  '(^|\]|>)5([弱中強])',
  '\1\2',
  'g'
)
WHERE category IN ('normal', 'unique')
  AND notation_numpad ~ '(^|\]|>)5[弱中強]';
