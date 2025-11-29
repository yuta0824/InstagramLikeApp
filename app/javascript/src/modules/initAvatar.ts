import { updateAvatar } from "../api/updateAvatar";
import i18n from "../i18n";

export const initAvatar = () => {
  const fileInput =
    document.querySelector<HTMLInputElement>("#js-avatar-input");
  const image = document.querySelector<HTMLImageElement>("#js-avatar-image");
  if (!fileInput || !image) return;

  const confirmChange = i18n.t("javascript.confirm.change_avatar");

  fileInput.addEventListener("change", async (e) => {
    const target = e.target as HTMLInputElement;
    const file = target.files?.[0];
    if (!file) return;

    const confirmed = confirm(confirmChange);
    if (confirmed) {
      try {
        const { avatar_url: avatarUrl } = await updateAvatar(file);
        image.src = avatarUrl;
        target.value = "";
      } catch (error) {
        console.error(error);
        target.value = "";
      }
    } else {
      target.value = "";
    }
  });
};
