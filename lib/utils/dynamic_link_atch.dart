import 'package:flutter/material.dart';

class DynamicLinkCatch extends StatefulWidget {
  final String dynamicData;

  const DynamicLinkCatch(this.dynamicData, {super.key});

  @override
  State<DynamicLinkCatch> createState() => _DynamicLinkCatchState();
}

class _DynamicLinkCatchState extends State<DynamicLinkCatch> {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(widget.dynamicData)],
    ),
  );
}
