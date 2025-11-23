import { CreateLikeResponse } from "../types/api";
import { getCsrfToken } from "../utils/getCsrfToken";

export const createLike = async (
  postId: string
): Promise<CreateLikeResponse> => {
  const csrfToken = getCsrfToken();
  const requestOptions: RequestInit = {
    method: "POST",
    headers: {
      "X-CSRF-Token": csrfToken,
    },
  };
  const response = await fetch(`/api/posts/${postId}/like`, requestOptions);
  if (!response.ok) {
    throw new Error(`レスポンスステータス: (${response.status})`);
  }
  return response.json();
};
