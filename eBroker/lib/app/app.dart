import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

PersonalizedInterestSettings personalizedInterestSettings =
    PersonalizedInterestSettings.empty();
AppSettingsDataModel appSettings = fallbackSettingAppSettings;

///

getAppSettings() async {
  await LoadAppSettings().load(true);
}

Future getLanguage() async {
  await getDefaultLanguage(
    () {},
  );
}

void initApp() async {
  ///Note: this file's code is very necessary and sensitive if you change it, this might affect whole app , So change it carefully.
  ///This must be used do not remove this line
  MobileAds.instance.initialize();
  await HiveUtils.initBoxes();
  // await Isolate.spawn(getLanguage, languageSettingReceivePort.sendPort);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationCacheDirectory(),
  );
  Api.initInterceptors();

  ///This is the widget to show uncaught runtime error in this custom widget so that user can know in that screen something is wrong instead of grey screen
  SomethingWentWrong.asGlobalErrorBuilder();

  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(
      NotificationService.onBackgroundMessageHandler);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    runApp(const EntryPoint());
  });
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    ///Here Fetching property report reasons
    context.read<FetchPropertyReportReasonsListCubit>().fetch();
    context.read<LanguageCubit>().loadCurrentLanguage();
    AppTheme currentTheme = HiveUtils.getCurrentTheme();

    ///Initialized notification services
    LocalAwsomeNotification().init(context);
    ///////////////////////////////////////
    NotificationService.init(context);

    /// Initialized dynamic links for share properties feature
    context.read<AppThemeCubit>().changeTheme(currentTheme);

    APICallTrigger.onTrigger(
      () {
        ///THIS WILL be CALLED WHEN USER WILL LOGIN FROM ANONYMOUS USER.
        context.read<LikedPropertiesCubit>().emptyCubit();
        context.read<GetApiKeysCubit>().fetch();

        loadInitialData(context, loadWithoutDelay: true);
      },
    );

    UiUtils.setContext(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ///Continuously watching theme change
    AppTheme currentTheme = context.watch<AppThemeCubit>().state.appTheme;
    return BlocListener<GetApiKeysCubit, GetApiKeysState>(
      listener: (context, state) {
        context.read<GetApiKeysCubit>().setAPIKeys();
      },
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, languageState) {
          return MaterialApp(
            initialRoute: Routes
                .splash, // App will start from here splash screen is first screen,
            navigatorKey: Constant
                .navigatorKey, //This navigator key is used for Navigate users through notification
            title: Constant.appName,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: Routes.onGenerateRouted,
            theme: appThemeData[currentTheme],
            builder: (context, child) {
              ErrorFilter.setContext(context);
              TextDirection direction;
              //here we are languages direction locally
              if (languageState is LanguageLoader) {
                if (languageState.isRTL) {
                  direction = TextDirection.rtl;
                } else {
                  direction = TextDirection.ltr;
                }
              } else {
                direction = TextDirection.ltr;
              }
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                  // textScaleFactor:
                  //     1.0, //set text scale factor to 1 so that this will not resize app's text while user change their system settings text scale
                ),
                child: Directionality(
                  textDirection:
                      direction, //This will convert app direction according to language
                  child: child!,
                ),
              );
            },
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: loadLocalLanguageIfFail(languageState),
          );
        },
      ),
    );
  }

  dynamic loadLocalLanguageIfFail(LanguageState state) {
    if ((state is LanguageLoader)) {
      return Locale(state.languageCode);
    } else if (state is LanguageLoadFail) {
      return const Locale("en");
    }
  }
}

void loadInitialData(BuildContext context,
    {bool? loadWithoutDelay, bool? forceRefresh}) {
  context.read<FetchProjectsCubit>().fetchProjects();
  context.read<SliderCubit>().fetchSlider(context,
      loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context.read<FetchCategoryCubit>().fetchCategories(
      loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context
      .read<FetchMostViewedPropertiesCubit>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context
      .read<FetchPromotedPropertiesCubit>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);

  context
      .read<FetchMostLikedPropertiesCubit>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context
      .read<FetchNearbyPropertiesCubit>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context.read<FetchCityCategoryCubit>().fetchCityCategory(
      loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context
      .read<FetchRecentPropertiesCubit>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context
      .read<FetchPersonalizedPropertyList>()
      .fetch(loadWithoutDelay: loadWithoutDelay, forceRefresh: forceRefresh);
  context.read<GetChatListCubit>().setContext(context);
  context.read<GetChatListCubit>().fetch();

  PersonalizedFeedRepository().getUserPersonalizedSettings().then((value) {
    print("Personalized settings $value");
    personalizedInterestSettings = value;
  });
  GuestChecker.listen().addListener(() {
    if (GuestChecker.value == false) {
      PersonalizedFeedRepository().getUserPersonalizedSettings().then((value) {
        personalizedInterestSettings = value;
      });
    }
  });

//    // }
}
