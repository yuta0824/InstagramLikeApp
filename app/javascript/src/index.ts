import { initFlash } from "./modules/initFlash";

document.addEventListener("turbo:load", () => {
  initFlash();
});

document.addEventListener("turbo:render", () => {
  initFlash();
});
