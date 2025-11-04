export const initFlash = () => {
  const DELAY_MSEC = 4000;
  const flashElements = document.querySelectorAll<HTMLElement>(".js-flash");
  flashElements.forEach((flash) => {
    setTimeout(() => {
      fadeOut(flash);
    }, DELAY_MSEC);
  });
};

const fadeOut = (element: HTMLElement) => {
  const FADE_DURATION_MSEC = 300;
  element.style.transition = `opacity ${FADE_DURATION_MSEC}ms ease-out`;
  element.style.opacity = "0";
  setTimeout(() => element.remove(), FADE_DURATION_MSEC);
};
