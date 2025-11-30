import { I18n } from "i18n-js";
import translations from "../../locales.json";

const i18n = new I18n(translations);

Object.defineProperty(i18n, "locale", {
  get() {
    return (
      document.body.dataset.locale || navigator.language.split("-")[0] || "en"
    );
  },
  set(value) {
    document.body.dataset.locale = value;
  },
});

i18n.defaultLocale = "en";
i18n.enableFallback = true;

export default i18n;
