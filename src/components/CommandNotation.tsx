"use client";

import React from "react";
import type { Move, NotationMode } from "@/types/combo";

type Strength = "light" | "medium" | "heavy" | "any";

const ALWAYS_BADGE_MOVE_IDS = new Set(["sys_dr", "sys_raw_dr", "sys_di"]);

interface CommandNotationProps {
  text: string;
}

const ARROW_ROTATION: Record<string, number> = {
  "→": 0,
  "↘": 45,
  "↓": 90,
  "↙": 135,
  "←": 180,
  "↖": 225,
  "↑": 270,
  "↗": 315,
};

const STRENGTH_CIRCLE_CLASS: Record<Strength, string> = {
  light: "bg-sky-500 text-white ring-1 ring-sky-600/40",
  medium: "bg-amber-500 text-white ring-1 ring-amber-600/40",
  heavy: "bg-rose-500 text-white ring-1 ring-rose-700/40",
  any: "bg-white text-slate-800 ring-[1.5px] ring-slate-500 dark:bg-[#2A2242] dark:text-[#F4F1FF] dark:ring-[#8E82B3]",
};

const STRENGTH_JA: Record<Exclude<Strength, "any">, string> = {
  light: "弱",
  medium: "中",
  heavy: "強",
};

function ArrowIcon({ dir }: { dir: string }) {
  const deg = ARROW_ROTATION[dir] ?? 0;
  return (
    <svg
      viewBox="0 0 16 16"
      className="h-4 w-4 shrink-0 text-slate-800 dark:text-[#F4F1FF]"
      aria-label={dir}
      style={{ transform: `rotate(${deg}deg)` }}
    >
      <path
        d="M1.5 5.8h6.4V2.6L14.5 8l-6.6 5.4v-3.2H1.5V5.8z"
        fill="currentColor"
      />
    </svg>
  );
}

/** くっきり見やすい正面の拳（パンチ）シルエットSVG（少し斜めに傾けて躍動感） */
function PunchSvg() {
  return (
    <svg
      viewBox="0 0 24 24"
      className="h-4 w-4 -rotate-12"
      aria-hidden="true"
    >
      {/* 4本の指の節 */}
      <rect x="4" y="5" width="3.3" height="7" rx="1.6" fill="currentColor" />
      <rect x="8.1" y="4" width="3.3" height="8" rx="1.6" fill="currentColor" />
      <rect x="12.2" y="4.5" width="3.3" height="7.5" rx="1.6" fill="currentColor" />
      <rect x="16.3" y="6" width="3.1" height="6.2" rx="1.5" fill="currentColor" />
      {/* 拳の下部と横に渡る親指 */}
      <path
        d="M4.5 13.2h14.5c.8 0 1.4.6 1.4 1.4v1.1c0 2.5-2 4.3-4.6 4.3H9.3C6.4 20 4 17.8 4 15v-.4c0-.8.2-1.4.5-1.4z"
        fill="currentColor"
      />
      <rect
        x="3.2"
        y="10.8"
        width="7.8"
        height="3.2"
        rx="1.6"
        fill="currentColor"
        stroke="none"
      />
    </svg>
  );
}

/** 拳と一目で区別できる斜め蹴り足（キック）シルエットSVG */
function KickSvg() {
  return (
    <svg
      viewBox="0 0 24 24"
      className="h-4 w-4 -rotate-12"
      aria-hidden="true"
    >
      {/* 足首からつま先へ突き出すシューズのシルエット */}
      <path
        d="M6.5 4.5h5.2l1.1 6.3 5.5 1.8c1.5.5 2.4 1.7 2.2 3.2l-.2 1.2c-.2 1.1-1.1 1.8-2.2 1.8H6.8c-1.5 0-2.6-1.2-2.6-2.7V11l2.3-6.5z"
        fill="currentColor"
      />
    </svg>
  );
}

function AttackBadge({
  kind,
  strength,
  count = 1,
}: {
  kind: "punch" | "kick";
  strength: Strength;
  count?: number;
}) {
  const label = strength === "any" ? "汎用" : STRENGTH_JA[strength];
  const aria = `${label}${kind === "punch" ? "パンチ" : "キック"}${
    count > 1 ? `×${count}` : ""
  }`;

  return (
    <span
      className="inline-flex items-center gap-0.5"
      aria-label={aria}
      title={aria}
    >
      {Array.from({ length: count }).map((_, idx) => (
        <span
          key={idx}
          className={`inline-flex h-[22px] w-[22px] shrink-0 items-center justify-center rounded-full shadow-2xs ${STRENGTH_CIRCLE_CLASS[strength]}`}
        >
          {kind === "punch" ? <PunchSvg /> : <KickSvg />}
        </span>
      ))}
    </span>
  );
}

