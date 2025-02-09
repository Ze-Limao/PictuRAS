import { API } from "../api";

export async function login(email: string, password: string) {
  const response = await API.post("/v1/login", {
    email,
    password,
  });

  return response.data;
}

export async function register(
  name: string,
  email: string,
  password: string,
  type: string,
) {
  const response = await API.post("/v1/register", {
    user: {
      name,
      email,
      password,
      type,
    },
  });

  return response.data;
}

export async function getCurrentUser(token: string) {
  const response = await API.get("/v1/me", {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.data.data;
}

export async function updateCurrentUser(token: string, data: any) {
  const response = await API.put(
    "/v1/me",
    {
      user: data,
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  return response.data;
}
