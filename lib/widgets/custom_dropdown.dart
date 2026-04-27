import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final List<T> items;
  final List<T> Function(String query) filter;
  final String hintText;
  final String Function(T item) displayString;
  final void Function(T selected) onSelected;

  const CustomDropdown({
    super.key,
    required this.controller,
    this.focusNode,
    required this.items,
    required this.filter,
    this.hintText = "",
    required this.displayString,
    required this.onSelected,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final GlobalKey _fieldKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  List<T> _filtered = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    _filtered = widget.items;
  }

  void _open() {
    _filtered = widget.items;
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onChanged(String value) {
    setState(() => _filtered = widget.filter(value));
    _overlayEntry == null ? _open() : _overlayEntry!.markNeedsBuild();
  }

  OverlayEntry _createOverlay() {
    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _close,
        child: Stack(
          children: <Widget>[
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                showWhenUnlinked: false,
                link: _layerLink,
                offset: Offset(0.0, size.height + 5.0),
                child: Material(
                  color: Colors.white,
                  elevation: 8.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250.0),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final item = _filtered[index];

                        return ListTile(
                          title: Text(widget.displayString(item)),
                          onTap: () {
                            widget.controller.text = widget.displayString(item);
                            widget.onSelected(item);
                            _close();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  UnderlineInputBorder _border(BuildContext context) => UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87.withValues(alpha: 0.05)));

  UnderlineInputBorder _focusedBorder(BuildContext context) => UnderlineInputBorder(
    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
  );

  Widget _title(BuildContext context) => Text.rich(
    TextSpan(
      children: <TextSpan>[
        TextSpan(
          text: widget.hintText,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );

  @override
  void dispose() {
    _close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    subtitle: CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _fieldKey,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12.dp),
            enabledBorder: _border(context),
            focusedBorder: _focusedBorder(context),
            hint: CustomText(widget.hintText, color: Colors.black38, fontSize: 16.0),
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          onTap: () => _overlayEntry == null ? _open() : _close(),
          onChanged: _onChanged,
        ),
      ),
    ),
    title: _title(context),
  );
}
