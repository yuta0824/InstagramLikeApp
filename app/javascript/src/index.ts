import { initAvatar } from "./modules/initAvatar";
import { initFlash } from "./modules/initFlash";

document.addEventListener("turbo:load", () => {
  initAvatar();
  initFlash();
});

document.addEventListener("turbo:render", () => {
  initFlash();
});
