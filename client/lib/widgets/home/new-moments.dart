import 'package:bot_toast/bot_toast.dart';
import 'package:cloudbase_database/cloudbase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:snsmax/cloudbase.dart';
import 'package:snsmax/models/moment.dart';
import 'package:snsmax/widgets/moment-list-item/moment-list-item.dart';
import 'package:snsmax/widgets/scroll-back-top-button.dart';

class HomeNewMoments extends StatefulWidget {
  const HomeNewMoments({Key key}) : super(key: key);

  @override
  _HomeNewMomentsState createState() => _HomeNewMomentsState();
}

class _HomeNewMomentsState extends State<HomeNewMoments>
    with AutomaticKeepAliveClientMixin<HomeNewMoments> {
  @override
  bool get wantKeepAlive => true;

  ScrollController scrollController;
  int momentsCount = 0;

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(onFetchMomentCount);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void onFetchMomentCount(Duration duration) async {
    await Future.delayed(duration);
    await onRefreshMomentCount();
  }

  Future<void> onRefreshMomentCount() async {
    try {
      CancelFunc onClose = BotToast.showLoading();
      final DbQueryResponse response =
          await CloudBase().database.collection('moments').count();
      setState(() {
        momentsCount = response.total;
        onClose();
      });
    } catch (e) {
      print(e);
    }
  }

  bool get isPhone {
    return MediaQuery.of(context).size.shortestSide < 600;
  }

  bool get isPortrait {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  StaggeredTile get staggeredTile {
    if (isPhone && isPortrait) {
      return const StaggeredTile.fit(6);
    } else if (isPhone && !isPortrait) {
      return const StaggeredTile.fit(2);
    }

    return const StaggeredTile.fit(3);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Scrollbar(
        controller: scrollController,
        child: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          onRefresh: onRefreshMomentCount,
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              SliverSafeArea(
                sliver: SliverStaggeredGrid.countBuilder(
                  itemCount: momentsCount,
                  itemBuilder: childBuilder,
                  crossAxisCount: 6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing:
                      staggeredTile.crossAxisCellCount == 6 ? 8 : 12,
                  staggeredTileBuilder: (int index) => staggeredTile,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        child: ScrollBackTopButton(scrollController),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget childBuilder(BuildContext context, int index) {
    return MomentListItem(onFetch: onFetchMoment(index));
  }

  FetchMomentCallback onFetchMoment(int offset) {
    return () async {
      final DbQueryResponse response = await CloudBase()
          .database
          .collection('moments')
          .limit(1)
          .skip(offset)
          .get();
      final List data = (response.data as List);
      if (data.isNotEmpty) {
        return Moment.fromJson(data.single);
      }

      return null;
    };
  }
}