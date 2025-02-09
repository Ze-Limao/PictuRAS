<template>
  <header
    class="flex p-4 justify-between items-center mb-4 border-b-[1.5px] border-gray-300"
  >
    <p class="text-2xl font-black">{{ project?.name }}</p>

    <!-- Actions -->
    <div class="flex space-x-3">
      <Button @click="downloadProject" variant="secondary">
        <Download class="w-6 h-6" />
        Download
      </Button>

      <Button
        variant="secondary"
        :disabled="!isProjectOwner()"
        @click="shareOpen = true"
      >
        <Share2 class="w-6 h-6" />
        Share
      </Button>

      <DropdownMenu v-if="isProjectOwner()">
        <DropdownMenuTrigger as-child>
          <Button variant="secondary">
            <span class="sr-only">Actions</span>
            <EllipsisIcon class="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem @select="renameOpen = true">
            Rename Project
          </DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem
            class="text-red-600"
            @select="showDeleteDialog = true"
          >
            Delete Project
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>

      <Button v-else variant="secondary" disabled>
        <EllipsisIcon class="w-6 h-6" />
      </Button>
    </div>
  </header>

  <Form v-slot="{ handleSubmit }" as="form" keep-values>
    <Dialog v-model:open="shareOpen">
      <DialogContent class="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Share Project</DialogTitle>
          <DialogDescription>
            Share your project with others by putting their email addresses
            here.
          </DialogDescription>
        </DialogHeader>

        <form id="shareForm" @submit="handleSubmit($event, onShareSubmit)">
          <FormField v-slot="{ componentField }" name="email">
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input
                  type="text"
                  placeholder="mail@picturas.com"
                  v-bind="componentField"
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>
        </form>

        <Separator class="my-2" />
        <div class="space-y-4 mb-2">
          <h4 class="text-sm font-medium">People with access</h4>

          <ul class="grid gap-3">
            <li
              v-for="(guest, index) in project?.guests!"
              :key="index"
              class="flex items-center justify-between space-x-4"
            >
              <p class="text-sm font-medium text-gray-800">
                {{ guest.email }}
              </p>

              <button
                type="button"
                @click="revokeUser(guest.email)"
                class="text-red-800 border rounded-md border-gray-300 p-1"
              >
                <UserRoundX class="w-4 h-4" />
                <span class="sr-only">Remove</span>
              </button>
            </li>
          </ul>
        </div>

        <DialogFooter>
          <Button type="submit" form="shareForm"> Share </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </Form>

  <Form
    v-slot="{ handleSubmit }"
    as=""
    keep-values
    :validation-schema="renameFormSchema"
  >
    <Dialog v-model:open="renameOpen">
      <DialogContent class="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Edit Project</DialogTitle>
          <DialogDescription>
            Make changes to your project here. Click save when you're done.
          </DialogDescription>
        </DialogHeader>

        <form id="renameForm" @submit="handleSubmit($event, onRenameSubmit)">
          <FormField v-slot="{ componentField }" name="name">
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input
                  type="text"
                  placeholder="Picturas"
                  v-bind="componentField"
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          </FormField>
        </form>

        <DialogFooter>
          <Button type="submit" form="renameForm"> Save Changes </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </Form>

  <AlertDialog v-model:open="showDeleteDialog">
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle
          >Are you sure you want to delete this project?</AlertDialogTitle
        >
        <AlertDialogDescription>
          This action cannot be undone. This will permanently delete the
          project.
        </AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel>Cancel</AlertDialogCancel>

        <AlertDialogAction
          @click="deleteProject"
          :class="buttonVariants({ variant: 'destructive' })"
          >Delete</AlertDialogAction
        >
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>

  <!-- 3 columns (25%, 50%, 25%)-->
  <div class="flex flex-row space-x-2 m-4">
    <!-- First column -->
    <div class="w-[25%] flex flex-col">
      <div
        class="flex flex-col space-y-3 border border-gray-300 rounded-md p-2 max-h-[620px] min-h-[620px] h-auto w-auto"
      >
        <p class="text-lg text-gray-400 uppercase font-bold text-center">
          Available Tools
        </p>

        <ul class="flex flex-col space-y-2 p-4 overflow-y-auto max-h-[620px]">
          <TooltipProvider>
            <li v-for="(tool, index) in availableTools" :key="index">
              <Tooltip>
                <TooltipContent>
                  <p>{{ tool.description }}</p>
                </TooltipContent>

                <TooltipTrigger class="w-full">
                  <Button
                    class="w-full"
                    variant="secondary"
                    @click="addOrConfigureTool(tool)"
                    >{{ tool.display_name }}</Button
                  >
                </TooltipTrigger>
              </Tooltip>
            </li>
          </TooltipProvider>
        </ul>
      </div>
    </div>

    <!-- Mid column -->
    <div class="w-[50%] space-y-2">
      <div
        class="relative flex justify-center border rounded-md border-gray-300"
      >
        <div class="editor-container max-h-[619px] min-h-[619px] h-auto w-auto">
          <div
            class="image-wrapper"
            @mousedown="handleDragStart"
            @mousemove="handleDrag"
            @mouseup="handleDragEnd"
            @mouseleave="handleDragEnd"
            @wheel.prevent="handleWheel"
          >
            <img
              v-if="filteredImages[currentImageIndex]"
              :src="filteredImages[currentImageIndex].url"
              class="pointer-events-none"
              :style="{
                transform: `translate(${position.x}px, ${position.y}px) scale(${scaling})`,
                cursor: isDragging ? 'grabbing' : 'grab',
              }"
              @load="resetTransform"
            />
          </div>
        </div>
      </div>

      <!-- Bottom part -->
      <div class="flex justify-between">
        <div class="flex space-x-3">
          <Button
            @click="$refs.fileInput.click()"
            :disabled="!isProjectOwner() || showInitials === false"
          >
            <Upload class="w-6 h-6" />
            Upload
          </Button>

          <input
            type="file"
            ref="fileInput"
            multiple
            accept="image/*"
            class="hidden"
            @change="handleFileSelect"
          />

          <Button
            @click="deleteCurrentImage"
            variant="destructive"
            :disabled="!isProjectOwner() || showInitials === false"
          >
            <Trash2 class="w-6 h-6" />
            Delete
          </Button>

          <TooltipProvider>
            <Tooltip>
              <TooltipContent>
                <p>Toggle between showing the initials or the final images</p>
              </TooltipContent>

              <TooltipTrigger>
                <Button
                  v-if="showInitials"
                  @click="showInitials = false"
                  size="icon"
                  variant="outline"
                  class="transition-all"
                >
                  <StarOff class="w-6 h-6" />
                </Button>
                <Button
                  v-else
                  @click="showInitials = true"
                  size="icon"
                  variant="outline"
                  class="text-amber-600 hover:text-amber-600 transition-all"
                >
                  <Star class="w-6 h-6" />
                </Button>
              </TooltipTrigger>
            </Tooltip>
          </TooltipProvider>
        </div>

        <div class="flex items-center space-x-3">
          <p v-if="totalPages > 0" class="font-medium">
            {{ currentImageIndex + 1 }} of {{ totalPages }}
          </p>
          <p v-else class="font-medium">0 of 0</p>

          <div class="flex items-center gap-1">
            <!-- First page -->
            <Button
              size="icon"
              @click="handlePageChange(0)"
              :disabled="currentImageIndex === 0"
            >
              <ChevronFirst />
            </Button>

            <!-- Previous page -->
            <Button
              size="icon"
              @click="handlePageChange(currentImageIndex - 1)"
              :disabled="currentImageIndex === 0"
            >
              <ChevronLeft />
            </Button>

            <!-- Next page -->
            <Button
              size="icon"
              @click="handlePageChange(currentImageIndex + 1)"
              :disabled="currentImageIndex >= totalPages - 1"
            >
              <ChevronRight />
            </Button>

            <!-- Last page -->
            <Button
              size="icon"
              @click="handlePageChange(totalPages - 1)"
              :disabled="currentImageIndex >= totalPages - 1"
            >
              <ChevronLast />
            </Button>
          </div>
        </div>
      </div>
    </div>

    <!-- Last column -->
    <div class="w-[25%] flex flex-col space-y-2">
      <div
        class="flex flex-col space-y-3 border border-gray-300 rounded-md p-2 overflow-y-auto max-h-[620px] min-h-[620px] h-auto w-auto"
      >
        <p class="text-lg text-gray-400 uppercase font-bold text-center">
          Pipeline
        </p>

        <ul
          id="sortable-list"
          :key="itemsKey"
          class="flex flex-col space-y-2 p-4"
        >
          <li
            v-for="(displayableTool, index) in pipelineTools"
            :key="index"
            class="flex justify-between items-center cursor-pointer"
          >
            <div
              class="w-full inline-flex items-center justify-between gap-2 whitespace-nowrap rounded-md text-sm font-medium ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 bg-secondary text-secondary-foreground shadow-sm h-9 px-4 py-2"
            >
              <div class="flex items-center space-x-2">
                <GripHorizontal class="text-gray-800 w-4 h-4" />
                <span class="font-medium">{{
                  displayableTool.display_name
                }}</span>
              </div>

              <div class="flex items-center space-x-3">
                <button
                  v-if="Object.keys(displayableTool.tool.parameters).length > 0"
                  @click="editTool(index)"
                >
                  <Pencil class="w-4 h-4" />
                </button>

                <button @click="removeTool(index)">
                  <CircleMinus class="w-4 h-4 text-red-800" />
                </button>
              </div>
            </div>
          </li>
        </ul>
      </div>

      <Button
        @click="executePipeline"
        :disabled="!isProjectOwner() || showInitials === false"
      >
        <MonitorCog class="w-6 h-6" />
        Execute Pipeline
      </Button>
    </div>

    <!-- Configure Tool Modal -->
    <Form v-slot="{ handleSubmit }" as="" keep-values>
      <Dialog v-model:open="configureToolOpen">
        <DialogContent class="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle
              >Configure {{ selectedTool?.display_name }}</DialogTitle
            >
            <DialogDescription>
              Adjust the parameters for your tool, then confirm to add it to the
              pipeline.
            </DialogDescription>
          </DialogHeader>

          <form
            @submit="handleSubmit($event, confirmToolParameters)"
            class="space-y-2"
            id="configureToolForm"
          >
            <FormField
              v-for="(parameter, index) in selectedTool!.parameters"
              :key="index"
              :name="parameter.name"
            >
              <FormItem>
                <FormLabel>{{ parameter.display_name }}</FormLabel>
                <FormControl>
                  <Input
                    v-if="parameter.type === AvailableToolParameterType.COLOR"
                    type="color"
                    v-model="toolParameters[parameter.name]"
                  />
                  <Input
                    v-else-if="
                      parameter.type === AvailableToolParameterType.NUMBER
                    "
                    type="number"
                    v-model="toolParameters[parameter.name]"
                  />
                  <div
                    v-else-if="
                      parameter.type === AvailableToolParameterType.SLIDER
                    "
                    class="flex flex-col space-y-2"
                  >
                    <Input
                      type="range"
                      v-model="toolParameters[parameter.name]"
                      :min="parameter.min"
                      :max="parameter.max"
                      :step="0.01"
                      class="w-full cursor-pointer"
                    />
                    <span>{{ toolParameters[parameter.name] }}</span>
                  </div>
                </FormControl>
                <FormMessage />
              </FormItem>
            </FormField>
          </form>

          <DialogFooter>
            <Button variant="secondary" @click="configureToolOpen = false">
              Cancel
            </Button>

            <Button type="submit" form="configureToolForm"> Confirm </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Form>
  </div>
