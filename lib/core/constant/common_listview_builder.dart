import 'package:flutter/material.dart';

class CommonListViewBuilder<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  const CommonListViewBuilder({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.shrinkWrap = true,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.padding,
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
      padding: padding,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );
  }
}
