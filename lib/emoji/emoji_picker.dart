import 'package:fleet_flutter/emoji/native_emoji_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:rxdart/rxdart.dart';

/// 絵文字選択UI (仮)
class EmojiPicker extends StatefulWidget {
  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  static const _emojiList = [
    EmojiData('🍣', '寿司'),
    EmojiData('🍖', '肉'),
    EmojiData('🐤', '鳥'),
    EmojiData('🐥', 'チンチン鳥'),
    EmojiData('😋', 'ぺろ'),
    EmojiData('😤', '圧倒的成長'),
    EmojiData('🥺', 'ぴぇん'),
    EmojiData('😫', '進捗を出してしまったぁ'),
    EmojiData('😄', 'ナンチャッテ'),
    EmojiData('🧠', '脳'),
    EmojiData('🫀', '心臓'),
    EmojiData('🫁', '肺'),
  ];
  static final _emojiParser = EmojiParser();

  final emojiSubject = BehaviorSubject.seeded('');

  Stream<String> get emojiStream => emojiSubject.map(parseEmoji);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('絵文字選択')),
      body: Column(
        children: [
          //  入力フォーム
          Padding(
            padding: const EdgeInsets.all(4),
            child: buildInputForm(),
          ),
          const Divider(),

          //  絵文字リスト
          Expanded(child: buildEmojiList()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emojiSubject.close();
    super.dispose();
  }

  //  入力フォームを生成する。
  Widget buildInputForm() {
    return Row(
      children: [
        //  絵文字プレビュー
        Padding(
          padding: const EdgeInsets.all(8),
          child: StreamBuilder<String>(
            initialData: '',
            stream: emojiStream,
            builder: (context, snapshot) {
              final emoji = snapshot.requireData;

              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0x33000000),
                ),
                child: NativeEmojiView(
                  key: ValueKey(emoji),
                  emoji: emoji,
                  capturable: false,
                  size: 48,
                ),
              );
            },
          ),
        ),

        //  テキストフィールド
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (value) => emojiSubject.value = value,
              decoration: const InputDecoration(
                hintText: '例 :sushi:',
              ),
            ),
          ),
        ),

        //  選択ボタン
        //  (プレビューは無効なものでも一応選択できるようにはする。)
        Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            onPressed: () {
              final parseResult = parseEmoji(emojiSubject.value);
              final result =
                  parseResult.isNotEmpty ? parseResult : emojiSubject.value;

              Navigator.pop(context, result);
            },
            child: const Text('選択'),
          ),
        ),
      ],
    );
  }

  //  絵文字リストを生成する。
  Widget buildEmojiList() {
    return ListView.builder(
      itemCount: _emojiList.length,
      itemBuilder: (context, index) {
        final data = _emojiList[index];

        return SizedBox(
          height: 48,
          child: ListTile(
            leading: NativeEmojiView(
              emoji: data.emoji,
              capturable: true,
              size: 32,
            ),
            title: Text(data.name),
            onTap: () => Navigator.pop(context, data.emoji),
          ),
        );
      },
    );
  }

  //  絵文字をパースする。
  //  (絵文字の名前、もしくは、絵文字の文字コードを入力すると、絵文字の文字コードが返ってくる。)
  //  (例1: ':sushi': → '🍣', 例2: '🍣' → '🍣', 例3: ':不正入力:' → '')
  String parseEmoji(String str) {
    //  絵文字の名前からの検索
    final byName = _emojiParser.get(str);
    if (byName != Emoji.None) return byName.code;

    //  絵文字の文字コードからの検索
    final byCode = _emojiParser.getEmoji(str);
    if (byCode != Emoji.None) return byCode.code;

    //  ヒットしない場合
    return '';
  }
}

class EmojiData {
  const EmojiData(this.emoji, this.name);

  final String emoji;
  final String name;
}