</template>

<script setup lang="ts">
import { useRoute } from "vue-router";
import {
  computed,
  nextTick,
  onMounted,
  watch,
  ref,
  type Ref,
  type ComputedRef,
  onBeforeUnmount,
} from "vue";
import { h } from "vue";
import Sortable from "sortablejs";
import JSZip from "jszip";
import * as z from "zod";
import { toTypedSchema } from "@vee-validate/zod";

import thumbnailPlaceholder from "@/assets/placeholder.svg";

import { Separator } from "@/components/ui/separator";
import { Button, buttonVariants } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Slider } from "@/components/ui/slider";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/toast";

import {
  Download,
  EllipsisIcon,
  Share2,
  Trash2,
  Upload,
  ChevronLeft,
  ChevronRight,
  ChevronFirst,
  ChevronLast,
  GripHorizontal,
  Pencil,
  CircleMinus,
  MonitorCog,
  UserRoundX,
  StarOff,
  Star,
} from "lucide-vue-next";

import {
  type Project,
  type AvailableTool,
  type PipelineTool,
  type AvailableToolParameter,
  AvailableToolParameterType,
  ImageType,
  ProjectState,
} from "@/types/api";
import { useSessionStore } from "@/stores/session";
import * as API from "@/api";

import ToastAction from "@/components/ui/toast/ToastAction.vue";

