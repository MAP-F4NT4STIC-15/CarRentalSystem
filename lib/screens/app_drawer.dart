import 'package:car_rental_system/constants/duration_contants.dart';
import 'package:car_rental_system/constants/firebase_contants.dart';
import 'package:car_rental_system/providers/auth_provider.dart';
import 'package:car_rental_system/providers/misc_provider.dart';
import 'package:car_rental_system/providers/trip_provider.dart';
import 'package:car_rental_system/providers/vehicle_provider.dart';
import 'package:car_rental_system/utils/context_less.dart';
import 'package:car_rental_system/utils/routes.dart';
import 'package:car_rental_system/widgets/state_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomAppDrawer extends ConsumerWidget {
  CustomAppDrawer({Key? key}) : super(key: key);
  bool hasCar = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isOpen = ref.watch(drawerStateProvider);
    ref.watch(userHasVehicleProvider).maybeWhen(
          orElse: () {},
          loaded: (_) {
            hasCar = _;
          },
        );
    ref.watch(activeTripProvider);
    ref.watch(carListProvider).maybeWhen(
          orElse: () {},
          loaded: (_) {
            ref.watch(allcarsProvider.notifier).state = _;
          },
        );

    return AnimatedPositioned(
      left: isOpen ? 0 : -255,
      top: 0,
      bottom: 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onPanUpdate: (details) {
          debugPrint('drag : ${details.delta.dx}');
          if (details.delta.dx < -3) {
            ref.watch(drawerStateProvider.notifier).state = false;
          }
        },
        child: SizedBox(
          width: 255,
          child: Drawer(
            child: ListView(
              children: [
                GestureDetector(
                  onTap: () {
                    //TODO: Navigate To Profile Page
                  },
                  child: SizedBox(
                    height: 165,
                    child: DrawerHeader(
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            foregroundColor: Colors.blue,
                            backgroundImage: AssetImage(
                              'images/ToyFaces_Colored_BG_47.jpg',
                            ),
                          ),
                          //TODO 1: User photo should be here
                          const SizedBox(width: 30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Name'),
                              SizedBox(height: 8),
                              Text(
                                'Visit Profile',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ), //Drawer Header
                if (!hasCar)
                  GestureDetector(
                    onTap: () {
                      context.nav.pushNamed(Routes.registerCar);
                      ref.watch(drawerStateProvider.notifier).state = false;
                    },
                    child: const ListTile(
                      leading: Icon(Icons.directions_car_rounded),
                      title: Text(
                        'Register Car',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                if (hasCar)
                  GestureDetector(
                    onTap: () {
                      ref
                          .watch(udateVehicleStatusProvider.notifier)
                          .getData(status: true);
                    },
                    child: const ListTile(
                      leading: Icon(Icons.directions_car_rounded),
                      title: Text(
                        'Give My Car On rent',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                if (hasCar)
                  GestureDetector(
                    onTap: () async {
                      EasyLoading.showInfo('Deleting Your car');
                      await AppFBC.allVehicleCollection
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .delete();
                      EasyLoading.dismiss();
                      EasyLoading.showSuccess('Deleted');
                      ref.refresh(userHasVehicleProvider);
                    },
                    child: const ListTile(
                      leading: Icon(Icons.directions_car_rounded),
                      title: Text(
                        'Delete car',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                if (hasCar)
                  GestureDetector(
                    onTap: () {
                      ref
                          .watch(udateVehicleStatusProvider.notifier)
                          .getData(status: false);
                    },
                    child: const ListTile(
                      leading: Icon(Icons.directions_car_rounded),
                      title: Text(
                        'Remove Car From rent',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    context.nav.pushNamed(Routes.tripHistory);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.history),
                    title: Text(
                      'History',
                      // style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.nav.pushNamed(Routes.tripReport);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.history),
                    title: Text(
                      'Report',
                      // style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                ref.watch(signOutProvider).map(
                      initial: (_) => GestureDetector(
                        onTap: () {
                          ref.watch(signOutProvider.notifier).signOut();
                        },
                        child: const ListTile(
                          leading: Icon(Icons.logout),
                          title: Text(
                            'Sign Out',
                            // style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      loading: (_) => const LoadingWidget(),
                      loaded: (_) {
                        Future.delayed(AppDurConst.transissionDuration, () {
                          context.nav.pushNamedAndRemoveUntil(
                            Routes.login,
                            (route) => false,
                          );
                        });
                        return const MessageWidget(
                          msg: 'Success',
                        );
                      },
                      error: (_) => ErrorHandleWidget(
                        error: _.error,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
