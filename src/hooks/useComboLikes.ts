"use client";

import { useCallback, useEffect, useState } from "react";
import type { Combo } from "@/types/combo";
import { createClient } from "@/lib/supabase/client";
import { useAuth } from "@/components/AuthProvider";

export interface ToggleLikeResult {
  requiresAuth?: boolean;
  liked?: boolean;
  error?: string;
}

export function useComboLikes(combos: Combo[]) {
  const { user } = useAuth();
  const [likedIds, setLikedIds] = useState<Set<string>>(() => new Set());
  const [countOverrides, setCountOverrides] = useState<Record<string, number>>(
    {}
  );
  const [pendingIds, setPendingIds] = useState<Set<string>>(() => new Set());

  // ログインユーザーのいいね済みID一覧をDBから取得
  useEffect(() => {
    if (!user) {
      return;
    }

    const supabase = createClient();
    let cancelled = false;

    supabase
      .from("combo_likes")
      .select("combo_id")
      .eq("user_id", user.id)
      .then(({ data, error }) => {
        if (cancelled || error || !data) return;
        setLikedIds(new Set(data.map((row) => row.combo_id as string)));
      });

    return () => {
      cancelled = true;
    };
  }, [user]);

  const isLiked = useCallback(
    (comboId: string) => (user ? likedIds.has(comboId) : false),
    [user, likedIds]
  );

  const getLikesCount = useCallback(
    (combo: Combo) => countOverrides[combo.id] ?? combo.likesCount,
    [countOverrides]
  );

  const toggleLike = useCallback(
    async (combo: Combo): Promise<ToggleLikeResult> => {
      if (!user) {
        return { requiresAuth: true };
      }

      if (pendingIds.has(combo.id)) {
        return {};
      }

      const currentlyLiked = likedIds.has(combo.id);
      const currentCount = countOverrides[combo.id] ?? combo.likesCount;
      const nextLiked = !currentlyLiked;
      const nextCount = Math.max(0, currentCount + (nextLiked ? 1 : -1));

      // 楽観的更新
      setPendingIds((prev) => new Set(prev).add(combo.id));
      setLikedIds((prev) => {
        const next = new Set(prev);
        if (nextLiked) {
          next.add(combo.id);
        } else {
          next.delete(combo.id);
        }
        return next;
      });
      setCountOverrides((prev) => ({
        ...prev,
        [combo.id]: nextCount,
      }));

      const supabase = createClient();

      try {
        if (nextLiked) {
          const { error } = await supabase.from("combo_likes").insert({
            user_id: user.id,
            combo_id: combo.id,
          });
          if (error) throw error;
        } else {
          const { error } = await supabase
            .from("combo_likes")
            .delete()
            .eq("user_id", user.id)
            .eq("combo_id", combo.id);
          if (error) throw error;
        }

        return { liked: nextLiked };
      } catch (err) {
        // エラー時はロールバック
        setLikedIds((prev) => {
          const next = new Set(prev);
          if (currentlyLiked) {
            next.add(combo.id);
          } else {
            next.delete(combo.id);
          }
          return next;
        });
        setCountOverrides((prev) => ({
          ...prev,
          [combo.id]: currentCount,
        }));
        const message =
          err instanceof Error ? err.message : "いいねの更新に失敗しました。";
        return { error: message };
      } finally {
        setPendingIds((prev) => {
          const next = new Set(prev);
          next.delete(combo.id);
          return next;
        });
      }
    },
    [user, pendingIds, likedIds, countOverrides]
  );

  return {
    isLiked,
    getLikesCount,
    toggleLike,
    isPending: (comboId: string) => pendingIds.has(comboId),
    combosCount: combos.length,
  };
}