const { toast } = useToast();
const route = useRoute();

// Image editor
const scaling: Ref<number> = ref(1);
const position: Ref<{ x: number; y: number }> = ref({ x: 0, y: 0 });
const isDragging: Ref<boolean> = ref(false);
const startPos: Ref<{ x: number; y: number }> = ref({ x: 0, y: 0 });

const handleDragStart = (e: any) => {
  isDragging.value = true;

  startPos.value = {
    x: e.clientX - position.value.x,
    y: e.clientY - position.value.y,
  };
};

const handleDrag = (e: any) => {
  if (!isDragging.value) return;

  position.value = {
    x: e.clientX - startPos.value.x,
    y: e.clientY - startPos.value.y,
  };
};

const handleDragEnd = () => {
  isDragging.value = false;
};

const handleWheel = (e: any) => {
  // Prevent page scroll
  e.preventDefault();

  if (e.deltaY < 0) {
    scaling.value = Math.min(scaling.value + 0.1, 3);
  } else {
    scaling.value = Math.max(scaling.value - 0.1, 0.5);
  }
};

// Reset position and scaling when shown
// image is changed
const resetTransform = () => {
  position.value = { x: 0, y: 0 };
  scaling.value = 1;
};

// Get project & available tools
const projectId: string = route.params.id as string;

