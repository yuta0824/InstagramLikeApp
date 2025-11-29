import { createRelationship } from "../api/createRelationship";
import { deleteRelationship } from "../api/deleteRelationship";
import i18n from "../i18n";

export const initFollowButton = () => {
  const button = document.querySelector<HTMLButtonElement>("#js-follow-button");
  if (!button) return;

  const confirmUnfollow = i18n.t("javascript.confirm.unfollow");
  const textFollow = i18n.t("javascript.button.follow");
  const textFollowing = i18n.t("javascript.button.following");

  button.addEventListener("click", async () => {
    const shouldFollow = button.dataset.following === "false";
    const userIdStr = button.dataset.userId;
    if (!userIdStr) return;

    try {
      if (shouldFollow) {
        const response = await createRelationship(userIdStr);
        if (response.status === 201) {
          increaseFollowCount();
          updateButtonBehavior(shouldFollow, button, textFollow, textFollowing);
        }
      } else {
        const confirmed = confirm(confirmUnfollow);
        if (confirmed) {
          const response = await deleteRelationship(userIdStr);
          if (response.status === 204) {
            decreaseFollowCount();
            updateButtonBehavior(shouldFollow, button, textFollow, textFollowing);
          }
        }
      }
    } catch (error) {
      console.error(error);
    }
  });
};

const updateButtonBehavior = (
  shouldFollow: boolean,
  button: HTMLButtonElement,
  textFollow: string,
  textFollowing: string
) => {
  const buttonText = button.querySelector<HTMLSpanElement>("span");
  if (!buttonText) return;

  if (shouldFollow) {
    button.dataset.following = "true";
    buttonText.textContent = textFollowing;
  } else {
    button.dataset.following = "false";
    buttonText.textContent = textFollow;
  }
};

const increaseFollowCount = () => updateFollowersCount(1);
const decreaseFollowCount = () => updateFollowersCount(-1);
const updateFollowersCount = (delta: number) => {
  const followersCountElement = document.querySelector<HTMLParagraphElement>(
    "#js-followers-count"
  );
  if (!followersCountElement) return;

  const currentCount = parseInt(followersCountElement.textContent || "0", 10);
  followersCountElement.textContent = (currentCount + delta).toString();
};
