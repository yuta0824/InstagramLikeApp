import { updateAvatar } from "../api/updateAvatar";

export const initAvatar = () => {
  const fileInput =
    document.querySelector<HTMLInputElement>("#js-avatar-input");
  const image = document.querySelector<HTMLImageElement>("#js-avatar-image");
  if (!fileInput || !image) return;

  fileInput.addEventListener("change", async (e) => {
    const target = e.target as HTMLInputElement;
    const file = target.files?.[0];
    if (!file) return;

    const confirmed = confirm("アバター画像を変更しますか？");
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
