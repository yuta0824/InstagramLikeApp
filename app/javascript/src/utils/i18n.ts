import { I18n } from "i18n-js";
import translations from "../../locales.json";

const i18n = new I18n(translations);
const locale =
  document.body.dataset.locale || navigator.language.split("-")[0] || "en";
i18n.locale = locale;
i18n.defaultLocale = "en";
i18n.enableFallback = true;

export default i18n;
