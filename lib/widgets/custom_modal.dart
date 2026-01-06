import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/phone_detail.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

// Dialog: For selecting a country
class CustomCountryPickerDialog extends StatefulWidget {
  const CustomCountryPickerDialog({super.key});

  @override
  State<CustomCountryPickerDialog> createState() => _CustomCountryPickerDialogState();

  static Future<PhoneDetail?> show(BuildContext context) async {
    return showDialog<PhoneDetail>(context: context, barrierDismissible: true, builder: (context) => const CustomCountryPickerDialog());
  }
}

class _CustomCountryPickerDialogState extends State<CustomCountryPickerDialog> {
  final TextEditingController _controller = TextEditingController();

  List<PhoneDetail> _countries = [];
  List<PhoneDetail> _filteredCountries = [];

  @override
  void initState() {
    super.initState();

    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final List<PhoneDetail> countries = await PhoneDetail.loadAll();

    if (mounted) {
      setState(() {
        _countries = countries;
        _filteredCountries = countries;
      });
    }
  }

  void _onSearchChanged(String value) {
    final String search = value.toLowerCase();

    setState(
      () => _filteredCountries = _countries.where((country) {
        return country.country.toLowerCase().contains(search) ||
            country.countryCode.toLowerCase().contains(search) ||
            country.dialCode.toLowerCase().contains(search);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      constraints: const BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusS), color: Colors.white),
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 24.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: ResponsiveHelper.getSpacing(context, 16.0),
        children: <Widget>[
          CustomSearchTextField(controller: _controller, onChanged: _onSearchChanged),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final PhoneDetail country = _filteredCountries[index];
                final String flag = PhoneDetail.countryCodeToEmoji(country.countryCode);

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => Navigator.pop(context, country),
                  leading: CustomText(flag, fontSize: 25.0),
                  subtitle: CustomText(country.countryCode, color: Colors.black54, fontSize: 14.0),
                  title: CustomText(country.country, fontSize: 16.0),
                  trailing: CustomText("+${country.dialCode}", fontSize: 14.0),
                );
              },
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
      constraints: const BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusM), color: Colors.white),
      padding: const EdgeInsets.all(kBorderRadiusM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: ResponsiveHelper.getSpacing(context, 16.0),
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