const userSession = useSessionStore();
const currentUser = userSession.currentUser;
const sessionToken = userSession.authToken;

const project: Ref<Project | null> = ref(null);

interface InternalImage {
  id?: string;
  url: string;
  blob: Blob;
  type: ImageType;
  width: number;
  height: number;
}

const images: Ref<Array<InternalImage>> = ref([]);

const fetchProject = (fromPipeline: boolean) => {
  API.getProject(currentUser.id, projectId, sessionToken)
    .then((response) => {
      project.value = response.data;
    })
    .then(() => {
      createImages(project.value!, fromPipeline);
    })
    .then(() => {
      createPipelineTools(project.value!, fromPipeline);
    })
    .catch((_error) => {
      toast({
        variant: "destructive",
        title: "Uh oh! Something went wrong.",
        description: "Failed to fetch project. Please try again.",
        action: h(
          ToastAction,
          {
            altText: "Try again",
            onClick: fetchProject,
          },
          {
            default: () => "Try again",
          },
        ),
      });
    });
};

async function createImages(project: Project, fromPipeline: boolean) {
  const newImages: InternalImage[] = fromPipeline ? [] : [...images.value];

  for (const image of project.images!) {
    const url: string = buildAuthedImageURL(image.id, project.id);

    try {
      const response = await fetch(url, {
        method: "GET",
        headers: {
          Authorization: `Bearer ${sessionToken}`,
        },
      });

      // Fallback
      if (!response.ok) {
        newImages.push({
          id: image.id,
          url: thumbnailPlaceholder,
          blob: new Blob(),
          type: image.type,
          width: 0,
          height: 0,
        });

        continue;
      }

      const blob = await response.blob();
      const objectUrl = URL.createObjectURL(blob);
      let dimensions = { width: 0, height: 0 };
      dimensions = await getImageDimensions(blob);

      newImages.push({
        id: image.id,
        url: objectUrl,
        blob: blob,
        type: image.type,
        width: dimensions.width,
        height: dimensions.height,
      });
    } catch (_error) {
      newImages.push({
        id: image.id,
        url: thumbnailPlaceholder,
        blob: new Blob(),
        type: image.type,
        width: 0,
        height: 0,
      });
    }
  }

  images.value = newImages;
}

