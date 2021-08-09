import 'package:flutter/material.dart';

//* For single route
class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({builder, settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // TODO: implement buildTransitions
    if (settings.name == '/') return child;

    //* Fade Transition only and no Pushing From the Bottom
    return FadeTransition(opacity: animation);
  }
}

//* General Theme affects all route transitions
class CustomPageTransitionBuild extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    // TODO: implement buildTransitions
    if (route.settings.name == '/') return child;

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
