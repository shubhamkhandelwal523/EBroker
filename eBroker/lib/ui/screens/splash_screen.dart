// import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import '../app/routes.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/Queue/queue.dart';
// import 'package:ebroker/main.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../../data/repositories/system_repository.dart';
import '../../utils/hive_keys.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AuthenticationState authenticationState;

  bool isTimerCompleted = false;
  bool isSettingsLoaded = false;
  bool isLanguageLoaded = false;

  @override
  void initState() {
    // Debugger().insert(context);
    context.read<FetchCategoryCubit>().fetchCategories();
    context.read<FetchOutdoorFacilityListCubit>().fetch();
    locationPermission();

    super.initState();
    ProcessQueue().getResult(Constant.languageTaskId!).then((value) {
      setState(() {
        isLanguageLoaded = true;
      });
    });

    checkIsUserAuthenticated();
    bool isDataAvailable = checkPersistedDataAvailibility();
    Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none && !isDataAvailable) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return NoInternet(
              onRetry: () async {
                try {
                  await LoadAppSettings().load(true);
                  if (context.color.brightness == Brightness.light) {
                    context.read<AppThemeCubit>().changeTheme(AppTheme.light);
                  } else {
                    context.read<AppThemeCubit>().changeTheme(AppTheme.dark);
                  }
                } catch (e) {
                  print("no internet");
                }
                Future.delayed(
                  Duration.zero,
                  () {
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.splash,
                    );
                  },
                );
              },
            );
          },
        ));
      }
    });
    startTimer();
    //get Currency Symbol from Admin Panel
    Future.delayed(Duration.zero, () {
      context.read<ProfileSettingCubit>().fetchProfileSetting(
            context,
            Api.currencySymbol,
          );
    });
  }

  Future<void> locationPermission() async {
    if ((await Permission.location.status) == PermissionStatus.denied) {
      await Permission.location.request();
    }
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void checkIsUserAuthenticated() async {
    authenticationState = context.read<AuthenticationCubit>().state;
    if (authenticationState == AuthenticationState.authenticated) {
      ///Only load sensitive details if user is authenticated
      ///This call will load sensitive details with settings
      context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymouse: false,
          );
      completeProfileCheck();
    } else {
      //This call will hide sensitive details.
      context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymouse: true,
          );
    }
  }

  Future<void> startTimer() async {
    Timer(const Duration(seconds: 1), () {
      isTimerCompleted = true;
      if (mounted) setState(() {});
    });
  }

  void navigateCheck() {
    ({
      "timer": isTimerCompleted,
      "setting": isSettingsLoaded,
      "language": isLanguageLoaded
    }).logg;

    if (isTimerCompleted && isSettingsLoaded && isLanguageLoaded) {
      navigateToScreen();
    }
  }

  void completeProfileCheck() {
    if (HiveUtils.getUserDetails().name == "" ||
        HiveUtils.getUserDetails().email == "") {
      Future.delayed(
        const Duration(milliseconds: 100),
        () {
          Navigator.pushReplacementNamed(
            context,
            Routes.completeProfile,
            arguments: {
              "from": "login",
            },
          );
        },
      );
    }
  }

  void navigateToScreen() {
    if (context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.maintenanceMode) ==
        "1") {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(
          Routes.maintenanceMode,
        );
      });
    } else if (authenticationState == AuthenticationState.authenticated) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context)
            .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
      });
    } else if (authenticationState == AuthenticationState.unAuthenticated) {
      if (Hive.box(HiveKeys.userDetailsBox).get("isGuest") == true) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context)
              .pushReplacementNamed(Routes.main, arguments: {"from": "splash"});
        });
      } else {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
      }
    } else if (authenticationState == AuthenticationState.firstTime) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushReplacementNamed(Routes.onboarding);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    navigateCheck();

    return BlocListener<FetchLanguageCubit, FetchLanguageState>(
      listener: (context, state) {},
      child: BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        listener: (context, state) {
          if (state is FetchSystemSettingsFailure) {
            print("Issue while load system settyings ${state.errorMessage}");
          }
          if (state is FetchSystemSettingsSuccess) {
            List setting = [];
            if ((setting).isNotEmpty) {
              if ((setting[0] as Map).containsKey("package_id")) {
                Constant.subscriptionPackageId = "";
              }
            }

            if (state.settings['data'].containsKey("demo_mode")) {
              Constant.isDemoModeOn = state.settings['data']['demo_mode'];
            }
            isSettingsLoaded = true;
            setState(() {});
          }
        },
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: context.color.tertiaryColor,
          ),
          child: Scaffold(
            backgroundColor: context.color.tertiaryColor,
            body: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 150,
                      height: 150,
                      child: LoadAppSettings().svg(
                        appSettings.splashLogo!,
                        // color: context.color.secondaryColor,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    key: const ValueKey("companylogo"),
                    child: UiUtils.getSvg(AppIcons.companyLogo),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future getDefaultLanguage(
  VoidCallback onSuccess,
) async {
  try {
    // await Hive.initFlutter();v
    await Hive.openBox(HiveKeys.languageBox);
    await Hive.openBox(HiveKeys.userDetailsBox);
    await Hive.openBox(HiveKeys.authBox);

    if (HiveUtils.getLanguage() == null ||
        HiveUtils.getLanguage()?['data'] == null) {
      Map result = await SystemRepository().fetchSystemSettings(
        isAnonymouse: true,
      );

      var code = (result['data']['default_language']);

      await Api.get(
        url: Api.getLanguagae,
        queryParameters: {
          Api.languageCode: code,
        },
        useAuthToken: false,
      ).then((value) {
        HiveUtils.storeLanguage({
          "code": value['data']['code'],
          "data": value['data']['file_name'],
          "name": value['data']['name']
        });
        onSuccess.call();
      });
    } else {
      onSuccess.call();
    }
  } catch (e, st) {
    log("Error while load default language $st");
    throw st;
  }
}

bool checkPersistedDataAvailibility() {
  int dataAvailibile = 0;
  for (Type cubit in Constant.hydratedCubits) {
    if (HydratedBloc.storage.read('$cubit') == null) {
    } else {
      dataAvailibile++;
    }
  }
  if (dataAvailibile == Constant.hydratedCubits.length) {
    return true;
  } else {
    return false;
  }
}
