import { UsersResponse } from "../types/api";

export const fetchUsers = async (): Promise<UsersResponse> => {
  const response = await fetch("/api/users");
  if (!response.ok) {
    throw new Error(`レスポンスステータス: (${response.status})`);
  }
  return response.json();
};
