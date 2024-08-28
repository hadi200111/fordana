import 'package:CampusConnect/Library/MajorTile';
import 'package:flutter/material.dart';

class CategoryTile extends StatefulWidget {
  final String category;
  final Map<String, List<String>> majors;

  const CategoryTile({
    required this.category,
    required this.majors,
  });

  @override
  _CategoryTileState createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            widget.category,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
        ),
        if (_expanded)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.majors.length,
            itemBuilder: (BuildContext context, int index) {
              final major = widget.majors.keys.elementAt(index);
              final courses = widget.majors[major]!;
              return ListTile(
                title: Text(major),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var course in courses) Text(course),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
