<template>
  <section class="p-8">
    <h2 class="text-2xl font-bold mb-4">Create Project</h2>

    <div
      class="relative border-2 border-dashed rounded-lg p-8 text-center transition-colors duration-200"
      :class="[
        isDragging ? 'border-primary bg-primary/5' : 'border-gray-300',
        isUploading ? 'pointer-events-none opacity-50' : '',
      ]"
      @dragenter.prevent="isDragging = true"
      @dragleave.prevent="handleDragLeave"
      @dragover.prevent
      @drop.prevent="handleDrop"
    >
      <input
        type="file"
        ref="fileInput"
        multiple
        accept="image/*,.zip"
        class="hidden"
        @change="handleFileSelect"
      />

      <div v-if="!isUploading">
        <UploadCloud
          class="w-8 h-8 mx-auto mb-3"
          :class="isDragging ? 'text-primary' : 'text-gray-400'"
        />
        <p class="text-gray-500">
          Drag and drop your pictures here to create a new project or
        </p>
        <button
          @click="$refs.fileInput.click()"
          class="text-gray-500 underline mt-2"
        >
          click here to select files from your computer
        </button>
      </div>

      <div v-else class="space-y-3">
        <Loader class="w-8 h-8 mx-auto animate-spin text-primary" />
        <p class="text-primary">Uploading {{ files.length }} images...</p>
      </div>

      <div
        v-if="previewURLs.length && !isUploading"
        class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 gap-2 mt-6"
      >
        <div
          v-for="(preview, index) in previewURLs"
          :key="index"
          class="relative group aspect-square"
        >
          <img
            :src="preview"
            class="w-full h-full object-cover rounded-lg"
            alt="Preview"
          />
          <Button
            variant="destructive"
            @click.stop="removePreview(index)"
            class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity"
            size="icon"
          >
            <X />
          </Button>
        </div>
      </div>
    </div>

    <div class="mt-2 flex justify-between md:justify-normal gap-2">
      <input
        id="projectName"
        type="text"
        v-model="projectName"
        placeholder="Enter project name"
        class="px-2 py-1 border-2 border-gray-300 rounded-lg hover:border-gray-500 hover:border-2 focus:border-gray-500 focus:outline-none md:w-1/3"
      />

      <Button
        @click="createProject"
        :disabled="previewURLs.length === 0 || isUploading"
      >
        <Plus class="w-4 h-4" /> Create
      </Button>
    </div>
  </section>

  <section class="p-8">
    <h2 class="text-2xl font-bold mb-4">My Projects</h2>

    <div class="relative">
      <span
        class="absolute top-1.5 left-1 px-1 flex items-center text-gray-300 pointer-events-none"
      >
        <Search />
      </span>
      <input
        type="text"
        v-model="input"
        placeholder="Search projects..."
        class="pl-9 w-full px-2 py-1 border-2 border-gray-300 rounded-lg focus:border-gray-500 focus:outline-none mb-4"
      />
    </div>

    <div
      class="flex flex-col items-center justify-center mt-8 gap-6"
      v-if="input && !filteredList().length"
    >
      <div
        class="flex items-center justify-center w-20 h-20 bg-gray-100 rounded-full dark:bg-gray-800"
      >
        <Inbox class="w-10 h-10" />
      </div>

      <div class="space-y-2 text-center">
        <h2 class="text-2xl font-bold tracking-tight">No projects to show</h2>
        <p class="text-gray-500 dark:text-gray-400">
          It looks like there's no data available yet. Try creating a new
          project.
        </p>
      </div>
    </div>

    <div
      class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 cursor-pointer"
    >
      <div
        v-for="project in filteredList()"
        :key="project.id"
        class="rounded-lg overflow-hidden shadow-sm hover:shadow-md transition-shadow group relative"
        @click="navigateToProject(project.id)"
      >
        <img
          v-if="project.thumbnail"
          :src="imageBlobs[project.id]"
          class="w-full h-40 object-cover"
        />
        <img
          v-else
          :src="thumbnailPlaceholder"
          class="w-full h-40 object-cover"
        />

        <div class="p-4 flex justify-between items-center">
          <div class="flex flex-col">
            <span class="font-medium">{{ project.name }}</span>
            <span class="text-sm text-gray-500">
              Created at {{ formatDate(project.created_at) }}
            </span>
          </div>

          <TooltipProvider>
            <Tooltip>
              <TooltipContent>
                <p>Total images in project</p>
              </TooltipContent>

              <TooltipTrigger>
                <div class="flex items-center gap-x-2">
                  <span>{{ project.image_count }}</span>
                  <Copy class="w-4 h-4" />
                </div>
              </TooltipTrigger>
            </Tooltip>
          </TooltipProvider>
        </div>

        <AlertDialog>
          <AlertDialogTrigger as-child v-if="isProjectOwner(project)">
            <Button
              class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity"
              variant="destructive"
              size="icon"
              @click.stop="projectToDelete = project.id"
            >
              <X />
            </Button>
          </AlertDialogTrigger>

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
              <AlertDialogCancel @click="projectToDelete = null">
                Cancel
              </AlertDialogCancel>

              <AlertDialogAction
                @click="deleteProject"
                :class="buttonVariants({ variant: 'destructive' })"
                >Delete
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>

        <Badge
          v-if="!isProjectOwner(project)"
          class="absolute top-2 left-2 rounded-md hover:bg-gray-100 p-1.5"
          variant="secondary"
        >
          Guest
          <Users class="w-4 h-4 ml-1" />
        </Badge>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";
