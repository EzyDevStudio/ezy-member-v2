import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/phone_detail.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Dialog: For action confirmation
class CustomConfirmationDialog extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final String message, title;
  final String? cancelText, confirmText;

  const CustomConfirmationDialog({
    super.key,
    required this.backgroundColor,
    required this.icon,
    required this.cancelText,
    required this.confirmText,
    required this.message,
    required this.title,
  });

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      constraints: const BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusM)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(kBorderRadiusM)),
              color: backgroundColor,
            ),
            height: kDialogHeight,
            padding: const EdgeInsets.all(kBorderRadiusM),
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Icon(icon, color: Colors.white),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(kBorderRadiusM)),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(kBorderRadiusM),
            child: Column(
              spacing: kBorderRadiusM,
              children: <Widget>[
                CustomText(title, fontSize: 24.0, fontWeight: FontWeight.bold, textAlign: TextAlign.center),
                CustomText(message, fontSize: 18.0, maxLines: null, textAlign: TextAlign.center),
                Row(
                  spacing: kBorderRadiusM,
                  children: <Widget>[
                    Expanded(
                      child: TextButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.black87),
                        onPressed: () => Navigator.pop(context, false),
                        child: CustomText(cancelText ?? "cancel".tr, fontSize: 18.0),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: CustomText(confirmText ?? "confirm".tr, color: Theme.of(context).colorScheme.onPrimary, fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  static Future<bool?> show(
    BuildContext context, {
    required Color backgroundColor,
    required IconData icon,
    String? cancelText,
    String? confirmText,
    required String message,
    required String title,
  }) => showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => CustomConfirmationDialog(
      backgroundColor: backgroundColor,
      icon: icon,
      cancelText: cancelText,
      confirmText: confirmText,
      message: message,
      title: title,
    ),
  );
}

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
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.l)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
        children: <Widget>[
          CustomSearchTextField(controller: _controller, onChanged: _onSearchChanged),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final PhoneDetail country = _filteredCountries[index];
                final String flag = PhoneDetail.countryCodeToEmoji(country.countryCode);

                return ListTile(
                  contentPadding: const EdgeInsets.all(0.0),
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
class CustomTypePickerDialog<T> extends StatelessWidget {
  final List<T> options;
  final String title;
  final String Function(T) onDisplay;

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
        spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
        children: <Widget>[
          CustomText(title, fontSize: 24.0, fontWeight: FontWeight.bold, textAlign: TextAlign.center),
          ...options.map((option) => ListTile(title: CustomText(onDisplay(option), fontSize: 16.0), onTap: () => Navigator.pop(context, option))),
        ],
      ),
    ),
  );

  static Future<T?> show<T>({
    required BuildContext context,
    required List<T> options,
    required String title,
    required String Function(T) onDisplay,
  }) => showDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: (context) => CustomTypePickerDialog<T>(options: options, title: title, onDisplay: onDisplay),
  );
}
