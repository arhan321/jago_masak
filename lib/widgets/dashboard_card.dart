import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isTight = c.maxHeight < 150;

        final pad = isTight ? 12.0 : 14.0;
        final iconBox = isTight ? 42.0 : 48.0;
        final iconSize = isTight ? 24.0 : 28.0;
        final titleFs = isTight ? 12.0 : 13.0;
        final valueFs = isTight ? 20.0 : 24.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: null, // kalau nanti mau clickable, isi handler-nya
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                // ✅ nuansa lama tapi lebih “rich”
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.softBlue.withOpacity(0.55),
                    Colors.white,
                  ],
                ),
                border: Border.all(
                  color: AppTheme.navy.withOpacity(0.12),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navy.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ top row: icon + accent
                    Row(
                      children: [
                        Container(
                          width: iconBox,
                          height: iconBox,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.navy.withOpacity(0.10),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child:
                              Icon(icon, color: AppTheme.navy, size: iconSize),
                        ),
                        const Spacer(),
                        Container(
                          height: 10,
                          width: isTight ? 44 : 54,
                          decoration: BoxDecoration(
                            color: AppTheme.navy.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTight ? 10 : 12),

                    // ✅ title (multiline aman)
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: titleFs,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navy.withOpacity(0.95),
                          height: 1.15,
                        ),
                      ),
                    ),

                    SizedBox(height: isTight ? 8 : 10),

                    // ✅ value (anti overflow)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: valueFs,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.navy,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
