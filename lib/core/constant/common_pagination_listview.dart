import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

/// A reusable ListView with built-in infinite-scroll pagination.
///
/// **Server-side mode:** pass [onLoadMore] + [hasMore] + [isLoadingMore].
/// The widget shows all [items] and calls [onLoadMore] when the user scrolls
/// near the bottom so the parent can fetch the next page from the API.
///
/// **Client-side mode:** pass [pageSize] (default 10). The widget initially
/// shows only the first [pageSize] items and reveals more on scroll without
/// any server call.
class CommonPaginationListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;
  final double threshold;
  final int pageSize;
  final Widget? loadingIndicator;
  final Widget? emptyWidget;

  const CommonPaginationListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.padding,
    this.shrinkWrap = true,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.threshold = 200,
    this.pageSize = 10,
    this.loadingIndicator,
    this.emptyWidget,
  });

  @override
  State<CommonPaginationListView<T>> createState() =>
      _CommonPaginationListViewState<T>();
}

class _CommonPaginationListViewState<T>
    extends State<CommonPaginationListView<T>> {
  late ScrollController _ownController;
  ScrollController? _externalController;
  bool _ownsController = false;
  int _clientDisplayCount = 0;

  bool get _useClientPagination => widget.onLoadMore == null;

  @override
  void initState() {
    super.initState();
    _ownController = ScrollController();
    _resolveController();
    _scrollController.addListener(_onScroll);
    if (_useClientPagination) {
      _clientDisplayCount = widget.pageSize;
    }
  }

  @override
  void didUpdateWidget(covariant CommonPaginationListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _scrollController.removeListener(_onScroll);
      _resolveController();
      _scrollController.addListener(_onScroll);
    }
    if (_useClientPagination && !identical(widget.items, oldWidget.items)) {
      _clientDisplayCount = widget.pageSize;
    }
  }

  void _resolveController() {
    if (widget.controller != null) {
      _externalController = widget.controller;
      _ownsController = false;
    } else {
      _ownsController = true;
    }
  }

  ScrollController get _scrollController =>
      _externalController ?? _ownController;

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (_ownsController) _ownController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    final pixels = _scrollController.position.pixels;

    if (pixels >= maxExtent - widget.threshold) {
      if (_useClientPagination) {
        if (_clientDisplayCount < widget.items.length) {
          setState(() {
            _clientDisplayCount =
                (_clientDisplayCount + widget.pageSize)
                    .clamp(0, widget.items.length);
          });
        }
      } else {
        if (!widget.isLoadingMore && widget.hasMore) {
          widget.onLoadMore!();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    if (_useClientPagination) {
      final visibleCount =
          _clientDisplayCount.clamp(0, widget.items.length);
      final allLoaded = visibleCount >= widget.items.length;

      return ListView.builder(
        controller: _scrollController,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        scrollDirection: widget.scrollDirection,
        padding: widget.padding,
        itemCount: visibleCount + (allLoaded ? 0 : 1),
        itemBuilder: (context, index) {
          if (index == visibleCount) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: ThemeColors.unifiedPrimary,
                  ),
                ),
              ),
            );
          }
          return widget.itemBuilder(context, widget.items[index], index);
        },
      );
    }

    final itemCount = widget.items.length + (widget.hasMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return widget.loadingIndicator ??
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: ThemeColors.unifiedPrimary,
                    ),
                  ),
                ),
              );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}
