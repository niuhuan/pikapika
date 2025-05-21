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
        title: const Text('隐藏词管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认清空'),
                  content: const Text('确定要清空所有隐藏词吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('确定'),
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
                    decoration: const InputDecoration(
                      hintText: '输入要隐藏的词',
                      border: OutlineInputBorder(),
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
                  return const Center(
                    child: Text('暂无隐藏词'),
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