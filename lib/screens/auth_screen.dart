import 'dart:math';

import 'package:NewtypeS/widgets/auth_card.dart';
import 'package:flutter/material.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(253, 239, 249, 1).withOpacity(0.5),
                    Color.fromRGBO(236, 56, 182, 1).withOpacity(0.6),
                    Color.fromRGBO(123, 3, 192, 1).withOpacity(0.7),
                    Color.fromRGBO(3, 0, 30, 1).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 40.0),
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 60.0),
                      transform: Matrix4.rotationZ(-10 * pi / 180)
                        ..translate(-10.0),

                      //? .. calls transalte on the Matrix4 object but returns what rotationZ returns.
                      //* Matrix4.rotationZ(-8 * pi / 180).translate(-10.0) chain will become void

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.red.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black26,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage(
                              "assets/icon/unicorn.jpg",
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'NewTypeS',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontFamily: 'Anton',
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
