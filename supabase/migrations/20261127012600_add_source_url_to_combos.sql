ALTER TABLE public.combos
  ADD COLUMN IF NOT EXISTS source_url text;

COMMENT ON COLUMN public.combos.source_url IS '参考動画・ポストURL（YouTube / X限定、任意）';
