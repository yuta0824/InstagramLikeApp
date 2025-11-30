import { getCsrfToken } from "../utils/getCsrfToken";

export const deleteRelationship = async (accountId: string) => {
  const csrfToken = getCsrfToken();
  const requestOptions: RequestInit = {
    method: "DELETE",
    headers: {
      "X-CSRF-Token": csrfToken,
    },
  };

  const response = await fetch(
    `/api/accounts/${accountId}/relationship`,
    requestOptions
  );

  if (!response.ok) {
    throw new Error(`レスポンスステータス: (${response.status})`);
  }

  return response;
};
