export function initGuestLoginButton() {
  const guestLoginButton = document.querySelector("#js-guest-login-button");
  if (!guestLoginButton) return;

  guestLoginButton.addEventListener("click", () => {
    const emailField = document.querySelector(
      "#user_email"
    ) as HTMLInputElement;
    const passwordField = document.querySelector(
      "#user_password"
    ) as HTMLInputElement;

    if (emailField) emailField.value = "guest@example.com";
    if (passwordField) passwordField.value = "password";
  });
}
