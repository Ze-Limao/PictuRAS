import { createRouter, createWebHistory } from "vue-router";

import { useSessionStore } from "@/stores/session";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      component: () => import("../views/MainPageView.vue"),
      meta: { title: "Home", requiresAuth: true },
    },
    {
      path: "/login",
      component: () => import("../views/LoginView.vue"),
      meta: { title: "Login", requiresAuth: false },
    },
    {
      path: "/register",
      component: () => import("../views/RegisterView.vue"),
      meta: { title: "Register", requiresAuth: false },
    },
    {
      path: "/projects/:id",
      component: () => import("../views/EditProjectView.vue"),
      meta: { title: "Edit Project", requiresAuth: true },
    },
  ],
});

router.beforeEach((to, _from, next) => {
  document.title = to.meta.title as string;

  if (to.meta.requiresAuth) {
    const sessionStore = useSessionStore();
    sessionStore.maybeGetCurrentUser().then(() => {
      if (sessionStore.isLoggedIn) {
        next();
      } else {
        next("/login");
      }
    });

    return;
  }

  next();
});

export default router;
