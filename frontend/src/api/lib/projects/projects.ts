import { API } from "../api";

/// Projects

export async function getUserProjects(userId: string, token: string) {
  const response = await API.get(`/v1/users/${userId}/projects`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.data;
}

export async function getProject(
  userId: string,
  projectId: string,
  token: string,
) {
  const response = await API.get(`/v1/users/${userId}/projects/${projectId}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.data;
}

export async function createProject(
  userId: string,
  token: string,
  projectName?: string,
) {
  const response = await API.post(
    `v1/users/${userId}/projects`,
    {
      project: {
        name: projectName,
      },
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  return response.data;
}

export async function updateProject(
  userId: string,
  projectId: string,
  data: any,
  token: string,
) {
  const response = await API.put(
    `/v1/users/${userId}/projects/${projectId}`,
    {
      project: {
        ...data,
      },
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  return response.data;
}

export async function deleteProject(
  userId: string,
  projectId: string,
  token: string,
) {
  const response = await API.delete(
    `/v1/users/${userId}/projects/${projectId}`,
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  return response.data;
}

/// Images

export async function uploadImages(
  userId: string,
  projectId: string,
  token: string,
  formData: FormData,
) {
  const response = await API.post(
    `/v1/users/${userId}/projects/${projectId}/upload`,
    formData,
    {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "multipart/form-data",
      },
    },
  );

  return response.data;
}

export async function deleteImage(
  userId: string,
  projectId: string,
  imageId: string,
  token: string,
) {
  const response = await API.delete(
    `/v1/users/${userId}/projects/${projectId}/${imageId}`,
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  return response.data;
}

/// Share
export async function inviteUser(
  userId: string,
  projectId: string,
  email: string,
  token: string,
) {
  const response = await API.post(
    `/v1/users/${userId}/projects/${projectId}/invite`,
    {
      email: email,
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  return response.data;
}

export async function revokeUser(
  userId: string,
  projectId: string,
  email: string,
  token: string,
) {
  const response = await API.put(
    `/v1/users/${userId}/projects/${projectId}/revoke`,
    {
      email: email,
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  return response.data;
}

/// Tools

export async function getAvailableTools(userId: string, token: string) {
  const response = await API.get(`/v1/users/${userId}/tools`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.data;
}

export async function executePipeline(
  userId: string,
  projectId: string,
  tools: any,
  token: string,
) {
  const response = await API.post(
    `/v1/users/${userId}/projects/${projectId}/process`,
    {
      tools,
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  return response.data;
}
