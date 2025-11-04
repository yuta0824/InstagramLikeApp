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
      postAvatar(file);
    } else {
      target.value = "";
    }
  });
};

const postAvatar = (file) => {
  // TODO: AJAX実装
  console.log(file);
};
