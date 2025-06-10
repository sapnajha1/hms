import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._private();
  NavigationService._private();

  static NavigationService get instance => _instance;

  GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();
  RouteObserver<Route<dynamic>> routeObserver = RouteObserver<Route<dynamic>>();

  BuildContext? get appContext => navigationKey.currentContext;

  Future<T?> pushNamed<T extends Object>(String routeName, {Object? args}) async {
    return navigationKey.currentState?.pushNamed<T>(
      routeName,
      arguments: args,
    );
  }

  Future<T?> pushNamedIfNotCurrent<T extends Object>(String routeName, {Object? args}) async {
    if (!isCurrent(routeName)) {
      return pushNamed(routeName, args: args);
    }
    return null;
  }

  bool isCurrent(String routeName) {
    bool isCurrent = false;
    navigationKey.currentState!.popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }

  void goBack<T extends Object>({T? result}) {
    navigationKey.currentState?.pop<T>(result);
  }
}







