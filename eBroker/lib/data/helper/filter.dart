import 'package:ebroker/utils/Extensions/lib/map.dart';

abstract class Filter {
  Map<String, dynamic> filter();
}

class PropertyTypeFilter extends Filter {
  final String type;
  PropertyTypeFilter(this.type);

  @override
  Map<String, dynamic> filter() {
    return {"property_type": type};
  }
}

class MinMaxBudget extends Filter {
  final String? min;
  final String? max;

  MinMaxBudget({
    required this.min,
    required this.max,
  });

  @override
  Map<String, dynamic> filter() {
    return {
      "min_price": min,
      "max_price": max,
    }..removeEmptyKeys();
  }
}

class CategoryFilter extends Filter {
  final String? categoryId;

  CategoryFilter(this.categoryId);
  @override
  Map<String, dynamic> filter() {
    return {"category_id": categoryId};
  }
}

enum PostedSinceDuration {
  anytime(""),
  lastWeek("0"),
  yesterday("1");

  final String value;
  const PostedSinceDuration(this.value);
}

class PostedSince extends Filter {
  final PostedSinceDuration since;

  PostedSince(this.since);

  @override
  Map<String, dynamic> filter() {
    return {"posted_since": since.value}..removeEmptyKeys();
  }
}

class LocationFilter extends Filter {
  // final PostedSinceDuration since;
  final String? city;
  final String? state;
  final String? country;

  @override
  Map<String, dynamic> filter() {
    return {
      "city": city,
      "state": state,
      "country": country,
    }..removeEmptyKeys();
  }

  LocationFilter({
    this.city,
    this.state,
    this.country,
  });
}

///This will be used to apply filter
class FilterApply {
  final List<Filter> _filters = [];

  void add(Filter filter) {
    _filters.add(filter);
  }

  ///This will add or update existing filter
  void addOrUpdate(Filter filter) {
    var existingFilterIndex = _filters
        .indexWhere((element) => element.runtimeType == filter.runtimeType);
    if (existingFilterIndex != -1) {
      _filters[existingFilterIndex] = filter;
    } else {
      _filters.add(filter);
    }
  }

  ///This will be used to compare filters
  T check<T>() {
    return _filters.whereType<T>().first;
  }

  ////It will return data in Map format of combined filters so we can send it in API
  Map getFilter() {
    return _filters.fold({},
        (previousValue, element) => previousValue..addAll(element.filter()));
  }
}
