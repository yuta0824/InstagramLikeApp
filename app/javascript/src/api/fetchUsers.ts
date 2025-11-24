import { AccountsResponse } from "../types/api";

export const fetchUsers = async (): Promise<AccountsResponse> => {
  const response = await fetch("/api/accounts");
  if (!response.ok) {
    throw new Error(`レスポンスステータス: (${response.status})`);
  }
  return response.json();
};
