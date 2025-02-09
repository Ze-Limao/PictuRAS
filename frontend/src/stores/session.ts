import { defineStore } from "pinia";

import { getCurrentUser } from "@/api";
import type { User, UserType } from "@/types/api";

export const useSessionStore = defineStore("session", {
  state: () => ({
    user: {} as User,
    token: "",
  }),
  persist: {
    storage: localStorage,
  },
  getters: {
    isLoggedIn: (state) => !!state.token,
    currentUser: (state) => state.user,
    authToken: (state) => state.token,
  },
  actions: {
    login(user: User, token: string) {
      this.user = user;
      this.token = token;
    },
    logout() {
      this.user = {} as User;
      this.token = "";
    },
    updateUserType(type: UserType) {
      this.user.type = type;
    },
    async maybeGetCurrentUser() {
      try {
        this.user = await getCurrentUser(this.token);
      } catch (_) {
        this.logout();
      }
    },
  },
});
