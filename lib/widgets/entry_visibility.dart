import 'package:flutter/material.dart';

import '../localization/language_constants.dart';

class EntryVisibility extends StatefulWidget {
  final bool isVisible;
  final Function(bool, String) onCheckboxChanged;

  const EntryVisibility({
    super.key,
    required this.isVisible,
    required this.onCheckboxChanged,
  });

  @override
  _EntryVisibilityState createState() => _EntryVisibilityState();
}

class _EntryVisibilityState extends State<EntryVisibility> {
  bool checkFamilial = false;
  bool checkSingle = false;
  bool checkMixed = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return Container();

    return Column(
      children: [
        _buildCheckboxRow(
          context,
          'Familial',
          checkFamilial,
          (value) {
            setState(() => checkFamilial = value);
            widget.onCheckboxChanged(value, 'Familial');
          },
        ),
        _buildCheckboxRow(
          context,
          'Single2',
          checkSingle,
          (value) {
            setState(() => checkSingle = value);
            widget.onCheckboxChanged(value, 'Single');
          },
        ),
        _buildCheckboxRow(
          context,
          'mixed',
          checkMixed,
          (value) {
            setState(() => checkMixed = value);
            widget.onCheckboxChanged(value, 'mixed');
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxRow(BuildContext context, String label, bool value,
      Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            getTranslated(context, label),
          ),
        ),
        Expanded(
          child: Checkbox(
            checkColor: Colors.white,
            value: value,
            onChanged: (bool? newValue) => onChanged(newValue!),
          ),
        ),
      ],
    );
  }
}