const getImageDimensions = (
  blob: Blob,
): Promise<{ width: number; height: number }> => {
  return new Promise((resolve, reject) => {
    const img = new Image();
    const url = URL.createObjectURL(blob);

    img.onload = () => {
      resolve({ width: img.width, height: img.height });
      URL.revokeObjectURL(url);
    };

    img.onerror = () => {
      reject();
      URL.revokeObjectURL(url);
    };

    img.src = url;
  });
};

function createPipelineTools(project: Project, fromPipeline: boolean) {
  if (fromPipeline) return;

  for (const tool of project.tools!) {
    const displayName = getDisplayNameFromProcedure(tool.procedure);

    pipelineTools.value.push({
      tool: tool,
      display_name: displayName!,
    });
  }
}

const availableTools: Ref<AvailableTool[]> = ref([]);

const fetchAvailableTools = () => {
  API.getAvailableTools(currentUser.id, sessionToken)
    .then((response) => {
      availableTools.value = response.data;
    })
    .catch(() => {
      toast({
        variant: "destructive",
        title: "Uh oh! Something went wrong.",
        description: "Failed to fetch available tools. Please try again.",
      });
    });
};

onMounted(() => {
  fetchAvailableTools();
  fetchProject(false);
});

// Upload image(s)
const handleFileSelect = async (e: any) => {
  const newFiles = await validateFiles(e.target.files);
  if (newFiles.length === 0) return;

  await uploadImages(project.value!.id, newFiles);

  e.target.value = "";
};

const uploadImages = async (projectId: string, filesToUpload: File[]) => {
  const formData = new FormData();

  let index = 0;
  filesToUpload.forEach((file) => {
    formData.append(`images[${index}]`, file);
    index++;
  });

  try {
    const response = await API.uploadImages(
      currentUser.id,
      projectId,
      sessionToken,
      formData,
    );

    for (const image of response.data) {
      project.value!.images!.push({ id: image.id, type: ImageType.INITIAL });
    }
  } catch (_error) {
    toast({
      variant: "destructive",
      title: "Uh oh! Something went wrong.",
      description: "Failed to upload images. Please try again.",
    });

    return;
  }

  for (const file of filesToUpload) {
    const url = URL.createObjectURL(file);
    images.value.push({
      url: url,
      blob: file,
      type: ImageType.INITIAL,
      width: 0,
      height: 0,
    });
  }

  toast({
    title: `${filesToUpload.length} image(s) uploaded successfully.`,
  });
};

// TODO: Also validate this on the backend
// size will be proportional to the user's type
const MAX_IMAGE_SIZE = 5 * 1024 * 1024; // 5 MiB
const MAX_IMAGE_SIZE_STRING = "5 MiB";

const validateFiles = async (files: File[]) => {
  const validFiles = [];

  for (const file of Array.from(files)) {
    const isImageType = file.type.startsWith("image/");

    if (isImageType) {
      if (file.size <= MAX_IMAGE_SIZE) {
        validFiles.push(file);
      } else {
        toast({
          variant: "destructive",
          title: "Image is too large.",
          description: `File ${file.name} exceeds the maximum size of ${MAX_IMAGE_SIZE_STRING}.`,
        });
      }
    } else {
      toast({
        variant: "destructive",
        title: "Invalid file type.",
        description: `File ${file.name} is nor an image or a ZIP file only containing images.`,
      });
    }
  }

  return validFiles;
};

