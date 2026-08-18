import 'package:flutter/material.dart';

import '../app/app_colors.dart';

/// Hero/banner image that always shows the ENTIRE source image.
///
/// Unlike [ResponsiveHeroImage] (which crops via `BoxFit.cover` into a fixed
/// height), this widget resolves the asset's intrinsic aspect ratio and
/// sizes itself as `availableWidth / imageWidth * imageHeight`, capped at
/// [maxHeight]. The image is always laid out with `BoxFit.contain`, so it is
/// never cropped, zoomed, or stretched — a taller/shorter box (or letterbox
/// space within it) is preferred over losing any part of the photo.
class FullVisibleHeroImage extends StatefulWidget {
  const FullVisibleHeroImage({
    super.key,
    required this.imagePath,
    this.maxHeight = 420,
    this.borderRadius,
    this.gradientEnabled = true,
    this.child,
    this.semanticLabel,
  });

  final String imagePath;
  final double maxHeight;
  final double? borderRadius;
  final bool gradientEnabled;
  final Widget? child;
  final String? semanticLabel;

  @override
  State<FullVisibleHeroImage> createState() => _FullVisibleHeroImageState();
}

class _FullVisibleHeroImageState extends State<FullVisibleHeroImage> {
  // Cached across instances so switching screens doesn't re-flash the
  // fallback aspect ratio for an asset we've already measured.
  static final Map<String, double> _aspectRatioCache = {};

  double? _aspectRatio;
  ImageStream? _imageStream;
  late final ImageStreamListener _listener;

  @override
  void initState() {
    super.initState();
    _aspectRatio = _aspectRatioCache[widget.imagePath];
    _listener = ImageStreamListener(_onImageLoaded);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant FullVisibleHeroImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _aspectRatio = _aspectRatioCache[widget.imagePath];
      _resolveImage();
    }
  }

  void _resolveImage() {
    final provider = AssetImage(widget.imagePath);
    final newStream = provider.resolve(createLocalImageConfiguration(context));
    if (newStream.key == _imageStream?.key) return;
    _imageStream?.removeListener(_listener);
    _imageStream = newStream;
    _imageStream!.addListener(_listener);
  }

  void _onImageLoaded(ImageInfo info, bool synchronousCall) {
    final ratio = info.image.width / info.image.height;
    _aspectRatioCache[widget.imagePath] = ratio;
    if (!mounted) return;
    setState(() => _aspectRatio = ratio);
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_listener);
    super.dispose();
  }

  double _radius(double width) {
    if (widget.borderRadius != null) return widget.borderRadius!;
    return width >= 1024 ? 20 : 16;
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final ratio = _aspectRatio ?? (16 / 9);
        final height = (width / ratio).clamp(0, widget.maxHeight).toDouble();
        final radius = _radius(width);

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: AppColors.peach100),
                Semantics(
                  label: widget.semanticLabel,
                  image: true,
                  excludeSemantics: widget.semanticLabel == null,
                  child: Image.asset(
                    widget.imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.peach100,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.peach900,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                if (widget.gradientEnabled)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: height * 0.2,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              scaffoldBg.withValues(alpha: 0),
                              scaffoldBg.withValues(alpha: 0.2),
                              scaffoldBg.withValues(alpha: 0.6),
                              scaffoldBg,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.child != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: widget.child!,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
