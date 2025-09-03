import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/timer_model.dart';
import '../services/database_service.dart';

enum TimerState { idle, running, paused, breakTime }

class TimerProvider with ChangeNotifier {
  TimerState _state = TimerState.idle;
  int _currentStepIndex = 0;
  int _remainingTime = 0;
  Timer? _timer;
  TimerConfiguration? _currentTimer;
  String _currentStepName = 'Get Ready!';
  String _nextStepName = '';

  final AudioPlayer _audioPlayer = AudioPlayer();
  final DatabaseService _dbService = DatabaseService();

  TimerState get state => _state;
  int get remainingTime => _remainingTime;
  int get currentStepIndex => _currentStepIndex;
  String get currentStepName => _currentStepName;
  String get nextStepName => _nextStepName;
  TimerConfiguration? get currentTimer => _currentTimer;

  void setTimer(TimerConfiguration timer) {
    _timer?.cancel();
    _currentTimer = timer;
    _currentStepIndex = 0;
    _state = TimerState.idle;
    if (_currentTimer!.steps.isNotEmpty) {
      _currentStepName = 'Get Ready!';
      _nextStepName = _currentTimer!.steps[0].intervalName;
    } else {
      _currentStepName = 'No steps';
      _nextStepName = '';
    }
    _remainingTime = 0;
    notifyListeners();
  }

  void startTimer() {
    if (_currentTimer == null ||
        _currentTimer!.steps.isEmpty ||
        _state != TimerState.idle) {
      return;
    }
    _currentStepIndex = 0;
    _state = TimerState.running;
    _startCountdown();
    notifyListeners();
  }

  void pauseTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _state = TimerState.paused;
      notifyListeners();
    }
  }

  void resumeTimer() {
    if (_state == TimerState.paused) {
      if (_currentTimer == null || _currentTimer!.steps.isEmpty) return;
      _state = TimerState.running;
      _startCountdown();
      notifyListeners();
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _state = TimerState.idle;
    _currentStepIndex = 0;
    _remainingTime = 0;
    if (_currentTimer != null && _currentTimer!.steps.isNotEmpty) {
      _currentStepName = 'Get Ready!';
      _nextStepName = _currentTimer!.steps[0].intervalName;
    } else {
      _currentStepName = 'Get Ready!';
      _nextStepName = '';
    }
    notifyListeners();
  }

  void resetCurrentInterval() {
    if (_currentTimer == null ||
        _currentStepIndex >= _currentTimer!.steps.length) {
      return;
    }
    _timer?.cancel();
    _state = TimerState.running;
    _remainingTime = _currentTimer!.steps[_currentStepIndex].intervalDuration;
    _currentStepName = _currentTimer!.steps[_currentStepIndex].intervalName;
    _nextStepName = _currentTimer!.steps.length > _currentStepIndex + 1
        ? _currentTimer!.steps[_currentStepIndex + 1].intervalName
        : 'Complete!';
    _startCountdown();
    notifyListeners();
  }

  void _startCountdown() {
    if (_currentStepIndex >= _currentTimer!.steps.length) {
      _finishTimer();
      return;
    }
    final step = _currentTimer!.steps[_currentStepIndex];

    if (_state == TimerState.running) {
      _remainingTime = step.intervalDuration;
      _currentStepName = step.intervalName;
      _nextStepName = _currentTimer!.steps.length > _currentStepIndex + 1
          ? _currentTimer!.steps[_currentStepIndex + 1].intervalName
          : 'Complete!';
      _playChime('chime_interval.mp3');
    } else if (_state == TimerState.breakTime) {
      _remainingTime = step.breakDuration;
      _currentStepName = 'Break';
      _nextStepName = _currentTimer!.steps.length > _currentStepIndex + 1
          ? _currentTimer!.steps[_currentStepIndex + 1].intervalName
          : 'Complete!';
      _playChime('chime_break.mp3');
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        if (_remainingTime == 2) {
          _playChime('chime_interval.mp3');
        }
        notifyListeners();
      } else {
        _timer?.cancel();
        _moveToNextStep();
      }
    });
  }

  void _moveToNextStep() {
    if (_state == TimerState.running) {
      final currentStep = _currentTimer!.steps[_currentStepIndex];
      if (currentStep.breakDuration > 0 &&
          _currentStepIndex < _currentTimer!.steps.length - 1) {
        _state = TimerState.breakTime;
        _startCountdown();
      } else {
        // No break for this step, or last step. Move to the next interval.
        _currentStepIndex++;
        if (_currentStepIndex < _currentTimer!.steps.length) {
          _state = TimerState.running;
          _startCountdown();
        } else {
          _finishTimer();
        }
      }
    } else if (_state == TimerState.breakTime) {
      _currentStepIndex++;
      if (_currentStepIndex < _currentTimer!.steps.length) {
        _state = TimerState.running;
        _startCountdown();
      } else {
        _finishTimer();
      }
    }
  }

  void _finishTimer() {
    _timer?.cancel();
    _state = TimerState.idle;
    _currentStepName = 'Complete!';
    _nextStepName = '';
    _playChime('chime_completion.mp3');
    notifyListeners();
  }

  Future<void> _playChime(String chimePath) async {
    await _audioPlayer.play(AssetSource('audio/$chimePath'));
  }

  Future<void> saveTimer(TimerConfiguration timer) async {
    await _dbService.insertTimer(timer);
  }

  Future<void> updateTimer(TimerConfiguration timer) async {
    await _dbService.updateTimer(timer);
  }

  Future<List<TimerConfiguration>> getSavedTimers() async {
    return await _dbService.getTimers();
  }

  Future<void> deleteTimer(int id) async {
    await _dbService.deleteTimer(id);
  }
}
