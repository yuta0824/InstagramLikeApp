import { initAvatar } from "./modules/initAvatar";
import { initFilePond } from "./modules/initFilePond";
import { initFlash } from "./modules/initFlash";
import { initLikeButton } from "./modules/initLike";

document.addEventListener("turbo:load", () => {
  initFilePond();
  initAvatar();
  initFlash();
  initLikeButton();
});

document.addEventListener("turbo:render", () => {
  initFlash();
});
