import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:yuuna/dictionary.dart';
import 'package:yuuna/media.dart';
import 'package:yuuna/pages.dart';

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

  final FloatingSearchBarController _controller = FloatingSearchBarController();

  List<DictionaryEntry> _entries = [];

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      if (shouldPlaceholderBeShown) buildPlaceholder() else Container(),
      buildFloatingSearchBar(),
    ]);
  }

  /// The search bar to show at the topmost of the tab body. When selected,
  /// [buildSearchBarBody] will take the place of the remainder tab body, or
  /// the elements below the search bar when unselected.
  @override
  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      controller: _controller,
      builder: (context, transition) {
        return SingleChildScrollView(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _entries.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return ClipRect(
                  child: ListTile(
                    title: SizedBox(
                      height: 250,
                      child: SelectText(onChangeText: (query) async {
                        _controller.query = query;
                      }),
                    ),
                  ),
                );
              } else {
                return ListTile(
                  title: Text(
                    '${_entries[i - 1].word}\n${_entries[i - 1].reading}\n${_entries[i - 1].meanings}\n',
                    textAlign: TextAlign.center,
                  ),
                );
              }
            },
          ),
        );
      },
      debounceDelay: const Duration(milliseconds: 50),
      onQueryChanged: (query) async {
        _entries = await appModel.getDictionarySearchEntries(query);
        setState(() {});
      },
      borderRadius: BorderRadius.zero,
      elevation: 0,
    );
  }
}

class SelectText extends StatefulWidget {
  const SelectText({
    required this.onChangeText,
    Key? key,
  }) : super(key: key);

  final void Function(String) onChangeText;

  @override
  State<StatefulWidget> createState() => _SelectTextState();
}

class _SelectTextState extends State<SelectText> {
  final String loremIpsum =
      'そして今、男は最大の罰を科されている。窓の外には凍てついた吹雪。森の大地を凍らせる極寒の夜。凍土の地に建てられた古城の一室は、だが優しく燃える暖炉の熱に守られている。そんなぬくもりの結界の中で、男は、ひとつの新しい生命を抱き上げていた。その、あまりにも小さな──儚いほどにちっぽけな身体には。覚悟していたほどの重さもない。手に掬い取った初雪のように、わずかに揺すっただけでも崩れてしまいそうな、危ういほどに繊細な手応え。  弱々しくも懸命に、眠りながらも体温を保ち、緩やかな呼吸に唇を震わせる。今はまだそれだけが限界の、ささやかな胸の鼓動。  「安心して、眠っていますね」  彼が赤子を抱き上げる様子を、母親は寝台に身を預けた姿勢のまま、微笑ましげに見守っている。  御産の憔悴からまだ立ち直れず、血色は優れないものの、それでも高貴な宝石を思わせる美貌は些かも衰えていない。なにより、疲弊による疲れをかき消すほどの至福の色が、優しい眼差しと微笑みを輝かしている。  「慣れてるはずの乳母たちでも、この子、むずがって泣くんです。こんなに大人しく抱かれているなんて初めて。──解ってるんですね。優しい人だから大丈夫、って」  「……」  男は返す言葉もなく、ただ呆然と、手の中の赤子とベッドの母親とを見比べる。  アイリスフィールの微笑みが、かつてこれほどに眩しく見えたことがあっただろうか。  もとより幸とは縁の薄い女である。誰一人として、彼女に幸福などという感情を与えようと思う者はいなかった。神の被造物たらぬ、人の手に因る人造物……ホムンクルスとして生まれた女には、それが当然の扱いだった。アイリスフィールもまた望みはしなかった。  人形として造られ、人形として育てられた彼女には、かつては幸福という言葉の意味さえ理解できていなかっただろう。  それが、今──晴れやかに笑っている。  「この子を産めて、本当に良かった」  静かに、慈しみを込めて、アイリスフィール・フォン・アインツベルンは眠る赤子を見つめながら語る。  「これから先、この子は紛い物の人間として生きていく。辛いだろうし、こうして紛い物の母親に産み落とされたことを呪うかもしれない。それでも、今は嬉しいんです。この子が愛しくて、誇らしいんです」  外見は何の変哲もない、見るからに愛らしい嬰児でありながら──  母の胎内にいるうちから幾度となく魔術的な処置を施されたその身体は、もはや母親以上に人間離れした組成に組み替えられている。生まれながらにして用途を限定された、魔術回路の塊とも言うべき肉体。それがアイリスフィールの愛娘の正体だった。  そんな残酷な誕生でありながら、アイリスフィールはなお「良し」と言う。産み落とした己を是とし、生まれ落ちた娘を是とし、その生命を愛して、誇って、微笑む。  その強さ、その貴き心の在りようは、まぎれもなく〝母〟のものだった。  ただの人形でしかなかった少女が、恋を得て女になり、そして母親として揺るがぬカを得た。それは何者にも侵せない〝幸〟の形であっただろう。暖炉のぬくもりに護られた母子の寝室は、今、どのような絶望とも不幸とも無縁だった。  だが──男は弁えていた。自分が属する世界には、むしろ窓の外の吹雪こそ似つかわしいのだと。  「アイリ、僕は──」  一言を発することに、男の胸には刃が突き刺さるかのようだった。その刃とは、赤子の安らかな寝顔であり、その母の眩しい微笑みであった。  「──僕は、いつか、君を死なせる羽目になる」  血を吐く思いで放たれた宣言に、アイリスフィールは安らかな表情のまま頷いた。  「解っています。もちろん。それがアインツベルンの悲願。そのための私なのですから」  それは、すでに確定された未来。  これより六年を経た後に、男は妻を連れて死地へと赴く。世界を救う一人の犠牲として、アイリスフィールは彼の理想に捧げられる生贄となる。  それは二人の間で、何度も語られ、了解された事柄だった。  すでに男は繰り返し涙を流し、自らを呪い、そのたびにアイリスフィールは彼を赦し、励ました。  「あなたの理想を知り、同じ祈りを胸に懐いたから、だから今の私があるんです。あなたは私を導いてくれた。人形ではない生き方を与えてくれた」  同じ理想に生きて、殉じる。そうすることで彼という男の半身となる。それがアイリスフィールという女の愛の形。そんな彼女だったからこそ、男もまたお互いを許容できた。  「あなたは私を悼まなくていい。もう私はあなたの一部なんだから。だから、ただ自分が欠け落ちる痛みにだけ耐えてくれればいいのです」  「……じゃあ、この子は？」  羽毛のように軽い嬰児の体重、その質量とは異なる次元の重圧で、今や男の両足は震えていた。  この子供は、彼の掲げる理想に対し、まだ何の理解も覚悟もない。  彼という男の生き様を断じることも、赦すこともできない。そんな力はまだ持ち合わせていない。  だが、そんな無垢な生命であろうとも、彼の理想は容赦するまい。  ひとつの命に卑賤はなく、老いも若きも間うことなく、定量のひとつの単位──  「僕に……この子を抱く資格は、ない」  狂おしいほどの愛おしさに潰されそうになりながらも、男は声を絞り出した。  腕の中の赤子の、ふくよかな桜色の頬に、一雫の涙が落ちる。  声もなく鳴咽しながら、とうとう男は膝を屈した。  世界の非情さを覆すため、それ以上の非情さを志し……それでも愛する者を持ってしまった男に対して、ついに科された最大の罰';
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        String before = loremIpsum.substring(0, selectedIndex);
        String during = loremIpsum[selectedIndex];
        String after =
            loremIpsum.substring(min(selectedIndex + 1, loremIpsum.length - 1));

