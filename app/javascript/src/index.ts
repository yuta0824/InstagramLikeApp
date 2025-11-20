import { initAvatar } from "./modules/initAvatar";
import { initFilePond } from "./modules/initFilePond";
import { initFlash } from "./modules/initFlash";
import { initLikeButton } from "./modules/initLike";
import { initMention } from "./modules/initMention";
import { initCommentForm } from "./modules/initPostComment";

document.addEventListener("turbo:load", () => {
  initMention();
  initFilePond();
  initAvatar();
  initCommentForm();
  initFlash();
  initLikeButton();
});

document.addEventListener("turbo:render", () => {
  initFlash();
});
