import 'package:flutter/material.dart';

import '../models/export_workflow_status.dart';

class ExportWorkflowStageIndicator extends StatelessWidget {
  const ExportWorkflowStageIndicator({
    super.key,
    required this.currentStage,
  });

  final ExportWorkflowStage currentStage;

  static const List<ExportWorkflowStage> _stages = [
    ExportWorkflowStage.preparing,
    ExportWorkflowStage.validating,
    ExportWorkflowStage.generating,
    ExportWorkflowStage.saving,
    ExportWorkflowStage.completed,
  ];

  static const List<String> _labels = [
    'Prepare',
    'Validate',
    'Generate',
    'Save',
    'Complete',
  ];

  int get _currentIndex {
    if (currentStage == ExportWorkflowStage.failed ||
        currentStage == ExportWorkflowStage.cancelled) {
      return -1;
    }

    return _stages.indexOf(currentStage);
  }

  @override
  Widget build(BuildContext context) {
    final Color primary =
        Theme.of(context).colorScheme.primary;

    final Color inactive =
        Theme.of(context).colorScheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      child: Row(
        children: List.generate(_stages.length, (index) {
          final bool isCompleted =
              _currentIndex > index ||
              currentStage == ExportWorkflowStage.completed;

          final bool isCurrent =
              _currentIndex == index;

          final Color stageColor =
              isCompleted || isCurrent ? primary : inactive;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 250,
                        ),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted || isCurrent
                              ? primary
                              : Colors.transparent,
                          border: Border.all(
                            color: stageColor,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check
                              : _stageIcon(index),
                          size: 15,
                          color: isCompleted || isCurrent
                              ? Colors.white
                              : inactive,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _labels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCompleted || isCurrent
                              ? primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < _stages.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(
                        bottom: 22,
                        left: 2,
                        right: 2,
                      ),
                      color: isCompleted
                          ? primary
                          : inactive,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  IconData _stageIcon(int index) {
    switch (index) {
      case 0:
        return Icons.menu_book_outlined;
      case 1:
        return Icons.fact_check_outlined;
      case 2:
        return Icons.description_outlined;
      case 3:
        return Icons.save_outlined;
      default:
        return Icons.check;
    }
  }
}
