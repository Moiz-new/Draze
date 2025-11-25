import 'package:draze/app/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/VisitorModel.dart';

class AllVisitorsProvider extends ChangeNotifier {
  List<VisitorModel> _visitors = [];
  bool _isLoading = false;
  String? _error;
  int _totalVisits = 0;
  String _selectedFilter = 'All';
  bool _isConfirming = false;
  bool _isCancelling = false;
  bool _isCompleting = false;

  List<VisitorModel> get visitors => _visitors;

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get totalVisits => _totalVisits;

  String get selectedFilter => _selectedFilter;

  bool get isConfirming => _isConfirming;

  bool get isCancelling => _isCancelling;

  bool get isCompleting => _isCompleting;

  List<VisitorModel> get filteredVisitors {
    if (_selectedFilter == 'All') return _visitors;
    return _visitors;
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  Future<void> fetchAllVisitors(String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final uri = Uri.parse('$base_url/api/visits/user?status=$status');

      final response = await http
          .get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print("AllVisitors${response.body}");

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        if (decodedData == null || decodedData is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        final data = decodedData as Map<String, dynamic>;

        if (data['success'] == true) {
          _totalVisits = data['totalVisits'] ?? 0;

          final visitsData = data['visits'];
          if (visitsData != null && visitsData is List) {
            _visitors =
                visitsData
                    .where(
                      (item) => item != null && item is Map<String, dynamic>,
                )
                    .map((visitor) {
                  try {
                    return VisitorModel.fromJson(
                      visitor as Map<String, dynamic>,
                    );
                  } catch (e) {
                    debugPrint('Error parsing visitor: $e');
                    return null;
                  }
                })
                    .where((visitor) => visitor != null)
                    .cast<VisitorModel>()
                    .toList();
          } else {
            _visitors = [];
          }

          _error = null;
        } else {
          _error = data['message']?.toString() ?? 'Failed to fetch visitors';
        }
      } else if (response.statusCode == 401) {
        _error = 'Unauthorized. Please login again.';
      } else if (response.statusCode == 404) {
        _error = 'API endpoint not found';
      } else {
        _error =
        'Failed to fetch visitors. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      debugPrint('Error fetching visitors: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmVisit({
    required String visitorId,
    String? confirmationNotes,
    String? meetingPoint,
  }) async {
    if (visitorId.isEmpty) {
      _error = 'Invalid visitor ID';
      notifyListeners();
      return false;
    }

    _isConfirming = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final body = <String, dynamic>{};

      if (confirmationNotes != null && confirmationNotes.isNotEmpty) {
        body['confirmationNotes'] = confirmationNotes;
      }

      if (meetingPoint != null && meetingPoint.isNotEmpty) {
        body['meetingPoint'] = meetingPoint;
      }

      final response = await http
          .put(
        Uri.parse('$base_url/api/visits/$visitorId/confirm'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('Confirm Response Body: ${response.body}');
      debugPrint('Confirm Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        if (decodedData == null || decodedData is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        final data = decodedData;

        if (data['success'] == true) {
          final visitData = data['visit'];
          if (visitData != null && visitData is Map<String, dynamic>) {
            try {
              final updatedVisitor = VisitorModel.fromJson(visitData);

              final index = _visitors.indexWhere((v) => v.id == visitorId);
              if (index != -1) {
                _visitors[index] = updatedVisitor;
              }

              _error = null;
              notifyListeners();
              return true;
            } catch (e) {
              debugPrint('Error parsing updated visitor: $e');
              throw Exception('Failed to parse updated visitor data');
            }
          } else {
            throw Exception('No visit data in response');
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to confirm visit');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Visit not found');
      } else {
        throw Exception(
          'Failed to confirm visit. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = 'Error confirming visit: ${e.toString()}';
      debugPrint('Error confirming visit: $e');
      notifyListeners();
      return false;
    } finally {
      _isConfirming = false;
      notifyListeners();
    }
  }

  Future<bool> completeVisit({
    required String visitorId,
    String? completionNotes,
    String? feedbackComment,
  }) async {
    if (visitorId.isEmpty) {
      _error = 'Invalid visitor ID';
      notifyListeners();
      return false;
    }

    _isCompleting = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final body = <String, dynamic>{};

      if (completionNotes != null && completionNotes.isNotEmpty) {
        body['completionNotes'] = completionNotes;
      }

      if (feedbackComment != null && feedbackComment.isNotEmpty) {
        body['feedback'] = {
          'comment': feedbackComment,
        };
      }

      final response = await http
          .put(
        Uri.parse('$base_url/api/visits/$visitorId/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('Complete Response Body: ${response.body}');
      debugPrint('Complete Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        if (decodedData == null || decodedData is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        final data = decodedData;

        if (data['success'] == true) {
          final visitData = data['visit'];
          if (visitData != null && visitData is Map<String, dynamic>) {
            try {
              final updatedVisitor = VisitorModel.fromJson(visitData);

              final index = _visitors.indexWhere((v) => v.id == visitorId);
              if (index != -1) {
                _visitors[index] = updatedVisitor;
              }

              _error = null;
              notifyListeners();
              return true;
            } catch (e) {
              debugPrint('Error parsing updated visitor: $e');
              throw Exception('Failed to parse updated visitor data');
            }
          } else {
            throw Exception('No visit data in response');
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to complete visit');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Visit not found');
      } else {
        throw Exception(
          'Failed to complete visit. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = 'Error completing visit: ${e.toString()}';
      debugPrint('Error completing visit: $e');
      notifyListeners();
      return false;
    } finally {
      _isCompleting = false;
      notifyListeners();
    }
  }

  Future<bool> cancelVisit({
    required String visitorId,
    String? cancellationReason,
    String? meetingPoint,
  }) async {
    if (visitorId.isEmpty) {
      _error = 'Invalid visitor ID';
      notifyListeners();
      return false;
    }

    _isCancelling = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final body = <String, dynamic>{};

      if (cancellationReason != null && cancellationReason.isNotEmpty) {
        body['cancellationReason'] = cancellationReason;
      } else {
        body['cancellationReason'] = 'No reason provided';
      }

      if (meetingPoint != null && meetingPoint.isNotEmpty) {
        body['meetingPoint'] = meetingPoint;
      }

      final response = await http
          .put(
        Uri.parse('$base_url/api/visits/$visitorId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      debugPrint('Cancel Response Body: ${response.body}');
      debugPrint('Cancel Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        if (decodedData == null || decodedData is! Map<String, dynamic>) {
          throw Exception('Invalid response format');
        }

        final data = decodedData;

        if (data['success'] == true) {
          final visitData = data['visit'];
          if (visitData != null && visitData is Map<String, dynamic>) {
            try {
              final updatedVisitor = VisitorModel.fromJson(visitData);

              final index = _visitors.indexWhere((v) => v.id == visitorId);
              if (index != -1) {
                _visitors[index] = updatedVisitor;
              }

              _error = null;
              notifyListeners();
              return true;
            } catch (e) {
              debugPrint('Error parsing updated visitor: $e');
              throw Exception('Failed to parse updated visitor data');
            }
          } else {
            throw Exception('No visit data in response');
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to cancel visit');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Visit not found');
      } else {
        throw Exception(
          'Failed to cancel visit. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = 'Error cancelling visit: ${e.toString()}';
      debugPrint('Error cancelling visit: $e');
      notifyListeners();
      return false;
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }

  Future<void> deleteVisitor(String visitorId) async {
    if (visitorId.isEmpty) {
      _error = 'Invalid visitor ID';
      notifyListeners();
      return;
    }

    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final response = await http
          .delete(
        Uri.parse('$base_url/api/visits/$visitorId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        if (decodedData != null && decodedData is Map<String, dynamic>) {
          final data = decodedData as Map<String, dynamic>;

          if (data['success'] == true) {
            _visitors.removeWhere((visitor) => visitor.id == visitorId);
            _totalVisits = _visitors.length;
            _error = null;
            notifyListeners();
          } else {
            throw Exception(data['message'] ?? 'Failed to delete visitor');
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Visitor not found');
      } else {
        throw Exception(
          'Failed to delete visitor. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _error = 'Error deleting visitor: ${e.toString()}';
      debugPrint('Error deleting visitor: $e');
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (filter.isNotEmpty) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshData(String status) async {
    await fetchAllVisitors(status);
  }

  void reset() {
    _visitors = [];
    _isLoading = false;
    _error = null;
    _totalVisits = 0;
    _selectedFilter = 'All';
    _isConfirming = false;
    _isCancelling = false;
    _isCompleting = false;
    notifyListeners();
  }
}