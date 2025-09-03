import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timer_model.dart';
import '../providers/timer_provider.dart';

class TimerCreationPage extends StatefulWidget {
  final TimerConfiguration? timer;
  const TimerCreationPage({super.key, this.timer});

  @override
  State<TimerCreationPage> createState() => _TimerCreationPageState();
}

class _TimerCreationPageState extends State<TimerCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _timerNameController = TextEditingController();
  late List<TimerStep> _steps;

  @override
  void initState() {
    super.initState();
    _steps =
        widget.timer?.steps
            .map(
              (s) => TimerStep(
                intervalName: s.intervalName,
                intervalDuration: s.intervalDuration,
                breakDuration: s.breakDuration,
              ),
            )
            .toList() ??
        [];
    if (widget.timer != null) {
      _timerNameController.text = widget.timer!.name;
    }
  }

  @override
  void dispose() {
    _timerNameController.dispose();
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _steps.insert(
        0,
        TimerStep(intervalName: '', intervalDuration: 0, breakDuration: 0),
      );
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  void _saveOrUpdateTimer() {
    if (_formKey.currentState!.validate()) {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);

      if (widget.timer != null) {
        final updatedTimer = TimerConfiguration(
          id: widget.timer!.id,
          name: _timerNameController.text,
          steps: _steps.reversed.toList(),
        );
        timerProvider.updateTimer(updatedTimer);
      } else {
        final newTimer = TimerConfiguration(
          name: _timerNameController.text,
          steps: _steps.reversed.toList(),
        );
        timerProvider.setTimer(newTimer);
        timerProvider.saveTimer(newTimer);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.timer != null ? 'Edit Timer' : 'Create New Timer'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _timerNameController,
                decoration: const InputDecoration(
                  labelText: 'Timer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name for your timer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _TimerStepForm(
                      key: ValueKey(_steps[index]), // Use a unique key
                      step: _steps[index],
                      onRemove: () => _removeStep(index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Step'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveOrUpdateTimer,
                    icon: const Icon(Icons.save),
                    label: Text(
                      widget.timer != null ? 'Update Timer' : 'Save Timer',
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerStepForm extends StatefulWidget {
  final TimerStep step;
  final VoidCallback onRemove;

  const _TimerStepForm({
    required Key key, // Make sure the key is required
    required this.step,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<_TimerStepForm> createState() => _TimerStepFormState();
}

class _TimerStepFormState extends State<_TimerStepForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _intervalController;
  late final TextEditingController _breakController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.step.intervalName);
    _intervalController = TextEditingController(
      text: widget.step.intervalDuration.toString(),
    );
    _breakController = TextEditingController(
      text: widget.step.breakDuration.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _intervalController.dispose();
    _breakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Interval Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.step.intervalName = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _intervalController,
              decoration: const InputDecoration(
                labelText: 'Interval Duration (seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                widget.step.intervalDuration = int.tryParse(value) ?? 0;
              },
              validator: (value) {
                if (value == null || int.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _breakController,
              decoration: const InputDecoration(
                labelText: 'Break Duration (seconds)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                widget.step.breakDuration = int.tryParse(value) ?? 0;
              },
              validator: (value) {
                if (value == null || int.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
