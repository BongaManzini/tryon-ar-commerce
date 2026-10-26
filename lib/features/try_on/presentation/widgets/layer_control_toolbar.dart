import 'package:flutter/material.dart';

/// Floating toolbar widget providing fast matrix controls, opacity tuning, and layer reordering.
class LayerControlToolbar extends StatelessWidget {
  final bool isCutoutOnTop;
  final double opacity;
  final VoidCallback onToggleLayerOrder;
  final ValueChanged<double> onOpacityChanged;
  final VoidCallback onResetTransform;
  final VoidCallback onFitCenter;
  final VoidCallback onCaptureSnapshot;

  const LayerControlToolbar({
    super.key,
    required this.isCutoutOnTop,
    required this.opacity,
    required this.onToggleLayerOrder,
    required this.onOpacityChanged,
    required this.onResetTransform,
    required this.onFitCenter,
    required this.onCaptureSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reset Transform Button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Position',
            onPressed: onResetTransform,
            color: Colors.white70,
          ),

          // Fit to Center Button
          IconButton(
            icon: const Icon(Icons.center_focus_strong_rounded),
            tooltip: 'Fit Center',
            onPressed: onFitCenter,
            color: Colors.white70,
          ),

          // Layer Ordering Toggle
          IconButton(
            icon: Icon(
              isCutoutOnTop ? Icons.flip_to_front_rounded : Icons.flip_to_back_rounded,
              color: isCutoutOnTop ? const Color(0xFF00E676) : Colors.amberAccent,
            ),
            tooltip: isCutoutOnTop ? 'Cutout in Front' : 'Garment in Front',
            onPressed: onToggleLayerOrder,
          ),

          // Opacity Slider Modal Trigger
          IconButton(
            icon: const Icon(Icons.opacity_rounded),
            tooltip: 'Adjust Opacity (${(opacity * 100).toInt()}%)',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1E1E24),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  double currentVal = opacity;
                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Layer Transparency',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${(currentVal * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Slider(
                              value: currentVal,
                              min: 0.1,
                              max: 1.0,
                              divisions: 18,
                              activeColor: const Color(0xFF6C63FF),
                              inactiveColor: Colors.white24,
                              onChanged: (val) {
                                setModalState(() => currentVal = val);
                                onOpacityChanged(val);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            color: Colors.white70,
          ),

          const SizedBox(width: 4),
          const SizedBox(
            height: 24,
            child: VerticalDivider(color: Colors.white24, width: 1),
          ),
          const SizedBox(width: 4),

          // Save / Snapshot Button
          ElevatedButton.icon(
            onPressed: onCaptureSnapshot,
            icon: const Icon(Icons.camera_alt_outlined, size: 16),
            label: const Text('Save Look'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
