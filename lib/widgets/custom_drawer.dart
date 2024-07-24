import 'package:diamond_booking/screen/chat_request_screen.dart';
import 'package:diamond_booking/screen/customer_points.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../general_provider.dart';
import '../localization/language_constants.dart';
import '../main.dart';
import '../page/Estate.dart';
import '../resources/auth_methods.dart';
import '../screen/all_posts_screen.dart';
import '../page/notification_user.dart';
import '../screen/profile_screen.dart';
import '../page/request.dart';
import '../page/type_estate.dart';
import '../page/upgrade_account.dart';
import '../screen/user_type_screen.dart';
import '../widgets/item_drawer.dart';
import 'package:badges/badges.dart' as badges;
// class CustomDrawer extends StatelessWidget {
//   final Map dataUser;
//   final String id;
//
//   const CustomDrawer({super.key, required this.dataUser, required this.id});
//
//   @override
//   Widget build(BuildContext context) {
//     final objProvider = Provider.of<GeneralProvider>(context, listen: false);
//     String userType = dataUser['TypeUser'];
//
//     return Drawer(
//       child: SafeArea(
//         child: ListView(
//           children: [
//             Container(height: 25),
//             SizedBox(
//               child: Image.asset(
//                 "assets/images/logo.png",
//                 width: 17.w,
//                 height: 17.h,
//               ),
//             ),
//             Container(height: 25),
//             DrawerItem(
//               text: getTranslated(context, "Profile"),
//               icon: const Icon(Icons.person, color: kPrimaryColor),
//               onTap: () {
//                 Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => const ProfileScreenUser()));
//               },
//               hint: getTranslated(
//                 context,
//                 "You can view your data here",
//               ),
//             ),
//             DrawerItem(
//               text: getTranslated(context, "Posts"),
//               icon: const Icon(Icons.person, color: kPrimaryColor),
//               onTap: () {
//                 Navigator.of(context)
//                     .push(MaterialPageRoute(builder: (context) => AllPost()));
//               },
//               hint: "Show the Post ",
//             ),
//             Visibility(
//               visible: userType != "1",
//               child: DrawerItem(
//                 icon: const Icon(Icons.add, color: kPrimaryColor),
//                 onTap: () {
//                   if (id != "null") {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => TypeEstate(Check: "Add")));
//                   } else {
//                     objProvider.FunSnackBarPage(
//                         getTranslated(context, "Please login first"), context);
//                   }
//                 },
//                 hint: getTranslated(
//                   context,
//                   "From here you can add new estate",
//                 ),
//                 text: getTranslated(
//                   context,
//                   "Add Estate",
//                 ),
//               ),
//             ),
//             Visibility(
//               visible: userType != "1",
//               child: DrawerItem(
//                 text: getTranslated(
//                   context,
//                   "My Estate",
//                 ),
//                 icon: const Icon(Icons.home, color: kPrimaryColor),
//                 onTap: () {
//                   if (id != "null") {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => TypeEstate(Check: "Edite")));
//                   } else {
//                     objProvider.FunSnackBarPage(
//                         getTranslated(context, "Please login first"), context);
//                   }
//                 },
//                 hint: getTranslated(
//                   context,
//                   "From here you can Edit your estate",
//                 ),
//               ),
//             ),
//             Visibility(
//               visible: userType != "1",
//               child: DrawerItem(
//                 text: getTranslated(
//                   context,
//                   "Request",
//                 ),
//                 icon: const Icon(Icons.account_box, color: kPrimaryColor),
//                 onTap: () {
//                   Navigator.of(context)
//                       .push(MaterialPageRoute(builder: (context) => Request()));
//                 },
//                 hint: getTranslated(context,
//                     "From here you can see the reservations for your estate"),
//               ),
//             ),
//             Visibility(
//               visible: true,
//               child: DrawerItem(
//                 text: getTranslated(
//                   context,
//                   "Notification",
//                 ),
//                 icon: const Icon(Icons.notification_add, color: kPrimaryColor),
//                 onTap: () {
//                   Navigator.of(context).push(MaterialPageRoute(
//                       builder: (context) => NotificationUser()));
//                 },
//                 hint: getTranslated(
//                   context,
//                   "You can see the notifications that come to you, such as booking confirmation",
//                 ),
//               ),
//             ),
//             Visibility(
//               visible: userType != "1",
//               child: DrawerItem(
//                 text: getTranslated(
//                   context,
//                   "Chat for Estate",
//                 ),
//                 icon: const Icon(Icons.chat, color: kPrimaryColor),
//                 onTap: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => TypeEstate(Check: "chat"),
//                     ),
//                   );
//                 },
//                 hint: getTranslated(
//                   context,
//                   "From here you can see the conversations that take place on your estate",
//                 ),
//               ),
//             ),
//             Visibility(
//               visible: true,
//               child: DrawerItem(
//                 text: getTranslated(
//                   context,
//                   "Chat for U",
//                 ),
//                 icon: const Icon(
//                   Icons.chat,
//                   color: kPrimaryColor,
//                 ),
//                 onTap: () {
//                   Navigator.of(context).push(MaterialPageRoute(
//                       builder: (context) => TypeEstate(Check: "chatuser")));
//                 },
//                 hint: getTranslated(
//                   context,
//                   "From here you can see the your conversations as user",
//                 ),
//               ),
//             ),
//             DrawerItem(
//               text: getTranslated(
//                 context,
//                 "upgrade account",
//               ),
//               icon: const Icon(
//                 Icons.update,
//                 color: kPrimaryColor,
//               ),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).push(
//                     MaterialPageRoute(builder: (context) => UpgradeAccount()));
//               },
//               hint: getTranslated(
//                 context,
//                 "From here you can upgrade account to Vip",
//               ),
//             ),
//             DrawerItem(
//               text: getTranslated(
//                 context,
//                 "Arabic",
//               ),
//               icon: const Icon(Icons.language, color: kPrimaryColor),
//               onTap: () async {
//                 SharedPreferences sharedPreferences =
//                 await SharedPreferences.getInstance();
//                 sharedPreferences.setString("Language", "ar");
//                 Locale newLocale = const Locale("ar", "SA");
//                 MyApp.setLocale(context, newLocale);
//               },
//               hint: getTranslated(
//                 context,
//                 "",
//               ),
//             ),
//             DrawerItem(
//               text: getTranslated(context, "English"),
//               icon: const Icon(Icons.language, color: kPrimaryColor),
//               onTap: () async {
//                 SharedPreferences sharedPreferences =
//                 await SharedPreferences.getInstance();
//                 sharedPreferences.setString("Language", "en");
//                 Locale newLocale = const Locale("en", "SA");
//                 MyApp.setLocale(context, newLocale);
//               },
//               hint: getTranslated(
//                 context,
//                 '',
//               ),
//             ),
//             DrawerItem(
//               text: getTranslated(
//                 context,
//                 "Logout",
//               ),
//               icon: const Icon(Icons.logout, color: kPrimaryColor),
//               onTap: () async {
//                 SharedPreferences sharedPreferences =
//                 await SharedPreferences.getInstance();
//                 await sharedPreferences.clear();
//                 Navigator.of(context).pushReplacement(MaterialPageRoute(
//                     builder: (context) => const ChooseTypeUser()));
//               },
//               hint: getTranslated(
//                 context,
//                 '',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class CustomDrawer extends StatelessWidget {
  final String userType;
  final String id;

  const CustomDrawer({
    super.key,
    required this.userType,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final objProvider = Provider.of<GeneralProvider>(context, listen: false);

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Container(height: 25),
            SizedBox(
              child: Image.asset(
                "assets/images/logo.png",
                width: 17.w,
                height: 17.h,
              ),
            ),
            Container(height: 25),
            DrawerItem(
              text: getTranslated(context, "Profile"),
              icon: const Icon(Icons.person, color: kPrimaryColor),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ProfileScreenUser()));
              },
              hint: getTranslated(
                context,
                "You can view your data here",
              ),
            ),
            DrawerItem(
              text: getTranslated(context, "Posts"),
              icon: const Icon(Icons.person, color: kPrimaryColor),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AllPostsScreen()));
              },
              hint: getTranslated(context, "Show the Post "),
            ),
            Visibility(
              visible: userType == "1",
              child: DrawerItem(
                icon: const Icon(Icons.point_of_sale, color: kPrimaryColor),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CustomerPoints()));
                },
                hint: getTranslated(
                  context,
                  "From here you can get points and discounts",
                ),
                text: getTranslated(
                  context,
                  "My Points",
                ),
              ),
            ),
            Visibility(
              visible: userType == "1",
              child: DrawerItem(
                icon: const Icon(Icons.message, color: kPrimaryColor),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PrivateChatRequest(),
                    ),
                  );
                },
                hint: getTranslated(
                  context,
                  "From here you can chat privately with other users",
                ),
                text: getTranslated(
                  context,
                  "Private Chat",
                ),
              ),
            ),
            Visibility(
              visible: userType != "1",
              child: DrawerItem(
                icon: const Icon(Icons.add, color: kPrimaryColor),
                onTap: () {
                  if (id != "null") {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TypeEstate(Check: "Add")));
                  } else {
                    objProvider.FunSnackBarPage(
                        getTranslated(context, "Please login first"), context);
                  }
                },
                hint: getTranslated(
                  context,
                  "From here you can add new estate",
                ),
                text: getTranslated(
                  context,
                  "Add Estate",
                ),
              ),
            ),
            Visibility(
              visible: userType != "1",
              child: DrawerItem(
                text: getTranslated(
                  context,
                  "My Estate",
                ),
                icon: const Icon(Icons.home, color: kPrimaryColor),
                onTap: () {
                  if (id != "null") {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TypeEstate(Check: "Edite")));
                  } else {
                    objProvider.FunSnackBarPage(
                        getTranslated(context, "Please login first"), context);
                  }
                },
                hint: getTranslated(
                  context,
                  "From here you can Edit your estate",
                ),
              ),
            ),
            Visibility(
              visible: userType != "1",
              child: Consumer<GeneralProvider>(
                builder: (context, provider, child) {
                  return DrawerItem(
                    text: getTranslated(context, "Request"),
                    icon: const Icon(Icons.account_box, color: kPrimaryColor),
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Request()));
                    },
                    hint: getTranslated(context,
                        "From here you can see the reservations for your estate"),
                    badge: provider.newRequestCount == 0
                        ? null
                        : badges.Badge(
                            badgeContent: Text(
                              provider.newRequestCount.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            child: const Icon(
                              Icons.account_box,
                              color: kPrimaryColor,
                            ),
                          ),
                  );
                },
              ),
            ),
            Visibility(
              visible: true,
              child: DrawerItem(
                text: getTranslated(
                  context,
                  "Notification",
                ),
                icon: const Icon(Icons.notification_add, color: kPrimaryColor),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationUser()));
                },
                hint: getTranslated(
                  context,
                  "You can see the notifications that come to you, such as booking confirmation",
                ),
              ),
            ),
            Visibility(
              visible: userType != "1",
              child: DrawerItem(
                text: getTranslated(
                  context,
                  "Chat for Estate",
                ),
                icon: const Icon(Icons.chat, color: kPrimaryColor),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TypeEstate(Check: "chat"),
                    ),
                  );
                },
                hint: getTranslated(
                  context,
                  "From here you can see the conversations that take place on your estate",
                ),
              ),
            ),
            Visibility(
              visible: true,
              child: DrawerItem(
                text: getTranslated(
                  context,
                  "Chat for U",
                ),
                icon: const Icon(
                  Icons.chat,
                  color: kPrimaryColor,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TypeEstate(Check: "chatuser")));
                },
                hint: getTranslated(
                  context,
                  "From here you can see the your conversations as user",
                ),
              ),
            ),
            DrawerItem(
              text: getTranslated(
                context,
                "upgrade account",
              ),
              icon: const Icon(
                Icons.update,
                color: kPrimaryColor,
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UpgradeAccount()));
              },
              hint: getTranslated(
                context,
                "From here you can upgrade account to Vip",
              ),
            ),
            DrawerItem(
              text: getTranslated(
                context,
                "Arabic",
              ),
              icon: const Icon(Icons.language, color: kPrimaryColor),
              onTap: () async {
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.setString("Language", "ar");
                Locale newLocale = const Locale("ar", "SA");
                MyApp.setLocale(context, newLocale);
              },
              hint: getTranslated(
                context,
                "",
              ),
            ),
            DrawerItem(
              text: getTranslated(context, "English"),
              icon: const Icon(Icons.language, color: kPrimaryColor),
              onTap: () async {
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                sharedPreferences.setString("Language", "en");
                Locale newLocale = const Locale("en", "SA");
                MyApp.setLocale(context, newLocale);
              },
              hint: getTranslated(
                context,
                '',
              ),
            ),
            DrawerItem(
              text: getTranslated(
                context,
                "Logout",
              ),
              icon: const Icon(Icons.logout, color: kPrimaryColor),
              onTap: () async {
                await AuthMethods().signOut(context);
              },
              hint: getTranslated(
                context,
                '',
              ),
            )
          ],
        ),
      ),
    );
  }
}
