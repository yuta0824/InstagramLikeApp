import { getCsrfToken } from "../utils/getCsrfToken";

type AvatarResponse = {
  avatar_url: string;
};

export const updateAvatar = async (file: File): Promise<AvatarResponse> => {
  const csrfToken = getCsrfToken();
  const formData = new FormData();
  formData.append("avatar", file);
  const requestOptions: RequestInit = {
    method: "PATCH",
    headers: {
      ...(csrfToken ? { "X-CSRF-Token": csrfToken } : {}),
      Accept: "application/json",
      "X-Requested-With": "XMLHttpRequest",
    },
    body: formData,
    credentials: "same-origin",
  };

  const response = await fetch("/api/avatar", requestOptions);
  if (!response.ok) {
    throw new Error(`レスポンスステータス: (${response.status})`);
  }
  return response.json();
};
