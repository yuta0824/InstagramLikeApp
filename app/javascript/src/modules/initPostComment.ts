import { createComment } from "../api/createComment";
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
      const comments = await createComment(postId, content);
      const lastComment = comments[comments.length - 1];
      appendComment(lastComment);
      field.value = "";
    } catch (error) {
      console.error(error);
      alert("コメントの投稿に失敗しました");
    }
  });
};

const getPostId = (): string | null => {
  const element = document.querySelector<HTMLElement>("[data-post-id]");
  if (!element) return null;
  return element.dataset.postId ?? null;
};

const appendComment = (comment) => {
  if (!comment) return;

  const commentContainer = document.querySelector("#js-comment-container");
  if (!commentContainer) return;

  const commentHtml = `
    <div class="flex gap-2 items-center">
      <img class="size-8 rounded-full" src="${escapeHtml(
        comment.userAvatar
      )}" alt="User avatar">
      <div class="space-y-1">
        <p class="text-base">${escapeHtml(comment.userName)}</p>
        <p class="text-sm text-brandGray">${escapeHtml(comment.content)}</p>
      </div>
    </div>
  `;

  commentContainer.insertAdjacentHTML("beforeend", commentHtml);
};
