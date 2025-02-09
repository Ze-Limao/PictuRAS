<template>
  <div class="flex items-center justify-center min-h-[calc(100vh-10rem)]">
    <Card class="w-full md:max-w-md mx-4">
      <CardHeader>
        <CardTitle class="text-2xl font-bold text-center"
          >Create an account</CardTitle
        >
      </CardHeader>

      <CardContent class="space-y-4">
        <AutoForm
          class="space-y-6"
          :schema="schema"
          :field-config="{
            name: {
              label: 'Name',
              inputProps: {
                type: 'string',
                placeholder: 'João Fernandes',
                required: true,
              },
            },
            email: {
              label: 'Email',
              inputProps: {
                type: 'string',
                placeholder: 'mail@picturas.com',
                required: true,
              },
            },
            password: {
              label: 'Password',
              inputProps: {
                type: 'password',
                placeholder: '••••••••••',
                required: true,
              },
            },
            confirm: {
              label: 'Confirm Password',
              inputProps: {
                type: 'password',
                placeholder: '••••••••••',
                required: true,
              },
            },
          }"
          @submit="onSubmit"
        >
          <Button type="submit" class="w-full"> Register </Button>
          <hr class="h-px bg-gray-300 border-0" />

          <p class="text-center text-sm">
            Already have an account?
            <a href="/login" class="text-blue-500 hover:underline">Login</a>
          </p>
        </AutoForm>
      </CardContent>
    </Card>
  </div>

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
              <RadioGroupItem id="normal" value="normal" class="peer sr-only" />
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
</template>

<script setup lang="ts">
import { ref, type Ref } from "vue";
import * as z from "zod";

import { Banknote, CheckIcon, HandshakeIcon } from "lucide-vue-next";

import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
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
import { AutoForm } from "@/components/ui/auto-form";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { useToast } from "@/components/ui/toast";

import router from "@/router";
import * as API from "@/api";
import { UserType } from "@/types/api";

const { toast } = useToast();

const schema = z
  .object({
    name: z.string().nonempty(),
    email: z.string().email(),
    password: z
      .string()
      .min(8, { message: "Password must be at least 8 characters long" })
      .max(72, { message: "Password must be at most 72 characters long" }),
    confirm: z.string(),
  })
  .refine((data) => data.password === data.confirm, {
    message: "Passwords must match",
    path: ["confirm"],
  });

const currentPlan: Ref<UserType> = ref(UserType.NORMAL);
const selectPlanOpen = ref(false);
const formValues: any = ref({});

function onSubmit(values: Record<string, any>) {
  formValues.value = values;
  selectPlanOpen.value = true;
}

const onSelectPlanSubmit = () => {
  API.register(
    formValues.value["name"],
    formValues.value["email"],
    formValues.value["password"],
    currentPlan.value,
  )
    .then((_response) => {
      selectPlanOpen.value = true;
      router.push("/login");

      toast({
        title: "Account created successfully!",
        description: "Please login to continue.",
      });
    })
    .catch((_error) => {
      selectPlanOpen.value = false;

      toast({
        variant: "destructive",
        title: "Uh oh! Something went wrong.",
        description: "Could not create an account. Please try again.",
      });
    });
};
</script>
