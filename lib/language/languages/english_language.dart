import 'package:chisachan/util/reading_direction.dart';
import 'package:chisachan/language/language.dart';
import 'package:chisachan/util/reg_exp.dart';

class EnglishLanguage extends Language {
  EnglishLanguage()
      : super(
          languageName: "English",
          languageCode: "en",
          countryCode: "US",
          readingDirection: ReadingDirection.horizontalLTR,
        );

  @override
  Future<void> initialiseLanguage() async {}

  @override
  String getRootForm(String word) {
    return word;
  }

  @override
  List<String> textToWords(String text) {
    return text.splitWithDelim(RegExp(r" "));
  }

  @override
  String wordFromIndex(String text, int index) {
    List<String> words = textToWords(text);

    List<String> wordTape = [];
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      for (int j = 0; j < word.length; j++) {
        wordTape.add(word);
      }
    }

    String word = wordTape[index];
    return word;
  }
}
