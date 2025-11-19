import { initAvatar } from "./modules/initAvatar";
import { initFilePond } from "./modules/initFilePond";
import { initFlash } from "./modules/initFlash";
import { initLikeButton } from "./modules/initLike";
import { initMention } from "./modules/initMention";

document.addEventListener("turbo:load", () => {
  initMention();
  initFilePond();
  initAvatar();
  initFlash();
  initLikeButton();
});

document.addEventListener("turbo:render", () => {
  initFlash();
});
