import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/styles.dart';
import '../services/product_repository.dart';
import 'publish_preview_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Part indicator (1 or 2)
  int _currentPart = 1;

  // Controllers & Form State
  final _nameController = TextEditingController(text: "Wireless Headphones");
  final _priceController = TextEditingController(text: "85000");
  final _stockController = TextEditingController(text: "50");
  final _skuController = TextEditingController(text: "WH-2024-BLK");
  final _descController = TextEditingController(
    text: "Premium noise-cancelling headphones with high-quality sound, long battery life and comfortable design. Perfect for work, travel and everyday use.",
  );

  // Category selection
  String _selectedCategory = "Electronics";
  final List<String> _categories = ["Electronics", "Agriculture", "Fashion", "Home", "Beauty", "Sports"];

  // Part 2 state
  final _originalPriceController = TextEditingController(text: "95000");
  final _discountPriceController = TextEditingController(text: "85000");
  final _taxController = TextEditingController(text: "0");
  final _minOrderController = TextEditingController(text: "1");
  bool _trackStock = true;

  // Shipping state
  bool _pickupChecked = true;
  bool _homeDeliveryChecked = true;
  bool _courierDeliveryChecked = false;
  final _shippingFeeController = TextEditingController(text: "5000");
  String _selectedDeliveryTime = "2 - 3 Days";

  // Additional settings state
  bool _featuredProduct = true;
  bool _promoteProduct = true;
  final List<String> _tags = ["headphones", "wireless", "audio"];
  final _tagInputController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _descController.dispose();
    _originalPriceController.dispose();
    _discountPriceController.dispose();
    _taxController.dispose();
    _minOrderController.dispose();
    _shippingFeeController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentPart == 2) {
              setState(() => _currentPart = 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _currentPart == 1 ? "Add New Product" : "Pricing & Shipping",
          style: AppStyles.titleMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar / Step Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentPart == 1 ? "Step 1 of 2: Product Info" : "Step 2 of 2: Details & Preview",
                  style: AppStyles.bodyMuted.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  _currentPart == 1 ? "50% Complete" : "90% Complete",
                  style: GoogleFonts.outfit(color: AppStyles.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _currentPart == 1 ? 0.5 : 0.9,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(AppStyles.accentGold),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 24),

            if (_currentPart == 1) _buildPart1Form() else _buildPart2Form(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Draft saved successfully!')),
                    );
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    "Save Draft",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPart == 1) {
                      setState(() => _currentPart = 2);
                    } else {
                      // Navigate to Preview Screen
                      final double price = double.tryParse(_priceController.text) ?? 85000;
                      final double? originalPrice = double.tryParse(_originalPriceController.text);
                      
                      final product = ProductItem(
                        name: _nameController.text,
                        price: price,
                        originalPrice: originalPrice,
                        icon: "🎧", // Headphones icon for new products
                        rating: "5.0",
                        description: _descController.text,
                        seller: "Doe Tech Store",
                        tags: List.from(_tags),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PublishPreviewScreen(product: product),
                        ),
                      );
                    }
                  },
                  style: AppStyles.goldButton.copyWith(
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
                  ),
                  child: Text(
                    _currentPart == 1 ? "Continue" : "Preview",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPart1Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Media Section
        _buildSectionHeader("1. Media", "Upload up to 10 images"),
        const SizedBox(height: 12),
        Row(
          children: [
            // Headphone preview square (High-fidelity design mockup)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppStyles.accentGold.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: const Text("🎧", style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: 10),
            // Placeholders matching mockup
            _buildMediaPlaceholder(false),
            const SizedBox(width: 10),
            _buildMediaPlaceholder(false),
            const SizedBox(width: 10),
            _buildMediaPlaceholder(true),
          ],
        ),
        const SizedBox(height: 16),
        
        // Video upload placeholder
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              const Icon(Icons.play_circle_outline, color: AppStyles.accentGold, size: 28),
              const SizedBox(height: 6),
              Text(
                "Upload Product Video (Optional)",
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                "Tap to upload video",
                style: AppStyles.bodyMuted.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // 2. Product Information
        _buildSectionHeader("2. Product Information", ""),
        const SizedBox(height: 12),
        _buildTextField("Product Name", _nameController),
        const SizedBox(height: 16),
        
        // Category Dropdown
        Text("Category", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppStyles.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              dropdownColor: AppStyles.cardBg,
              isExpanded: true,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCategory = val);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildTextField("Price (TZS)", _priceController, isNumber: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField("Stock Quantity", _stockController, isNumber: true)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField("SKU (Optional)", _skuController),
        const SizedBox(height: 28),

        // 3. Description
        _buildSectionHeader("3. Description", ""),
        const SizedBox(height: 12),
        
        // Rich text toolbar mockup
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const BoxDecoration(
            color: Color(0xFF1F1E22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Row(
            children: [
              Icon(Icons.format_bold_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 16),
              Icon(Icons.format_italic_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 16),
              Icon(Icons.format_underlined_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 16),
              Icon(Icons.format_list_bulleted_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 16),
              Icon(Icons.link_rounded, color: Colors.white70, size: 20),
            ],
          ),
        ),
        TextField(
          controller: _descController,
          maxLines: 4,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, height: 1.4),
          decoration: InputDecoration(
            fillColor: AppStyles.cardBg,
            filled: true,
            hintText: "Enter product description...",
            hintStyle: AppStyles.bodyMuted,
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white12),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppStyles.accentGold),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPart2Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 4. Pricing & Inventory
        _buildSectionHeader("4. Pricing & Inventory", ""),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField("Original Price (TZS)", _originalPriceController, isNumber: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField("Discount Price (TZS)", _discountPriceController, isNumber: true)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField("Tax (Optional) %", _taxController, isNumber: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField("Minimum Order", _minOrderController, isNumber: true)),
          ],
        ),
        const SizedBox(height: 16),
        
        // Track Stock Switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: AppStyles.cardDecoration,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Track Stock",
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _trackStock,
                activeColor: AppStyles.accentGold,
                onChanged: (val) {
                  setState(() => _trackStock = val);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // 5. Delivery & Shipping
        _buildSectionHeader("5. Delivery & Shipping", ""),
        const SizedBox(height: 12),
        
        Text("Delivery Options", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _buildCheckboxTile("Pickup", _pickupChecked, (val) => setState(() => _pickupChecked = val ?? false)),
        _buildCheckboxTile("Home Delivery", _homeDeliveryChecked, (val) => setState(() => _homeDeliveryChecked = val ?? false)),
        _buildCheckboxTile("Courier Delivery", _courierDeliveryChecked, (val) => setState(() => _courierDeliveryChecked = val ?? false)),
        
        const SizedBox(height: 16),
        _buildTextField("Shipping Fee (TZS)", _shippingFeeController, isNumber: true),
        const SizedBox(height: 16),

        // Delivery Time dropdown
        Text("Estimated Delivery Time", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppStyles.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDeliveryTime,
              dropdownColor: AppStyles.cardBg,
              isExpanded: true,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              items: ["1 Day", "2 - 3 Days", "4 - 7 Days", "2 Weeks"].map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedDeliveryTime = val);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 28),

        // 6. Additional Settings
        _buildSectionHeader("6. Additional Settings", ""),
        const SizedBox(height: 12),
        
        _buildSwitchTile("Featured Product", _featuredProduct, (val) => setState(() => _featuredProduct = val)),
        const SizedBox(height: 10),
        _buildSwitchTile("Promote Product", _promoteProduct, (val) => setState(() => _promoteProduct = val)),
        const SizedBox(height: 16),

        // Tags List
        Text("Tags", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map((tag) {
              return Chip(
                label: Text(tag, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white)),
                backgroundColor: AppStyles.cardBg,
                side: const BorderSide(color: Colors.white12),
                deleteIcon: const Icon(Icons.close, size: 12, color: AppStyles.textMuted),
                onDeleted: () {
                  setState(() => _tags.remove(tag));
                },
              );
            }),
            GestureDetector(
              onTap: _showAddTagDialog,
              child: Chip(
                avatar: const Icon(Icons.add, size: 12, color: AppStyles.accentGold),
                label: Text("Add", style: GoogleFonts.outfit(fontSize: 11, color: AppStyles.accentGold, fontWeight: FontWeight.bold)),
                backgroundColor: AppStyles.accentGold.withValues(alpha: 0.1),
                side: const BorderSide(color: AppStyles.accentGold, width: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppStyles.titleMedium.copyWith(fontSize: 15),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: AppStyles.bodyMuted.copyWith(fontSize: 11),
          ),
      ],
    );
  }

  Widget _buildMediaPlaceholder(bool isAddButton) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: isAddButton
          ? const Icon(Icons.add, color: AppStyles.accentGold, size: 28)
          : null,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            fillColor: AppStyles.cardBg,
            filled: true,
            hintText: "Enter $label",
            hintStyle: AppStyles.bodyMuted,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white12),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppStyles.accentGold),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(String label, bool value, ValueChanged<bool?> onChanged) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: Colors.white54),
      child: CheckboxListTile(
        title: Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
        value: value,
        activeColor: AppStyles.accentGold,
        checkColor: Colors.black,
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: AppStyles.cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
          Switch(
            value: value,
            activeColor: AppStyles.accentGold,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppStyles.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Add Tag", style: AppStyles.titleMedium),
          content: TextField(
            controller: _tagInputController,
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: InputDecoration(
              hintText: "e.g. smart",
              hintStyle: AppStyles.bodyMuted,
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppStyles.accentGold)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                final tag = _tagInputController.text.trim().toLowerCase();
                if (tag.isNotEmpty && !_tags.contains(tag)) {
                  setState(() => _tags.add(tag));
                }
                _tagInputController.clear();
                Navigator.pop(context);
              },
              style: AppStyles.goldButton,
              child: Text("Add", style: GoogleFonts.outfit(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}
