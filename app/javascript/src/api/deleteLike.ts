import { paths } from "../types/generated/openapi";
import { getCsrfToken } from "../utils/getCsrfToken";

type DeleteLikeResponse =
  paths["/api/posts/{post_id}/like"]["delete"]["responses"][200]["content"]["application/json"];

export const deleteLike = async (
  postId: string
): Promise<DeleteLikeResponse> => {
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
