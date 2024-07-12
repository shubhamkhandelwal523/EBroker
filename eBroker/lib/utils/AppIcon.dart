// ignore_for_file: non_constant_identifier_names, file_names

class AppIcons {
  static String placeHolder = "";

  static var ads = "";

  static var propertyLimites = "";

  AppIcons._();
  //
  static const String _basePath = "assets/svg/";
  //** */
  static String magic = _svgPath("magic");
  static String bin = _svgPath("bin");
  static String apple = _svgPath("apple");
  static String google = _svgPath("google");
  static String chat = _svgPath("inactive_chat");
  static String update = _svgPath("update");
  static String companyLogo = _svgPath("Logo/company_logo");
  static String home = _svgPath("home");
  static String profile = _svgPath("profile");
  static String search = _svgPath("search");
  static String properties = _svgPath("properties");
  static String iconArrowLeft = _svgPath("icon_arrow_left");
  static String filter = _svgPath("filter");
  static String location = _svgPath("location");
  static String downArrow = _svgPath("down_arrow");
  static String arrowRight = _svgPath("arrow_right");
  static String like = _svgPath("like");
  static String like_fill = _svgPath("like_fill");
  static String notification = _svgPath("notification");
  static String language = _svgPath("language");
  static String darkTheme = _svgPath("dark_theme");
  static String subscription = _svgPath("subscription");
  static String articles = _svgPath("article");
  static String favorites = _svgPath("like_fill");
  static String shareApp = _svgPath("share");
  static String areaConvertor = _svgPath("area_convertor");
  static String rateUs = _svgPath("rate_us");
  static String contactUs = _svgPath("contact_us");
  static String aboutUs = _svgPath("about_us");
  static String terms = _svgPath("t_c");
  static String privacy = _svgPath("privacypolicy");
  static String delete = _svgPath("delete_account");
  static String logout = _svgPath("logout");
  static String edit = _svgPath("edit");
  static String call = _svgPath("call");
  static String message = _svgPath("message");
  static String defaultPersonLogo = _svgPath("defaultProfileIcon");
  static String arrowLeft = _svgPath("arrow_left");
  static String warning = _svgPath("warning");
  static String promoted = _svgPath("promoted");
  static String headerCurve = _svgPath("header_curve");
  static String v360Degree = _svgPath("v360");
  static String deleteGirlSvg = _svgPath("delete");
  static String forRent = _svgPath("for_rent");
  static String forSale = _svgPath("for_sale");
  static String propertyMap = _svgPath("propertymap");
  static String calender = _svgPath("calender");
  static String interested = _svgPath("interested");
  static String somethingwentwrong =
      _svgPath("MultiColorSvg/something_went_wrong");

  static String paystack = _svgPath("paystack");
  static String razorpay = _svgPath("razorpay");
  static String paypal = _svgPath("paypal");
  static String transaction = _svgPath("transaction");
  static String reportDark = _svgPath("report_dark");
  static String report = _svgPath("report");
  static String propertySubmittedc = _svgPath("MultiColorSvg/propertysubmited");
  static String no_chat_found = _svgPath("MultiColorSvg/no_chat_found");
  static String no_data_found =
      _svgPath("MultiColorSvg/no_data_found_illustrator");
  static String days = _svgPath("days");

  ///
  static String propertiesIcon = _svgPath("properties_icon");
  static String upcomingProject = _svgPath("upcoming_projects_icon");

  ///Fallback icons
  static String fallbackSplashLogo = _svgPath("Fallback/splash");
  static String fallbackPlaceholderLogo = _svgPath("Fallback/placeholder");
  static String fallbackHomeLogo = _svgPath("Fallback/homeLogo");

  static String no_internet = _svgPath("MultiColorSvg/no_internet_illustrator");
  static String deleteIcon = _svgPath("MultiColorSvg/delete_illustrator");
  static String logoutIcon = _svgPath("MultiColorSvg/logout_illustrator");

  //on boardings
  static String onBoardingsOne = _svgPath("onbo_a");
  static String onBoardingsTwo = _svgPath("onbo_b");
  static String onBoardingsThree = _svgPath("onbo_c");

  ///
  ///
  static String _svgPath(String name) {
    return "$_basePath$name.svg";
  }
}
