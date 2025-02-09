export interface User {
  id: string;
  name: string;
  email: string;
  type: UserType;
}

export enum UserType {
  NORMAL = "normal",
  PREMIUM = "premium",
}

export interface Project {
  id: string;
  name: string;
  state: ProjectState;
  completion: number;
  owner_id: string;
  created_at: string;

  guest_count: number;
  guests?: Guest[];

  image_count: number;
  images?: Image[];
  thumbnail?: string;

  tools?: PipelineTool[];
}

export enum ProjectState {
  IDLE = "idle",
  PROCESSING = "processing",
  CANCELED = "canceled",
  FAILED = "failed",
}

interface Guest {
  id?: string;
  email: string;
}

interface Image {
  id: string;
  type: ImageType;
}

export enum ImageType {
  INITIAL = "initial",
  FINAL = "final",
}

export interface AvailableTool {
  description: string;
  display_name: string;
  parameters: AvailableToolParameter[];
  procedure: string;
}

export interface AvailableToolParameter {
  description: string;
  display_name: string;
  name: string;
  type: AvailableToolParameterType;
  default: any;
  min?: any;
  max?: any;
}

export enum AvailableToolParameterType {
  NUMBER = "number",
  COLOR = "color",
  SLIDER = "slider",
}

export interface PipelineTool {
  procedure: string;
  position: number;
  parameters: { [key: string]: any };
}
