import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class MTabBar extends StatefulWidget {
  final List<MTab> tabs;
  final MTabDecoration? activeTabDecoration;
  final MTabDecoration? deactiveTabDecoration;
  final EdgeInsetsGeometry? padding;
  final PageController controller;
  final Function(int page) onChange;
  MTabBar(
      {Key? key,
      required this.tabs,
      this.activeTabDecoration,
      this.deactiveTabDecoration,
      this.padding,
      required this.controller,
      required this.onChange})
      : super(key: key) {}

  @override
  State<MTabBar> createState() => _MTabBarState();
}

class _MTabBarState extends State<MTabBar> {
  int _activeTabindex = 0;
  Map? selectedTab;

  ScrollController _scrollController = ScrollController();
  GlobalKey? selectedKey;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<_IndexedMTab> indexxedList =
        List.generate(widget.tabs.length, (index) {
      return _IndexedMTab(index, widget.tabs[index]);
    }).toList();
    return ListView(
      shrinkWrap: true,
      controller: _scrollController,
      padding: widget.padding,
      scrollDirection: Axis.horizontal,
      children: [
        ...indexxedList.map<Widget>((_IndexedMTab e) {
          MTabDecoration? decoration = _activeTabindex == e.index
              ? widget.activeTabDecoration
              : widget.deactiveTabDecoration;
          GlobalKey _key = GlobalKey();
          if (decoration == null) {
            return MaterialButton(
              key: _key,
              onPressed: () {
                setState(() {
                  Map<String, double> info =
                      UiUtils.getWidgetInfo(context, _key);
                  selectedTab = info;

                  selectedKey = _key;
                  _activeTabindex = e.index;
                  widget.controller.jumpToPage(e.index);
                  widget.onChange(e.index);

                  setState(() {});
                });
              },
              child: Text(e.tab.title),
            );
          }
          return decoration._buildButton(
            _key,
            context,
            child: Text(e.tab.title),
            onPressed: (info) {
              selectedTab = info;
              widget.controller.jumpToPage(e.index);
              _activeTabindex = e.index;
              widget.onChange(e.index);
              setState(() {});
            },
          );
        }).toList()
      ],
    );
  }
}

class MTab {
  final String title;
  final MTabDecoration? activeDecoration;
  final MTabDecoration? deactiveDecoration;
  MTab({required this.title, this.activeDecoration, this.deactiveDecoration});
}

class _IndexedMTab {
  final int index;
  final MTab tab;

  _IndexedMTab(this.index, this.tab);
}

class MTabDecoration {
  final Color? color;
  final Color? textColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final MaterialStateProperty<Color?>? overlayColor;
  final BorderSide? side;
  final MaterialTapTargetSize? tapTargetSize;
  final Duration? animationDuration;
  final Clip? clipBehavior;
  final FocusNode? focusNode;
  final bool? autofocus;

  MTabDecoration({
    this.color,
    this.textColor,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.overlayColor,
    this.side,
    this.tapTargetSize,
    this.animationDuration,
    this.clipBehavior,
    this.focusNode,
    this.autofocus,
  });

  // Helper method to create the MaterialButton
  MaterialButton _buildButton(GlobalKey key, BuildContext context,
      {required Widget child, Function(Map info)? onPressed}) {
    return MaterialButton(
      key: key,
      onPressed: () {
        Map<String, double> info = UiUtils.getWidgetInfo(context, key);

        onPressed?.call(info);
      },
      child: child,
      color: color,
      textColor: textColor,
      elevation: elevation,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8.0),
        side: side ?? BorderSide.none,
      ),
      materialTapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      focusNode: focusNode,
      onHighlightChanged: (isHighlighted) {
        // You can add any additional logic here when the button is highlighted.
      },
      onLongPress: () {
        // You can add any additional logic here when the button is long-pressed.
      },
      mouseCursor: SystemMouseCursors.click,
      enableFeedback: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      disabledColor: Colors.transparent,
      focusElevation: 0.0,
      hoverElevation: 0.0,
      highlightElevation: 0.0,
    );
  }
}

class RoundedMTabDecoration extends MTabDecoration {
  final Color borderColor;
  final double radius;
  final Color? tColor;
  final Color? buttonColor;

  RoundedMTabDecoration({
    required this.radius,
    required this.borderColor,
    this.tColor,
    this.buttonColor,
  });
  @override
  BorderRadius? get borderRadius => BorderRadius.circular(radius);
  @override
  Color? get textColor => tColor ?? super.textColor;
  @override
  Color? get color => buttonColor ?? super.color;

  @override
  BorderSide? get side => BorderSide(width: 1.5, color: borderColor);
}

class MTabView extends StatefulWidget {
  final PageController controller;
  final List<Widget> pages;
  const MTabView({Key? key, required this.controller, required this.pages})
      : super(key: key);

  @override
  State<MTabView> createState() => _MTabViewState();
}

class _MTabViewState extends State<MTabView> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: widget.controller,
      children: widget.pages,
    );
  }
}
