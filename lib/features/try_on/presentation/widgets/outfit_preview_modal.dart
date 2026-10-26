import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../catalog/domain/models/product.dart';

/// Modal dialog showing the captured composite snapshot with checkout and wishlist actions.
class OutfitPreviewModal extends StatefulWidget {
  final Uint8List snapshotBytes;
  final Product? selectedProduct;
  final Future<void> Function(String title) onSaveToWishlist;
  final VoidCallback onCheckout;

  const OutfitPreviewModal({
    super.key,
    required this.snapshotBytes,
    required this.selectedProduct,
    required this.onSaveToWishlist,
    required this.onCheckout,
  });

  @override
  State<OutfitPreviewModal> createState() => _OutfitPreviewModalState();
}

class _OutfitPreviewModalState extends State<OutfitPreviewModal> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.selectedProduct != null
        ? '${widget.selectedProduct!.title} Fit'
        : 'My Try-On Look';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 680),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Composited Outfit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Captured Snapshot Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.black,
                  child: Image.memory(
                    widget.snapshotBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name Field
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Outfit Name',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_isSaving || _saved)
                        ? null
                        : () async {
                            setState(() => _isSaving = true);
                            await widget.onSaveToWishlist(_nameController.text.trim());
                            setState(() {
                              _isSaving = false;
                              _saved = true;
                            });
                          },
                    icon: Icon(
                      _saved ? Icons.check_circle : Icons.bookmark_border,
                      color: _saved ? const Color(0xFF00E676) : Colors.white,
                    ),
                    label: Text(
                      _saved ? 'Saved!' : 'Wishlist',
                      style: TextStyle(
                        color: _saved ? const Color(0xFF00E676) : Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _saved ? const Color(0xFF00E676) : Colors.white24,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onCheckout();
                    },
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
                    label: const Text(
                      'Checkout',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
