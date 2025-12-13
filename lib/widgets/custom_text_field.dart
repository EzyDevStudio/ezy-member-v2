import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/phone_detail.dart';
import 'package:ezy_member_v2/widgets/custom_modal.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomIDTypeTextField extends StatefulWidget {
  final TextEditingController typeController, valueController;
  final bool? isRequired;
  final String label;

  const CustomIDTypeTextField({super.key, required this.typeController, required this.valueController, this.isRequired = false, required this.label});

  @override
  State<CustomIDTypeTextField> createState() => _CustomIDTypeTextFieldState();
}

class _CustomIDTypeTextFieldState extends State<CustomIDTypeTextField> {
  final List<String> _idTypes = AppStrings().idTypes;

  @override
  void initState() {
    super.initState();

    widget.typeController.text = widget.typeController.text.isEmpty ? _idTypes.first : widget.typeController.text;
  }

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.all(0.0),
    subtitle: Row(
      spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
      children: <Widget>[
        Expanded(
          flex: 1,
          child: TextField(
            controller: widget.typeController,
            readOnly: true,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: kTextFieldPaddingV),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87.withAlpha((0.05 * 255).round()))),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
              ),
              hint: CustomText("registration_scheme_id".tr, fontSize: 18.0, textAlign: TextAlign.center),
            ),
            onTap: () async {
              final pickedIDTypes = await CustomTypePickerDialog.show<String>(
                context: context,
                title: "pick_registration_type".tr,
                options: _idTypes,
                onDisplay: (option) => option,
              );

              if (pickedIDTypes != null) widget.typeController.text = pickedIDTypes;
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: widget.valueController,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: kTextFieldPaddingV),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87.withAlpha((0.05 * 255).round()))),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
              ),
              hint: CustomText(widget.label, color: Colors.black38, fontSize: 16.0),
            ),
          ),
        ),
      ],
    ),
    title: Text.rich(
      TextSpan(
        children: <TextSpan>[
          if (widget.isRequired!)
            const TextSpan(
              text: "* ",
              style: TextStyle(color: Colors.red),
            ),
          TextSpan(
            text: widget.label,
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.linear(ResponsiveHelper.getTextScaler(context)),
    ),
    trailing: Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.primary),
  );
}

class CustomOutlinedTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool? isPassword;
  final IconData icon;
  final String label;

  const CustomOutlinedTextField({super.key, required this.controller, this.isPassword, required this.icon, required this.label});

  @override
  State<CustomOutlinedTextField> createState() => _CustomOutlinedTextFieldState();
}

class _CustomOutlinedTextFieldState extends State<CustomOutlinedTextField> {
  late bool _isShow;

  @override
  void initState() {
    super.initState();

    _isShow = widget.isPassword ?? false;
  }

  @override
  Widget build(BuildContext context) => Material(
    borderRadius: BorderRadius.circular(kBorderRadiusS),
    elevation: kElevation,
    child: TextField(
      controller: widget.controller,
      obscureText: _isShow,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getSpacing(context, SizeType.s),
          vertical: ResponsiveHelper.getSpacing(context, SizeType.m),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadiusS), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusS),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
        ),
        hintText: widget.label,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.isPassword != true
            ? null
            : IconButton(
                onPressed: () => setState(() => _isShow = !_isShow),
                icon: Icon(_isShow ? Icons.visibility_rounded : Icons.visibility_off_rounded),
              ),
      ),
    ),
  );
}

class CustomPhoneTextField extends StatefulWidget {
  final TextEditingController controller;
  final PhoneDetail? phone;
  final ValueChanged<PhoneDetail> onChanged;

  const CustomPhoneTextField({super.key, required this.controller, this.phone, required this.onChanged});

  @override
  State<CustomPhoneTextField> createState() => _CustomPhoneTextFieldState();
}

class _CustomPhoneTextFieldState extends State<CustomPhoneTextField> {
  late PhoneDetail _selectedPhoneDetail;

  @override
  void initState() {
    super.initState();

    _selectedPhoneDetail = widget.phone ?? PhoneDetail();
  }

  void _updatePhoneDetail(PhoneDetail phoneDetail) {
    setState(() => _selectedPhoneDetail = phoneDetail);
    widget.onChanged.call(_selectedPhoneDetail);
  }

  @override
  Widget build(BuildContext context) => Material(
    borderRadius: BorderRadius.circular(kBorderRadiusS),
    elevation: kElevation,
    child: Row(
      spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
      children: <Widget>[
        Expanded(
          flex: 1,
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
              hint: CustomText(_selectedPhoneDetail.displayFlagCode, fontSize: 16.0, textAlign: TextAlign.center),
            ),
            onTap: () async {
              final selectedPhone = await CustomCountryPickerDialog.show(context);

              if (selectedPhone != null) _updatePhoneDetail(selectedPhone);
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(context, SizeType.s),
                vertical: ResponsiveHelper.getSpacing(context, SizeType.m),
              ),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadiusS), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kBorderRadiusS),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
              ),
              hintText: _selectedPhoneDetail.hintLabel,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(kPhoneLength)],
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              _selectedPhoneDetail.number = value;
              widget.onChanged.call(_selectedPhoneDetail);
            },
          ),
        ),
      ],
    ),
  );
}

class CustomProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool? enabled;
  final bool? isRequired;
  final String label;
  final VoidCallback? onTap;

  const CustomProfileTextField({super.key, required this.controller, this.enabled = true, this.isRequired = false, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.all(0.0),
    onTap: enabled! ? onTap : null,
    subtitle: TextField(
      controller: controller,
      readOnly: onTap != null,
      enabled: enabled,
      decoration: InputDecoration(
        isCollapsed: true,
        contentPadding: const EdgeInsets.symmetric(vertical: kTextFieldPaddingV),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87.withAlpha((0.05 * 255).round()))),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
        ),
        hint: CustomText("msg_hint_text".trParams({"label": label.toLowerCase()}), color: Colors.black38, fontSize: 16.0),
      ),
      onTap: onTap,
    ),
    title: Text.rich(
      TextSpan(
        children: <TextSpan>[
          if (isRequired!)
            const TextSpan(
              text: "* ",
              style: TextStyle(color: Colors.red),
            ),
          TextSpan(
            text: label,
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.linear(ResponsiveHelper.getTextScaler(context)),
    ),
    trailing: Icon(
      onTap == null ? Icons.edit_rounded : Icons.arrow_forward_ios_rounded,
      color: enabled! ? Theme.of(context).colorScheme.primary : Colors.transparent,
    ),
  );
}

class CustomProfilePhoneTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool? isRequired;
  final PhoneDetail? phone;
  final String label;
  final ValueChanged<PhoneDetail> onChanged;

  const CustomProfilePhoneTextField({
    super.key,
    required this.controller,
    this.isRequired = false,
    this.phone,
    required this.label,
    required this.onChanged,
  });

  @override
  State<CustomProfilePhoneTextField> createState() => _CustomProfilePhoneTextFieldState();
}

class _CustomProfilePhoneTextFieldState extends State<CustomProfilePhoneTextField> {
  late PhoneDetail _selectedPhoneDetail;

  @override
  void initState() {
    super.initState();

    _selectedPhoneDetail = widget.phone ?? PhoneDetail();
  }

  void _updatePhoneDetail(PhoneDetail phoneDetail) {
    setState(() => _selectedPhoneDetail = phoneDetail);
    widget.onChanged.call(_selectedPhoneDetail);
  }

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.all(0.0),
    subtitle: Row(
      spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
      children: <Widget>[
        Expanded(
          flex: 1,
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: kTextFieldPaddingV),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87.withAlpha((0.05 * 255).round()))),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
              ),
              hint: CustomText(_selectedPhoneDetail.displayFlagCode, fontSize: 16.0, textAlign: TextAlign.center),
            ),
            onTap: () async {
              final selectedPhone = await CustomCountryPickerDialog.show(context);

              if (selectedPhone != null) _updatePhoneDetail(selectedPhone);
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(vertical: kTextFieldPaddingV),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87.withAlpha((0.05 * 255).round()))),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
              ),
              hint: CustomText(_selectedPhoneDetail.hintLabel, color: Colors.black38, fontSize: 16.0),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(kPhoneLength)],
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              _selectedPhoneDetail.number = value;
              widget.onChanged.call(_selectedPhoneDetail);
            },
          ),
        ),
      ],
    ),
    title: Text.rich(
      TextSpan(
        children: <TextSpan>[
          if (widget.isRequired!)
            const TextSpan(
              text: "* ",
              style: TextStyle(color: Colors.red),
            ),
          TextSpan(
            text: widget.label,
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.linear(ResponsiveHelper.getTextScaler(context)),
    ),
    trailing: Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.primary),
  );
}

class CustomSearchTextField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const CustomSearchTextField({super.key, required this.controller, this.onChanged});

  @override
  State<CustomSearchTextField> createState() => _CustomSearchTextFieldState();
}

class _CustomSearchTextFieldState extends State<CustomSearchTextField> {
  @override
  Widget build(BuildContext context) => Material(
    borderRadius: BorderRadius.circular(kBorderRadiusS),
    elevation: kElevation,
    child: TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getSpacing(context, SizeType.m),
          vertical: ResponsiveHelper.getSpacing(context, SizeType.s),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadiusS), borderSide: BorderSide.none),
        hintText: "search".tr,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: widget.controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged?.call("");
                  setState(() {});
                },
                icon: const Icon(Icons.cancel_rounded),
              ),
      ),
      onChanged: (value) {
        setState(() {});
        widget.onChanged?.call(value);
      },
    ),
  );
}
