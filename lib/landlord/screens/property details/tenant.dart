import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/landlord/models/tenant_model.dart';
import 'package:draze/landlord/providers/tenant_provider.dart';

import 'TenantDetailsScreen.dart';

class TenantsTab extends StatefulWidget {
  final String propertyId;

  const TenantsTab({super.key, required this.propertyId});

  @override
  State<TenantsTab> createState() => _TenantsTabState();
}

class _TenantsTabState extends State<TenantsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TenantProvider>(
        context,
        listen: false,
      ).loadTenants(widget.propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Consumer<TenantProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 1.6),
                );
              }

              if (provider.error != null) {
                return _buildErrorState(context, provider.error!);
              }

              final tenants = provider.tenants;
              if (tenants == null || tenants.isEmpty) {
                return _buildEmptyState(context);
              }

              return _buildTenantsList(context, tenants);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 0.8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 3.2,
            offset: const Offset(0, 1.6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tenants',
            style: TextStyle(
              fontSize: AppSizes.largeText(context) * 0.8,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              Icons.person_outline,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.mediumPadding(context) * 0.8),
          Text(
            'No tenants added yet',
            style: TextStyle(
              fontSize: AppSizes.mediumText(context) * 0.8,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6.4),
          Text(
            'Start by adding your first tenant',
            style: TextStyle(
              fontSize: AppSizes.smallText(context) * 0.8,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 38.4, color: Colors.red),
          const SizedBox(height: 12.8),
          Text(
            'Error loading tenants',
            style: TextStyle(
              fontSize: AppSizes.mediumText(context) * 0.8,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 6.4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error,
              style: TextStyle(
                fontSize: AppSizes.smallText(context) * 0.8,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantsList(BuildContext context, List<Tenant> tenants) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<TenantProvider>(
          context,
          listen: false,
        ).loadTenants(widget.propertyId);
      },
      child: ListView.separated(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context) * 1.3),
        itemCount: tenants.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12.8),
        itemBuilder: (context, index) {
          return TenantCard(
            tenant: tenants[index],
            propertyId: widget.propertyId,
          );
        },
      ),
    );
  }
}

class TenantCard extends StatefulWidget {
  final Tenant tenant;
  final String propertyId;

  const TenantCard({super.key, required this.tenant, required this.propertyId});

  @override
  State<TenantCard> createState() => _TenantCardState();
}

class _TenantCardState extends State<TenantCard> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TenantDetailsScreen(
                  tenantId:
                      widget.tenant.tenantId!.isEmpty
                          ? ""
                          : widget.tenant.tenantId!,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6.4,
              offset: const Offset(0, 1.6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildTenantInfo(),
            if (_showMore) _buildExpandedDetails(),
            _buildShowMoreButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    const String placeholderImage =
        'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=400';

    return SizedBox(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.8),
              topRight: Radius.circular(12.8),
            ),
            child: Image.network(
              widget.tenant.photo ?? placeholderImage,
              width: double.infinity,
              height: AppSizes.buttonHeight(context) * 4,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: AppSizes.buttonHeight(context) * 4,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.person_off,
                    size: 38.4,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 9.6,
            right: 9.6,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.4,
                vertical: 3.2,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(widget.tenant.status),
                borderRadius: BorderRadius.circular(9.6),
              ),
              child: Text(
                widget.tenant.status.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantInfo() {
    return Padding(
      padding: const EdgeInsets.all(12.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.tenant.name ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14.4,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.4,
                  vertical: 3.2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.4),
                ),
                child: Text(
                  widget.tenant.status.displayName,
                  style: TextStyle(
                    fontSize: 9.6,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.4),
          Row(
            children: [
              Icon(Icons.currency_rupee, size: 12.8, color: AppColors.primary),
              Text(
                '${widget.tenant.monthlyRent?.toStringAsFixed(0) ?? "N/A"}/month',
                style: TextStyle(
                  fontSize: 12.8,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12.8),
              Icon(Icons.email_outlined, size: 12.8, color: Colors.grey[600]),
              const SizedBox(width: 3.2),
              Expanded(
                child: Text(
                  widget.tenant.email ?? 'N/A',
                  style: TextStyle(fontSize: 11.2, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.8, 0, 12.8, 12.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 0.8),
          const SizedBox(height: 12.8),
          _buildDetailRow('Phone', widget.tenant.mobile ?? 'N/A'),
          _buildDetailRow(
            'Deposit',
            '₹${widget.tenant.deposit?.toStringAsFixed(0) ?? "N/A"}',
          ),
          _buildDetailRow(
            'Start Date',
            widget.tenant.startDate != null
                ? '${widget.tenant.startDate!.day}/${widget.tenant.startDate!.month}/${widget.tenant.startDate!.year}'
                : 'N/A',
          ),
          if (widget.tenant.notes != null &&
              widget.tenant.notes!.isNotEmpty) ...[
            const SizedBox(height: 9.6),
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 11.2,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6.4),
            Text(
              widget.tenant.notes!,
              style: const TextStyle(fontSize: 9.6, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11.2, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11.2,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowMoreButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12.8),
          bottomRight: Radius.circular(12.8),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _showMore = !_showMore;
            });
          },
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12.8),
            bottomRight: Radius.circular(12.8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _showMore ? 'Show Less' : 'Show More',
                  style: TextStyle(
                    fontSize: 11.2,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 3.2),
                AnimatedRotation(
                  turns: _showMore ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TenantStatus status) {
    switch (status) {
      case TenantStatus.active:
        return Colors.green;
      case TenantStatus.pending:
        return Colors.orange;
      case TenantStatus.inactive:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
