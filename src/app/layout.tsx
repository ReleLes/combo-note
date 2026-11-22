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
          </AuthProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
