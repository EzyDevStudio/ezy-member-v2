import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

typedef ToCompare<T> = String Function(T item);
typedef WidgetBuilder<T> = Widget Function(BuildContext context, T item);

class CustomPickerDialog<T> extends StatefulWidget {
  final Future<List<T>> Function() loadItems;
  final ToCompare<T> toCompare;
  final WidgetBuilder<T> itemTileBuilder;

  const CustomPickerDialog({super.key, required this.loadItems, required this.toCompare, required this.itemTileBuilder});

  static Future<T?> show<T>(
    BuildContext context, {
    required Future<List<T>> Function() loadItems,
    required ToCompare<T> toCompare,
    required WidgetBuilder<T> itemTileBuilder,
  }) async => showDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: (context) => CustomPickerDialog<T>(loadItems: loadItems, toCompare: toCompare, itemTileBuilder: itemTileBuilder),
  );

  @override
  State<CustomPickerDialog<T>> createState() => _CustomPickerDialogState<T>();
}

class _CustomPickerDialogState<T> extends State<CustomPickerDialog<T>> {
  final TextEditingController _controller = TextEditingController();

  List<T> _items = [];
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();

    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await widget.loadItems();

    if (!mounted) return;

    setState(() {
      _items = items;
      _filteredItems = items;
    });
  }

  void _onSearchChanged(String value) {
    final search = value.toLowerCase();

    setState(() => _filteredItems = _items.where((item) => widget.toCompare(item).toLowerCase().contains(search)).toList());
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusS), color: Colors.white),
      padding: EdgeInsets.all(24.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16.dp,
        children: <Widget>[
          CustomSearchTextField(controller: _controller, onChanged: _onSearchChanged),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) =>
                  InkWell(onTap: () => Navigator.pop(context, _filteredItems[index]), child: widget.itemTileBuilder(context, _filteredItems[index])),
            ),
          ),
        ],
      ),
    ),
  );
}

// Dialog: Displays a selectable list of "Items"
class CustomTypePickerDialog<K, V> extends StatelessWidget {
  final Map<K, V> options;
  final String title;
  final String Function(V) onDisplay;

  const CustomTypePickerDialog({super.key, required this.options, required this.title, required this.onDisplay});

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusM), color: Colors.white),
      padding: const EdgeInsets.all(kBorderRadiusM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16.dp,
        children: <Widget>[
          CustomText(title, fontSize: 24.0, fontWeight: FontWeight.bold, textAlign: TextAlign.center),
          ...options.entries.map(
            (entry) => ListTile(title: CustomText(onDisplay(entry.value), fontSize: 16.0), onTap: () => Navigator.pop(context, entry)),
          ),
        ],
      ),
    ),
  );

  static Future<MapEntry<K, V>?> show<K, V>({
    required BuildContext context,
    required Map<K, V> options,
    required String title,
    required String Function(V) onDisplay,
  }) => showDialog<MapEntry<K, V>>(
    context: context,
    barrierDismissible: true,
    builder: (context) => CustomTypePickerDialog<K, V>(options: options, title: title, onDisplay: onDisplay),
  );
}
