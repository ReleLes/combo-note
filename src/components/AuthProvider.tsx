"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";
import type { User } from "@supabase/supabase-js";
import { createClient } from "@/lib/supabase/client";
import { fetchClientIsAdmin } from "@/lib/supabase/clientQueries";

interface AuthContextValue {
  user: User | null;
  isAdmin: boolean;
  isLoading: boolean;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue>({
  user: null,
  isAdmin: false,
  isLoading: true,
  signOut: async () => {},
});

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isAuthLoading, setIsAuthLoading] = useState(true);
  const [adminState, setAdminState] = useState<{
    userId: string | null;
    isAdmin: boolean;
  }>({
    userId: null,
    isAdmin: false,
  });

  useEffect(() => {
    const supabase = createClient();
    let mounted = true;

    supabase.auth
      .getUser()
      .then(({ data }) => {
        if (!mounted) return;
        setUser(data.user ?? null);
        setIsAuthLoading(false);
      })
      .catch(() => {
        if (!mounted) return;
        setUser(null);
        setIsAuthLoading(false);
      });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (!mounted) return;
      setUser(session?.user ?? null);
      setIsAuthLoading(false);
    });

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

  const currentUserId = user?.id ?? null;

  useEffect(() => {
    if (!currentUserId) {
      return;
    }

    let cancelled = false;

    fetchClientIsAdmin(currentUserId)
      .then((result) => {
        if (cancelled) return;
        setAdminState({
          userId: currentUserId,
          isAdmin: result,
        });
      })
      .catch(() => {
        if (cancelled) return;
        setAdminState({
          userId: currentUserId,
          isAdmin: false,
        });
      });

    return () => {
      cancelled = true;
    };
  }, [currentUserId]);

  const signOut = useCallback(async () => {
    const supabase = createClient();
    await supabase.auth.signOut();
    setUser(null);
    setAdminState({ userId: null, isAdmin: false });
  }, []);

  const isAdminResolvedForCurrentUser =
    !currentUserId || adminState.userId === currentUserId;
  const isAdmin = Boolean(
    currentUserId && adminState.userId === currentUserId && adminState.isAdmin
  );
  const isLoading = isAuthLoading || !isAdminResolvedForCurrentUser;

  const value = useMemo(
    () => ({
      user,
      isAdmin,
      isLoading,
      signOut,
    }),
    [user, isAdmin, isLoading, signOut]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}
