// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';

Widget CustomDropdownButton<T>({
  required BuildContext context,
  required final String hintText,
  required final T value,
  required final Function(T?)? onChanged,
  required final List<DropdownMenuItem<T>> items,
}) {
  return Center(
    child: Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(161, 224, 224, 224),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<T>(
        underline: const SizedBox(),
        padding: const EdgeInsets.symmetric(horizontal: 11),
        focusColor: Colors.transparent,
        value: value,
        icon: Icon(Icons.arrow_drop_down_rounded,
            color: Colors.black.withOpacity(0.7)),
        isExpanded: true,
        borderRadius: BorderRadius.circular(5),
        hint: Text(hintText,
            style: TextStyle(color: Colors.black.withOpacity(0.75))),
        onChanged: onChanged,
        items: items,
      ),
    ),
  );
}
