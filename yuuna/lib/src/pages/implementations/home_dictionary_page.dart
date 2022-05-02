import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:spaces/spaces.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';
import 'package:yuuna/utils.dart';

/// The body content for the Dictionary tab in the main menu.
class HomeDictionaryPage extends BaseTabPage {
  /// Create an instance of this page.
  const HomeDictionaryPage({Key? key}) : super(key: key);

  @override
  BaseTabPageState<BaseTabPage> createState() => _HomeDictionaryPageState();
}

class _HomeDictionaryPageState<T extends BaseTabPage> extends BaseTabPageState {
  @override
  MediaType get mediaType => DictionaryMediaType.instance;

  @override
  bool get shouldPlaceholderBeShown => true;

  String get searchLabel => appModel.translate('search');

  final FloatingSearchBarController _controller = FloatingSearchBarController();

  DictionarySearchResult? _result;

  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      if (shouldPlaceholderBeShown) buildPlaceholder() else Container(),
      buildFloatingSearchBar(),
    ]);
  }

  JidoujishoTextSelectionControls get selectionControls =>
      JidoujishoTextSelectionControls(
        customAction: (selection) => _controller.query = selection,
        customActionLabel: searchLabel,
      );

  /// The search bar to show at the topmost of the tab body. When selected,
  /// [buildSearchBarBody] will take the place of the remainder tab body, or
  /// the elements below the search bar when unselected.
  @override
  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      controller: _controller,
      builder: (context, transition) {
        if (_result == null) {
          return const SizedBox.shrink();
        }
        return SingleChildScrollView(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              List<int> indexesByPair = _result!.mapping[index];
              return buildWordSection(indexesByPair);
            },
            itemCount: _result?.mapping.length,
          ),
        );
      },
      borderRadius: BorderRadius.zero,
      elevation: 0,
      backgroundColor:
          appModel.isDarkMode ? theme.cardColor : const Color(0xFFE5E5E5),
      backdropColor: appModel.isDarkMode
          ? Colors.black.withOpacity(0.95)
          : Colors.white.withOpacity(0.95),
      accentColor: theme.colorScheme.primary,
      scrollPadding: const EdgeInsets.only(top: 6, bottom: 56),
      transitionDuration: Duration.zero,
      margins: const EdgeInsets.symmetric(horizontal: 6),
      width: double.maxFinite,
      debounceDelay: const Duration(milliseconds: 500),
      transition: SlideFadeFloatingSearchBarTransition(),
      automaticallyImplyBackButton: false,
      progress: _isSearching,
      onQueryChanged: (query) async {
        _isSearching = true;
        setState(() {});

        try {
          _result = await appModel.getDictionarySearchEntries(query);
        } finally {
          _isSearching = false;
          setState(() {});
        }
      },
    );
  }

  Widget buildWordSection(List<int> indexesByPair) {
    List<DictionaryEntry> entries = indexesByPair
        .map((index) => appModel.getEntryFromIndex(index))
        .toList();
    String word = entries.first.word;
    String reading = entries.first.reading;

    Set<DictionaryPair> pairs = {};

    for (DictionaryEntry entry in entries) {
      for (String tag in entry.wordTags) {
        pairs.add(DictionaryPair(word: entry.dictionaryName, reading: tag));
      }
    }

    List<Widget> tags = [];
    tags.addAll(pairs.map((pair) {
      if (pair.reading.isNotEmpty) {
        return JidoujishoTag(
          text: pair.reading,
          backgroundColor: Colors.red.shade900,
        );
      } else {
        return const SizedBox.shrink();
      }
    }).toList());

    return Card(
      color: appModel.isDarkMode
          ? theme.cardColor.withOpacity(0.75)
          : Colors.grey.shade200.withOpacity(0.55),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: Spacing.of(context).insets.all.normal,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            const Space.small(),
            SelectableText(
              word,
              style:
                  textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              selectionControls: selectionControls,
            ),
            SelectableText(
              reading,
              style: textTheme.titleMedium,
              selectionControls: selectionControls,
            ),
            const Space.normal(),
            Wrap(children: tags),
            const Space.normal(),
            Padding(
              padding: Spacing.of(context).insets.horizontal.small,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: indexesByPair.length,
                itemBuilder: (context, index) {
                  return buildEntrySection(indexesByPair[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEntrySection(int index) {
    DictionaryEntry entry = appModel.getEntryFromIndex(index);

    List<Widget> tags = [];
    tags.add(
      JidoujishoTag(
        text: entry.dictionaryName,
        backgroundColor: Colors.red.shade900,
      ),
    );
    tags.addAll(entry.meaningTags.map((tag) {
      if (tag.isNotEmpty) {
        return JidoujishoTag(
          text: tag,
          backgroundColor: Colors.red.shade900.withOpacity(0.5),
        );
      } else {
        return const SizedBox.shrink();
      }
    }).toList());

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        const Space.small(),
        Wrap(children: tags),
        Padding(
          padding: EdgeInsets.only(
            top: Spacing.of(context).spaces.small,
            bottom: Spacing.of(context).spaces.normal,
            left: Spacing.of(context).spaces.normal,
          ),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: entry.meanings.length,
            itemBuilder: (context, index) {
              if (entry.meanings.length != 1) {
                return SelectableText('• ${entry.meanings[index]}');
              } else {
                return SelectableText(
                  entry.meanings.first,
                  selectionControls: selectionControls,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

// class SelectText extends StatefulWidget {
//   const SelectText({
//     required this.onChangeText,
//     Key? key,
//   }) : super(key: key);

//   final void Function(String) onChangeText;

//   @override
//   State<StatefulWidget> createState() => _SelectTextState();
// }

// class _SelectTextState extends State<SelectText> {
//   final String loremIpsum =
//       'ウクライナ情勢をめぐってロシアのプーチン大統領は27日「外部から進行中の作戦に干渉しようとするなら、電撃的な対抗措置をとる。そのための手段はすべてそろっている」などと述べました。ウクライナへの軍事支援を強化する欧米側を強くけん制した形です。 ロシアのプーチン大統領は27日、サンクトペテルブルクで演説し「外部から進行中の作戦に干渉しようとするなら、容認できない戦略的脅威であり、電撃的な対抗措置をとる。そのための手段はすべてそろっていて、必要であれば使用する」などと述べました。プーチン大統領はウクライナへの軍事侵攻を始めた直後に「現代のロシアは、ソビエトが崩壊したあとも、最強の核保有国の1つだ」と核大国であることを誇示しています。 今回の発言について欧米メディアなどは、ロシアが核兵器の使用も辞さない構えを示したという見方も伝えていて、ウクライナへの軍事支援を強化する欧米側を強くけん制した形です。 一方、アメリカ国防総省のカービー報道官は27日の記者会見で核兵器をめぐるこのところのロシア側の発言について「核の対立が起こるのではないかと不安にさせるのは無責任だ」と批判したうえで「われわれの核の戦略的な抑止態勢を変えさせるようなことは引き続き何も見当たらない。国土や同盟国などを防衛する能力に自信を持っている」と述べました。';
//   int selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         String before = loremIpsum.substring(0, selectedIndex);
//         String during = loremIpsum[selectedIndex];
//         String after =
//             loremIpsum.substring(min(selectedIndex + 1, loremIpsum.length - 1));

//         final textPainter = TextPainter(
//           text: TextSpan(children: [
//             TextSpan(text: before),
//             TextSpan(text: during, style: const TextStyle(color: Colors.red)),
//             TextSpan(text: after),
//           ]),
//           textDirection: TextDirection.ltr,
//         );

//         final width = constraints.maxWidth;
//         textPainter.layout(
//           minWidth: 22,
//           maxWidth: width,
//         );
//         const double height = 250;
//         return Container(
//           width: width,
//           height: height,
//           color: Colors.black,
//           child: GestureDetector(
//             onHorizontalDragUpdate: (details) {
//               TextPosition selection =
//                   textPainter.getPositionForOffset(details.localPosition);

//               selectedIndex = selection.offset;

//               widget.onChangeText(loremIpsum.substring(max(0, selectedIndex),
//                   min(selectedIndex + 20, loremIpsum.length - 1)));
//               setState(() {});
//             },
//             onVerticalDragUpdate: (details) {
//               TextPosition selection =
//                   textPainter.getPositionForOffset(details.localPosition);

//               selectedIndex = selection.offset;

//               widget.onChangeText(loremIpsum.substring(max(0, selectedIndex),
//                   min(selectedIndex + 20, loremIpsum.length - 1)));
//               setState(() {});
//             },
//             onTapDown: (details) {
//               TextPosition selection =
//                   textPainter.getPositionForOffset(details.localPosition);

//               widget.onChangeText(loremIpsum.substring(max(0, selection.offset),
//                   min(selection.offset + 20, loremIpsum.length - 1)));
//               selectedIndex = selection.offset;

//               setState(() {});
//             },
//             child: CustomPaint(
//               size: Size(width, height), // Parent width, text height
//               painter: TextCustomPainter(textPainter),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class TextCustomPainter extends CustomPainter {
//   TextPainter textPainter;

//   TextCustomPainter(this.textPainter, {Listenable? repaint})
//       : super(repaint: repaint);

//   @override
//   void paint(Canvas canvas, Size size) {
//     textPainter.paint(canvas, Offset(0, 0));
//   }

//   @override
//   bool shouldRepaint(CustomPainter old) {
//     return false;
//   }
// }
