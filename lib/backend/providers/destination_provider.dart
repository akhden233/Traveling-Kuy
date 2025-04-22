import 'package:flutter/material.dart';
import '../models/destination_model.dart' as models;
import '../services/destination_services.dart';

class DestinationProvider extends ChangeNotifier {
  List<models.Destination> _destinations = [];
  // List<models.Destination> _popularDestinations = [];
  bool _isLoading = false;
  String? _error;

  List<models.Destination> get destinations => _destinations;
  // List<models.Destination> get popularDestinations => _popularDestinations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllDestinations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await DestinationServices.getAllDestinations();
      _destinations =
          data.map((json) => models.Destination.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> loadPopularDestinations() async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();

  //   try {
  //     final data = await DestinationServices.getPopularDestinations();
  //     _popularDestinations =
  //         data.map((json) => models.Destination.fromJson(json)).toList();
  //   } catch (e) {
  //     _error = e.toString();
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<models.Destination?> getDestinationDetail(int destination_id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await DestinationServices.getDestinationDetail(destination_id);
      if (data.isEmpty) {
        _error = 'Destination not found';
        return null;
      }
      return models.Destination.fromJson(data);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<models.Destination>> searchDestinations(String keyword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await DestinationServices.searchDestinations(keyword);
      return data.map((json) => models.Destination.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<List<models.Destination>> getDestinationsByCategory(
  //   String category,
  // ) async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();

  //   try {
  //     final data = await DestinationServices.getDestinationsByCategory(
  //       category,
  //     );
  //     return data.map((json) => models.Destination.fromJson(json)).toList();
  //   } catch (e) {
  //     _error = e.toString();
  //     return [];
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
