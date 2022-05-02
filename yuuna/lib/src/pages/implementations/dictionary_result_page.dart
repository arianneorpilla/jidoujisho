// import 'package:flutter/material.dart';
// import 'package:yuuna/dictionary.dart';
// import 'package:yuuna/pages.dart';

// /// Used for displaying and processing a [DictionarySearchResult].
// class DictionaryResultPage extends BasePage {
//   /// Create an instance of this page.
//   const DictionaryResultPage({
//     required this.result,
//     Key? key,
//   }) : super(key: key);

//   /// This page must have an attached result to be displayed on it.
//   final DictionarySearchResult result;

//   @override
//   BasePageState createState() => _DictionaryResultPageState();
// }

// class _DictionaryResultPageState extends BasePageState<DictionaryResultPage> {
//   @override
//   void initState() {
//     super.initState();
//     widget.result.references.loadSync();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: ListView.builder(
//         shrinkWrap: true,
//         itemCount: widget.result.references.length,
//         itemBuilder: (context, index) {
//           return Text(widget.result.references.elementAt(index).word);
//         },
//       ),
//     );
//   }
// }
