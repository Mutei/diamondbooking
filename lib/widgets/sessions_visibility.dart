import 'package:flutter/material.dart';

import '../localization/language_constants.dart';

class SessionsVisibility extends StatefulWidget {
  final bool isVisible;
  final Function(bool, String) onCheckboxChanged;

  const SessionsVisibility({
    super.key,
    required this.isVisible,
    required this.onCheckboxChanged,
  });

  @override
  _SessionsVisibilityState createState() => _SessionsVisibilityState();
}

class _SessionsVisibilityState extends State<SessionsVisibility> {
  bool checkInternal = false;
  bool checkExternal = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return Container();

    return Column(
      children: [
        _buildCheckboxRow(
          context,
          'internal sessions',
          checkInternal,
          (value) {
            setState(() => checkInternal = value);
            widget.onCheckboxChanged(value, 'internal sessions');
          },
        ),
        _buildCheckboxRow(
          context,
          'External sessions',
          checkExternal,
          (value) {
            setState(() => checkExternal = value);
            widget.onCheckboxChanged(value, 'External sessions');
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
