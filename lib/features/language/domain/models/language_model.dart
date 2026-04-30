// LanguageModel
//
// Lightweight data holder describing a single supported app language.
// Used by the LocalizationController to drive the language selection UI
// and by the GetX translation pipeline to resolve the active locale.
//
// Fields:
//   imageUrl     – asset path of the flag/icon shown in the picker
//   languageName – English/canonical display name (e.g. "Spanish")
//   nativeName   – Name written in the language's own script (e.g. "Español")
//                  Optional; falls back to languageName when null.
//   countryCode  – ISO country code used for the Locale (e.g. "ES")
//   languageCode – ISO language code used for the Locale (e.g. "es")
class LanguageModel {
  String? imageUrl;
  String? languageName;
  String? nativeName;
  String? languageCode;
  String? countryCode;

  LanguageModel({
    this.imageUrl,
    this.languageName,
    this.nativeName,
    this.countryCode,
    this.languageCode,
  });
}
