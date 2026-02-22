import 'package:dashbaord/extensions.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String)? onSearch;
  final TextEditingController? controller;
  final String hintText;
  final Color backgroundColor;
  final Color searchBarColor;
  final Color iconColor;

  const CustomSearchBar({
    super.key,
    this.onSearch,
    this.controller,
    this.hintText = 'Search for something',
    this.backgroundColor = Colors.black,
    this.searchBarColor = const Color(0xFF333333),
    this.iconColor = Colors.white,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isSearching = _focusNode.hasFocus;
    });
  }

  void _clearSearch() {
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _isSearching = false;
    });
    if (widget.onSearch != null) {
      widget.onSearch!('');
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: _isSearching
              ? MediaQuery.of(context).size.width - 78
              : MediaQuery.of(context).size.width - 40,
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              color: widget.searchBarColor,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.fromLTRB(8, 6, 2, 2),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              cursorColor: context.customColors.customAccentColor,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.grey[400]),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                ),
                hintText: !_isSearching && _controller.text.isEmpty ? widget.hintText : null,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                border: InputBorder.none,
              ),
              onSubmitted: widget.onSearch,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
        _isSearching
            ? AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: _isSearching ? 1.0 : 0.0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: IconButton(
                    icon: Icon(Icons.close, color: widget.iconColor, size: 30),
                    onPressed: _clearSearch,
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
