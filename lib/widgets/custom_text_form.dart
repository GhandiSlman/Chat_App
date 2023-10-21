import 'package:flutter/material.dart';


// ignore: must_be_immutable
class CustomTextForm extends StatelessWidget {
  final String? hint;
  final TextInputType? type;
  final TextEditingController? mycontroller;
  final String? Function(String?)? validator;
  final Icon? icon;
  final Widget? label;
  final String? initialValue;
  void Function(String?)? onSaved;

  void Function(String)? onChanged;
  CustomTextForm({
    super.key,
    this.onSaved,
    this.initialValue,
    this.label,
    this.hint,
    this.mycontroller,
    this.type,
    this.validator,
    this.icon,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: mycontroller,
      onChanged: onChanged,
      onSaved: onSaved,
      initialValue: initialValue,
      decoration: InputDecoration(
        label: label,
        prefixIcon: icon,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
