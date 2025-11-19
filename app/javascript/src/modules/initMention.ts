import Tribute from "tributejs";

export const initMention = () => {
  const commentTextareas =
    document.querySelector<HTMLTextAreaElement>("#js-mention-input");
  if (!commentTextareas) return;

  initTribute(commentTextareas);
};

const initTribute = (commentTextareas) => {
  const tribute = new Tribute({
    // TODO: APIでユーザー情報を取得する
    values: [
      {
        key: "Phil Heartman",
        value: "PhilHeartman",
        avatar: "/assets/icon_avatar1.webp",
      },
      {
        key: "Gordon Ramsey",
        value: "GordonRamsey",
        avatar: "/assets/icon_avatar2.webp",
      },
    ],
    menuItemTemplate: function (item: any) {
      return `
      <div class="flex items-center gap-2 p-2">
        <img src="${item.original.avatar}" class="size-6 rounded-full" alt="">
        <span>${item.string}</span>
      </div>
    `;
    },
  });
  tribute.attach(commentTextareas);
};
