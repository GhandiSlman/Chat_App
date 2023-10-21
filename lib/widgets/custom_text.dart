import 'package:flutter/widgets.dart';

class CustomText extends StatelessWidget {
  final String ?text;
  final double ?size;
  final FontWeight? weight;
  final Color ?color;
  final TextOverflow? overflow;
  final TextDirection? textDirection;
  final String? fontFamily;
  final TextAlign ? textAlign;
  final int ? max;
  CustomText({
    this.text,
    this.size,
    this.weight,
    this.color,
    this.fontFamily,
    this.overflow,
    this.textAlign,
    this.textDirection,
    this.max,
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: max,
      style: TextStyle(fontSize: size, fontWeight: weight,color: color,overflow: overflow,fontFamily: fontFamily,
      
      ),
    );
  }
}
