import 'package:flutter/material.dart';

class MaterialIconButton extends StatelessWidget {
  final Function onPressed;
  final Icon icon;
  final double? iconSize;

  const MaterialIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: IconButton(
        onPressed: () {
          onPressed();
        },
        iconSize: 35,
        icon: icon,
      ),
    );
  }
}
