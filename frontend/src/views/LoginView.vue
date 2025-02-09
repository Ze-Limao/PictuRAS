<template>
  <div class="flex items-center justify-center min-h-[calc(100vh-10rem)]">
    <Card class="w-full md:max-w-md mx-4">
      <CardHeader>
        <CardTitle class="text-2xl font-bold text-center"
          >Welcome to Picturas</CardTitle
        >
      </CardHeader>

      <CardContent class="space-y-4">
        <AutoForm
          class="space-y-6"
          :schema="schema"
          :field-config="{
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
          }"
          @submit="onSubmit"
        >
          <Button type="submit" class="w-full"> Login </Button>
          <hr class="h-px bg-gray-300 border-0" />

          <p class="text-center text-sm">
            Don't have an account?
            <a href="/register" class="text-blue-500 hover:underline"
              >Register</a
            >
          </p>
        </AutoForm>
      </CardContent>
    </Card>
  </div>
</template>

<script setup lang="ts">
import * as z from "zod";

import { Button } from "@/components/ui/button";
import { AutoForm } from "@/components/ui/auto-form";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { useToast } from "@/components/ui/toast";

import { useSessionStore } from "@/stores/session";
import * as API from "@/api";

const session = useSessionStore();

const schema = z.object({
  email: z.string().email(),
  password: z.string(),
});

const { toast } = useToast();

function onSubmit(values: Record<string, any>) {
  API.login(values["email"], values["password"])
    .then((response) => {
      session.login(response.data, response.token);
      window.location.href = "/";
    })
    .catch((_error) => {
      toast({
        variant: "destructive",
        title: "Uh oh! Something went wrong.",
        description: "Could not login. Please check your credentials.",
      });
    });
}
</script>
