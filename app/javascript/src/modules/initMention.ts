import Tribute from "tributejs";

export const initMention = () => {
  const commentTextareas =
    document.querySelector<HTMLTextAreaElement>("#js-mention-input");
  if (!commentTextareas) return;

  const tribute = new Tribute({
    // TODO: APIでユーザー情報を取得する
    values: [
      { key: "@Phil Heartman", value: "pheartman" },
      { key: "@Gordon Ramsey", value: "gramsey" },
    ],
  });

  tribute.attach(commentTextareas);
};
