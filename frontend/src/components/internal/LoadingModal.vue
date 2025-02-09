<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div
        v-if="isOpen"
        class="fixed inset-0 z-50 flex items-center justify-center"
      >
        <!-- Backdrop -->
        <div class="fixed inset-0 bg-black/50" @click.prevent></div>

        <!-- Modal -->
        <div
          class="relative z-50 bg-white rounded-lg shadow-xl p-6 w-[400px] flex flex-col items-center gap-4"
          @keydown.esc.prevent
        >
          <!-- Progress Text -->
          <p class="text-center font-medium text-lg">{{ progress }}%</p>

          <!-- Progress Bar -->
          <div class="w-full h-4 bg-gray-200 rounded-full overflow-hidden">
            <div
              class="h-full bg-primary transition-all duration-300 ease-out"
              :style="{ width: `${progress}%` }"
            ></div>
          </div>

          <!-- Status Message -->
          <p class="text-sm text-gray-600">{{ message || "Processing..." }}</p>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
defineProps({
  isOpen: {
    type: Boolean,
    required: true,
  },
  progress: {
    type: Number,
    required: true,
    validator: (value) => value >= 0 && value <= 100,
  },
  message: {
    type: String,
    default: "",
  },
});
</script>

<style scoped>
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
</style>
