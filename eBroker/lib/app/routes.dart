import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../sandbox/playground.dart';

class Routes {
  //private constructor
  Routes._();

  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const completeProfile = 'complete_profile';
  static const main = 'main';
  static const home = 'Home';
  static const addProperty = 'addProperty';
  static const waitingScreen = 'waitingScreen';
  static const categories = 'Categories';
  static const addresses = 'address';
  static const chooseAdrs = 'chooseAddress';
  static const propertiesList = 'propertiesList';
  static const propertyDetails = 'PropertyDetails';
  static const contactUs = 'ContactUs';
  static const profileSettings = 'profileSettings';
  static const myEnquiry = 'MyEnquiry';
  static const filterScreen = 'filterScreen';
  static const notificationPage = 'notificationpage';
  static const notificationDetailPage = 'notificationdetailpage';
  static const addPropertyScreenRoute = 'addPropertyScreenRoute';
  static const articlesScreenRoute = 'articlesScreenRoute';
  static const subscriptionPackageListRoute = 'subscriptionPackageListRoute';
  static const subscriptionScreen = 'subscriptionScreen';
  static const maintenanceMode = '/maintenanceMode';
  static const favoritesScreen = '/favoritescreen';
  static const createAdvertismentScreenRoute = '/createAdvertisment';
  static const promotedPropertiesScreen = '/promotedPropertiesScreen';
  static const mostLikedPropertiesScreen = '/mostLikedPropertiesScreen';
  static const mostViewedPropertiesScreen = '/mostViewedPropertiesScreen';
  static const articleDetailsScreenRoute = '/articleDetailsScreenRoute';
  static const areaConvertorScreen = '/areaCalculatorScreen';
  static const languageListScreenRoute = '/languageListScreenRoute';
  static const searchScreenRoute = '/searchScreenRoute';
  static const chooseLocaitonMap = '/chooseLocationMap';
  static const propertyMapScreen = '/propertyMap';
  static const dashboard = '/dashboard';

  static const myAdvertisment = '/myAdvertisment';
  static const transactionHistory = '/transactionHistory';
  static const nearbyAllProperties = '/nearbyAllProperties';
  static const personalizedPropertyScreen = '/personalizedPropertyScreen';
  static const allProjectsScreen = '/allProjectsScreen';

  ///Project section routes

  static const String addProjectDetails = "/addProjectDetails";
  static const String projectMetaDataScreens = "/projectMetaDataScreens";
  static const String manageFloorPlansScreen = "/manageFloorPlansScreen";

  ///Add property screens
  static const selectPropertyTypeScreen = '/selectPropertyType';
  static const addPropertyDetailsScreen = '/addPropertyDetailsScreen';
  static const setPropertyParametersScreen = '/setPropertyParametersScreen';
  static const selectOutdoorFacility = '/selectOutdoorFacility';

  ///View project
  static const projectDetailsScreen = '/projectDetailsScreen';
  static const projectListScreen = '/projectListScreen';

  //Sandbox[test]
  static const playground = 'playground';

