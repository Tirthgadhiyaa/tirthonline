import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constant/string_constant.dart';
import '../services/functions/keyboard_hide_function.dart';
import '../utils/math_utils.dart';

class CustFormField extends StatelessWidget {
  final String hint;
  final String? label;
  final Widget? suffix;
  final Widget? prefix;
  final bool isObscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final String? errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final bool? autoFocus;
  final Function(String?)? onFieldSubmitted;
  final Function(String?)? onChanged;
  final Function()? onTap;
  final int minLines;
  final int maxLines;
  final bool readOnly;
  final String? initialValue;
  final int? maxLength;
  final bool isFilled;
  final Color? fillcolor;
  final Color? hintcolor;
  final double? hintsize;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final BorderSide? borderSide;
  final InputBorder? focusedBorderside;
  const CustFormField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.keyboardType,
    this.suffix,
    this.prefix,
    this.isObscureText = false,
    this.inputFormatters,
    this.textInputAction,
    this.errorText,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.autoFocus,
    this.onFieldSubmitted,
    this.onTap,
    this.minLines = 1,
    this.maxLines = 5,
    this.readOnly = false,
    this.initialValue,
    this.maxLength,
    this.isFilled = false,
    this.fillcolor,
    this.hintcolor,
    this.hintsize,
    this.contentPadding,
    this.borderRadius = 10,
    this.borderSide,
    this.focusedBorderside,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    //double borderRadius = 15.0;
    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      validator: validator,
      autovalidateMode: autovalidateMode,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onTapOutside: (_) => hideKeyboard(context),
      obscureText: isObscureText,
      obscuringCharacter: StringConstant.obscuringCharacter,
      focusNode: focusNode,
      onTap: onTap,
      minLines: minLines,
      maxLines: maxLines,
      readOnly: readOnly,
      autofocus: autoFocus ?? false,
      initialValue: initialValue,
      onSaved: (val) => onFieldSubmitted?.call(val),
      decoration: InputDecoration(
        hintText: hint,
        fillColor: fillcolor ?? Theme.of(context).colorScheme.outlineVariant,
        filled: true,
        hintStyle: TextStyle(
          fontSize: hintsize,
          color: hintcolor ?? Theme.of(context).colorScheme.outline,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        contentPadding: contentPadding ?? EdgeInsets.all(getSize(context,20)),
        /*  label: Text(
          label ?? hint,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
        ), */
        errorText: errorText,
        suffixIcon: suffix,
        prefixIcon: prefix,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
        focusedBorder: focusedBorderside ??
            OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(borderRadius!),
              ),
            ),
        hoverColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderSide: borderSide ?? BorderSide.none,
          // (
          //   color: Theme.of(context).colorScheme.outline,
          // ),
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius!),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
      ),
    );
  }
}
