import { AvatarResponse } from "../types/api";
import { getCsrfToken } from "../utils/getCsrfToken";

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

  const response = await fetch("/api/me/avatar", requestOptions);
  if (!response.ok) {
    throw new Error(`レスポンスステータス: (${response.status})`);
  }
  return response.json();
};
