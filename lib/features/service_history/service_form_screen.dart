import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/responsive_layout.dart';
import '../../data/models/service_record_model.dart';
import '../products/product_provider.dart';
import 'service_provider.dart';

/// Form screen for logging a new maintenance or repair service record.
class ServiceFormScreen extends StatefulWidget {
  final String? initialProductId;

  const ServiceFormScreen({super.key, this.initialProductId});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProductId;
  late DateTime _serviceDate;
  late TextEditingController _providerController;
  late TextEditingController _issueController;
  late TextEditingController _costController;
  late TextEditingController _resolutionController;
  DateTime? _nextMaintenanceDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.initialProductId;
    _serviceDate = DateTime.now();
    _providerController = TextEditingController();
    _issueController = TextEditingController();
    _costController = TextEditingController();
    _resolutionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _providerController.dispose();
    _issueController.dispose();
    _costController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an associated product asset')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final cost = double.tryParse(_costController.text.trim().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    final newRecord = ServiceRecordModel(
      productId: _selectedProductId!,
      serviceDate: _serviceDate,
      serviceProvider: _providerController.text.trim(),
      issueDescription: _issueController.text.trim(),
      cost: cost,
      resolution: _resolutionController.text.trim().isEmpty ? null : _resolutionController.text.trim(),
      nextMaintenanceDate: _nextMaintenanceDate,
      isSample: false,
    );

    final success = await context.read<ServiceProvider>().createRecord(newRecord);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service record saved to history'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Service & Repair'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _saveForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.champagne,
                foregroundColor: const Color(0xFF1A1300),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Color(0xFF1A1300))
                  : const Text('Save Service Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
      body: ResponsiveContentContainer(
        maxWidth: 720,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Product Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product / Asset *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedProductId,
                    dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.devices_rounded, size: 20, color: AppColors.champagne),
                      hintText: 'Select product being serviced',
                    ),
                    items: products.map((p) {
                      return DropdownMenuItem<String?>(
                        value: p.id,
                        child: Text('${p.name} (${p.brand ?? 'Asset'})'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedProductId = val),
                    validator: (val) => val == null ? 'Please select a product' : null,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Service Date
              CustomDatePickerField(
                label: 'Service Date *',
                selectedDate: _serviceDate,
                isRequired: true,
                onDateSelected: (date) {
                  if (date != null) setState(() => _serviceDate = date);
                },
              ),
              const SizedBox(height: 18),

              // Provider
              CustomTextField(
                controller: _providerController,
                label: 'Service Provider / Repair Center *',
                hint: 'e.g. Apple Genius Bar, Authorized Service, Self',
                prefixIcon: Icons.storefront_rounded,
                validator: (val) => Validators.required(val, 'Service provider'),
              ),
              const SizedBox(height: 18),

              // Issue Description
              CustomTextField(
                controller: _issueController,
                label: 'Issue Description *',
                hint: 'e.g. Broken keyboard key, cracked screen, annual filter change',
                prefixIcon: Icons.report_problem_outlined,
                validator: (val) => Validators.required(val, 'Issue description'),
              ),
              const SizedBox(height: 18),

              // Cost
              CustomTextField(
                controller: _costController,
                label: 'Service Cost (0 if covered under warranty) *',
                hint: '0.00',
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => Validators.numeric(val, 'Cost', allowZero: true),
              ),
              const SizedBox(height: 18),

              // Resolution
              CustomTextField(
                controller: _resolutionController,
                label: 'Resolution / Work Performed',
                hint: 'e.g. Replaced battery and tested cycle health to 100%',
                prefixIcon: Icons.check_circle_outline_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 18),

              // Next Scheduled Maintenance Date
              CustomDatePickerField(
                label: 'Next Maintenance Date (Optional)',
                hint: 'Schedule next checkup / service',
                selectedDate: _nextMaintenanceDate,
                onDateSelected: (date) => setState(() => _nextMaintenanceDate = date),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
