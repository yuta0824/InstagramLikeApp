import { getCsrfToken } from "../utils/getCsrfToken";

export const createComment = async (postId: string, content: string) => {
  const csrfToken = getCsrfToken();
  const requestOptions: RequestInit = {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken,
    },
    body: JSON.stringify({ comment: { content: content } }),
  };
  const response = await fetch(`/api/posts/${postId}/comment`, requestOptions);
  if (!response.ok) {
    throw new Error(`レスポンスステータス: (${response.status})`);
  }
  return response.json();
};