function AssistBadge() {
  return (
    <span
      title="アシスト (A)"
      className="inline-flex h-[20px] items-center rounded bg-slate-700 px-1 text-[10px] font-bold text-white dark:bg-[#4C3C78] dark:text-[#F4F1FF]"
    >
      A
    </span>
  );
}

function ModernStrengthBadge({
  strength,
  isAssist = false,
}: {
  strength: Exclude<Strength, "any">;
  isAssist?: boolean;
}) {
  const label = STRENGTH_JA[strength];
  return (
    <span
      className="inline-flex items-center gap-0.5"
      title={isAssist ? `アシスト${label}` : label}
    >
      {isAssist && <AssistBadge />}
      <span
        className={`inline-flex h-[22px] w-[22px] items-center justify-center rounded-full text-[11px] font-bold shadow-2xs ${STRENGTH_CIRCLE_CLASS[strength]}`}
      >
        {label}
      </span>
    </span>
  );
}

function ModernAnyAttackBadge({ count = 1 }: { count?: number }) {
  const aria = count > 1 ? `攻撃ボタン×${count}` : "攻撃ボタン";
  return (
    <span
      className="inline-flex items-center gap-0.5"
      aria-label={aria}
      title={aria}
    >
      {Array.from({ length: count }).map((_, idx) => (
        <span
          key={idx}
          className="inline-flex h-[22px] w-[22px] shrink-0 items-center justify-center rounded-full bg-slate-100 shadow-2xs ring-[1.5px] ring-slate-500 dark:bg-[#2A2242] dark:ring-[#8E82B3]"
        />
      ))}
    </span>
  );
}

const TOKEN_REGEX =
  /(\[[^\]]+\]|(?:前|垂直|後)J中|アシスト弱|アシスト中|アシスト強|攻撃×3|攻撃×2|攻撃|弱P|中P|強P|弱K|中K|強K|PPP|PP|KKK|KK|CDR|DR|DI|DP|SP|空中|立|屈|(?<![一-龠A-Za-z])J(?=[弱中強])|(?<![A-Za-z])(?:AUTO|A)(?=\+)|[↑↓←→↗↘↙↖]|[+>]|\b[PK]\b|(?<![ぁ-んァ-ヶ一-龠A-Za-z])[PK](?![A-Za-z])|(?<![一-龠A-Za-z])[弱中強](?=出し切り|(?![一-龠ぁ-んァ-ヶ])))/g;

