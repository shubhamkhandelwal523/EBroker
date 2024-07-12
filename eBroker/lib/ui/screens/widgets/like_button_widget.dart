import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/cubits/Utility/like_properties.dart';
import '../../../data/cubits/favorite/add_to_favorite_cubit.dart';
import '../../../data/model/property_model.dart';
import '../../../utils/AppIcon.dart';
import '../../../utils/Extensions/extensions.dart';
import '../../../utils/guestChecker.dart';
import '../../../utils/ui_utils.dart';

//This like button is used in app for favorite feature, it is used in all propery so it is very important
class LikeButtonWidget extends StatefulWidget {
  final PropertyModel property;
  final Function(FavoriteType type)? onLikeChanged;
  final Function(AddToFavoriteCubitState state)? onStateChange;
  const LikeButtonWidget({
    super.key,
    required this.property,
    this.onStateChange,
    this.onLikeChanged,
  });

  @override
  State<LikeButtonWidget> createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget> {
  @override
  void initState() {
    //checking is property is already favorite , it will come in api
    if (GuestChecker.value != true) {
      if (widget.property.isFavourite == 1 &&
          context
                  .read<LikedPropertiesCubit>()
                  .state
                  .liked
                  .contains(widget.property.id) ==
              false) {
        if (!context
            .read<LikedPropertiesCubit>()
            .getRemovedLikes()!
            .contains(widget.property.id)) {
          context.read<LikedPropertiesCubit>().add(widget.property.id);
        }
      }
    }

    super.initState();
  }

//this is main like button method
  Widget setFavorite(PropertyModel property, BuildContext context) {
    return BlocConsumer<AddToFavoriteCubitCubit, AddToFavoriteCubitState>(
      listener: (BuildContext context, AddToFavoriteCubitState state) {
        widget.onStateChange?.call(state);
        if (state is AddToFavoriteCubitFailure) {}
        if (state is AddToFavoriteCubitSuccess) {
          //callback
          widget.onLikeChanged?.call(state.favorite);

          /// if it is already added then we'll add remove , other wise we'll add it into local list
          context.read<LikedPropertiesCubit>().changeLike(state.id);
        }
      },
      builder: (BuildContext context, AddToFavoriteCubitState addState) {
        return GestureDetector(
          onTap: () {
            GuestChecker.check(onNotGuest: () {
              ///checking if added then remove or else add it
              FavoriteType favoriteType;

              bool contains = context
                  .read<LikedPropertiesCubit>()
                  .state
                  .liked
                  .contains(property.id!);

              if (contains == true || property.isFavourite == 1) {
                favoriteType = FavoriteType.remove;
              } else {
                favoriteType = FavoriteType.add;
              }
              context.read<AddToFavoriteCubitCubit>().setFavroite(
                    propertyId: property.id!,
                    type: favoriteType,
                  );
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.color.primaryColor,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                    color: Color.fromARGB(33, 0, 0, 0),
                    offset: Offset(0, 2),
                    blurRadius: 15,
                    spreadRadius: 0)
              ],
            ),
            child: BlocBuilder<LikedPropertiesCubit, LikedPropertiesState>(
              builder: (context, state) {
                return Center(
                    child: (addState is AddToFavoriteCubitInProgress)
                        ? UiUtils.progress(width: 20, height: 20)
                        : state.liked.contains(widget.property.id)
                            ? UiUtils.getSvg(
                                AppIcons.like_fill,
                                color: context.color.tertiaryColor,
                              )
                            : UiUtils.getSvg(AppIcons.like,
                                color: context.color.tertiaryColor));
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return setFavorite(widget.property, context);
  }
}
