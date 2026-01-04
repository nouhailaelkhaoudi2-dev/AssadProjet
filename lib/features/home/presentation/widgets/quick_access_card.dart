import 'package:flutter/material.dart';

class QuickAccessCard extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? asset; // optional image asset for circular avatar style

  const QuickAccessCard({
    super.key,
    this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: (asset != null)
                ? ClipOval(
                    child: Image.asset(
                      asset!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return (icon != null)
                            ? Icon(icon!, color: color, size: 28)
                            : const SizedBox.shrink();
                      },
                    ),
                  )
                : (icon != null)
                ? Icon(icon!, color: color, size: 28)
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
