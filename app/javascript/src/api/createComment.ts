import { CommentRequestBody, CommentResponse } from "../types/api";
import { getCsrfToken } from "../utils/getCsrfToken";

export const createComment = async (
  postId: string,
  content: string
): Promise<CommentResponse> => {
  const requestBody: CommentRequestBody = {
    comment: { content },
  };

  const response = await fetch(`/api/posts/${postId}/comment`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": getCsrfToken(),
    },
    body: JSON.stringify(requestBody),
  });

  if (!response.ok) {
    throw new Error(`レスポンスステータス: (${response.status})`);
  }

  return response.json();
};
