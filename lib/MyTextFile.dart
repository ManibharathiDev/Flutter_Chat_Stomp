import 'package:flutter/material.dart';

class MyTextFile extends StatelessWidget {
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final String labelText;
  final bool obsCureText;
  final bool validateText;

  const MyTextFile(
      {super.key,
      required this.controller,
      required this.labelText,
      required this.obsCureText,
      required this.validateText,
      required this.textInputAction
      });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      child: TextField(
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green.shade800)),
            fillColor: Colors.white70,
            filled: true,
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade800)),
            errorText: validateText ? 'Required Field' : null,
            labelText: labelText),
        textInputAction: textInputAction,
        controller: controller,
        obscureText: obsCureText,
      ),
    );
  }
}
