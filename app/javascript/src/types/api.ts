import type { paths } from "./generated/openapi";

// Comment API
export type CommentRequestBody =
  paths["/api/posts/{post_id}/comment"]["post"]["requestBody"]["content"]["application/json"];

export type CommentResponse =
  paths["/api/posts/{post_id}/comment"]["post"]["responses"][200]["content"]["application/json"];

// Like API
export type CreateLikeResponse =
  paths["/api/posts/{post_id}/like"]["post"]["responses"][200]["content"]["application/json"];

export type DeleteLikeResponse =
  paths["/api/posts/{post_id}/like"]["delete"]["responses"][200]["content"]["application/json"];

// Avatar API
export type AvatarResponse =
  paths["/api/avatar"]["patch"]["responses"][200]["content"]["application/json"];

// User API
export type UsersResponse =
  paths["/api/users"]["get"]["responses"][200]["content"]["application/json"];
