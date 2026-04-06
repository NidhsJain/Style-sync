import 'package:flutter/material.dart';
import '../models/outfit_model.dart';
import '../services/wardrobe_service.dart';
import 'home_screen.dart';

class EditOutfitScreen extends StatefulWidget {
  final Outfit outfit;

  const EditOutfitScreen({super.key, required this.outfit});

  @override
  State<EditOutfitScreen> createState() => _EditOutfitScreenState();
}

class _EditOutfitScreenState extends State<EditOutfitScreen> {
  static const Color _bg = Color(0xFF0F051D);
  static const Color _card = Color(0xFF1B0B2E);
  
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _colorController;
  late String _selectedCategory;
  
  final List<String> _categories = ['Topwear', 'Bottomwear', 'Footwear', 'Accessories'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.outfit.clothingName);
    _colorController = TextEditingController(text: widget.outfit.color);
    _selectedCategory = _categories.contains(widget.outfit.category) 
        ? widget.outfit.category 
        : _categories.first;
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: _card,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.purpleAccent.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.purpleAccent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  void _updateOutfit() {
    if (_formKey.currentState!.validate()) {
      final updatedOutfit = widget.outfit.copyWith(
        clothingName: _nameController.text.trim(),
        color: _colorController.text.trim(),
        category: _selectedCategory,
      );
      WardrobeService().updateOutfit(updatedOutfit);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen(gender: 'Female')),
                (route) => false,
              );
            }
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
        title: const Text(
          'Edit Outfit',
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('Clothing Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _colorController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('Color'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a color' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: _card,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('Category'),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _updateOutfit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 8,
                      shadowColor: Colors.purpleAccent.withOpacity(0.5),
                    ),
                    child: const Text('Update Outfit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
