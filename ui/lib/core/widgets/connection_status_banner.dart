import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../models/terminal_session.dart';

class ConnectionStatusBanner extends StatelessWidget {
  final TerminalConnectionState state;
  final VoidCallback? onReconnect;

  const ConnectionStatusBanner({
    super.key,
    required this.state,
    this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    if (state == TerminalConnectionState.connected) {
      return const SizedBox.shrink();
    }

    final isReconnecting = state == TerminalConnectionState.reconnecting;
    final bgColor = isReconnecting
        ? AppColors.warning.withOpacity(0.15)
        : AppColors.error.withOpacity(0.18);
    final borderColor = isReconnecting ? AppColors.warning : AppColors.error;
    final textColor = isReconnecting ? AppColors.warning : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor.withOpacity(0.4)),
        ),
      ),
      child: Row(
        children: [
          if (isReconnecting)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          else
            Icon(Icons.cloud_off_rounded, size: 16, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onReconnect != null)
            TextButton(
              onPressed: onReconnect,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                backgroundColor: textColor.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Reconnect',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
