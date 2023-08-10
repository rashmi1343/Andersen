import 'package:andersonappnew/screens/NewExpandwidget.dart';
import 'package:andersonappnew/screens/documentView.dart';
import 'package:andersonappnew/screens/post_screen.dart';
import 'package:andersonappnew/screens/submenunew.dart';
import 'package:andersonappnew/screens/teams_screen.dart';

import 'package:flutter/material.dart';

import '../../constant.dart';
import '../../screens/HomeMenuPage.dart';
import '../../screens/Postbymenu.dart';
import '../../screens/SplashScreen.dart';

import '../../screens/countriesnew.dart';

import '../../screens/event_page_new.dart';
import '../../screens/getstarted.dart';
import '../../screens/home_screen.dart';
import '../../screens/home_screen_arabic.dart';
import '../../screens/languagesnew.dart';

import '../pages/about_page.dart';
// import '../pages/home_page.dart';
import '../pages/contact_us_page.dart';



import '../pages/not_found_page.dart';
import '../pages/settings_page.dart';
import '../router/route_constants.dart';

class CustomRouter {
  static Route<dynamic> generatedRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashroute:
        return MaterialPageRoute(builder: (_) => SplashScreenPage());
      case countryroute:
        return MaterialPageRoute(
            builder: (_) => CountriesNew(
                  isComingFromSideMenu: false,
                ));
      case languageroute:
        return MaterialPageRoute(
            builder: (_) => const Languages(
                  isComingFromSideMenu: false,
                ));

      case homeMenuRoute:
        return MaterialPageRoute(builder: (_) => HomeGridPage());
      /*  case subMenuRoute:
        return MaterialPageRoute(
            builder: (_) => const Submenulatest(submenuid: 0));*/
      case aboutRoute:
        return MaterialPageRoute(builder: (_) => AboutPage());
      case postbymenuRoute:
        return MaterialPageRoute(
            builder: (_) => Postbymenu(
                  title: APIDATA.postByMenuTitle,
                  submenuchild: APIDATA.submenuitem,
                  currentmenuitem: APIDATA.currentmenuitem,
                ));
      case postscreenRoute:
        return MaterialPageRoute(
            builder: (_) => PostScreen(
                  discussionthread: APIDATA.selecteddiscussionthreads,
                  currentmenuitem: APIDATA.currentmenuitem,
                  submenuchild: APIDATA.submenuitem,
                  title: APIDATA.postByMenuTitle,
                ));
      case expandablemenuRoute:
        return MaterialPageRoute(builder: (_) => NewExpandablewidget());

      case settingsRoute:
        return MaterialPageRoute(builder: (_) => SettingsPage());
      /* case contactUsRoute:
        return MaterialPageRoute(builder: (_) => ContactUsPage(eventData: null,));*/
      case featuredocRoute:
        return MaterialPageRoute(builder: (_) => DocumentView());

      // case eventsRoute:
      //   return MaterialPageRoute(builder: (_) => EventPage());

      case eventsNewRoute:
        return MaterialPageRoute(builder: (_) => EventPageNew());

      case getStartedRoute:
        return MaterialPageRoute(builder: (_) => GetStartedPage());
      case subMenuRoute:
        return MaterialPageRoute(
            builder: (_) => submenunew(
                submenuid: APIDATA.submenuid, submenu: APIDATA.submenuitem));
      case teamRoute:
        return MaterialPageRoute(builder: (_) => teamscreen());
      default:
        return MaterialPageRoute(builder: (_) => NotFoundPage());
    }
  }
}
