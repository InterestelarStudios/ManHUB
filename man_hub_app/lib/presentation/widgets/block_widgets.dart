import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../domain/models/content_block.dart';
import '../../../core/theme/app_colors.dart';

class ContentBlockRenderer extends StatelessWidget {
  final ContentBlock block;

  const ContentBlockRenderer({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    if (block is TitleBlock) {
      return TitleBlockWidget(block: block as TitleBlock);
    } else if (block is Title2Block) {
      return Title2BlockWidget(block: block as Title2Block);
    } else if (block is DescriptionBlock) {
      return DescriptionBlockWidget(block: block as DescriptionBlock);
    } else if (block is HighlightedDescriptionBlock) {
      return HighlightedDescriptionBlockWidget(block: block as HighlightedDescriptionBlock);
    } else if (block is ImageBlock) {
      return ImageBlockWidget(block: block as ImageBlock);
    } else if (block is VideoBlock) {
      return VideoBlockWidget(block: block as VideoBlock);
    }
    return const SizedBox();
  }
}

/// Utilitário para transformar marcações como **negrito** e *itálico* em TextSpans estilizados
TextSpan buildMarkdownTextSpan({
  required String text,
  required TextStyle baseStyle,
  TextStyle? boldStyle,
  TextStyle? italicStyle,
}) {
  final effectiveBoldStyle = boldStyle ??
      baseStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );
  final effectiveItalicStyle = italicStyle ??
      baseStyle.copyWith(
        fontStyle: FontStyle.italic,
      );

  final pattern = RegExp(r'(\*\*([\s\S]+?)\*\*|\*([^\*]+?)\*)');
  final matches = pattern.allMatches(text);

  if (matches.isEmpty) {
    return TextSpan(text: text, style: baseStyle);
  }

  final spans = <InlineSpan>[];
  int currentIndex = 0;

  for (final match in matches) {
    if (match.start > currentIndex) {
      spans.add(TextSpan(
        text: text.substring(currentIndex, match.start),
        style: baseStyle,
      ));
    }

    final fullMatch = match.group(0)!;
    if (fullMatch.startsWith('**') && fullMatch.endsWith('**')) {
      final boldContent = match.group(2) ?? '';
      spans.add(TextSpan(
        text: boldContent,
        style: effectiveBoldStyle,
      ));
    } else if (fullMatch.startsWith('*') && fullMatch.endsWith('*')) {
      final italicContent = match.group(3) ?? '';
      spans.add(TextSpan(
        text: italicContent,
        style: effectiveItalicStyle,
      ));
    }

    currentIndex = match.end;
  }

  if (currentIndex < text.length) {
    spans.add(TextSpan(
      text: text.substring(currentIndex),
      style: baseStyle,
    ));
  }

  return TextSpan(children: spans);
}

class TitleBlockWidget extends StatelessWidget {
  final TitleBlock block;

  const TitleBlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.neonPrimary,
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(
          color: AppColors.neonPrimary,
          fontWeight: FontWeight.bold,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text.rich(
        buildMarkdownTextSpan(
          text: block.text,
          baseStyle: baseStyle,
          boldStyle: baseStyle.copyWith(color: Colors.white),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class Title2BlockWidget extends StatelessWidget {
  final Title2Block block;

  const Title2BlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      child: Text.rich(
        buildMarkdownTextSpan(
          text: block.text,
          baseStyle: baseStyle,
          boldStyle: baseStyle.copyWith(color: AppColors.neonPrimary),
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

class DescriptionBlockWidget extends StatelessWidget {
  final DescriptionBlock block;

  const DescriptionBlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: AppColors.textSecondary,
        ) ??
        const TextStyle(
          height: 1.6,
          color: AppColors.textSecondary,
        );

    final boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    );

    final italicStyle = baseStyle.copyWith(
      fontStyle: FontStyle.italic,
      color: AppColors.neonLight,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: Text.rich(
        buildMarkdownTextSpan(
          text: block.text,
          baseStyle: baseStyle,
          boldStyle: boldStyle,
          italicStyle: italicStyle,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

class HighlightedDescriptionBlockWidget extends StatelessWidget {
  final HighlightedDescriptionBlock block;

  const HighlightedDescriptionBlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: AppColors.neonLight,
          fontWeight: FontWeight.w500,
        ) ??
        const TextStyle(
          height: 1.6,
          color: AppColors.neonLight,
          fontWeight: FontWeight.w500,
        );

    final boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    final italicStyle = baseStyle.copyWith(
      fontStyle: FontStyle.italic,
      color: AppColors.neonPrimary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.neonPrimary.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.neonPrimary.withValues(alpha: 0.5), width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPrimary.withValues(alpha: 0.08),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text.rich(
          buildMarkdownTextSpan(
            text: block.text,
            baseStyle: baseStyle,
            boldStyle: boldStyle,
            italicStyle: italicStyle,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}

class ImageBlockWidget extends StatelessWidget {
  final ImageBlock block;

  const ImageBlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    if (block.imageUrl.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: CachedNetworkImage(
          imageUrl: block.imageUrl,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          placeholder: (context, url) => AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: AppColors.card,
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.neonPrimary,
                  ),
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: AppColors.card,
              child: const Center(
                child: Icon(Icons.broken_image, color: AppColors.textSecondary, size: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoBlockWidget extends StatefulWidget {
  final VideoBlock block;

  const VideoBlockWidget({super.key, required this.block});

  @override
  State<VideoBlockWidget> createState() => _VideoBlockWidgetState();
}

class _VideoBlockWidgetState extends State<VideoBlockWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.block.videoUrl));
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.neonPrimary,
          handleColor: AppColors.neonLight,
          backgroundColor: AppColors.backgroundMain,
          bufferedColor: AppColors.textSecondary,
        ),
      );
      setState(() {});
    } catch (e) {
      setState(() {
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text('Erro ao carregar o vídeo.', style: TextStyle(color: AppColors.error)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            : const AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(child: CircularProgressIndicator(color: AppColors.neonPrimary)),
              ),
      ),
    );
  }
}
