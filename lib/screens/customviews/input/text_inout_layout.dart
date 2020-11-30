import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextInputLayout extends StatefulWidget {
  final TextInputType inputType;
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String fieldName;
  final EdgeInsetsGeometry padding;
  final TextInputAction textInputAction;
  final Widget suffixIcon;
  final bool enable;
  final FocusNode focusNode;
  final bool obscureText;
  final int maxLength;
  final int minLines;
  final int maxLines;
  final bool focusable;
  final bool required;
  final ValueChanged<String> onFieldSubmitted;
  final Widget prefixIcon;
  final EdgeInsetsGeometry contentPadding;
  final GestureTapCallback textFieldOnTap;
  final double height;
  final double width;

  TextInputLayout(
      {Key key,
      this.inputType,
      this.controller,
      this.labelText,
      this.hintText,
      this.fieldName,
      this.padding,
      this.textInputAction,
      this.suffixIcon,
      this.enable,
      this.focusNode,
      this.obscureText,
      this.maxLength,
      this.focusable,
      this.required,
      this.onFieldSubmitted,
      this.prefixIcon,
      this.contentPadding,
      this.textFieldOnTap,
      this.height,
      this.width,
        this.minLines, this.maxLines,
      })
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TextInputLayoutState(
      inputType: inputType,
      fieldName: fieldName,
      controller: controller,
      hintText: hintText,
      labelText: labelText,
      padding: padding,
      suffixIcon: suffixIcon,
      enable: enable,
      focusNode: focusNode,
      obscureText: obscureText,
      maxLenght: maxLength,
      focusable: focusable,
      required: required,
      contentPadding: contentPadding,
      textFieldOnTap: textFieldOnTap);
}

class TextInputLayoutState extends State<TextInputLayout> {
  final TextInputType inputType;
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String fieldName;
  final EdgeInsetsGeometry padding;
  bool hasFocus = false;
  final Widget suffixIcon;
  final bool enable;
  FocusNode focusNode;
  final bool obscureText;
  int maxLenght;
  final bool focusable;
  final bool required;
  final EdgeInsetsGeometry contentPadding;
  final GestureTapCallback textFieldOnTap;

  TextInputLayoutState({
    this.inputType,
    this.controller,
    this.labelText,
    this.hintText,
    this.fieldName,
    this.padding,
    this.suffixIcon,
    this.enable,
    this.focusNode,
    this.obscureText,
    this.maxLenght,
    this.focusable,
    this.required,
    this.contentPadding,
    this.textFieldOnTap,
  });

  @override
  void initState() {
    super.initState();
    if (focusNode == null) {
      focusNode = FocusNode();
    }
    hasFocus = focusNode.hasFocus;
    focusNode.addListener(() {
      hasFocus = focusNode.hasFocus;
    });
    if (TextInputType.datetime == inputType) {
      focusNode?.addListener(() {
        focusNode.unfocus();
      });
    }
    if (focusable != null && focusable == false) {
      focusNode?.addListener(() {
        focusNode.unfocus();
      });
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      margin: widget.height == null ? EdgeInsets.only(top: 16) : null,
      child: TextFormField(
        onTap: textFieldOnTap ?? null,
        minLines: widget.minLines,
        maxLines: widget.maxLines??1,
        onFieldSubmitted: widget.onFieldSubmitted,
        obscureText: obscureText != null ? obscureText : false,
        focusNode: focusNode,
        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16.0),
        maxLength: maxLenght,
        keyboardType: inputType,
        controller: controller,
        textCapitalization: inputType == TextInputType.emailAddress ? TextCapitalization.none : TextCapitalization.words,
        validator: false == required
            ? null
            : (String text) {
                if (text.trim().isEmpty) {
                  return '$fieldName cannot be empty!';
                }
                return null;
              },
        decoration: InputDecoration(
            labelText: labelText,
            filled: true,
            fillColor: Colors.grey[1],
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            border: UnderlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            counterText: '',
            hintText: hintText,
            labelStyle:
                hasFocus || controller.text.length > 0 ? TextStyle(color: Theme.of(context).primaryColor) : TextStyle(color: Theme.of(context).hintColor),
            suffixIcon: suffixIcon,
            prefixIcon: widget.prefixIcon,
            enabled: enable != null ? enable : true,
            contentPadding: contentPadding),
        textInputAction: widget.textInputAction == null ? TextInputAction.next : widget.textInputAction,
        enabled: enable != null ? enable : true,
      ),
    );
  }
}
