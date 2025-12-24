import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/phone_detail.dart';
import 'package:ezy_member_v2/widgets/custom_modal.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum OutlinedType { text, password, phone }

enum UnderlineType { text, idType, phone }

class CustomOutlinedTextField extends StatefulWidget {
  final TextEditingController controller;
  final IconData? icon;
  final OutlinedType type;
  final PhoneDetail? phone;
  final String label;
  final TextInputType? keyboardType;
  final ValueChanged<PhoneDetail>? onPhoneChanged;

  const CustomOutlinedTextField({
    super.key,
    required this.controller,
    this.icon,
    required this.type,
    this.phone,
    required this.label,
    this.keyboardType,
    this.onPhoneChanged,
  });

  @override
  State<CustomOutlinedTextField> createState() => _CustomOutlinedTextFieldState();
}

class _CustomOutlinedTextFieldState extends State<CustomOutlinedTextField> {
  late bool _isObscure;
  late PhoneDetail _phoneDetail;

  @override
  void initState() {
    super.initState();

    _isObscure = widget.type == OutlinedType.password;
    _phoneDetail = widget.phone ?? PhoneDetail();
  }

  InputDecoration _decoration(BuildContext context, {Widget? prefix, Widget? suffix, String? hint}) => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 8.0), vertical: ResponsiveHelper.getSpacing(context, 16.0)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadiusS), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusS),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
    ),
    hintText: hint,
    prefixIcon: prefix,
    suffixIcon: suffix,
  );

  @override
  Widget build(BuildContext context) => Material(
    borderRadius: BorderRadius.circular(kBorderRadiusS),
    elevation: kElevation,
    child: widget.type == OutlinedType.phone ? _buildPhoneField(context) : _buildNormalField(context),
  );

  Widget _buildNormalField(BuildContext context) => TextField(
    controller: widget.controller,
    obscureText: widget.type == OutlinedType.password && _isObscure,
    decoration: _decoration(
      context,
      hint: widget.label,
      prefix: widget.icon != null ? Icon(widget.icon) : null,
      suffix: widget.type != OutlinedType.password
          ? null
          : IconButton(
              onPressed: () => setState(() => _isObscure = !_isObscure),
              icon: Icon(_isObscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
            ),
    ),
    keyboardType: widget.keyboardType,
  );

  Widget _buildPhoneField(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        flex: 1,
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
            border: InputBorder.none,
            hint: CustomText(_phoneDetail.displayFlagCode, fontSize: 16.0, textAlign: TextAlign.center),
          ),
          onTap: () async {
            final phone = await CustomCountryPickerDialog.show(context);

            if (phone != null) {
              setState(() => _phoneDetail = phone);
              widget.onPhoneChanged?.call(_phoneDetail);
            }
          },
        ),
      ),
      Expanded(
        flex: 3,
        child: TextField(
          controller: widget.controller,
          decoration: _decoration(context, hint: _phoneDetail.hintLabel),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(kPhoneLength)],
          keyboardType: widget.keyboardType,
          onChanged: (value) {
            _phoneDetail.number = value;
            widget.onPhoneChanged?.call(_phoneDetail);
          },
        ),
      ),
    ],
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
          horizontal: ResponsiveHelper.getSpacing(context, 16.0),
          vertical: ResponsiveHelper.getSpacing(context, 8.0),
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

class CustomUnderlineTextField extends StatefulWidget {
  final TextEditingController? controller, typeController, valueController;
  final bool enabled, isRequired;
  final PhoneDetail? phone;
  final String label;
  final UnderlineType? type;
  final TextInputType? keyboardType;
  final ValueChanged<PhoneDetail>? onPhoneChanged;
  final VoidCallback? onTap;

  const CustomUnderlineTextField({
    super.key,
    this.controller,
    this.typeController,
    this.valueController,
    this.enabled = true,
    this.isRequired = false,
    this.phone,
    required this.label,
    this.type = UnderlineType.text,
    this.keyboardType,
    this.onPhoneChanged,
    this.onTap,
  });

