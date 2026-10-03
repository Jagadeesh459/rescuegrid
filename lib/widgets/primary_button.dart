import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isDanger;
  final bool isSecondary;
  final bool isSuccess;
  final bool isOutline;
  final bool isLoading;
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isDanger = false,
    this.isSecondary = false,
    this.isSuccess = false,
    this.isOutline = false,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    if (isOutline) {
      bg = Colors.transparent;
      fg = AppTheme.textPrimary;
      border = AppTheme.surfaceBorder;
    } else if (isDanger) {
      bg = AppTheme.emergencyRed;
      fg = Colors.white;
      border = AppTheme.emergencyRed;
    } else if (isSuccess) {
      bg = AppTheme.successGreen;
      fg = Colors.white;
      border = AppTheme.successGreen;
    } else if (isSecondary) {
      bg = AppTheme.surfaceLight;
      fg = AppTheme.textPrimary;
      border = AppTheme.surfaceBorder;
    } else {
      bg = AppTheme.pulseCyan;
      fg = Colors.black;
      border = AppTheme.pulseCyan;
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border, width: isOutline ? 1.5 : 1.0),
              boxShadow: isDanger && !isOutline
                  ? [
                      BoxShadow(
                        color: AppTheme.emergencyRed.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: content,
          ),
        ),
      ),
    );
  }
}

