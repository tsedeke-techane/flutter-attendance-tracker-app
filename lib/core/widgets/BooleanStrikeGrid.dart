import 'package:flutter/material.dart';

class BooleanStrikeGrid extends StatelessWidget {
  final List<bool> data;
  final double size;
  final double gap;
  final Color presentColor;
  final Color absentColor;
  final Color emptyColor;

  const BooleanStrikeGrid({
    super.key,
    required this.data,
    this.size = 16,
    this.gap = 4,
    this.presentColor = Colors.green,
    this.absentColor = Colors.red,
    this.emptyColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    const rows = 4;
    const columns = 11;
    const totalSquares = rows * columns;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The 4x11 grid
        Column(
          children: List.generate(rows, (rowIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(columns, (colIndex) {
                final index = rowIndex * columns + colIndex;
                final hasData = index < data.length;
                return Container(
                  margin: EdgeInsets.only(
                    right: colIndex < columns - 1 ? gap : 0,
                    bottom: gap,
                  ),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: hasData
                        ? (data[index] ? presentColor : absentColor)
                        : emptyColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            );
          }),
        ),
        
        // Legend
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend('Present', presentColor),
            SizedBox(width: gap * 2),
            _buildLegend('Absent', absentColor),
            SizedBox(width: gap * 2),
            _buildLegend('Empty', emptyColor),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size / 2,
          height: size / 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
