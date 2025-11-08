import 'package:responsive_framework/responsive_framework.dart';

class AppBreakpoints {
  const AppBreakpoints._();

  static const List<Breakpoint> defaults = <Breakpoint>[
    Breakpoint(start: 0, end: 450, name: PHONE),
    Breakpoint(start: 451, end: 800, name: TABLET),
    Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
  ];
}
