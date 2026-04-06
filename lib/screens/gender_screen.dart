import 'package:flutter/material.dart';
import 'home_screen.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {

  String selectedGender = "";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0F051D),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              /// BACK BUTTON
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {},
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "StyleSync",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Choose Your Style",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Personalize your fashion feed and discover trends\nthat match you.",
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 40),

              /// GENDER OPTIONS
              Row(
                children: [

                  /// MALE CARD
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = "Male";
                        });
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedGender == "Male"
                                ? Colors.purpleAccent
                                : Colors.transparent,
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: AssetImage("assets/avatar/male_model.png"),
                            fit: BoxFit.cover,
                          ),
                        ),

                        alignment: Alignment.bottomLeft,

                        padding: const EdgeInsets.all(10),

                        child: const Text(
                          "♂ Male",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// FEMALE CARD
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGender = "Female";
                        });
                      },
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selectedGender == "Female"
                                ? Colors.purpleAccent
                                : Colors.transparent,
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: AssetImage("assets/avatar/female_model.png"),
                            fit: BoxFit.cover,
                          ),
                        ),

                        alignment: Alignment.bottomLeft,
                        padding: const EdgeInsets.all(10),

                        child: const Text(
                          "♀ Female",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(

                  onPressed: selectedGender.isEmpty
                      ? null
                      : () {

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  HomeScreen(gender: selectedGender),
                            ),
                          );

                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "By continuing, you agree to our Terms of Service\nand Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}