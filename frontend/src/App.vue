<template>
  <div class="min-h-screen bg-white flex flex-col">
    <header
      class="flex justify-between items-center p-4 border-b-[1.5px] border-gray-300"
    >
      <a href="/" class="flex flex-row items-center space-x-3">
        <img :src="logo" class="size-10" />
        <p class="text-3xl font-black">Picturas</p>
      </a>

      <DropdownMenu v-if="isLoggedIn && user">
        <DropdownMenuTrigger>
          <div class="flex cursor-pointer gap-2 items-center">
            <span>{{ user.name }}</span>
            <SquareUserRound class="w-6 h-6" />
          </div>
        </DropdownMenuTrigger>

        <DropdownMenuContent align="end">
          <DropdownMenuLabel>{{
            capitalizeString(user.type)
          }}</DropdownMenuLabel>
          <DropdownMenuSeparator />
          <DropdownMenuItem class="cursor-pointer" @click="openPlanSelection"
            >Change Plan</DropdownMenuItem
          >
          <DropdownMenuItem class="cursor-pointer" @click="logout"
            >Logout
            <LogOut />
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </header>

    <Form v-slot="{ handleSubmit }" as="">
      <Dialog v-model:open="selectPlanOpen">
        <DialogContent class="max-w-xl">
          <DialogHeader>
            <DialogTitle>Select Plan</DialogTitle>
            <DialogDescription>
              Choose the plan that best fits your needs.
            </DialogDescription>
          </DialogHeader>

          <form
            id="selectPlanForm"
            @submit="handleSubmit($event, onSelectPlanSubmit)"
          >
            <RadioGroup v-model="currentPlan" class="grid grid-cols-2 gap-6">
              <div>
                <RadioGroupItem
                  id="normal"
                  value="normal"
                  class="peer sr-only"
                />
                <Label
                  for="normal"
                  class="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-popover p-4 hover:bg-accent hover:text-accent-foreground peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary"
                >
                  <div class="flex items-center space-x-2">
                    <HandshakeIcon class="h-6 w-6" />
                    <p class="text-lg">Normal</p>
                  </div>

                  <ul class="space-y-3 mt-4">
                    <li class="flex items-center">
                      <CheckIcon class="w-4 h-4 mr-2" />
                      5 processes per day
                    </li>

                    <li class="flex items-center">
                      <CheckIcon class="w-4 h-4 mr-2" />
                      20 images per project
                    </li>

                    <li class="flex items items-center">
                      <CheckIcon class="w-4 h-4 mr-2" />
                      Images up to 5 MiB
                    </li>

                    <li class="flex items items-center">
                      <CheckIcon class="w-4 h-4 mr-2" />
                      Access to basic tools
                    </li>
                  </ul>
                </Label>
              </div>

              <div>
                <RadioGroupItem
                  id="premium"
                  value="premium"
                  class="peer sr-only"
                />
                <Label
                  for="premium"
                  class="flex flex-col items-center justify-between rounded-md border-2 border-muted bg-popover p-4 hover:bg-accent hover:text-accent-foreground peer-data-[state=checked]:border-primary [&:has([data-state=checked])]:border-primary"
                >
                  <div class="flex items-center space-x-2">
                    <Banknote class="h-6 w-6" />
                    <p class="text-lg">Premium</p>
                  </div>

                  <ul class="space-y-3 mt-4">
                    <li class="flex items-center">
                      <CheckIcon class="w-4 h-4 mr-2" />
                      Unlimited processes
                    </li>

                    <li class="flex items-center">
                      <CheckIcon class="w-4 h-4 mr-2" />
                      No cap per project
                    </li>

                    <li class="flex items items-center">
                      <CheckIcon class="w-4 h-4 mr-2" />
                      Images up to 100 MiB
                    </li>

                    <li class="flex items items-center">
                      <CheckIcon class="w-4 h-4 mr-2" />
                      Access to all tools
                    </li>
                  </ul>
                </Label>
              </div>
            </RadioGroup>
          </form>

          <DialogFooter>
            <Button type="submit" form="selectPlanForm" class="w-full">
              Apply
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Form>

    <main class="flex-1">
      <RouterView :key="$route.fullPath" />
    </main>

    <footer class="p-4 border-t-[1.5px] border-gray-300">
      <p class="text-center text-sm text-gray-500">
        &copy; 2025 Picturas. All rights reserved.
      </p>
    </footer>
  </div>

  <Toaster />
</template>

<script lang="ts" setup>
import { ref, type Ref } from "vue";
import { RouterView } from "vue-router";

import { Banknote, CheckIcon, HandshakeIcon } from "lucide-vue-next";

import Toaster from "@/components/ui/toast/Toaster.vue";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuLabel,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Button } from "@/components/ui/button";
import { Form } from "@/components/ui/form";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { toast } from "@/components/ui/toast";

import { LogOut, SquareUserRound } from "lucide-vue-next";

import { useSessionStore } from "@/stores/session";
import { UserType, type User } from "@/types/api";
import * as API from "@/api";

import logo from "@/assets/picturas.png";

const sessionStore = useSessionStore();
const isLoggedIn = sessionStore.isLoggedIn;
const user: User = sessionStore.currentUser;
const token = sessionStore.authToken;

const currentPlan: Ref<UserType> = ref(user.type);
const selectPlanOpen: Ref<boolean> = ref(false);

function onSelectPlanSubmit(_values: any) {
  selectPlanOpen.value = false;

  API.updateCurrentUser(token, {
    type: currentPlan.value,
  }).then(() => {
    user.type = currentPlan.value;
    sessionStore.updateUserType(currentPlan.value);

    toast({
      title: "You are all set!",
      description: "Your plan has been updated successfully.",
    });
  });
}

function openPlanSelection() {
  selectPlanOpen.value = true;
}

function logout() {
  sessionStore.logout();
  window.location.href = "/login";

  toast({
    title: "Logout",
    description: "You have been logged out.",
  });
}

// Helpers
const capitalizeString = (str: string) =>
  str.charAt(0).toUpperCase() + str.slice(1);
</script>
