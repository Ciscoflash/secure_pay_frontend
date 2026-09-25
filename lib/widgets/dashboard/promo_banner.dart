import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
class PromoSlide {
  const PromoSlide({required this.headline});
  final String headline;
}
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    super.key,
    required this.slides,
    this.autoPlayInterval = const Duration(seconds: 4),
  });
  final List<PromoSlide> slides;
  final Duration autoPlayInterval;
  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}
class _PromoCarouselState extends State<PromoCarousel> {
  static const _loopCount = 5;
  late final int _initialPage = _centeredPage();
  late final PageController _controller = PageController(
    initialPage: _initialPage,
  );
  Timer? _timer;
  late int _page = _initialPage;
  int _centeredPage() {
    if (widget.slides.isEmpty) return 0;
    return widget.slides.length * (_loopCount ~/ 2);
  }
  bool get _reduceMotion =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  bool get _enabled => !_reduceMotion && widget.slides.length > 1;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_enabled && _timer == null) _startAutoPlay();
  }
  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayInterval, (_) => _advance());
  }
  void _pauseAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }
  void _advance() {
    if (!_controller.hasClients) return;
    final lastPage = widget.slides.length * _loopCount - 1;
    if (_controller.page!.round() >= lastPage) {
      _controller.jumpToPage(_initialPage);
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }
  void _goTo(int slide) {
    final block = _page - _page % widget.slides.length;
    _controller.animateToPage(
      block + slide,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }
  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 246,
          child: Listener(
            onPointerDown: (_) => _pauseAutoPlay(),
            onPointerUp: (_) {
              if (_enabled) _startAutoPlay();
            },
            onPointerCancel: (_) {
              if (_enabled) _startAutoPlay();
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.slides.length * _loopCount,
              onPageChanged: (index) {
                setState(() => _page = index);
                if (_enabled) _startAutoPlay();
              },
              itemBuilder: (context, index) =>
                  _Banner(slide: widget.slides[index % widget.slides.length]),
            ),
          ),
        ),
        if (widget.slides.length > 1) ...[
          const SizedBox(height: 9.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.slides.length; i++)
                Semantics(
                  button: true,
                  selected: i == _page % widget.slides.length,
                  label: 'Slide ${i + 1} of ${widget.slides.length}',
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _goTo(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page % widget.slides.length
                              ? AppColors.navyButton
                              : AppColors.dotInactive,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
class _Banner extends StatelessWidget {
  const _Banner({required this.slide});
  final PromoSlide slide;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.navy,
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard/dashboard-banner-bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(AppColors.navy, BlendMode.multiply),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;
            return Stack(
              children: [
                Positioned(
                  top: compact ? null : 0,
                  height: compact ? 150 : null,
                  right: compact ? 8 : 20,
                  bottom: 0,
                  child: ExcludeSemantics(
                    child: Image.asset(
                      'assets/images/dashboard/dashboard-banner-boxes.png',
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Positioned(
                  left: compact ? 20 : 38,
                  right: compact ? constraints.maxWidth * 0.4 : 320,
                  bottom: compact ? null : 42,
                  top: compact ? 24 : null,
                  child: Text(
                    slide.headline,
                    style: AppText.style(
                      compact ? 24 : 44,
                      weight: 700,
                      color: Colors.white,
                      height: compact ? 1.1 : 1.0,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}