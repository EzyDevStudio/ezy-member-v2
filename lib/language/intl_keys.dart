import 'package:ezymember/language/intl/en_US.dart';
import 'package:ezymember/language/intl/ms_MY.dart';
import 'package:ezymember/language/intl/zh_CN.dart';
import 'package:get/get_navigation/src/root/internacionalization.dart';

class IntlKeys extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {"en_US": EnUs.keys, "zh_CN": ZhCn.keys, "ms_MY": MsMy.keys};
}
