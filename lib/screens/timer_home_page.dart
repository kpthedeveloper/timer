import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'active_timer_page.dart';
import 'timer_creation_page.dart';
import '../models/timer_model.dart';
import '../providers/timer_provider.dart';

class TimerHomePage extends StatefulWidget {
  const TimerHomePage({super.key});

  @override
  State<TimerHomePage> createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage> {
  late Future<List<TimerConfiguration>> _timersFuture;

  @override
  void initState() {
    super.initState();
    _loadTimers();
  }

  void _loadTimers() {
    setState(() {
      _timersFuture = Provider.of<TimerProvider>(
        context,
        listen: false,
      ).getSavedTimers();
    });
  }

  void _deleteTimer(int id) async {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    await timerProvider.deleteTimer(id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Timer deleted')));
    }
    _loadTimers(); // Refresh the list
  }

  void _useTimer(TimerConfiguration timer) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    timerProvider.setTimer(timer);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ActiveTimerPage()));
  }

  void _editTimer(TimerConfiguration timer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TimerCreationPage(timer: timer)),
    );
    if (mounted) {
      _loadTimers(); // Refresh the list after editing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Timers'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TimerCreationPage(),
                ),
              );
              if (mounted) {
                _loadTimers();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<TimerConfiguration>>(
        future: _timersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No saved timers yet.'));
          } else {
            final timers = snapshot.data!;
            return ListView.builder(
              itemCount: timers.length,
              itemBuilder: (context, index) {
                final timer = timers[index];
                return Dismissible(
                  key: Key(timer.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteTimer(timer.id!);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(timer.name),
                      subtitle: Text('${timer.steps.length} steps'),
                      onTap: () => _useTimer(timer),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Colors.grey.shade400),
                        onPressed: () => _editTimer(timer),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
