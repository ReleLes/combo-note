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

## 検出優先順位

1. `.webp`
2. `.png`
3. `.jpg`

## 推奨サイズ・トリミング

- アスペクト比: **縦長 3:4**（目安: `600x800px` または `750x1000px`）
- カード表示は `object-cover object-top`（上寄せトリミング）のため、キャラクターの顔・上半身が上半分〜中央寄りに収まる構図にすると見切れにくくなります。
- 下部約35%にはキャラ名・タグ・コンボ件数とダークグラデーションが重なります。
