import type { Metadata, Viewport } from "next";
import { AuthProvider } from "@/components/AuthProvider";
import { Header } from "@/components/Header";
import { ThemeProvider } from "@/components/ThemeProvider";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "コンボノート｜スト6 コンボ管理・共有アプリ",
    template: "%s｜コンボノート",
  },
  description:
    "ストリートファイター6（SF6）向けコンボ管理・共有Webアプリ。状況別フィルタ・3表記切替・マイノートで、練習中や対戦の合間にすぐコンボを確認できます。",
  applicationName: "コンボノート",
  appleWebApp: {
    capable: true,
    title: "コンボノート",
    statusBarStyle: "default",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#0B162C",
};

const THEME_INIT_SCRIPT = `(function(){try{var t=localStorage.getItem('combonote_v1_theme');if(t==='dark'){document.documentElement.classList.add('dark');var m=document.querySelector('meta[name="theme-color"]');if(m)m.setAttribute('content','#0F0B1A');}}catch(e){}})();`;

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="ja" className="h-full antialiased" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: THEME_INIT_SCRIPT }} />
      </head>
      <body className="min-h-full flex flex-col overflow-x-hidden bg-slate-50 text-slate-900 transition-colors dark:bg-[#0F0B1A] dark:text-[#F4F1FF]">
        <ThemeProvider>
          <AuthProvider>
            <Header />
            <main className="flex flex-1 flex-col">{children}</main>
            <footer className="mt-auto border-t border-slate-200/80 py-4 text-center text-[11px] leading-relaxed text-slate-500 dark:border-[#2D2346] dark:text-[#8E82B3]">
              <div className="mx-auto max-w-5xl px-4">
                本アプリは個人制作の非公式ファンツールです。ゲーム名・キャラクター名等の権利は各権利者に帰属します。
              </div>
            </footer>
          </AuthProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