import { ref, onMounted, type Ref, h } from "vue";
import JSZip from "jszip";

import thumbnailPlaceholder from "@/assets/placeholder.svg";

import {
  UploadCloud,
  Copy,
  X,
  Loader,
  Users,
  Search,
  Plus,
  Inbox,
} from "lucide-vue-next";

import { Badge } from "@/components/ui/badge";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { Button, buttonVariants } from "@/components/ui/button";
import { ToastAction, useToast } from "@/components/ui/toast";

import * as API from "@/api";
import { useSessionStore } from "@/stores/session";
import type { Project, User } from "@/types/api";

const router = useRouter();
const { toast } = useToast();

const sessionStore = useSessionStore();
const sessionToken = sessionStore.authToken;
const currentUser: User = sessionStore.currentUser;

// List projects
const projects: Ref<Project[]> = ref([]);
const imageBlobs: Ref<Record<string, string>> = ref({});

const fetchProjects = () => {
  API.getUserProjects(currentUser.id, sessionToken)
    .then((response) => {
      projects.value = response.data;
    })
    .then(() => {
      createThumbnails(projects.value);
    })
    .catch((_error) => {
      toast({
        variant: "destructive",
        title: "Uh oh! Something went wrong.",
        description: "Failed to fetch projects. Please refresh the page.",
        action: h(
          ToastAction,
          {
            altText: "Try again",
            onClick: fetchProjects,
          },
          {
            default: () => "Try again",
          },
        ),
      });
    });
};

onMounted(() => {
  fetchProjects();
});

async function createThumbnails(projects: Project[]) {
  for (const project of projects) {
    imageBlobs.value[project.id] = thumbnailPlaceholder;

    if (!project.thumbnail) {
      continue;
    }

    const url: string = buildAuthedImageURL(project.thumbnail, project.id);

    try {
      const response = await fetch(url, {
        method: "GET",
        headers: {
          Authorization: `Bearer ${sessionToken}`,
        },
      });

      if (response.ok) {
        const blob = await response.blob();
        imageBlobs.value[project.id] = URL.createObjectURL(blob);
      }
    } catch (_error) {
      imageBlobs.value[project.id] = thumbnailPlaceholder;
    }
  }
}

const isProjectOwner = (project: Project) => {
  return project.owner_id === currentUser.id;
};

const filteredList = () => {
  return projects.value.filter((project) => {
    return project.name.toLowerCase().includes(input.value.toLowerCase());
  });
};

// Delete project
const projectToDelete: Ref<string | null> = ref(null);

const deleteProject = () => {
  const id: any = projectToDelete.value;

  API.deleteProject(currentUser.id, id, sessionToken)
    .then(() => {
      projects.value = projects.value.filter((project) => project.id !== id);

      toast({ title: "Project deleted successfully!" });
    })
    .catch((_error) => {
      toast({
        variant: "destructive",
        title: "Uh oh! Something went wrong.",
        description: "Failed to delete project. Please try again.",
      });
    });
};

// Search functionality
let input: Ref<string> = ref("");

// Create project
const projectName: Ref<string> = ref("");

const createProject = async () => {
  isUploading.value = true;

  // Firstly creates the project
  // then uploads the images to
  // the newly created project
  try {
    const createResponse = await API.createProject(
      currentUser.id,
      sessionToken,
      projectName.value,
    );

    const newProject: Project = createResponse.data;

    await uploadImages(newProject.id, files.value);
  } catch (_error) {
    isUploading.value = false;

    toast({
      variant: "destructive",
      title: "Uh oh! Something went wrong.",
      description: "Failed to create project. Please try again.",
    });
  } finally {
    files.value = [];
    previewURLs.value = [];
    projectName.value = "";
  }

  isUploading.value = false;
};