function renderToken(token: string, key: number): React.ReactNode {
  if (token in ARROW_ROTATION) {
    return <ArrowIcon key={key} dir={token} />;
  }

  switch (token) {
    case "屈":
      return <ArrowIcon key={key} dir="↓" />;
    case "立":
      return null;
    case "空中":
    case "J":
      return (
        <span
          key={key}
          className="rounded bg-slate-200/80 px-1 py-0.5 text-[10px] font-bold leading-none text-slate-700 dark:bg-[#30264A] dark:text-[#E2DCF5]"
        >
          空中
        </span>
      );
    case "弱P":
      return <AttackBadge key={key} kind="punch" strength="light" />;
    case "中P":
      return <AttackBadge key={key} kind="punch" strength="medium" />;
    case "強P":
      return <AttackBadge key={key} kind="punch" strength="heavy" />;
    case "弱K":
      return <AttackBadge key={key} kind="kick" strength="light" />;
    case "中K":
      return <AttackBadge key={key} kind="kick" strength="medium" />;
    case "強K":
      return <AttackBadge key={key} kind="kick" strength="heavy" />;
    case "P":
      return <AttackBadge key={key} kind="punch" strength="any" count={1} />;
    case "PP":
      return <AttackBadge key={key} kind="punch" strength="any" count={2} />;
    case "PPP":
      return <AttackBadge key={key} kind="punch" strength="any" count={3} />;
    case "K":
      return <AttackBadge key={key} kind="kick" strength="any" count={1} />;
    case "KK":
      return <AttackBadge key={key} kind="kick" strength="any" count={2} />;
    case "KKK":
      return <AttackBadge key={key} kind="kick" strength="any" count={3} />;
    case "アシスト弱":
      return <ModernStrengthBadge key={key} strength="light" isAssist />;
    case "アシスト中":
      return <ModernStrengthBadge key={key} strength="medium" isAssist />;
    case "アシスト強":
      return <ModernStrengthBadge key={key} strength="heavy" isAssist />;
    case "弱":
      return <ModernStrengthBadge key={key} strength="light" />;
    case "中":
      return <ModernStrengthBadge key={key} strength="medium" />;
    case "強":
      return <ModernStrengthBadge key={key} strength="heavy" />;
    case "攻撃":
      return <ModernAnyAttackBadge key={key} count={1} />;
    case "攻撃×2":
      return <ModernAnyAttackBadge key={key} count={2} />;
    case "攻撃×3":
      return <ModernAnyAttackBadge key={key} count={3} />;
    case "A":
    case "AUTO":
      return <AssistBadge key={key} />;
    case "SP":
      return (
        <span
          key={key}
          title="必殺技ボタン (SP)"
          className="inline-flex h-[20px] items-center justify-center rounded-[4px] bg-orange-500 px-1.5 text-[11px] font-extrabold tracking-tight text-white shadow-2xs ring-1 ring-orange-600/30"
        >
          SP
        </span>
      );
    case "DI":
      return (
        <span
          key={key}
          title="ドライブインパクト (DI)"
          className="inline-flex h-[20px] items-center justify-center rounded-[4px] bg-cyan-600 px-1.5 text-[11px] font-extrabold tracking-tight text-white shadow-2xs ring-1 ring-cyan-700/30"
        >
          DI
        </span>
      );
    case "DP":
      return (
        <span
          key={key}
          title="ドライブパリィ (DP)"
          className="inline-flex h-[20px] items-center justify-center rounded-[4px] bg-blue-600 px-1.5 text-[11px] font-extrabold tracking-tight text-white shadow-2xs ring-1 ring-blue-700/30"
        >
          DP
        </span>
      );
    case "DR":
      return (
        <span
          key={key}
          title="ドライブラッシュ (DR)"
          className="inline-flex h-[20px] items-center justify-center rounded-[4px] bg-emerald-600 px-1.5 text-[11px] font-extrabold tracking-tight text-white shadow-2xs ring-1 ring-emerald-700/30"
        >
          DR
        </span>
      );
    case "CDR":
      return (
        <span
          key={key}
          title="キャンセルドライブラッシュ (CDR)"
          className="inline-flex h-[20px] items-center justify-center rounded-[4px] bg-teal-600 px-1.5 text-[11px] font-extrabold tracking-tight text-white shadow-2xs ring-1 ring-teal-700/30"
        >
          CDR
        </span>
      );
    case "+":
      return (
        <span key={key} className="text-xs font-bold text-slate-400">
          +
        </span>
      );
    case ">":
      return (
        <span key={key} className="text-xs font-bold text-slate-400">
          ▸
        </span>
      );
    default:
      return (
        <span key={key} className="leading-snug">
          {token}
        </span>
      );
  }
}

export function CommandNotation({ text }: CommandNotationProps) {
  const parts: React.ReactNode[] = [];
  let lastIndex = 0;
  let keyCounter = 0;

  for (const match of text.matchAll(TOKEN_REGEX)) {
    const matchIndex = match.index ?? 0;
    if (matchIndex > lastIndex) {
      const plain = text.slice(lastIndex, matchIndex);
      if (plain) {
        parts.push(
          <span key={keyCounter++} className="leading-snug">
            {plain}
          </span>
        );
      }
    }
    parts.push(renderToken(match[0], keyCounter++));
    lastIndex = matchIndex + match[0].length;
  }

  if (lastIndex < text.length) {
    parts.push(
      <span key={keyCounter++} className="leading-snug">
        {text.slice(lastIndex)}
      </span>
    );
  }

  return (
    <span className="inline-flex flex-wrap items-center gap-1 align-middle">
      {parts}
    </span>
  );
}

/**
 * 技1つを選択中の表記モードで描画する共通コンポーネント。
 * CDR / DR / DI は全表記モード共通でコマンドアイコン（四角カラーバッジ）に統一する。
 */
export function MoveNotation({
  move,
  notationMode,
}: {
  move: Move;
  notationMode: NotationMode;
}) {
  if (
    notationMode === "command" ||
    ALWAYS_BADGE_MOVE_IDS.has(move.id)
  ) {
    return <CommandNotation text={move.notationCommand} />;
  }

  return (
    <>
      {notationMode === "numpad" ? move.notationNumpad : move.notationName}
    </>
  );
}
