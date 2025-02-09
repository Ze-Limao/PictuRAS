import axios from "axios";
import type { AxiosInstance } from "axios";

const API_URL = import.meta.env.VITE_API_URL;

export const API: AxiosInstance = axios.create({
  baseURL: API_URL + "/api",
  responseType: "json",
  headers: {
    "Content-Type": "application/json",
  },
});
