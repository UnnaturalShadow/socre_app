import 'package:flutter/material.dart';

class RoundNumberCell extends StatelessWidget {
  final int round;
  final bool isCurrent;

  const RoundNumberCell({super.key, required this.round, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 60,
      alignment: Alignment.center,
      color: isCurrent ? Colors.yellow.shade200 : Colors.grey.shade200,
      child: Text('$round'),
    );
  }
}
