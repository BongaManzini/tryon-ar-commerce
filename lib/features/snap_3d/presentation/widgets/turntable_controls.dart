import 'package:flutter/material.dart';

/// Floating control panel for 360° rotation presets, continuous slider, and AR mode toggling.
class TurntableControls extends StatelessWidget {
  final double currentAngle;
  final bool isAutoRotating;
  final bool isARMode;
  final ValueChanged<double> onAngleChanged;
  final ValueChanged<bool> onToggleAutoRotate;
  final ValueChanged<bool> onToggleARMode;
  final VoidCallback onResetCamera;

  const TurntableControls({
    super.key,
    required this.currentAngle,
    required this.isAutoRotating,
    required this.isARMode,
    required this.onAngleChanged,
    required this.onToggleAutoRotate,
    required this.onToggleARMode,
    required this.onResetCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Angle Presets Row (Front, Right, Back, Left)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnglePresetButton(
                label: 'Front (0°)',
                isSelected: (currentAngle % 360).round() == 0,
                onTap: () => onAngleChanged(0.0),
              ),
              _AnglePresetButton(
                label: 'Right (90°)',
                isSelected: (currentAngle % 360).round() == 90,
                onTap: () => onAngleChanged(90.0),
              ),
              _AnglePresetButton(
                label: 'Back (180°)',
                isSelected: (currentAngle % 360).round() == 180,
                onTap: () => onAngleChanged(180.0),
              ),
              _AnglePresetButton(
                label: 'Left (270°)',
                isSelected: (currentAngle % 360).round() == 270,
                onTap: () => onAngleChanged(270.0),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 360° Continuous Orbit Slider
          Row(
            children: [
              const Icon(Icons.rotate_90_degrees_ccw, color: Colors.white70, size: 20),
              Expanded(
                child: Slider(
                  value: currentAngle.clamp(0.0, 360.0),
                  min: 0.0,
                  max: 360.0,
                  activeColor: const Color(0xFF6C63FF),
                  inactiveColor: Colors.white24,
                  onChanged: (val) => onAngleChanged(val),
                ),
              ),
              Text(
                '${currentAngle.toInt()}°',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Secondary Toggles: Auto-Spin, AR Mode, Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Auto-Spin Turntable Toggle
              TextButton.icon(
                onPressed: () => onToggleAutoRotate(!isAutoRotating),
                icon: Icon(
                  isAutoRotating ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: isAutoRotating ? const Color(0xFF00E676) : Colors.white70,
                  size: 18,
                ),
                label: Text(
                  isAutoRotating ? 'Auto-Spin ON' : 'Spin Turntable',
                  style: TextStyle(
                    color: isAutoRotating ? const Color(0xFF00E676) : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20, child: VerticalDivider(color: Colors.white24)),

              // Augmented Reality Passthrough Mode
              TextButton.icon(
                onPressed: () => onToggleARMode(!isARMode),
                icon: Icon(
                  Icons.view_in_ar,
                  color: isARMode ? const Color(0xFF00E676) : Colors.white70,
                  size: 18,
                ),
                label: Text(
                  isARMode ? 'AR Mode ON' : 'AR View',
                  style: TextStyle(
                    color: isARMode ? const Color(0xFF00E676) : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20, child: VerticalDivider(color: Colors.white24)),

              // Reset Camera
              IconButton(
                icon: const Icon(Icons.center_focus_strong, color: Colors.white70, size: 20),
                tooltip: 'Reset Camera',
                onPressed: onResetCamera,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnglePresetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnglePresetButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade400,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