// Delete image
const deleteCurrentImage = async () => {
  if (filteredImages.value.length === 0) return;

  const index = currentImageIndex.value;
  const imageToDelete = filteredImages.value[index];

  try {
    await API.deleteImage(
      currentUser.id,
      project.value!.id,
      imageToDelete.id,
      sessionToken,
    );
  } catch (_error) {
    toast({
      variant: "destructive",
      title: "Uh oh! Something went wrong.",
      description: "Failed to delete image. Please try again.",
    });

    return;
  }

  const globalIndex = images.value.findIndex(
    (image) => image.url === filteredImages.value[index].url,
  );
  if (globalIndex !== -1) {
    images.value.splice(globalIndex, 1);
  }

  const projectImageIndex = project.value!.images!.findIndex(
    (img) => img.id === imageToDelete.id,
  );
  if (projectImageIndex !== -1) {
    project.value!.images!.splice(projectImageIndex, 1);
  }

  toast({
    title: "Image deleted successfully.",
  });
};

// Download project
const downloadProject = async () => {
  try {
    const zip = new JSZip();

    const imagePromises = images.value.map(async (item, index) => {
      try {
        const mimeType = item.blob.type;
        let extension = mimeType.split("/")[1];
        extension = extension.split(";")[0];

        zip.file(`${index + 1}.${extension}`, item.blob);
      } catch (_error) {
        toast({
          variant: "destructive",
          title: "Uh oh! Something went wrong.",
          description: "Could not obtain all images. Please try again.",
        });
      }
    });

    await Promise.all(imagePromises);

    const content = await zip.generateAsync({ type: "blob" });
    downloadBlob(content, `${project.value!.name}.zip`);
  } catch (_error) {
    toast({
      variant: "destructive",
      title: "Uh oh! Something went wrong.",
      description: "Could not generate project ZIP file. Please try again.",
    });
  }
};

// Images listing and pagination
const showInitials: Ref<boolean> = ref(true);
const filteredImages: any = computed(() => {
  return images.value.filter(
    (image) =>
      image.type === (showInitials.value ? ImageType.INITIAL : ImageType.FINAL),
  );
});

watch(filteredImages, (newFilteredImages: any) => {
  if (newFilteredImages.length === 0) {
    currentImageIndex.value = 0;
  } else if (currentImageIndex.value >= newFilteredImages.length) {
    currentImageIndex.value = newFilteredImages.length - 1;
  }
});

const currentImageIndex: Ref<number> = ref(0);
const totalPages: ComputedRef<number> = computed(
  () => filteredImages.value.length,
);

const handlePageChange = (index: number) => {
  if (index < 0) {
    currentImageIndex.value = 0;
  } else if (index >= totalPages.value) {
    currentImageIndex.value = totalPages.value - 1;
  } else {
    currentImageIndex.value = index;
  }
};

// Sortable pipeline list
onMounted(() => {
  initializeSortable();
});

const executePipeline = async () => {
  const pipeline: PipelineTool[] = pipelineTools.value.map((tool) => tool.tool);

  try {
    await API.executePipeline(
      currentUser.id,
      project.value!.id,
      pipeline,
      sessionToken,
    );

    toast({
      title: "Pipeline execution started.",
      description: "Your pipeline is now processing!",
    });

    startPolling();
  } catch (_error) {
    toast({
      variant: "destructive",
      title: "Uh oh! Something went wrong.",
      description:
        "Failed to execute pipeline. Make sure you have selected tools.",
    });
  }
};

const pollingInterval: Ref<number | null> = ref(null);

const startPolling = () => {
  if (pollingInterval.value !== null) return;

  pollingInterval.value = window.setInterval(async () => {
    fetchProject(true);

    if (project.value?.state === ProjectState.IDLE) {
      stopPolling();
      fetchProject(true);

      toast({
        title: "Pipeline execution completed.",
        description: "Your project has finished processing.",
      });
    }
  }, 1000);
};

const stopPolling = () => {
  if (pollingInterval.value === null) return;

  window.clearInterval(pollingInterval.value);
  pollingInterval.value = null;
};

onBeforeUnmount(() => {
  stopPolling();
});

const findToolByProcedure = (procedure: string) => {
  return availableTools.value.find((tool) => tool.procedure === procedure);
};

const getDisplayNameFromProcedure = (procedure: string) => {
  for (const tool of availableTools.value) {
    if (tool.procedure == procedure) {
      return tool.display_name;
    }
  }
};

