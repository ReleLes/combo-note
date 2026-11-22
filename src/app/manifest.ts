import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "コンボノート",
    short_name: "コンボノート",
    description: "ストリートファイター6（SF6）向けコンボ管理・共有アプリ",
    start_url: "/",
    display: "standalone",
    background_color: "#0B162C",
    theme_color: "#0B162C",
    icons: [
      {
        src: "/icons/icon-192.png",
        sizes: "192x192",
        type: "image/png",
      },
      {
        src: "/icons/icon-512.png",
        sizes: "512x512",
        type: "image/png",
      },
    ],
  };
}
