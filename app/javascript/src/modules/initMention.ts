import Tribute, { type TributeItem } from "tributejs";
import { fetchUsers } from "../api/fetchUsers";
import type { UsersResponse } from "../types/api";

interface TributeValue {
  key: string;
  value: string;
  avatar: string;
}

export const initMention = async () => {
  const commentTextareas =
    document.querySelector<HTMLTextAreaElement>("#js-mention-input");
  if (!commentTextareas) return;

  await initTribute(commentTextareas);
};

const initTribute = async (commentTextareas: HTMLTextAreaElement) => {
  let users: UsersResponse = [];

  try {
    users = await fetchUsers();
  } catch (error) {
    console.error(error);
    users = [];
  }

  const tributeValues: TributeValue[] = users.map((user) => ({
    key: user.name,
    value: user.name,
    avatar: user.avatarUrl,
  }));

  const tribute = new Tribute<TributeValue>({
    values: tributeValues,
    menuItemTemplate: (item: TributeItem<TributeValue>) => {
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