        final textPainter = TextPainter(
          text: TextSpan(children: [
            TextSpan(text: before),
            TextSpan(text: during, style: const TextStyle(color: Colors.red)),
            TextSpan(text: after),
          ]),
          textDirection: TextDirection.ltr,
        );

        final width = constraints.maxWidth;
        textPainter.layout(
          minWidth: 22,
          maxWidth: width,
        );
        const double height = 250;
        return Container(
          width: width,
          height: height,
          color: Colors.black,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              TextPosition selection =
                  textPainter.getPositionForOffset(details.localPosition);

              selectedIndex = selection.offset;
              setState(() {});
            },
            onVerticalDragUpdate: (details) {
              TextPosition selection =
                  textPainter.getPositionForOffset(details.localPosition);

              selectedIndex = selection.offset;

              setState(() {});
            },
            onVerticalDragEnd: (details) {
              widget.onChangeText(loremIpsum.substring(max(0, selectedIndex),
                  min(selectedIndex + 20, loremIpsum.length - 1)));
            },
            onHorizontalDragEnd: (details) {
              widget.onChangeText(loremIpsum.substring(max(0, selectedIndex),
                  min(selectedIndex + 20, loremIpsum.length - 1)));
            },
            onTapDown: (details) {
              TextPosition selection =
                  textPainter.getPositionForOffset(details.localPosition);

              widget.onChangeText(loremIpsum.substring(max(0, selection.offset),
                  min(selection.offset + 20, loremIpsum.length - 1)));
              selectedIndex = selection.offset;

              setState(() {});
            },
            child: CustomPaint(
              size: Size(width, height), // Parent width, text height
              painter: TextCustomPainter(textPainter),
            ),
          ),
        );
      },
    );
  }
}

class TextCustomPainter extends CustomPainter {
  TextPainter textPainter;

  TextCustomPainter(this.textPainter, {Listenable? repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.paint(canvas, Offset(0, 0));
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
