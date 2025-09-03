import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class ActiveTimerPage extends StatelessWidget {
  const ActiveTimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Reset the timer and navigate back
            Provider.of<TimerProvider>(context, listen: false).resetTimer();
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Active Timer'),
        centerTitle: true,
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          final isRunning = timerProvider.state == TimerState.running;
          final isPaused = timerProvider.state == TimerState.paused;
          final isBreak = timerProvider.state == TimerState.breakTime;
          final isIdle = timerProvider.state == TimerState.idle;

          Color timerColor = Colors.greenAccent[400]!;
          if (isBreak) {
            timerColor = Colors.orangeAccent[400]!;
            if (timerProvider.remainingTime <= 5) {
              timerColor = Colors.redAccent[400]!;
            }
          }

          double progress = 0.0;
          if (timerProvider.currentTimer != null &&
              timerProvider.currentStepIndex <
                  timerProvider.currentTimer!.steps.length) {
            final totalDuration = isBreak
                ? timerProvider
                      .currentTimer!
                      .steps[timerProvider.currentStepIndex]
                      .breakDuration
                : timerProvider
                      .currentTimer!
                      .steps[timerProvider.currentStepIndex]
                      .intervalDuration;
            if (totalDuration > 0) {
              progress =
                  (totalDuration - timerProvider.remainingTime) / totalDuration;
            } else {
              progress = 1.0;
            }
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Container(color: Colors.black),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isBreak)
                      Column(
                        children: [
                          Text(
                            'Next Up:',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.normal,
                              color: timerColor,
                            ),
                          ),
                          Text(
                            timerProvider.nextStepName,
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: timerColor,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        timerProvider.currentStepName,
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: timerColor,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 16,
                            backgroundColor: Colors.grey.shade700,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              timerColor,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(timerProvider.remainingTime),
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: timerColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (isIdle || isPaused)
                          IconButton(
                            iconSize: 64,
                            icon: Icon(
                              Icons.play_arrow,
                              color: Colors.greenAccent[400],
                            ),
                            onPressed: isIdle
                                ? timerProvider.startTimer
                                : timerProvider.resumeTimer,
                          )
                        else if (isRunning || isBreak)
                          IconButton(
                            iconSize: 64,
                            icon: Icon(
                              Icons.pause,
                              color: Colors.greenAccent[400],
                            ),
                            onPressed: timerProvider.pauseTimer,
                          ),
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 64,
                          icon: Icon(
                            Icons.rotate_left,
                            color: Colors.orangeAccent[400],
                          ),
                          onPressed: timerProvider.resetCurrentInterval,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 64,
                          icon: Icon(Icons.stop, color: Colors.redAccent[400]),
                          onPressed: timerProvider.resetTimer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
