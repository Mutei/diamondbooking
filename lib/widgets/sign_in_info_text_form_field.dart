import 'package:flutter/material.dart';

class SignInInfoTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?) validator;
  final bool obscureText;
  final Widget? suffixIcon;

  const SignInInfoTextFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.validator,
    this.obscureText = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  _SignInInfoTextFormFieldState createState() =>
      _SignInInfoTextFormFieldState();
}

class _SignInInfoTextFormFieldState extends State<SignInInfoTextFormField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: OutlineInputBorder(),
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
      ),
      obscureText: _obscureText,
      validator: widget.validator,
    );
  }
}
