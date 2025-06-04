import 'package:shelf_router/shelf_router.dart';
import 'auth_routes.dart';
import 'destination_routes.dart';
import 'userProfile_routes.dart';
import 'order_route.dart';

final mainRouter = Router()
  ..mount('/auth/', AuthRoutes().router.call)
  ..mount('/destination/', destinationRouter.call)
  ..mount('/user/', UserprofileRoutes().router.call)
  ..mount('/order/', orderRouter().router.call);