  static String currentRoute = splash;
  static String previousCustomerRoute = splash;
  static Route? onGenerateRouted(RouteSettings routeSettings) {
    previousCustomerRoute = currentRoute;
    currentRoute = routeSettings.name ?? "";
    print("CURRENT ROUTE $currentRoute");

    ///This is to prevent infinity loading while login browser
    if (routeSettings.name!.contains("/link?")) {
      return null;
    }

    switch (routeSettings.name) {
      case "":
        break;

      case splash:
        return BlurredRouter(builder: ((context) => const SplashScreen()));
      case onboarding:
        return CupertinoPageRoute(
            builder: ((context) => const OnboardingScreen()));
      case main:
        return MainActivity.route(routeSettings);
      case login:
        return LoginScreen.route(routeSettings);
      case completeProfile:
        return UserProfileScreen.route(routeSettings);
      // case addProperty:
      //   return AddEditProperty.route(routeSettings);
      //return AddProperty.route(routeSettings);

      case categories:
        return CategoryList.route(routeSettings);
      case maintenanceMode:
        return MaintenanceMode.route(routeSettings);
      case languageListScreenRoute:
        return LanguagesListScreen.route(routeSettings);
      case propertiesList:
        return PropertiesList.route(routeSettings);
      case propertyDetails:
        return PropertyDetails.route(routeSettings);
      case contactUs:
        return ContactUs.route(routeSettings);
      case profileSettings:
        return ProfileSettings.route(routeSettings);

      case filterScreen:
        return FilterScreen.route(routeSettings);
      case notificationPage:
        return Notifications.route(routeSettings);
      case notificationDetailPage:
        return NotificationDetail.route(routeSettings);
      case chooseLocaitonMap:
        return ChooseLocationMap.route(routeSettings);
      case articlesScreenRoute:
        return ArticlesScreen.route(routeSettings);
      case mostLikedPropertiesScreen:
        return MostLikedPropertiesScreen.route(routeSettings);
      case areaConvertorScreen:
        return AreaCalculator.route(routeSettings);

      case articleDetailsScreenRoute:
        return ArticleDetails.route(routeSettings);
      case subscriptionPackageListRoute:
        return SubscriptionPackageListScreen.route(routeSettings);
      case subscriptionScreen:
        return SubscriptionScreen.route(routeSettings);
      case favoritesScreen:
        return FavoritesScreen.route(routeSettings);
      case createAdvertismentScreenRoute:
        return CreateAdvertisementScreen.route(routeSettings);
      case promotedPropertiesScreen:
        return PromotedPropertiesScreen.route(routeSettings);
      case mostViewedPropertiesScreen:
        return MostViewedPropertiesScreen.route(routeSettings);

      case selectPropertyTypeScreen:
        return SelectPropertyType.route(routeSettings);

      case transactionHistory:
        return TransactionHistory.route(routeSettings);

      case myAdvertisment:
        return MyAdvertismentScreen.route(routeSettings);
      case personalizedPropertyScreen:
        return PersonalizedPropertyScreen.route(routeSettings);
      // case dashboard:
      //   return DashboardScreen.route(routeSettings);
      case addPropertyDetailsScreen:
        return AddPropertyDetails.route(routeSettings);
      case setPropertyParametersScreen:
        return SetProeprtyParametersScreen.route(routeSettings);
      case searchScreenRoute:
        return SearchScreen.route(routeSettings);

      case propertyMapScreen:
        return PropertyMapScreen.route(routeSettings);
      case nearbyAllProperties:
        return NearbyAllPropertiesScreen.route(routeSettings);
      case selectOutdoorFacility:
        return SelectOutdoorFacility.route(routeSettings);

      case addProjectDetails:
        return AddProjectDetails.route(routeSettings);

      case projectMetaDataScreens:
        return ProjectMetaDetails.route(routeSettings);

      case projectDetailsScreen:
        return ProjectDetailsScreen.route(routeSettings);

      case manageFloorPlansScreen:
        return ManageFloorPlansScreen.route(routeSettings);
      case projectListScreen:
        return ProjectListScreen.route(routeSettings);
      case allProjectsScreen:
        return AllProjectsScreen.route(routeSettings);

      //sandBox//Playground
      case playground:
        return PlayGround.route(routeSettings);

      default:
        if (routeSettings.name!.contains(AppSettings.shareNavigationWebUrl)) {
          return NativeLinkWidget.render(routeSettings);
        }
        return BlurredRouter(
          builder: ((context) => Scaffold(
                body: Center(
                  child: Text(
                    UiUtils.translate(context, "pageNotFoundErrorMsg"),
                  ),
                ),
              )),
        );
      // if (routeSettings.name != "" && routeSettings.name != null)
      //   return NativeDeepLinkManager().build(routeSettings);
    }
  }
}
