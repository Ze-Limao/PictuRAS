<template>
  <Form v-slot="{ handleSubmit }" as="">
    <Dialog v-model:open="showSelectLocal">
      <DialogContent class="max-w-xl">
        <DialogHeader>
          <DialogTitle>Select Plan</DialogTitle>
          <DialogDescription>
            Choose the plan that best fits your needs.
          </DialogDescription>
        </DialogHeader>

        <form id="selectPlanForm" @submit="handleSubmit($event, onSubmit)">
          <RadioGroup v-model="currentPlanLocal" class="grid grid-cols-2 gap-6">
            <!-- Free Plan -->
            <RadioGroupItem value="free" class="sr-only" id="free" />
            <label
              for="free"
              :class="[
                'flex flex-col p-6 rounded-lg border cursor-pointer',
                currentPlanLocal === UserType.NORMAL
                  ? 'bg-gray-200 border-gray-300'
                  : 'border-gray-200 hover:border-gray-300',
              ]"
            >
              <span class="text-lg font-bold mb-4 text-center">Normal</span>
              <ul class="space-y-3 text-sm">
                <li class="flex items-center">
                  <CheckIcon class="w-4 h-4 mr-2" /> Max 5 Daily Processes
                </li>
                <li class="flex items-center">
                  <CheckIcon class="w-4 h-4 mr-2" /> Max 20 Images per Project
                </li>
                <li class="flex items-center">
                  <CheckIcon class="w-4 h-4 mr-2" /> Images of any Size
                </li>
                <li class="flex items-center">
                  <CheckIcon class="w-4 h-4 mr-2" /> Access to basic tools
                </li>
              </ul>
            </label>

            <!-- Premium Plan -->
            <RadioGroupItem value="premium" class="sr-only" id="premium" />
            <label
              for="premium"
              :class="[
                'flex flex-col p-6 rounded-lg border cursor-pointer',
                currentPlanLocal === UserType.PREMIUM
                  ? 'bg-gray-200 border-gray-300'
                  : 'border-gray-200 hover:border-gray-300',
              ]"
            >
              <span class="text-lg font-bold mb-4 text-center">Premium</span>
              <ul class="space-y-3 text-sm">
                <li class="flex items-center">
                  <CheckIcon class="w-4 h-4 mr-2" /> Unlimited Daily Processes
                </li>
                <li class="flex items-center">
                  <CheckIcon class="w-4 h-4 mr-2" /> Unlimited Images per
                  Project
                </li>
                <li class="flex items-center">
                  <CheckIcon class="w-4 h-4 mr-2" /> Images of any Size
                </li>
                <li class="flex items-center">
                  <CheckIcon class="w-4 h-4 mr-2" /> Access to all tools
                </li>
                <li class="pt-4 font-bold">4,99 €/month</li>
              </ul>
            </label>
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
</template>

<script setup lang="ts">
import { computed, ref, type Ref } from "vue";

import { CheckIcon } from "lucide-vue-next";

import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";

import { UserType } from "@/types/api";
import { on } from "events";

interface Props {
  showSelect: boolean;
  currentPlan: UserType;
  isLoggedIn?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  currentPlan: UserType.NORMAL,
  isLoggedIn: false,
});

const emit = defineEmits<{
  (e: "planSelected", plan: UserType): void;
  (e: "update:showSelect", value: boolean): void;
}>();

const showSelectLocal = computed({
  get: () => props.showSelect,
  set: (value) => emit("update:showSelect", value),
});

const currentPlanLocal: Ref<UserType> = ref(props.currentPlan);

const onSubmit = (_values: any) => {
  console.log("here");

  emit("planSelected", currentPlanLocal.value);
  emit("update:showSelect", false);
};
</script>