  @override
  State<CustomUnderlineTextField> createState() => _CustomUnderlineTextFieldState();
}

class _CustomUnderlineTextFieldState extends State<CustomUnderlineTextField> {
  late PhoneDetail _phoneDetail;

  @override
  void initState() {
    super.initState();

    _phoneDetail = widget.phone ?? PhoneDetail();
  }

  UnderlineInputBorder _border(BuildContext context) => UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87.withValues(alpha: 0.05)));

  UnderlineInputBorder _focusedBorder(BuildContext context) => UnderlineInputBorder(
    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
  );

  Widget _title(BuildContext context) => Text.rich(
    TextSpan(
      children: <TextSpan>[
        if (widget.isRequired)
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
  );

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    subtitle: _buildField(context),
    title: _title(context),
    trailing: Icon(
      widget.onTap == null ? Icons.edit_rounded : Icons.arrow_forward_ios_rounded,
      color: widget.enabled ? Theme.of(context).colorScheme.primary : Colors.transparent,
    ),
    onTap: widget.enabled ? widget.onTap : null,
  );

  Widget _buildField(BuildContext context) {
    switch (widget.type!) {
      case UnderlineType.text:
        return _textField(context);
      case UnderlineType.idType:
        return _idTypeField(context);
      case UnderlineType.phone:
        return _phoneField(context);
    }
  }

  Widget _textField(BuildContext context) => TextField(
    controller: widget.controller,
    readOnly: widget.onTap != null,
    enabled: widget.enabled,
    decoration: InputDecoration(
      isCollapsed: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
      enabledBorder: _border(context),
      focusedBorder: _focusedBorder(context),
      hint: CustomText("msg_hint_text".trParams({"label": widget.label.toLowerCase()}), color: Colors.black38, fontSize: 16.0),
    ),
    keyboardType: widget.keyboardType,
    onTap: widget.onTap,
  );

  Widget _idTypeField(BuildContext context) => Row(
    spacing: ResponsiveHelper.getSpacing(context, 16.0),
    children: <Widget>[
      Expanded(
        flex: 1,
        child: TextField(
          controller: widget.typeController,
          readOnly: true,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
            enabledBorder: _border(context),
            focusedBorder: _focusedBorder(context),
            hint: CustomText("registration_scheme_id".tr, fontSize: 16.0, textAlign: TextAlign.center),
          ),
          onTap: widget.onTap,
        ),
      ),
      Expanded(
        flex: 3,
        child: TextField(
          controller: widget.valueController,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
            enabledBorder: _border(context),
            focusedBorder: _focusedBorder(context),
            hint: CustomText(widget.label, color: Colors.black38, fontSize: 16.0),
          ),
          keyboardType: widget.keyboardType,
        ),
      ),
    ],
  );

  Widget _phoneField(BuildContext context) => Row(
    spacing: ResponsiveHelper.getSpacing(context, 16.0),
    children: <Widget>[
      Expanded(
        flex: 1,
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
            enabledBorder: _border(context),
            focusedBorder: _focusedBorder(context),
            hint: CustomText(_phoneDetail.displayFlagCode, fontSize: 16.0, textAlign: TextAlign.center),
          ),
          onTap: () async {
            final phone = await CustomCountryPickerDialog.show(context);

            if (phone != null) {
              setState(() => _phoneDetail = phone);
              widget.onPhoneChanged?.call(_phoneDetail);
            }
          },
        ),
      ),
      Expanded(
        flex: 3,
        child: TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
            enabledBorder: _border(context),
            focusedBorder: _focusedBorder(context),
            hint: CustomText(_phoneDetail.hintLabel, color: Colors.black38, fontSize: 16.0),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(kPhoneLength)],
          keyboardType: widget.keyboardType,
          onChanged: (value) {
            _phoneDetail.number = value;
            widget.onPhoneChanged?.call(_phoneDetail);
          },
        ),
      ),
    ],
  );
}
