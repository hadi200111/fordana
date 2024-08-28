import 'package:flutter/material.dart';

class HideableBottomNavigationBar extends StatefulWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HideableBottomNavigationBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _HideableBottomNavigationBarState createState() => _HideableBottomNavigationBarState();
}

class _HideableBottomNavigationBarState extends State<HideableBottomNavigationBar> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? kBottomNavigationBarHeight : 0.0,
      child: Wrap(
        children: [
          BottomNavigationBar(
            items: widget.items,
            currentIndex: widget.currentIndex,
            onTap: widget.onTap,
          ),
        ],
      ),
    );
  }

  void setVisibility(bool visible) {
    setState(() {
      isVisible = visible;
    });
  }
}
