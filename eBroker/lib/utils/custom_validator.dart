import 'package:flutter/material.dart';

class CustomValidator<T> extends FormField<T> {
  CustomValidator(
      {required FormFieldValidator<T> validator,
      required Widget Function(FormFieldState<T> state) builder,
      T? initialValue,
      bool autovalidate = true})
      : super(
          validator: validator,
          initialValue: initialValue,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<T> state) {
            return builder(state);
          },
        );
}