type DisplayablePipelineTool = {
  tool: PipelineTool;
  display_name: string;
};

const pipelineTools: Ref<DisplayablePipelineTool[]> = ref([]);
const itemsKey: Ref<number> = ref(0);

let sortableInstance: any = null;

const initializeSortable = () => {
  const el: any = document.getElementById("sortable-list");
  if (sortableInstance) {
    sortableInstance.destroy();
  }

  sortableInstance = Sortable.create(el, {
    animation: 150,
    onEnd: (e: any) => {
      const movedItem = pipelineTools.value.splice(e.oldIndex, 1)[0];
      pipelineTools.value.splice(e.newIndex, 0, movedItem);

      updatePipeline([...pipelineTools.value]);
    },
  });
};

const updatePipeline = async (newList: DisplayablePipelineTool[]) => {
  pipelineTools.value = newList;
  itemsKey.value += 1;
  await nextTick();
  initializeSortable();
};

// Configure tools
const configureToolOpen: Ref<boolean> = ref(false);
const selectedTool: Ref<AvailableTool | null> = ref(null);
const toolParameters: Ref<any> = ref({});

const addOrConfigureTool = (tool: AvailableTool) => {
  if (tool.parameters && tool.parameters.length > 0) {
    selectedTool.value = tool;
    toolParameters.value = convertParameters(tool.parameters);
    configureToolOpen.value = true;
  } else {
    addTool(tool);
  }
};

const addTool = (tool: AvailableTool) => {
  const pipelineTool: DisplayablePipelineTool = {
    tool: {
      procedure: tool.procedure,
      position: pipelineTools.value.length + 1,
      parameters: convertParameters(tool.parameters),
    },
    display_name: tool.display_name,
  };

  updatePipeline([...pipelineTools.value, pipelineTool]);
};

const confirmToolParameters = (_values: any) => {
  if (!selectedTool.value) {
    configureToolOpen.value = false;
    return;
  }

  if (editingToolIndex.value !== -1) {
    pipelineTools.value[editingToolIndex.value].tool.parameters =
      toolParameters.value;
    updatePipeline([...pipelineTools.value]);
    editingToolIndex.value = -1;
    configureToolOpen.value = false;
    return;
  }

  const newTool: PipelineTool = {
    procedure: selectedTool.value.procedure,
    position: pipelineTools.value.length + 1,
    parameters: toolParameters.value,
  };

  const displayName = getDisplayNameFromProcedure(newTool.procedure);
  const displayableTool: DisplayablePipelineTool = {
    tool: newTool,
    display_name: displayName!,
  };

  configureToolOpen.value = false;
  updatePipeline([...pipelineTools.value, displayableTool]);
};

const editingToolIndex: Ref<number> = ref(-1);

const editTool = (index: number) => {
  const tool = pipelineTools.value[index].tool;
  const availableTool = findToolByProcedure(tool.procedure);

  if (!availableTool) return;

  selectedTool.value = availableTool;
  toolParameters.value = tool.parameters;

  configureToolOpen.value = true;
  editingToolIndex.value = index;
};

const removeTool = (index: number) => {
  pipelineTools.value.splice(index, 1);
  updatePipeline([...pipelineTools.value]);
};

const convertParameters = (parameters: AvailableToolParameter[]) => {
  const convertedParameters: any = {};

  parameters.forEach((parameter) => {
    convertedParameters[parameter.name] = buildDefault(parameter.default);
  });

  return convertedParameters;
};

const buildDefault = (defaultParam: any): any => {
  if (defaultParam === "imageWidth") {
    return images.value[currentImageIndex.value].width;
  } else if (defaultParam === "imageHeight") {
    return images.value[currentImageIndex.value].height;
  } else {
    return defaultParam;
  }
};

// Delete & rename project
const showDeleteDialog: Ref<boolean> = ref(false);
const renameOpen: Ref<boolean> = ref(false);

