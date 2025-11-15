import { createLike } from "../api/createLike";
import { deleteLike } from "../api/deleteLike";

export const initLikeButton = () => {
  const buttons = document.querySelectorAll<HTMLElement>(".js-like-button");
  if (buttons.length === 0) return;

  buttons.forEach((button) => {
    button.addEventListener("click", async () => {
      const postId = getPostId(button);
      if (!postId) return;

      const hasLiked = button.hasAttribute("data-liked");
      if (hasLiked) {
        await handleRemoveLike(postId, button);
      } else {
        await handleAddLike(postId, button);
      }
    });
  });
};

const getPostId = (element: HTMLElement): string | undefined => {
  const postElement = element.closest<HTMLElement>("[data-post-id]");
  return postElement?.dataset.postId;
};

const handleAddLike = async (
  postId: string,
  button: HTMLElement
): Promise<void> => {
  try {
    const response = await createLike(postId);
    if (response.isLiked) {
      button.setAttribute("data-liked", "true");
    }
  } catch (error) {
    console.error("いいね処理に失敗しました", error);
  }
};

const handleRemoveLike = async (
  postId: string,
  button: HTMLElement
): Promise<void> => {
  try {
    const response = await deleteLike(postId);
    if (!response.isLiked) {
      button.removeAttribute("data-liked");
    }
  } catch (error) {
    console.error("いいね解除に失敗しました", error);
  }
};
