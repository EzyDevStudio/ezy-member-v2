import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/phone_detail.dart';
import 'package:ezymember/widgets/custom_modal.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum OutlinedType { text, password, phone }

enum UnderlineType { text, phone }

class CustomOutlinedTextField extends StatefulWidget {
  final TextEditingController controller;
  final IconData? icon;
  final List<TextInputFormatter>? inputFormatters;
  final OutlinedType type;
  final PhoneDetail? phone;
  final String label;
  final TextInputType? keyboardType;
  final ValueChanged<PhoneDetail>? onPhoneChanged;

  const CustomOutlinedTextField({
    super.key,
    required this.controller,
    this.icon,
    this.inputFormatters,
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
    contentPadding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 16.dp),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadiusS), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusS),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: kBorderWidth),
    ),
    hintText: hint,
    prefixIcon: prefix != null
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.dp),
            child: prefix,
          )
        : null,
    suffixIcon: suffix != null
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.dp),
            child: suffix,
          )
        : null,
  );

  @override
  Widget build(BuildContext context) => Material(
    borderRadius: BorderRadius.circular(kBorderRadiusS),
    color: Colors.white,
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
    inputFormatters: widget.inputFormatters,
    textInputAction: TextInputAction.next,
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
            contentPadding: EdgeInsets.symmetric(vertical: 12.dp),
            border: InputBorder.none,
            hint: CustomText(_phoneDetail.displayFlagCode, fontSize: 16.0, textAlign: TextAlign.center),
          ),
          onTap: () async {
            PhoneDetail? phone = await CustomPickerDialog.show<PhoneDetail>(
              context,
              loadItems: PhoneDetail.loadAll,
              toCompare: (item) => item.toCompare(),
              itemTileBuilder: (context, item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CustomText(PhoneDetail.countryCodeToEmoji(item.countryCode), fontSize: 25.0),
                subtitle: CustomText(item.countryCode, color: Colors.black54, fontSize: 14.0),
                title: CustomText(item.country, fontSize: 16.0),
                trailing: CustomText("+${item.dialCode}", fontSize: 14.0),
              ),
            );

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
          textInputAction: TextInputAction.next,
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
  final ValueChanged<String>? onChanged, onSubmit;
  final VoidCallback? onClear;

  const CustomSearchTextField({super.key, required this.controller, this.onChanged, this.onSubmit, this.onClear});

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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 8.dp),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(kBorderRadiusS), borderSide: BorderSide.none),
        hintText: Globalization.search.tr,
        prefixIcon: widget.controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  widget.controller.clear();
                  widget.onClear?.call();
                  setState(() {});
                },
                icon: const Icon(Icons.cancel_rounded),
              ),
        suffixIcon: IconButton(onPressed: () => widget.onSubmit?.call(widget.controller.text.trim()), icon: const Icon(Icons.search_rounded)),
      ),
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        setState(() {});
        widget.onChanged?.call(value.trim());
      },
      onSubmitted: (value) => widget.onSubmit?.call(value.trim()),
    ),
  );
}

class CustomUnderlineTextField extends StatefulWidget {
  final TextEditingController? controller, typeController, valueController;
  final FocusNode? focusNode;
  final bool enabled, isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final PhoneDetail? phone;
  final String label;
  final UnderlineType? type;
  final TextInputType? keyboardType;
  final ValueChanged<PhoneDetail>? onPhoneChanged;
  final ValueChanged<String>? onChanged, onSubmitted;
  final VoidCallback? onTap;

  const CustomUnderlineTextField({
    super.key,
    this.controller,
    this.typeController,
    this.valueController,
    this.focusNode,
    this.enabled = true,
    this.isRequired = false,
    this.inputFormatters,
    this.phone,
    required this.label,
    this.type = UnderlineType.text,
    this.keyboardType,
    this.onPhoneChanged,
    this.onChanged,
    this.onSubmitted,
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
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    subtitle: _buildField(context),
    title: _title(context),
    trailing: widget.onTap != null
        ? Icon(Icons.arrow_forward_ios_rounded, color: widget.enabled ? Theme.of(context).colorScheme.primary : Colors.transparent)
        : null,
    onTap: widget.enabled ? widget.onTap : null,
  );

  Widget _buildField(BuildContext context) {
    switch (widget.type!) {
      case UnderlineType.text:
        return _textField(context);
      case UnderlineType.phone:
        return _phoneField(context);
    }
  }

  Widget _textField(BuildContext context) => TextField(
    controller: widget.controller,
    focusNode: widget.focusNode,
    readOnly: widget.onTap != null,
    enabled: widget.enabled,
    decoration: InputDecoration(
      isCollapsed: true,
      contentPadding: EdgeInsets.symmetric(vertical: 12.dp),
      enabledBorder: _border(context),
      focusedBorder: _focusedBorder(context),
      hint: CustomText(Globalization.msgHintText.trParams({"label": widget.label.toLowerCase()}), color: Colors.black38, fontSize: 16.0),
    ),
    inputFormatters: widget.inputFormatters,
    textInputAction: TextInputAction.next,
    keyboardType: widget.keyboardType,
    onTap: widget.onTap,
    onChanged: widget.onChanged,
    onSubmitted: widget.onSubmitted,
  );

  Widget _phoneField(BuildContext context) => Row(
    spacing: 16.dp,
    children: <Widget>[
      Expanded(
        flex: 1,
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 12.dp),
            enabledBorder: _border(context),
            focusedBorder: _focusedBorder(context),
            hint: CustomText(_phoneDetail.displayFlagCode, fontSize: 16.0, textAlign: TextAlign.center),
          ),
          onTap: () async {
            PhoneDetail? phone = await CustomPickerDialog.show<PhoneDetail>(
              context,
              loadItems: PhoneDetail.loadAll,
              toCompare: (item) => item.toCompare(),
              itemTileBuilder: (context, item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CustomText(PhoneDetail.countryCodeToEmoji(item.countryCode), fontSize: 25.0),
                subtitle: CustomText(item.countryCode, color: Colors.black54, fontSize: 14.0),
                title: CustomText(item.country, fontSize: 16.0),
                trailing: CustomText("+${item.dialCode}", fontSize: 14.0),
              ),
            );

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
            contentPadding: EdgeInsets.symmetric(vertical: 12.dp),
            enabledBorder: _border(context),
            focusedBorder: _focusedBorder(context),
            hint: CustomText(_phoneDetail.hintLabel, color: Colors.black38, fontSize: 16.0),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(kPhoneLength)],
          textInputAction: TextInputAction.next,
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
