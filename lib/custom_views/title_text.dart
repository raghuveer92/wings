import 'package:flutter/material.dart';
import 'package:wings/utils/colors.dart';

class TitleText extends StatelessWidget {
  final String text;
  final Color color;
  final double textSize;
  final AlignmentGeometry alignment;
  final TextAlign textAlign;
  final EdgeInsetsGeometry margin;
  final TextOverflow overflow;
  final double width;
  final int maxLines;
  final double lineSpacing;

  const TitleText(
      this.text,
      {Key key,
      this.color,
      this.textSize,
      this.alignment,
      this.textAlign,
      this.margin,
      this.overflow, this.width, this.maxLines, this.lineSpacing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      margin: margin,
      alignment: alignment,
      width: width,
      child: Text(
        text ?? '',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color ?? AppColors.titleTextColor,
          fontSize: textSize??14,
          height: lineSpacing
        ),
        textAlign: textAlign,
        overflow: overflow ?? TextOverflow.ellipsis,
        maxLines: maxLines,
      ),
    );
  }
}
