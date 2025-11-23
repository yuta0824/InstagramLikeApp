import { UsersResponse } from "../types/api";

export const fetchUsers = async (): Promise<UsersResponse> => {
  const response = await fetch("/api/accounts");
  if (!response.ok) {
    throw new Error(`レスポンスステータス: (${response.status})`);
  }
  return response.json();
};
