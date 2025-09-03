class TimerConfiguration {
  final int? id; // Null for new timers, populated by the database
  final String name;
  final List<TimerStep> steps;

  TimerConfiguration({this.id, required this.name, required this.steps});

  // Convert a TimerConfiguration object into a Map for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  // Create a TimerConfiguration object from a Map (retrieved from the database)
  factory TimerConfiguration.fromJson(Map<String, dynamic> json) {
    return TimerConfiguration(
      id: json['id'],
      name: json['name'],
      steps: (json['steps'] as List)
          .map((stepJson) => TimerStep.fromJson(stepJson))
          .toList(),
    );
  }
}

class TimerStep {
  String intervalName;
  int intervalDuration; // in seconds
  int breakDuration; // in seconds

  TimerStep({
    required this.intervalName,
    required this.intervalDuration,
    required this.breakDuration,
  });

  // Convert a TimerStep object into a Map
  Map<String, dynamic> toJson() {
    return {
      'intervalName': intervalName,
      'intervalDuration': intervalDuration,
      'breakDuration': breakDuration,
    };
  }

  // Create a TimerStep object from a Map
  factory TimerStep.fromJson(Map<String, dynamic> json) {
    return TimerStep(
      intervalName: json['intervalName'],
      intervalDuration: json['intervalDuration'],
      breakDuration: json['breakDuration'],
    );
  }
}