const uploadImages = async (projectId: string, filesToUpload: File[]) => {
  const formData = new FormData();

  let index = 0;
  filesToUpload.forEach((file) => {
    formData.append(`images[${index}]`, file);
    index++;
  });

  try {
    await API.uploadImages(currentUser.id, projectId, sessionToken, formData);
    navigateToProject(projectId);
  } catch (_error) {
    toast({
      variant: "destructive",
      title: "Uh oh! Something went wrong.",
      description: "Failed to upload images. Please try again.",
    });
  }
};

// Drag and drop | uploads functionalities
const isDragging: Ref<boolean> = ref(false);
const isUploading: Ref<boolean> = ref(false);

const files: Ref<File[]> = ref([]);
const previewURLs: Ref<string[]> = ref([]);
const fileInput: any = ref(null);

const handleDragLeave = (e: any) => {
  const rect = e.currentTarget.getBoundingClientRect();
  const x = e.clientX;
  const y = e.clientY;

  if (x <= rect.left || x >= rect.right || y <= rect.top || y >= rect.bottom) {
    isDragging.value = false;
  }
};

const handleDrop = async (e: any) => {
  isDragging.value = false;

  const newFiles = await validateFiles(e.dataTransfer.files);
  if (newFiles.length) {
    files.value = [...files.value, ...newFiles];
    await createPreviews(newFiles);
  }
};

const handleFileSelect = async (e: any) => {
  const newFiles = await validateFiles(e.target.files);

  if (newFiles.length) {
    files.value = [...files.value, ...newFiles];
    await createPreviews(newFiles);
  }

  e.target.value = "";
};

const createPreviews = async (newFiles: File[]) => {
  for (const file of newFiles) {
    const url = URL.createObjectURL(file);
    previewURLs.value.push(url);
  }
};

// TODO: Also validate this on the backend
// size will be proportional to the user's type
const MAX_IMAGE_SIZE = 5 * 1024 * 1024; // 5 MiB
const MAX_IMAGE_SIZE_STRING = "5 MiB";

const validateFiles = async (files: File[]) => {
  const validFiles = [];

  for (const file of Array.from(files)) {
    const isZipType = file.type === "application/zip";
    const isZipExtension = file.name.toLowerCase().endsWith(".zip");

    const isImageType = file.type.startsWith("image/");

    if (isZipType || isZipExtension) {
      try {
        const zip = new JSZip();
        const zipContent = await zip.loadAsync(file);

        for (const filename in zipContent.files) {
          const zipEntry = zipContent.files[filename];

          if (!zipEntry.dir && /\.(jpg|jpeg|png|gif|webp)$/i.test(filename)) {
            const blob = await zipEntry.async("blob");
            const imageFile = new File([blob], filename, {
              // @ts-ignore
              type: `image/${filename.split(".").pop().toLowerCase()}`,
            });

            if (imageFile.size <= MAX_IMAGE_SIZE) {
              validFiles.push(imageFile);
            } else {
              toast({
                variant: "destructive",
                title: "Image is too large.",
                description: `Max size is ${MAX_IMAGE_SIZE_STRING}. File ${imageFile.name} weighs ${imageFile.size} bytes.`,
              });
            }
          }
        }
      } catch (error) {
        toast({
          variant: "destructive",
          title: "Failed to read ZIP file.",
          description: "Please make sure the file contains images only.",
        });
      }
    } else if (isImageType) {
      if (file.size <= MAX_IMAGE_SIZE) {
        validFiles.push(file);
      } else {
        toast({
          variant: "destructive",
          title: "Image is too large.",
          description: `Max size is ${MAX_IMAGE_SIZE_STRING}. File ${file.name} weighs ${file.size} bytes.`,
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

const removePreview = (index: number) => {
  if (previewURLs.value[index]) {
    URL.revokeObjectURL(previewURLs.value[index]);
  }

  files.value.splice(index, 1);
  previewURLs.value.splice(index, 1);
};

// Helpers
const navigateToProject = (projectId: string) => {
  router.push(`/projects/${projectId}`);
};

const buildAuthedImageURL = (imageId: string, projectId: string) => {
  const baseURL = import.meta.env.VITE_API_URL + "/api/v1";
  return `${baseURL}/users/${currentUser.id}/projects/${projectId}/${imageId}`;
};

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString("pt-PT", {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
  });
};
</script>
