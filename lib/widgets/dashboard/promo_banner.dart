import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
class PromoSlide {
  const PromoSlide({required this.headline});
  final String headline;
}
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key, required this.slides, this.initialPage = 0});
  final List<PromoSlide> slides;
  final int initialPage;
  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}
class _PromoCarouselState extends State<PromoCarousel> {
  late final _controller = PageController(initialPage: widget.initialPage);
  late int _page = widget.initialPage;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 246,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => _Banner(slide: widget.slides[i]),
          ),
        ),
        const SizedBox(height: 9.5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.slides.length; i++)
              Semantics(
                button: true,
                selected: i == _page,
                label: 'Slide ${i + 1} of ${widget.slides.length}',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _controller.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
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
            image: AssetImage('assets/images/dashboard/9436904_19089 1.png'),
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
                      'assets/images/dashboard/earth-boxes-cardboard-texture 1.png',
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
