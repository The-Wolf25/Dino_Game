import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(DinoGame());
}

class DinoGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dino Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MenuScreen(),
    );
  }
}

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil here
    ScreenUtil.init(
      context,
      designSize:
          Size(360, 690), // Change these values to match your design size
      minTextAdapt: true,
    );

    return Scaffold(
      backgroundColor: Colors.teal[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dino Game',
              style: TextStyle(
                fontSize: 50.sp,
                fontWeight: FontWeight.bold,
                color: Colors.teal[900],
              ),
            ),
            SizedBox(height: 50.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                textStyle: TextStyle(fontSize: 20.sp),
              ),
              child: Text('New Game'),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                // Quit functionality (could be implemented to exit app)
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                textStyle: TextStyle(fontSize: 20.sp),
              ),
              child: Text('Quit'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static double dinoY = 0.73; // Adjusted to align with ground
  double initialPos = dinoY;
  double height = 0;
  double time = 0;
  double gravity = -3.1; // Adjusted gravity for a slower fall
  double velocity = 5.5; // Increased velocity for a higher jump
  bool gameHasStarted = false;
  bool isJumping = false;
  bool isFalling = false;
  double obstacleX = 1.5;
  double coinX = 2.0;
  int score = 0;
  int coinScore = 0;
  bool isGameOver = false;
  Timer? _timer;
  Random random = Random();
  double obstacleSpeed = 0.05;
  double minObstacleInterval = 1.5;
  double coinInterval = 3.0;
  bool isDay = true;

  @override
  void initState() {
    super.initState();
    // Initialize the game state
    Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        isDay = !isDay; // Toggle day/night every 5 seconds
      });
    });
  }

  void startGame() {
    gameHasStarted = true;
    _timer = Timer.periodic(Duration(milliseconds: 25), (timer) {
      if (isJumping || isFalling) {
        time += 0.04;
        height = gravity * time * time + velocity * time;

        if (initialPos - height > 0.8) {
          time = 0;
          height = 0;
          dinoY = 0.8;
          initialPos = dinoY;
          isJumping = false;
        } else {
          dinoY = initialPos - height;
        }
      }

      setState(() {
        if (obstacleX < -1) {
          obstacleX = minObstacleInterval + random.nextDouble() * 2;
          score++;
          adjustDifficulty();
        } else {
          obstacleX -= obstacleSpeed;
        }

        if (coinX < -1) {
          coinX = random.nextDouble() * 2 + 1.5;
        } else {
          coinX -= obstacleSpeed;
        }

        if (coinX < -0.3 && coinX > -0.7 && dinoY > 0.7) {
          coinScore++;
          coinX = -2; // Move coin off screen
        }

        if (obstacleX < -0.3 && obstacleX > -0.7 && dinoY > 0.7) {
          gameHasStarted = false;
          _timer?.cancel();
          isGameOver = true;
          // Auto-return to menu after 1 second
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuScreen()),
            );
          });
        }
      });
    });
  }

  void jump() {
    if (!gameHasStarted) {
      startGame();
    }
    if (!isJumping && !isFalling) {
      isJumping = true;
      time = 0;
      initialPos = dinoY;
    }
  }

  void fall() {
    if (isJumping) {
      time = 0;
      height = 0;
      dinoY = initialPos;
      isJumping = false;
      isFalling = true;
    } else {
      isFalling = false; // Prevent jumping again on swipe down
    }
  }

  void adjustDifficulty() {
    if (score >= 5) {
      minObstacleInterval = 1.0; // Reduce the interval between cacti
    }

    if (score % 5 == 0) {
      obstacleSpeed += 0.02; // Increase speed every 5 points
    }
  }

  void resetGame() {
    setState(() {
      dinoY = 0.8; // Align with ground
      gameHasStarted = false;
      obstacleX = 1.5;
      coinX = 2.0;
      score = 0;
      coinScore = 0;
      isGameOver = false;
      isJumping = false;
      isFalling = false;
      obstacleSpeed = 0.05;
      minObstacleInterval = 1.5;
      coinInterval = 3.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: jump,
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 0) {
          fall();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.lightBlue[50],
        body: Stack(
          children: [
            // Background (Day/Night)
            AnimatedContainer(
              duration: Duration(seconds: 1),
              color: isDay ? Colors.lightBlue[300] : Colors.deepPurple[900],
              child: Stack(
                children: [
                  // Snow Effect
                  if (!isDay)
                    Positioned.fill(
                      child: SnowfallWidget(),
                    ),
                  // Rain Effect
                  if (isDay)
                    Positioned.fill(
                      child: RainfallWidget(),
                    ),
                ],
              ),
            ),
            // Ground and grass
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100.h,
                color: Colors.brown,
                child: Container(
                  height: 30.h,
                  color: Colors.green,
                ),
              ),
            ),
            // Dino
            Positioned(
              bottom: 80.h + (1 - dinoY) * 80.h, // Adjust based on dinoY
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment(-0.5, 0),
                child: Image.asset(
                  'Assets/images/dinooo.png',
                  height: 70.h,
                  width: 70.w,
                ),
              ),
            ),
            // Obstacle (Cactus)
            Positioned(
              bottom: 90.h,
              left: (MediaQuery.of(context).size.width * obstacleX),
              child: Container(
                height: 50.h,
                width: 50.w,
                child: Center(
                  child: Image.asset('Assets/images/cactuss.png'),
                ),
              ),
            ),
            // Coin
            Positioned(
              bottom: 109.h,
              left: (MediaQuery.of(context).size.width * coinX),
              child: Container(
                height: 30.h,
                width: 30.w,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.yellow,
                    ),
                    child: Icon(
                      Icons.money,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            // Score Display
            Positioned(
              top: 30.h,
              left: MediaQuery.of(context).size.width / 2 - 70.w,
              child: Container(
                width: 140.w,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Score',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Coin Score Display
            Positioned(
              top: 120.h,
              left: MediaQuery.of(context).size.width / 2 - 70.w,
              child: Container(
                width: 140.w,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Coin Score',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '$coinScore',
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Game Over Screen
            if (isGameOver)
              Center(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Game Over',
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MenuScreen(),
                            ),
                          );
                        },
                        child: Text('Return to Menu'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.teal,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.w, vertical: 15.h),
                          textStyle: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Snowfall Effect
class SnowfallWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SnowfallPainter(),
    );
  }
}

class SnowfallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final random = Random();
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2 + 1, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Rainfall Effect
class RainfallWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RainfallPainter(),
    );
  }
}

class RainfallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final random = Random();
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = random.nextDouble() * 10 + 5;
      canvas.drawLine(Offset(x, y), Offset(x, y + length), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
