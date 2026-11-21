"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { AlertCircle, CheckCircle2, LogIn, UserPlus } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { useAuth } from "@/components/AuthProvider";

type AuthMode = "login" | "signup";

function translateAuthError(message: string): string {
  const lower = message.toLowerCase();
  if (lower.includes("invalid login credentials")) {
    return "メールアドレスまたはパスワードが正しくありません。";
  }
  if (lower.includes("user already registered")) {
    return "このメールアドレスは既に登録されています。ログインをお試しください。";
  }
  if (lower.includes("email not confirmed")) {
    return "メールアドレスの確認が完了していません。受信メール内のリンクをご確認ください。";
  }
  if (lower.includes("password should be at least")) {
    return "パスワードは6文字以上で入力してください。";
  }
  if (lower.includes("rate limit")) {
    return "短時間にリクエストが集中しました。少し時間をおいてお試しください。";
  }
  return message;
}

function getSafeNextPath(nextParam: string | null): string {
  if (!nextParam) return "/";
  if (nextParam.startsWith("/") && !nextParam.startsWith("//")) {
    return nextParam;
  }
  return "/";
}

export function LoginFormClient() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { user, signOut } = useAuth();

  const [mode, setMode] = useState<AuthMode>("login");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [infoMessage, setInfoMessage] = useState<string | null>(null);

  const nextPath = getSafeNextPath(searchParams.get("next"));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);
    setInfoMessage(null);

    const trimmedEmail = email.trim();
    if (!trimmedEmail) {
      setErrorMessage("メールアドレスを入力してください。");
      return;
    }
    if (password.length < 6) {
      setErrorMessage("パスワードは6文字以上で入力してください。");
      return;
    }

    setSubmitting(true);
    const supabase = createClient();

    try {
      if (mode === "login") {
        const { error } = await supabase.auth.signInWithPassword({
          email: trimmedEmail,
          password,
        });
        if (error) {
          setErrorMessage(translateAuthError(error.message));
          return;
        }
        router.push(nextPath);
        router.refresh();
      } else {
        const { data, error } = await supabase.auth.signUp({
          email: trimmedEmail,
          password,
        });
        if (error) {
          setErrorMessage(translateAuthError(error.message));
          return;
        }

        if (data.session) {
          router.push(nextPath);
          router.refresh();
        } else {
          setInfoMessage(
            "確認メールを送信しました。メール内のリンクを開いて認証を完了したあと、ログインしてください。"
          );
          setMode("login");
          setPassword("");
        }
      }
    } catch {
      setErrorMessage("認証処理中にエラーが発生しました。再度お試しください。");
    } finally {
      setSubmitting(false);
    }
  };

  if (user) {
    return (
      <div className="mx-auto w-full max-w-md px-3 py-10 sm:px-6">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-xs">
          <div className="mb-3 flex items-center gap-2 text-emerald-700">
            <CheckCircle2 className="h-5 w-5" aria-hidden="true" />
            <h1 className="text-lg font-bold text-slate-900">ログイン済み</h1>
          </div>
          <p className="text-sm text-slate-600">
            現在 <strong className="font-semibold text-slate-900">{user.email}</strong>{" "}
            としてログインしています。
          </p>
          <div className="mt-5 flex flex-wrap items-center gap-2.5">
            <Link
              href={nextPath}
              className="rounded-lg bg-blue-600 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-blue-700"
            >
              アプリへ戻る
            </Link>
            <button
              type="button"
              onClick={async () => {
                await signOut();
                router.refresh();
              }}
              className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50"
            >
              ログアウト
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto w-full max-w-md px-3 py-8 sm:px-6 sm:py-12">
      <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-xs sm:p-6">
        <div className="mb-5 text-center">
          <h1 className="text-xl font-bold tracking-tight text-slate-900">
            {mode === "login" ? "コンボノートにログイン" : "アカウント新規登録"}
          </h1>
          <p className="mt-1 text-xs text-slate-500">
            ログインすると「いいね」や今後のコンボ投稿機能が利用できます。
          </p>
        </div>

        {/* モード切替タブ */}
        <div
          role="tablist"
          aria-label="認証モード切替"
          className="mb-5 grid grid-cols-2 rounded-lg bg-slate-100 p-1"
        >
          <button
            type="button"
            role="tab"
            aria-selected={mode === "login"}
            onClick={() => {
              setMode("login");
              setErrorMessage(null);
            }}
            className={`inline-flex items-center justify-center gap-1.5 rounded-md py-1.5 text-xs font-semibold transition-all sm:text-sm ${
              mode === "login"
                ? "bg-white text-blue-700 shadow-xs"
                : "text-slate-600 hover:text-slate-900"
            }`}
          >
            <LogIn className="h-3.5 w-3.5" aria-hidden="true" />
            <span>ログイン</span>
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={mode === "signup"}
            onClick={() => {
              setMode("signup");
              setErrorMessage(null);
            }}
            className={`inline-flex items-center justify-center gap-1.5 rounded-md py-1.5 text-xs font-semibold transition-all sm:text-sm ${
              mode === "signup"
                ? "bg-white text-blue-700 shadow-xs"
                : "text-slate-600 hover:text-slate-900"
            }`}
          >
            <UserPlus className="h-3.5 w-3.5" aria-hidden="true" />
            <span>新規登録</span>
          </button>
        </div>

        {errorMessage && (
          <div
            role="alert"
            className="mb-4 flex items-start gap-2 rounded-lg border border-rose-200 bg-rose-50 px-3 py-2.5 text-xs font-medium text-rose-700"
          >
            <AlertCircle className="mt-0.5 h-4 w-4 shrink-0" aria-hidden="true" />
            <span>{errorMessage}</span>
          </div>
        )}

        {infoMessage && (
          <div
            role="status"
            className="mb-4 flex items-start gap-2 rounded-lg border border-emerald-200 bg-emerald-50 px-3 py-2.5 text-xs font-medium text-emerald-800"
          >
            <CheckCircle2 className="mt-0.5 h-4 w-4 shrink-0" aria-hidden="true" />
            <span>{infoMessage}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-1">
            <label
              htmlFor="auth-email"
              className="block text-xs font-semibold text-slate-700"
            >
              メールアドレス
            </label>
            <input
              id="auth-email"
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-base text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none sm:text-sm"
            />
          </div>

          <div className="space-y-1">
            <label
              htmlFor="auth-password"
              className="block text-xs font-semibold text-slate-700"
            >
              パスワード（6文字以上）
            </label>
            <input
              id="auth-password"
              type="password"
              autoComplete={
                mode === "login" ? "current-password" : "new-password"
              }
              required
              minLength={6}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••"
              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-base text-slate-900 placeholder:text-slate-400 focus:border-blue-500 focus:outline-none sm:text-sm"
            />
          </div>

          <button
            type="submit"
            disabled={submitting}
            className="w-full rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white shadow-xs transition-colors hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-60"
          >
            {submitting
              ? "処理中..."
              : mode === "login"
                ? "ログインする"
                : "新規登録する"}
          </button>
        </form>

        <div className="mt-5 border-t border-slate-100 pt-4 text-center text-xs text-slate-500">
          閲覧やマイノート機能はログインなしでも利用できます。
          <div className="mt-2">
            <Link href="/" className="font-medium text-blue-600 hover:underline">
              キャラクター一覧へ戻る
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
