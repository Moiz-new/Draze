import 'package:draze/landlord/models/tenant_model.dart';

class TenantService {
  // Mock implementation - replace with actual backend integration
  final List<Tenant> _tenants = [];

  Future<List<Tenant>> getTenantsByProperty(String propertyId) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return _tenants.where((tenant) => tenant.propertyId == propertyId).toList();
  }

  Future<void> addTenant(Tenant tenant) async {
    await Future.delayed(Duration(seconds: 1));
    _tenants.add(tenant);
  }

  Future<void> updateTenant(Tenant tenant) async {
    await Future.delayed(Duration(seconds: 1));
    final index = _tenants.indexWhere((t) => t.id == tenant.id);
    if (index != -1) {
      _tenants[index] = tenant;
    }
  }

  Future<void> deleteTenant(String tenantId) async {
    await Future.delayed(Duration(seconds: 1));
    _tenants.removeWhere((t) => t.id == tenantId);
  }

  Future<Tenant?> getTenant(String tenantId) async {
    await Future.delayed(Duration(seconds: 1));
    try {
      return _tenants.firstWhere((t) => t.id == tenantId);
    } catch (e) {
      return null;
    }
  }
}
