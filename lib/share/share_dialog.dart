import 'package:fleet_flutter/share/capture_service.dart';
import 'package:fleet_flutter/share/output_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' show window;

/// 共有ダイアログの引数
class ShareDialogArgs {
  ShareDialogArgs(this.image, this.shareLink);

  /// キャプチャ画像
  final CapturedImage image;

  /// 共有リンク
  /// (利用可能な場合のみ)
  final String? shareLink;
}

/// 共有ダイアログ
class ShareDialog extends StatelessWidget {
  const ShareDialog({
    Key? key,
    required this.args,
  }) : super(key: key);

  /// 引数
  final ShareDialogArgs args;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: _buildContent(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
      insetPadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      actionsPadding: const EdgeInsets.only(bottom: 4),
      buttonPadding: EdgeInsets.zero,
    );
  }

  //  コンテンツ部分を生成する。
  Widget _buildContent() {
    final outputView = OutputView(
      imageBytes: args.image.imageBytes,
      width: args.image.width,
      height: args.image.height,
    );

    final isShareLinkAvailable = args.shareLink != null;
    if (isShareLinkAvailable) {
      return Column(
        children: [
          Expanded(child: outputView),
          _buildShareLinkField(),
          const SizedBox(height: 4),
          _buildShareButton(),
        ],
      );
    } else {
      return outputView;
    }
  }

  //  共有リンクのフィールドを生成する。
  Widget _buildShareLinkField() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: args.shareLink));
          },
          padding: const EdgeInsets.all(4),
          splashRadius: 16,
          icon: const Icon(Icons.copy),
          tooltip: 'コピー',
        ),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(args.shareLink!, maxLines: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //  共有ボタンを生成する。
  Widget _buildShareButton() {
    return ElevatedButton(
      onPressed: () => _share(args.shareLink!, 'Fleetを共有しよう!'),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: const [
          Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.share, size: 16),
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: Text('編集用リンクを共有', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  //  リンクを共有する。
  Future<bool> _share(String url, String title) async {
    try {
      //  まずはブラウザの機能での共有を試す。
      //  (本来はnavigator.shareがundefinedかどうかで有効性を判定すべき。)
      final shareData = {'url': url, 'title': title};
      await window.navigator.share(shareData);

      return true;
    } catch (e) {
      //  何かしらの例外が発生した場合、
      //  ブラウザの共有機能が未対応であるとみなし、
      //  Twitterでの共有にフォールバックする。
      final encodedTitle = Uri.encodeQueryComponent(title);
      final encodedUrl = Uri.encodeQueryComponent(url);
      final twitterUrl =
          'https://twitter.com/intent/tweet?text=$encodedTitle - $encodedUrl';
      window.open(twitterUrl, '_blank');

      return false;
    }
  }
}

/// --------- old -------------

/// 共有ダイアログ
class ShareDialog2 extends StatelessWidget {
  const ShareDialog2({
    Key? key,
    required this.shareLink,
  }) : super(key: key);

  /// 共有リンク
  final String? shareLink;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('あなたのFleetを共有'),
      content: SizedBox(
        width: double.maxFinite,
        child: shareLink != null
            ? _buildAvailableContent(shareLink!)
            : _buildUnavailableContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

  //  共有が利用可能な場合のコンテンツを生成する。
  Widget _buildAvailableContent(String link) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('このリンクにアクセスすれば誰でもあなたのFleetを閲覧・追加編集できます!'),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.copy),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(link, maxLines: 1),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => _share(link, 'Fleetを共有しよう!'),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.share, size: 22),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text('共有', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //  共有が利用不可能な場合のコンテンツを生成する。
  Widget _buildUnavailableContent() {
    return const Text('おっと! 共有ができないみたいです。');
  }

  //  共有する。
  Future<bool> _share(String url, String title) async {
    try {
      //  まずはブラウザの機能での共有を試す。
      //  (本来はnavigator.shareがundefinedかどうかで有効性を判定すべき。)
      final shareData = {'url': url, 'title': title};
      await window.navigator.share(shareData);

      return true;
    } catch (e) {
      //  何かしらの例外が発生した場合、
      //  ブラウザの共有機能が未対応であるとみなし、
      //  Twitterでの共有にフォールバックする。
      final encodedTitle = Uri.encodeQueryComponent(title);
      final encodedUrl = Uri.encodeQueryComponent(url);
      final twitterUrl =
          'https://twitter.com/intent/tweet?text=$encodedTitle - $encodedUrl';
      window.open(twitterUrl, '_blank');

      return false;
    }
  }
}
