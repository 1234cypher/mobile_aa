import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../utils/theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier unifié'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks;

          Map<DateTime, List<Task>> groupedTasks = {};
          for (var task in tasks) {
            if (task.dueDate != null) {
              final day = DateTime(
                  task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
              if (groupedTasks[day] == null) {
                groupedTasks[day] = [];
              }
              groupedTasks[day]!.add(task);
            }
          }

          List<Task> _getTasksForDay(DateTime day) {
            return groupedTasks[DateTime(day.year, day.month, day.day)] ?? [];
          }

          return Column(
            children: [
              TableCalendar<Task>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                eventLoader: _getTasksForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _selectedDay == null
                    ? const Center(
                        child:
                            Text('Sélectionnez un jour pour voir les tâches'))
                    : ListView(
                        padding: const EdgeInsets.all(12),
                        children: _getTasksForDay(_selectedDay!).map((task) {
                          return Card(
                            child: ListTile(
                              title: Text(task.title),
                              subtitle: Text(
                                  task.category.toString().split('.').last),
                              trailing: Icon(
                                task.status == TaskStatus.completed
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: task.status == TaskStatus.completed
                                    ? AppTheme.accentColor
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
