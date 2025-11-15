import { getCsrfToken } from "../utils/getCsrfToken";

interface LikeResponse {
  isLiked: boolean;
}

export const deleteLike = async (postId: string): Promise<LikeResponse> => {
  const csrfToken = getCsrfToken();
  const requestOptions: RequestInit = {
    method: "DELETE",
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
