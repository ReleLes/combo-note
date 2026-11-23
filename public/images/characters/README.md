# キャラクターポートレート画像の配置ルール

トップ画面（`/`）のキャラクター選択カードは、このディレクトリ内の画像を自動検出して表示します。
画像が配置されていないキャラクターは、404エラーを出さずにテーマカラー＋透かし英字のフォールバック表現で表示されます。

## ファイル命名ルール

ファイル名はキャラクターの `slug` と一致させてください（小文字）。

- 豪鬼: `akuma.webp` / `akuma.png` / `akuma.jpg`
- ジュリ: `juri.webp` / `juri.png` / `juri.jpg`
- イングリッド: `ingrid.webp` / `ingrid.png` / `ingrid.jpg`
- C.ヴァイパー: `c-viper.webp` / `c-viper.png` / `c-viper.jpg`
- 舞: `mai.webp` / `mai.png` / `mai.jpg`
- リュウ: `ryu.webp` / `ryu.png` / `ryu.jpg`
- ケン: `ken.webp` / `ken.png` / `ken.jpg`
- ルーク: `luke.webp` / `luke.png` / `luke.jpg`
- キャミィ: `cammy.webp` / `cammy.png` / `cammy.jpg`
- 春麗: `chun-li.webp` / `chun-li.png` / `chun-li.jpg`
- ガイル: `guile.webp` / `guile.png` / `guile.jpg`
- ザンギエフ: `zangief.webp` / `zangief.png` / `zangief.jpg`
- ベガ: `vega.webp` / `vega.png` / `vega.jpg`
- JP: `jp.webp` / `jp.png` / `jp.jpg`
- エド: `ed.webp` / `ed.png` / `ed.jpg`
- テリー: `terry.webp` / `terry.png` / `terry.jpg`
- サガット: `sagat.webp` / `sagat.png` / `sagat.jpg`
- ディージェイ: `deejay.webp` / `deejay.png` / `deejay.jpg`
- ラシード: `rashid.webp` / `rashid.png` / `rashid.jpg`
- A.K.I.: `aki.webp` / `aki.png` / `aki.jpg`
- エレナ: `elena.webp` / `elena.png` / `elena.jpg`
- アレックス: `alex.webp` / `alex.png` / `alex.jpg`
- ヤスミン: `yasmine.webp` / `yasmine.png` / `yasmine.jpg`
- アルジュン: `arjun.webp` / `arjun.png` / `arjun.jpg`
- ジェイミー: `jamie.webp` / `jamie.png` / `jamie.jpg`
- キンバリー: `kimberly.webp` / `kimberly.png` / `kimberly.jpg`
- マリーザ: `marisa.webp` / `marisa.png` / `marisa.jpg`
- マノン: `manon.webp` / `manon.png` / `manon.jpg`
- ブランカ: `blanka.webp` / `blanka.png` / `blanka.jpg`
- エドモンド本田: `ehonda.webp` / `ehonda.png` / `ehonda.jpg`
- ダルシム: `dhalsim.webp` / `dhalsim.png` / `dhalsim.jpg`
- リリー: `lily.webp` / `lily.png` / `lily.jpg`

## 検出優先順位

1. `.webp`
2. `.png`
3. `.jpg`
4. `.jpeg`

## 推奨サイズ・トリミング

- トップ画面のキャラ選択カードは横長コンパクトバナー（右側約45%にポートレート配置）です。
- カード表示は `object-cover object-top`（上寄せトリミング）＋左側への横グラデーションフェードのため、キャラクターの顔・上半身が上半分〜中央寄りに収まる構図にすると見切れにくくなります。
