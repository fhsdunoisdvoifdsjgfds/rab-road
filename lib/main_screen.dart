import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/main_page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/menu.png', height: 100),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GamePage()),
                    );
                  },
                  child: Image.asset('assets/play_btn.png', height: 80),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotebookPage()),
                    );
                  },
                  child: Image.asset('assets/notebook_btn.png', height: 60),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int coins = 100;
  List<int> availableVegetables = [1];
  List<PlantedVegetable?> plantedField = List.filled(9, null);

  @override
  void initState() {
    super.initState();
    loadGameData();
  }

  loadGameData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 100;
      availableVegetables =
          prefs
              .getStringList('vegetables')
              ?.map((e) => int.parse(e))
              .toList() ??
          [1];
    });
  }

  saveGameData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
    await prefs.setStringList(
      'vegetables',
      availableVegetables.map((e) => e.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/game_page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Top bar
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/back.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopPage(
                              coins: coins,
                              availableVegetables: availableVegetables,
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            coins = result['coins'];
                            availableVegetables = result['vegetables'];
                          });
                          saveGameData();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/coins.png',
                            height: 80,
                            width: 100,
                          ),
                          Positioned(
                            right: 10,
                            child: Text(
                              coins.toString(),
                              style: GoogleFonts.titanOne(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Game field
            Expanded(
              child: Container(
                width: 300,
                height: 300,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return DragTarget<int>(
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              70,
                              52,
                              46,
                            ).withOpacity(0.3),
                            border: Border.all(color: Colors.brown, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: plantedField[index] != null
                              ? PlantedVegetableWidget(
                                  vegetable: plantedField[index]!,
                                  onCollect: () => _collectVegetable(index),
                                )
                              : Container(),
                        );
                      },
                      onAccept: (vegetableId) {
                        _plantVegetable(index, vegetableId);
                      },
                    );
                  },
                ),
              ),
            ),

            // Bottom vegetables table
            Container(
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/vegetables_table.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(right: 20, left: 20, top: 60),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availableVegetables.length,
                  itemBuilder: (context, index) {
                    int vegId = availableVegetables[index];
                    return Draggable<int>(
                      data: vegId,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset(
                          'assets/veg/$vegId.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                      feedback: Image.asset(
                        'assets/veg/$vegId.png',
                        width: 60,
                        height: 60,
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Image.asset(
                            'assets/veg/$vegId.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _plantVegetable(int fieldIndex, int vegetableId) {
    if (plantedField[fieldIndex] == null) {
      setState(() {
        plantedField[fieldIndex] = PlantedVegetable(
          id: vegetableId,
          plantTime: DateTime.now(),
          growthDuration: 10,
        );
      });
    }
  }

  void _collectVegetable(int fieldIndex) {
    if (plantedField[fieldIndex] != null &&
        plantedField[fieldIndex]!.isReadyToCollect()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GrowPage(
            onComplete: (success) {
              if (success) {
                setState(() {
                  coins += 20; // Увеличено до 20 за победу
                  plantedField[fieldIndex] = null;
                  // Исправлена логика разблокировки новых овощей
                  if (availableVegetables.length < 9) {
                    int nextVeg = availableVegetables.length + 1;
                    if (!availableVegetables.contains(nextVeg) &&
                        Random().nextDouble() > 0.3) {
                      availableVegetables.add(nextVeg);
                    }
                  }
                });
                saveGameData();
              } else {
                setState(() {
                  plantedField[fieldIndex] = null;
                });
              }
            },
          ),
        ),
      );
    }
  }
}

class NotebookPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/game_page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with back button
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/back.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              Text(
                'Notebook',
                style: GoogleFonts.titanOne(
                  fontSize: 36,
                  color: Colors.green[800],
                  shadows: [
                    Shadow(
                      blurRadius: 3.0,
                      color: Colors.black26,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('How to Play'),
                      SizedBox(height: 10),

                      _buildInstructionStep(
                        '1. Plant the Seed 🌱',
                        '• Choose a vegetable and place it on the field.',
                      ),

                      SizedBox(height: 15),

                      _buildInstructionStep(
                        '2. Pick the Right Helpers ☀️💧⚡',
                        '• Each plant needs the correct icons (like Sun, Water, Soil, etc.).\n• Be careful! Wrong icons (Fire, Snow, Lightning, etc.) will stop the plant from growing.',
                      ),

                      SizedBox(height: 15),

                      _buildInstructionStep(
                        '3. Tap "Grow" 🌿',
                        '• If your choices are correct, the plant will grow, and you\'ll earn coins.\n• Use coins to unlock new vegetables in the shop.',
                      ),

                      SizedBox(height: 15),

                      _buildInstructionStep(
                        'Unlock & Expand 🏪🌾',
                        '• Collect more plants, grow your garden, and discover all the crops!',
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Play button at bottom right
              Padding(
                padding: EdgeInsets.only(right: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Navigate to main page
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Image.asset('assets/play_btn.png', height: 70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.titanOne(
        fontSize: 24,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 2.0,
            color: Colors.black,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String title, String description) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green[300]!, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.titanOne(fontSize: 18, color: Colors.green[700]),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.titanOne(
              fontSize: 14,
              color: Colors.brown[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ShopPage extends StatefulWidget {
  final int coins;
  final List<int> availableVegetables;

  ShopPage({required this.coins, required this.availableVegetables});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late int coins;
  late List<int> availableVegetables;

  @override
  void initState() {
    super.initState();
    coins = widget.coins;
    availableVegetables = List.from(widget.availableVegetables);
  }

  int getVegetablePrice(int vegId) {
    return 100 + (vegId * 20); // 120, 140, 160, 180, и т.д.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/game_page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, {
                          'coins': coins,
                          'vegetables': availableVegetables,
                        });
                      },
                      child: Image.asset(
                        'assets/back.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/coins.png', height: 80, width: 100),
                        Positioned(
                          right: 10,
                          child: Text(
                            coins.toString(),
                            style: GoogleFonts.titanOne(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Shop title

            // Shop items
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/shop.png'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsGeometry.only(top: 120),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      int vegId = index + 1;
                      bool isUnlocked = availableVegetables.contains(vegId);
                      int price = getVegetablePrice(vegId);
                      bool canBuy = coins >= price && !isUnlocked;

                      return GestureDetector(
                        onTap: canBuy
                            ? () {
                                setState(() {
                                  coins -= price;
                                  availableVegetables.add(vegId);
                                });
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/veg/$vegId.png',
                                width: 50,
                                height: 50,
                                color: isUnlocked
                                    ? null
                                    : canBuy
                                    ? null
                                    : Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isUnlocked ? 'OWNED' : '$price',
                                  style: GoogleFonts.titanOne(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlantedVegetable {
  final int id;
  final DateTime plantTime;
  final int growthDuration;

  PlantedVegetable({
    required this.id,
    required this.plantTime,
    required this.growthDuration,
  });

  bool isReadyToCollect() {
    return DateTime.now().difference(plantTime).inSeconds >= growthDuration;
  }

  int getRemainingTime() {
    int elapsed = DateTime.now().difference(plantTime).inSeconds;
    return math.max(0, growthDuration - elapsed);
  }
}

class PlantedVegetableWidget extends StatefulWidget {
  final PlantedVegetable vegetable;
  final VoidCallback onCollect;

  PlantedVegetableWidget({required this.vegetable, required this.onCollect});

  @override
  _PlantedVegetableWidgetState createState() => _PlantedVegetableWidgetState();
}

class _PlantedVegetableWidgetState extends State<PlantedVegetableWidget> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
      if (widget.vegetable.isReadyToCollect()) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.vegetable.isReadyToCollect() ? widget.onCollect : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/veg/${widget.vegetable.id}.png',
            width: 80,
            height: 80,
          ),
          Positioned(
            bottom: 5,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.vegetable.isReadyToCollect()
                    ? 'COLLECT'
                    : widget.vegetable.getRemainingTime().toString(),
                style: GoogleFonts.titanOne(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GrowPage extends StatefulWidget {
  final Function(bool) onComplete;

  GrowPage({required this.onComplete});

  @override
  _GrowPageState createState() => _GrowPageState();
}

class _GrowPageState extends State<GrowPage> {
  int? selectedBoost;
  bool canGrow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/grow_page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/back.png',
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/grow_table.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      width: 340,
                      height: 500,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 140,
                          left: 80,
                          right: 90,
                          bottom: 90,
                        ),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            int boostId = index + 1;
                            bool isSelected = selectedBoost == boostId;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedBoost = boostId;
                                  canGrow = true;
                                });
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.yellow,
                                          width: 3,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(
                                  'assets/boost/$boostId.png',
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    GestureDetector(
                      onTap: canGrow ? () => _processGrow() : null,
                      child: Image.asset(
                        height: 140,
                        width: 120,
                        canGrow
                            ? 'assets/grow_btn_select.png'
                            : 'assets/grow_btn_unselect.png',
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

  void _processGrow() {
    if (selectedBoost == null) return;

    bool isWin = selectedBoost != 5 && selectedBoost != 6;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          isWin: isWin,
          onComplete: () {
            Navigator.pop(context);
            widget.onComplete(isWin);
          },
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final bool isWin;
  final VoidCallback onComplete;

  ResultPage({required this.isWin, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg/grow_page.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Win/Lose table
              Image.asset(
                isWin ? 'assets/win_table.png' : 'assets/lose_table.png',
                width: 300,
                height: 400,
              ),

              SizedBox(height: 30),

              // OK button
              GestureDetector(
                onTap: onComplete,
                child: Image.asset('assets/ok_btn.png', width: 120, height: 60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
