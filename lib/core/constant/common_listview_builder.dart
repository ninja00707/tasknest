import 'package:flutter/material.dart';

class CommonListViewBuilder<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final ScrollController? controller;
  const CommonListViewBuilder({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.controller,
  });
  final bool shrinkWrap;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      physics: physics,
      controller: controller,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index]);
      },
    );
  }
}
