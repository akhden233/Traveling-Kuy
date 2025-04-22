import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import '../utils/constants/constants_server.dart';

final destinationRouter = Router()
  ..get('$destinationEndpoint', (Request request) async {
    return Response.ok('List Destinasi');
  })
  ..get('$destinationEndpoint/<destination_id>', (Request request, int destination_id) async {
    return Response.ok('Detail destinasi $destination_id');
  });