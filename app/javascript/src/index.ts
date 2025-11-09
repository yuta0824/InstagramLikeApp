import { initAvatar } from "./modules/initAvatar";
import { initFilePond } from "./modules/initFilePond";
import { initFlash } from "./modules/initFlash";

document.addEventListener("turbo:load", () => {
  initFilePond();
  initAvatar();
  initFlash();
});

document.addEventListener("turbo:render", () => {
  initFlash();
});
