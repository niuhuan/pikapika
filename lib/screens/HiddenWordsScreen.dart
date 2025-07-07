import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../basic/config/HiddenWords.dart';
import 'components/RightClickPop.dart';
import 'components/ListView.dart';
import 'components/ContentBuilder.dart';

class HiddenWordsScreen extends StatefulWidget {
  const HiddenWordsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HiddenWordsScreenState();
}

class _HiddenWordsScreenState extends State<HiddenWordsScreen> {
  late Future<String> _future = initHiddenWords();
  late Key _key = UniqueKey();
  final TextEditingController _textController = TextEditingController();

  Future<void> _addWord() async {
    if (_textController.text.trim().isEmpty) return;
    await addHiddenWord(_textController.text.trim());
    _textController.clear();
    setState(() {
      _future = initHiddenWords();
      _key = UniqueKey();
    });
  }

  Future<void> _removeWord(String word) async {
    await removeHiddenWord(word);
    setState(() {
      _future = initHiddenWords();
      _key = UniqueKey();
    });
  }

  Future<void> _clearAll() async {
    await clearHiddenWords();
    setState(() {
      _future = initHiddenWords();
      _key = UniqueKey();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.hidden_words.title")),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(tr("settings.hidden_words.clear_all")),
                  content: Text(tr("settings.hidden_words.clear_all_desc")),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(tr("settings.hidden_words.cancel")),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(tr("settings.hidden_words.confirm")),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _clearAll();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: tr("settings.hidden_words.input_hint"),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addWord(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addWord,
                ),
              ],
            ),
          ),
          Expanded(
            child: ContentBuilder(
              key: _key,
              future: _future,
              onRefresh: () async {
                setState(() {
                  _future = initHiddenWords();
                  _key = UniqueKey();
                });
              },
              successBuilder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (hiddenWords.isEmpty) {
                  return Center(
                    child: Text(tr("settings.hidden_words.no_words")),
                  );
                }
                return PikaListView(
                  children: hiddenWords.map((word) => ListTile(
                    title: Text(word),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeWord(word),
                    ),
                  )).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 