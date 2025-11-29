import { createComment } from "../api/createComment";
import { CommentResponse } from "../types/api";
import { escapeHtml } from "../utils/escapeHtml";

export const initCommentForm = () => {
  const form = document.querySelector<HTMLElement>("#js-comment-form");
  if (!form) return;

  const field = form.querySelector<HTMLTextAreaElement>("textarea");
  if (!field) return;

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const postId = getPostId();
    const content = field.value.trim();
    if (!postId || !content) return;

    try {
      const comment = await createComment(postId, content);
      appendComment(comment);
      field.value = "";
    } catch (error) {
      console.error(error);
    }
  });
};

const getPostId = (): string | null => {
  const element = document.querySelector<HTMLElement>("[data-post-id]");
  if (!element) return null;
  return element.dataset.postId ?? null;
};

const appendComment = (comment: CommentResponse) => {
  if (!comment) return;

  const commentContainer = document.querySelector("#js-comment-container");
  if (!commentContainer) return;

  const commentHtml = `
    <div class="flex gap-2">
      <img class="size-8 rounded-full" src="${escapeHtml(
        comment.userAvatar
      )}" alt="User avatar">
      <div class="space-y-1">
        <p class="text-base">${escapeHtml(comment.userName)}</p>
        <p class="text-sm text-brandGray whitespace-pre-line">${escapeHtml(
          comment.content
        )}</p>
      </div>
    </div>
  `;

  commentContainer.insertAdjacentHTML("beforeend", commentHtml);
};