const deleteProject = () => {
  API.deleteProject(currentUser.id, projectId, sessionToken)
    .then(() => {
      toast({
        title: "Project deleted successfully.",
      });

      window.location.href = "/";
    })
    .catch(() => {
      toast({
        variant: "destructive",
        title: "Uh oh! Something went wrong.",
        description: "Failed to delete project. Please try again.",
      });
    });
};

const renameFormSchema = toTypedSchema(
  z.object({
    name: z.string().nonempty({ message: "Required" }),
  }),
);

function onRenameSubmit(values: any) {
  const name: string = values.name;

  API.updateProject(currentUser.id, projectId, { name: name }, sessionToken)
    .then(() => {
      project.value!.name = name;
      renameOpen.value = false;

      toast({
        title: "Project renamed successfully.",
      });
    })
    .catch(() => {
      toast({
        variant: "destructive",
        title: "Uh oh! Something went wrong.",
        description: "Failed to rename project. Please try again.",
      });
    });
}

// Share
const shareOpen: Ref<boolean> = ref(false);

function onShareSubmit(values: any) {
  if (!values.email) return;
  const email: string = values.email;

  API.inviteUser(currentUser.id, projectId, email, sessionToken)
    .then(() => {
      toast({
        title: "User invited successfully.",
      });

      shareOpen.value = false;
      virtuallyAddUser(email);
    })
    .catch(() => {
      toast({
        variant: "destructive",
        title: "Uh oh! Something went wrong.",
        description: "Failed to invite user. Please try again.",
      });
    });
}

function revokeUser(email: string) {
  API.revokeUser(currentUser.id, projectId, email, sessionToken)
    .then(() => {
      toast({
        title: "User revoked successfully.",
      });

      shareOpen.value = false;
      virtuallyRemoveUser(email);
    })
    .catch(() => {
      toast({
        variant: "destructive",
        title: "Uh oh! Something went wrong.",
        description: "Failed to revoke user. Please try again.",
      });
    });
}

const virtuallyAddUser = (email: string) => {
  project.value!.guests!.push({ email: email });
};

const virtuallyRemoveUser = (email: string) => {
  const index = project.value!.guests!.findIndex(
    (guest) => guest.email === email,
  );
  project.value!.guests!.splice(index, 1);
};

// Helpers
const isProjectOwner = () => {
  return project.value?.owner_id === currentUser.id;
};

const buildAuthedImageURL = (imageId: string, projectId: string) => {
  const baseURL = import.meta.env.VITE_API_URL + "/api/v1";
  return `${baseURL}/users/${currentUser.id}/projects/${projectId}/${imageId}`;
};

const downloadBlob = (blob: Blob, filename: string) => {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.style.display = "none";
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
};
</script>

<style scoped>
.editor-container {
  width: 100%;
  height: 100%;
  overflow: hidden;
  position: relative;
  background: transparent;
}

.image-wrapper {
  width: 100%;
  height: 100%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  transform-origin: center;
  user-select: none;
  transition: transform 0.05s ease-out;
  position: relative;
}

/* Reset range default appearance */
input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  background: transparent;
  margin: 0;
}

/* Track styles */
input[type="range"]::-webkit-slider-runnable-track {
  width: 100%;
  height: 8px;
  cursor: pointer;
  background: #000000;
  border-radius: 4px;
}

input[type="range"]::-moz-range-track {
  width: 100%;
  height: 8px;
  cursor: pointer;
  background: #000000;
  border-radius: 4px;
}

input[type="range"]::-ms-track {
  width: 100%;
  height: 8px;
  cursor: pointer;
  background: transparent;
  border-color: transparent;
  color: transparent;
}

/* Thumb styles */
input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  margin-top: -4px;
  width: 20px;
  height: 20px;
  background: #ffffff;
  border: 2px solid #000000;
  border-radius: 50%;
  cursor: pointer;
}

input[type="range"]::-moz-range-thumb {
  width: 15px;
  height: 15px;
  background: #ffffff;
  border: 2px solid #000000;
  border-radius: 99%;
  cursor: pointer;
}

input[type="range"]::-ms-thumb {
  width: 10px;
  height: 10px;
  background: #ffffff;
  border: 2px solid #000000;
  border-radius: 99%;
  cursor: pointer;
}
</style>
