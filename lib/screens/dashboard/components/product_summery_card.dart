import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utility/constants.dart';
import '../../../models/product_summery_info.dart';

class ProductSummeryCard extends StatefulWidget {
  const ProductSummeryCard({
    Key? key,
    required this.info,
    required this.onTap,
  }) : super(key: key);

  final ProductSummeryInfo info;
  final Function(String?) onTap;

  @override
  State<ProductSummeryCard> createState() => _ProductSummeryCardState();
}

class _ProductSummeryCardState extends State<ProductSummeryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: InkWell(
          onTap: () => widget.onTap(widget.info.title),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  secondaryColor,
                  _isHovered 
                    ? widget.info.color!.withOpacity(0.15) 
                    : secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isHovered 
                  ? widget.info.color!.withOpacity(0.3) 
                  : Colors.transparent,
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.info.color!.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Animated icon container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(defaultPadding * 0.75),
                      height: _isHovered ? 44 : 40,
                      width: _isHovered ? 44 : 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.info.color!.withOpacity(0.2),
                            widget.info.color!.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SvgPicture.asset(
                        widget.info.svgSrc!,
                        colorFilter: ColorFilter.mode(
                          widget.info.color ?? Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    // Count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.info.color!.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.info.productsCount}',
                        style: TextStyle(
                          color: widget.info.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  widget.info.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ProgressLine(
                  color: widget.info.color,
                  percentage: widget.info.percentage,
                  isAnimated: _isHovered,
                ),
                const SizedBox(height: 8),
                // Footer with percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.info.percentage?.toStringAsFixed(0) ?? 0}% of total',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: _isHovered 
                        ? widget.info.color 
                        : Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    Key? key,
    this.color = primaryColor,
    required this.percentage,
    this.isAnimated = false,
  }) : super(key: key);

  final Color? color;
  final double? percentage;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            width: constraints.maxWidth * ((percentage ?? 0) / 100),
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color!,
                  color!.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: isAnimated
                  ? [
                      BoxShadow(
                        color: color!.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
          ),
        ),
      ],
    );
  }
}
