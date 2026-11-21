import type { Metadata, Viewport } from "next";
import { AuthProvider } from "@/components/AuthProvider";
import { Header } from "@/components/Header";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "コンボノート｜スト6 コンボ管理・共有アプリ",
    template: "%s｜コンボノート",
  },
  description:
    "ストリートファイター6（SF6）向けコンボ管理・共有Webアプリ。状況別フィルタ・3表記切替・マイノートで、練習中や対戦の合間にすぐコンボを確認できます。",
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#f8fafc",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="ja" className="h-full antialiased">
      <body className="min-h-full flex flex-col overflow-x-hidden bg-slate-50 text-slate-900">
        <AuthProvider>
          <Header />
          <main className="flex flex-1 flex-col">{children}</main>
        </AuthProvider>
      </body>
    </html>
  );
}
