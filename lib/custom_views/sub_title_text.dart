import 'package:flutter/material.dart';
import 'package:wings/utils/colors.dart';

class SubTitle extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final double textSize;
  final Color color;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry margin;
  final TextOverflow overflow;
  final int maxLines;
  final double lineSpacing;
  final double minWidth;
  final double maxWidth;
  final double height;
  final TextDecoration decoration;

  const SubTitle(this.text,
      {Key key,
      this.textAlign,
      this.textSize,
      this.alignment,
      this.color,
      this.margin,
      this.overflow,
      this.maxLines,
      this.lineSpacing,
      this.minWidth,
      this.maxWidth,
      this.height,
      this.decoration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      alignment: alignment,
      constraints: minWidth != null && maxWidth != null ? BoxConstraints(minWidth: minWidth, maxWidth: maxWidth) : null,
      child: Text(
        text,
        style: TextStyle(
          fontSize: textSize ?? 14,
          color: color == null ? AppColors.titleTextColor : color,
          fontWeight: FontWeight.w300,
          height: lineSpacing,
          decoration: decoration,
        ),
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}
