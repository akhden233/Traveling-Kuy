import 'package:shelf_router/shelf_router.dart';
import 'auth_routes.dart';
import 'destination_routes.dart';
import 'userProfile_routes.dart';

final mainRouter = Router()
  ..mount('/auth/', AuthRoutes().router.call)
  ..mount('/destination/', destinationRouter.call)
  ..mount('/user/', UserprofileRoutes().router.call);