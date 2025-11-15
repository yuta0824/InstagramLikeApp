import { getCsrfToken } from "../utils/getCsrfToken";

interface LikeResponse {
  is_liked: boolean;
}

export const createLike = async (postId: string): Promise<LikeResponse> => {
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
