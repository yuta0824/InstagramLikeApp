import type { paths } from "./generated/openapi";

// Comment API
export type CommentRequestBody =
  paths["/api/posts/{post_id}/comment"]["post"]["requestBody"]["content"]["application/json"];

export type CommentResponse =
  paths["/api/posts/{post_id}/comment"]["post"]["responses"][200]["content"]["application/json"];
