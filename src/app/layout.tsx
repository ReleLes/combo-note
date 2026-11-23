import type { Metadata, Viewport } from "next";
import { ExternalLink, MessageSquare } from "lucide-react";
import { AuthProvider } from "@/components/AuthProvider";
import { Header } from "@/components/Header";
import { ThemeProvider } from "@/components/ThemeProvider";
import "./globals.css";

const SITE_URL = "https://combo-note.vercel.app";
const SITE_TITLE = "コンボノート | スト6 コンボ管理・共有アプリ";
const SITE_DESCRIPTION =
  "ストリートファイター6（SF6）全32キャラ・クラシック／モダン両対応の非公式コンボメモ＆共有Webアプリ。テンキー・コマンド・技名の3表記をワンタップ切替、ログイン不要で閲覧＆マイノート保存可能。";
const FEEDBACK_FORM_URL = "https://forms.gle/9mnbE2GorT3vfMaD8";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: SITE_TITLE,
    template: "%s | コンボノート",
  },
  description: SITE_DESCRIPTION,
  applicationName: "コンボノート",
  openGraph: {
    type: "website",
    locale: "ja_JP",
    siteName: "コンボノート",
    url: SITE_URL,
    title: SITE_TITLE,
    description: SITE_DESCRIPTION,
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: SITE_TITLE,
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: SITE_TITLE,
    description: SITE_DESCRIPTION,
    images: ["/og-image.png"],
  },
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
              <div className="mx-auto flex max-w-5xl flex-col items-center justify-center gap-2 px-4 sm:flex-row sm:justify-between sm:text-left">
                <p>
                  本アプリは個人制作の非公式ファンツールです。ゲーム名・キャラクター名等の権利は各権利者に帰属します。
                </p>
                <a
                  href={FEEDBACK_FORM_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex shrink-0 items-center gap-1 rounded-md border border-slate-200/90 bg-white/80 px-2.5 py-1 text-[11px] font-medium text-slate-600 transition-colors hover:border-blue-300 hover:text-blue-600 dark:border-[#3A2E58] dark:bg-[#1B152B] dark:text-[#CFC6E8] dark:hover:border-[#8B5CF6] dark:hover:text-[#F4F1FF]"
                >
                  <MessageSquare className="h-3 w-3 shrink-0" aria-hidden="true" />
                  <span>ご意見・不具合報告</span>
                  <ExternalLink className="h-3 w-3 shrink-0 opacity-75" aria-hidden="true" />
                </a>
              </div>
            </footer>
          </AuthProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
