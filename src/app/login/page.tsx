import type { Metadata } from "next";
import { Suspense } from "react";
import { LoginFormClient } from "@/components/LoginFormClient";

export const metadata: Metadata = {
  title: "ログイン / 新規登録",
};

export default function LoginPage() {
  return (
    <Suspense
      fallback={
        <div className="mx-auto w-full max-w-md px-3 py-10 sm:px-6">
          <div className="h-72 animate-pulse rounded-2xl border border-slate-200 bg-white" />
        </div>
      }
    >
      <LoginFormClient />
    </Suspense>
  );
}
