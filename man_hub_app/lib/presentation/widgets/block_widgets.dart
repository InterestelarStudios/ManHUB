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

class TitleBlockWidget extends StatelessWidget {
  final TitleBlock block;

  const TitleBlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        block.text,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.neonPrimary,
              fontWeight: FontWeight.bold,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        block.text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: Text(
        block.text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.neonPrimary.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.neonPrimary.withValues(alpha: 0.5), width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          block.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppColors.neonLight,
                fontWeight: FontWeight.w500,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: CachedNetworkImage(
          imageUrl: block.imageUrl,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: AppColors.neonPrimary),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.broken_image, color: AppColors.textSecondary, size: 48),
          ),
          fit: BoxFit.cover,
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
