import 'package:flutter/material.dart';
import 'app_data.dart';

// ─── Exercise model ────────────────────────────────────────────────────────────

class Exercise {
  final String name;
  final String sets;
  final String reps;
  final String rest;
  final List<String> instructions;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.instructions,
  });
}

// ─── Exercise library ──────────────────────────────────────────────────────────

class WorkoutLibrary {
  static const Map<String, List<Exercise>> abs = {
    'Beginner': [
      Exercise(
        name: 'Crunches',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Lie on your back with knees bent and feet flat on the floor.',
          'Place your hands lightly behind your head, elbows wide.',
          'Engage your core and curl your shoulders up toward your knees.',
          'Pause at the top for a moment, then slowly lower back down.',
          'Keep your lower back pressed to the floor throughout.',
        ],
      ),
      Exercise(
        name: 'Plank Hold',
        sets: '3', reps: '20 sec', rest: '45 sec',
        instructions: [
          'Start face-down and prop yourself up on your forearms and toes.',
          'Keep your elbows directly under your shoulders.',
          'Form a straight line from your head to your heels — no sagging hips.',
          'Squeeze your glutes and brace your core as if bracing for a punch.',
          'Hold the position, breathing steadily throughout.',
        ],
      ),
      Exercise(
        name: 'Leg Raises',
        sets: '3', reps: '10', rest: '45 sec',
        instructions: [
          'Lie flat on your back with legs straight and hands under your lower back for support.',
          'Press your lower back into the floor and keep it there.',
          'Raise both legs together until they are vertical.',
          'Slowly lower your legs back down, stopping just before they touch the floor.',
          'Repeat without letting your lower back arch off the ground.',
        ],
      ),
      Exercise(
        name: 'Dead Bug',
        sets: '3', reps: '8 each side', rest: '45 sec',
        instructions: [
          'Lie on your back with arms straight up toward the ceiling and knees bent at 90 degrees.',
          'Press your lower back firmly into the floor — maintain this throughout.',
          'Slowly lower your right arm behind your head while extending your left leg straight.',
          'Return to the starting position with control.',
          'Repeat on the opposite side — left arm down, right leg extends.',
        ],
      ),
      Exercise(
        name: 'Bicycle Crunches',
        sets: '2', reps: '10 each side', rest: '45 sec',
        instructions: [
          'Lie on your back, hands behind your head, knees bent and lifted to 90 degrees.',
          'Bring your right elbow toward your left knee while extending your right leg.',
          'Rotate your torso — the movement comes from your obliques, not your neck.',
          'Switch sides in a controlled, pedalling motion.',
          'Keep the pace slow and deliberate for maximum muscle engagement.',
        ],
      ),
    ],
    'Intermediate': [
      Exercise(
        name: 'Plank Hold',
        sets: '3', reps: '45 sec', rest: '30 sec',
        instructions: [
          'Get into a forearm plank with elbows directly under your shoulders.',
          'Keep your body in a rigid straight line — no raised hips or sagging.',
          'Squeeze your glutes and brace your core hard.',
          'Push your forearms into the floor to engage your shoulders.',
          'Hold for the full duration, breathing steadily.',
        ],
      ),
      Exercise(
        name: 'Hanging Knee Raises',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Hang from a pull-up bar with an overhand grip, arms fully extended.',
          'Engage your core and avoid swinging your body.',
          'Slowly raise your knees toward your chest by flexing your hips and abs.',
          'Hold briefly at the top with knees as high as possible.',
          'Lower your legs in a controlled manner back to the start position.',
        ],
      ),
      Exercise(
        name: 'Russian Twists',
        sets: '3', reps: '16 total', rest: '30 sec',
        instructions: [
          'Sit on the floor with knees bent and feet elevated slightly off the ground.',
          'Lean back to about 45 degrees — your torso and thighs form a V shape.',
          'Clasp your hands together in front of your chest.',
          'Rotate your torso to the right, bringing your hands beside your hip.',
          'Rotate to the left in the same controlled manner — that is one full rep.',
        ],
      ),
      Exercise(
        name: 'Ab Wheel Rollout',
        sets: '3', reps: '10', rest: '60 sec',
        instructions: [
          'Kneel on the floor and hold the ab wheel with both hands directly under your shoulders.',
          'Brace your core tight — imagine bracing for a punch.',
          'Slowly roll the wheel forward, extending your body toward the floor.',
          'Go as far as you can without letting your hips sag or lower back arch.',
          'Use your abs to pull the wheel back to the starting position.',
        ],
      ),
      Exercise(
        name: 'Reverse Crunch',
        sets: '3', reps: '15', rest: '30 sec',
        instructions: [
          'Lie on your back with arms flat by your sides and knees bent at 90 degrees.',
          'Keep your lower back pressed to the floor.',
          'Use your abs to curl your pelvis upward, bringing your knees toward your chest.',
          'Lift your hips slightly off the floor at the top of the movement.',
          'Slowly lower back down — do not let momentum take over.',
        ],
      ),
      Exercise(
        name: 'Mountain Climbers',
        sets: '3', reps: '20 each leg', rest: '30 sec',
        instructions: [
          'Start in a high plank position with hands directly under your shoulders.',
          'Keep your body in a straight line and core tight.',
          'Drive your right knee quickly toward your chest.',
          'Return your right foot and immediately drive your left knee in.',
          'Alternate legs at a fast pace while keeping your hips level.',
        ],
      ),
    ],
    'Advanced': [
      Exercise(
        name: 'Dragon Flag',
        sets: '4', reps: '6', rest: '90 sec',
        instructions: [
          'Lie on a bench and grip something sturdy behind your head with both hands.',
          'Raise your legs and hips off the bench so your body is vertical.',
          'Keep your entire body rigid like a plank — do not bend at the hips.',
          'Slowly lower your body toward the bench over 3 counts, stopping just above it.',
          'Drive back up using your core to return to the vertical position.',
        ],
      ),
      Exercise(
        name: 'Toes-to-Bar',
        sets: '4', reps: '10', rest: '60 sec',
        instructions: [
          'Hang from a pull-up bar with an overhand grip, arms fully extended.',
          'Start with a slight hollow body — core braced, ribs down.',
          'Swing your legs forward and upward, keeping them straight.',
          'Touch the bar with your toes at the top of the movement.',
          'Lower your legs under control and repeat in a smooth rhythm.',
        ],
      ),
      Exercise(
        name: 'Ab Wheel Rollout',
        sets: '4', reps: '12', rest: '60 sec',
        instructions: [
          'Kneel with the ab wheel under your shoulders and core fully braced.',
          'Roll forward slowly until your nose is nearly touching the floor.',
          'Keep your hips from dropping — your body should stay rigid.',
          'Pull back using your abs, not your hip flexors.',
          'Reset fully upright between each rep.',
        ],
      ),
      Exercise(
        name: 'L-Sit Hold',
        sets: '4', reps: '15 sec', rest: '60 sec',
        instructions: [
          'Sit between two parallel bars or on the floor with palms flat.',
          'Press down firmly through your hands and straighten your arms.',
          'Lift your body off the surface and extend your legs straight out in front.',
          'Hold your legs parallel to the floor — forming an L shape.',
          'Breathe steadily and hold for the full duration.',
        ],
      ),
      Exercise(
        name: 'Plank to Pike',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Begin in a high plank position, hands under shoulders, core braced.',
          'Keep your legs straight and drive your hips explosively up toward the ceiling.',
          'Your body should form an inverted V at the top.',
          'Hold the pike briefly, squeezing your core.',
          'Lower your hips back to the plank position slowly and with control.',
        ],
      ),
      Exercise(
        name: 'V-Ups',
        sets: '4', reps: '15', rest: '45 sec',
        instructions: [
          'Lie flat on your back with arms extended overhead and legs straight.',
          'Simultaneously lift your legs and your upper body off the floor.',
          'Reach your hands toward your feet, meeting in the middle.',
          'Your body should form a V shape at the top.',
          'Lower both your legs and torso back down with control.',
        ],
      ),
      Exercise(
        name: 'Hollow Body Hold',
        sets: '3', reps: '30 sec', rest: '45 sec',
        instructions: [
          'Lie on your back and press your lower back completely flat into the floor.',
          'Extend your arms overhead and legs straight out.',
          'Lift your shoulders and legs a few inches off the floor.',
          'Hold the position — your lower back must stay flat, no arch.',
          'Breathe steadily and maintain the tension throughout.',
        ],
      ),
    ],
  };

  static const Map<String, List<Exercise>> arms = {
    'Beginner': [
      Exercise(
        name: 'Bicep Curls',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Stand tall holding a dumbbell in each hand, arms fully extended.',
          'Keep your elbows pinned close to your sides throughout.',
          'Curl the weights upward by flexing your biceps.',
          'Squeeze at the top, then slowly lower back to the start.',
          'Avoid swinging your body — only your forearms should move.',
        ],
      ),
      Exercise(
        name: 'Tricep Dips (bench)',
        sets: '3', reps: '10', rest: '45 sec',
        instructions: [
          'Sit on the edge of a bench and place your hands next to your hips.',
          'Slide your hips off the bench and support your weight on your hands.',
          'Bend your elbows and lower your body toward the floor.',
          'Stop when your upper arms are parallel to the floor.',
          'Press back up by straightening your arms, keeping your back close to the bench.',
        ],
      ),
      Exercise(
        name: 'Hammer Curls',
        sets: '3', reps: '10', rest: '45 sec',
        instructions: [
          'Stand holding a dumbbell in each hand with a neutral grip — palms facing each other.',
          'Keep your elbows tight to your sides.',
          'Curl the dumbbells up while maintaining the neutral grip throughout.',
          'Squeeze at the top, then lower slowly.',
          'Do not rotate your wrists — the neutral grip targets the brachialis.',
        ],
      ),
      Exercise(
        name: 'Overhead Tricep Extension',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Stand or sit holding a single dumbbell with both hands overhead.',
          'Your upper arms should be vertical and close to your ears.',
          'Slowly lower the dumbbell behind your head by bending your elbows.',
          'Stop when your forearms are roughly parallel to the floor.',
          'Press the dumbbell back up to the starting position by straightening your arms.',
        ],
      ),
    ],
    'Intermediate': [
      Exercise(
        name: 'Barbell Curls',
        sets: '4', reps: '10', rest: '45 sec',
        instructions: [
          'Stand with feet shoulder-width apart holding a barbell with an underhand grip.',
          'Keep your elbows close to your body and your upper arms still.',
          'Curl the bar upward until your biceps are fully contracted.',
          'Squeeze at the top for a moment.',
          'Lower the bar slowly over 2–3 counts to maximise tension.',
        ],
      ),
      Exercise(
        name: 'Skull Crushers',
        sets: '4', reps: '10', rest: '45 sec',
        instructions: [
          'Lie on a bench holding an EZ bar or dumbbells with arms extended above your chest.',
          'Keep your upper arms perpendicular to the floor — they should not move.',
          'Slowly bend your elbows, lowering the weight toward your forehead.',
          'Stop just before the weight reaches your head.',
          'Extend your arms back to the starting position using your triceps.',
        ],
      ),
      Exercise(
        name: 'Concentration Curls',
        sets: '3', reps: '12', rest: '30 sec',
        instructions: [
          'Sit on a bench with your legs apart, leaning forward slightly.',
          'Rest the back of your right upper arm against your inner right thigh.',
          'Hold a dumbbell and let your arm fully extend.',
          'Curl the weight upward, squeezing your bicep hard at the top.',
          'Lower slowly and complete all reps before switching arms.',
        ],
      ),
      Exercise(
        name: 'Cable Tricep Pushdown',
        sets: '3', reps: '15', rest: '30 sec',
        instructions: [
          'Stand at a cable machine with a rope or bar attachment set at chest height.',
          'Grip the attachment and tuck your elbows tightly to your sides.',
          'Push the weight straight down until your arms are fully extended.',
          'Squeeze your triceps hard at the bottom.',
          'Slowly return to the starting position — upper arms stay still throughout.',
        ],
      ),
      Exercise(
        name: 'Incline Dumbbell Curl',
        sets: '3', reps: '10', rest: '45 sec',
        instructions: [
          'Set an incline bench to about 60 degrees and sit back against it.',
          'Let your arms hang straight down, dumbbells in hand — this fully stretches the bicep.',
          'Curl both dumbbells upward without moving your upper arms forward.',
          'Squeeze at the top, then lower all the way back down for a full stretch.',
          'The incline position removes the ability to cheat — control every rep.',
        ],
      ),
    ],
    'Advanced': [
      Exercise(
        name: 'Barbell 21s',
        sets: '4', reps: '21', rest: '60 sec',
        instructions: [
          'Hold a barbell with an underhand grip, arms fully extended.',
          'First 7 reps: curl only from the bottom to the halfway point — upper arms parallel.',
          'Next 7 reps: curl only from the halfway point up to the top — full contraction.',
          'Final 7 reps: perform full range-of-motion curls from bottom to top.',
          'No rest between the three phases — complete all 21 reps continuously.',
        ],
      ),
      Exercise(
        name: 'Rope Tricep Pushdown',
        sets: '4', reps: '15', rest: '45 sec',
        instructions: [
          'Attach a rope to a high cable pulley and stand facing the machine.',
          'Grip the rope with both hands and tuck your elbows to your sides.',
          'Push the rope down until your arms are fully extended.',
          'At the bottom, flare the rope ends outward to maximise contraction.',
          'Slowly return to the starting position — keep upper arms fixed.',
        ],
      ),
      Exercise(
        name: 'Close-Grip Bench Press',
        sets: '4', reps: '8', rest: '90 sec',
        instructions: [
          'Lie on a bench and grip the barbell with hands about shoulder-width apart.',
          'Unrack the bar and hold it directly above your chest.',
          'Lower the bar slowly to your lower chest, keeping your elbows tucked close to your sides.',
          'Press the bar back up by driving through your triceps.',
          'Do not let your elbows flare out — that shifts the work to the chest.',
        ],
      ),
      Exercise(
        name: 'Preacher Curls',
        sets: '4', reps: '10', rest: '60 sec',
        instructions: [
          'Sit at a preacher bench and rest the back of your upper arms on the angled pad.',
          'Grip an EZ bar or dumbbell with an underhand grip, arms fully extended.',
          'Curl the weight upward until your biceps are fully contracted.',
          'Squeeze at the top, then lower all the way down for a complete stretch.',
          'The pad prevents cheating — every rep is pure bicep work.',
        ],
      ),
      Exercise(
        name: 'Diamond Push-Ups',
        sets: '3', reps: '15', rest: '45 sec',
        instructions: [
          'Start in a push-up position and bring your hands together under your chest.',
          'Form a diamond shape with your thumbs and index fingers.',
          'Keep your elbows tucked close to your body as you lower down.',
          'Lower until your chest nearly touches your hands.',
          'Push back up explosively, squeezing your triceps at the top.',
        ],
      ),
      Exercise(
        name: 'Behind-the-Neck Tricep Ext',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Stand or sit holding a dumbbell or EZ bar overhead with both hands.',
          'Warm up your elbows and shoulders thoroughly before starting.',
          'Lower the weight behind your head by bending your elbows.',
          'Keep your upper arms vertical and close to your ears.',
          'Extend your arms back up to the start position using your triceps.',
        ],
      ),
    ],
  };

  static const Map<String, List<Exercise>> chest = {
    'Beginner': [
      Exercise(
        name: 'Push-Ups',
        sets: '3', reps: '10', rest: '45 sec',
        instructions: [
          'Place your hands slightly wider than shoulder-width on the floor.',
          'Keep your body in a straight line from head to heels — core tight.',
          'Lower your chest all the way to the floor, elbows at roughly 45 degrees.',
          'Press back up to the starting position.',
          'Do not let your hips sag or rise — maintain a rigid plank throughout.',
        ],
      ),
      Exercise(
        name: 'Dumbbell Chest Press',
        sets: '3', reps: '12', rest: '60 sec',
        instructions: [
          'Lie on a bench or flat surface holding a dumbbell in each hand at chest level.',
          'Plant your feet flat on the floor and create a slight arch in your lower back.',
          'Press the dumbbells upward until your arms are fully extended.',
          'Lower the weights slowly back to chest level, elbows at about 45 degrees.',
          'Keep your shoulder blades retracted and pinched together throughout.',
        ],
      ),
      Exercise(
        name: 'Dumbbell Fly',
        sets: '3', reps: '10', rest: '45 sec',
        instructions: [
          'Lie on a bench holding dumbbells above your chest, palms facing each other.',
          'Maintain a slight bend in your elbows — keep this bend throughout.',
          'Lower your arms out to the sides in a wide arc until you feel a stretch across your chest.',
          'Squeeze your chest and bring the dumbbells back together at the top.',
          'Think of hugging a large tree — the motion is an arc, not a press.',
        ],
      ),
      Exercise(
        name: 'Incline Push-Ups',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Place your hands on an elevated surface such as a bench or step.',
          'Walk your feet back so your body forms a straight line.',
          'Lower your chest toward the surface, keeping elbows at 45 degrees.',
          'Push back up to the starting position.',
          'The higher the surface, the easier — lower it as you get stronger.',
        ],
      ),
    ],
    'Intermediate': [
      Exercise(
        name: 'Barbell Bench Press',
        sets: '4', reps: '8', rest: '90 sec',
        instructions: [
          'Lie on the bench with eyes directly under the bar.',
          'Grip the bar slightly wider than shoulder-width, retract your shoulder blades.',
          'Unrack the bar and lower it to your lower chest in a controlled manner.',
          'Touch your chest lightly, then drive the bar back up explosively.',
          'Keep your feet flat and your back arched naturally throughout.',
        ],
      ),
      Exercise(
        name: 'Incline Dumbbell Press',
        sets: '3', reps: '10', rest: '60 sec',
        instructions: [
          'Set the bench to a 30 to 45 degree incline.',
          'Sit back with a dumbbell in each hand at shoulder level.',
          'Press the dumbbells upward and slightly inward until arms are extended.',
          'Lower slowly back to shoulder level, feeling the stretch in your upper chest.',
          'Keep your core tight and avoid arching excessively.',
        ],
      ),
      Exercise(
        name: 'Cable Fly',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Set both cable pulleys to chest height and stand in the middle of the machine.',
          'Hold a handle in each hand with a slight bend in your elbows.',
          'Step forward slightly and lean forward a touch for balance.',
          'Bring both handles together in front of your chest in a wide arc.',
          'Squeeze your chest hard at the centre, then slowly return to the start.',
        ],
      ),
      Exercise(
        name: 'Dips (chest lean)',
        sets: '3', reps: '10', rest: '60 sec',
        instructions: [
          'Grip the dip bars and push yourself up to the starting position.',
          'Lean your torso forward at about 30 degrees to target the chest.',
          'Lower yourself by bending your elbows until your upper arms are parallel to the floor.',
          'Keep your elbows slightly flared out rather than tucked in.',
          'Push back up through your chest to the starting position.',
        ],
      ),
      Exercise(
        name: 'Decline Push-Ups',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Place your feet on a bench or elevated surface and hands on the floor.',
          'Your body should form a straight declining line.',
          'Lower your chest toward the floor, keeping elbows at 45 degrees.',
          'Push back up to the starting position.',
          'The higher your feet, the more emphasis on the lower chest.',
        ],
      ),
    ],
    'Advanced': [
      Exercise(
        name: 'Weighted Dips',
        sets: '4', reps: '8', rest: '90 sec',
        instructions: [
          'Attach a weight plate to a dip belt around your waist.',
          'Grip the bars and get into the starting position.',
          'Lean forward slightly to target the chest over the triceps.',
          'Lower yourself until your upper arms are parallel to the floor.',
          'Drive back up powerfully through your chest.',
        ],
      ),
      Exercise(
        name: 'Paused Bench Press',
        sets: '4', reps: '6', rest: '120 sec',
        instructions: [
          'Set up on the bench the same way as a regular bench press.',
          'Lower the bar to your chest in a controlled manner.',
          'Pause for a full 2 seconds with the bar on your chest — do not bounce.',
          'Drive the bar back up explosively after the pause.',
          'The pause eliminates momentum and forces pure muscle strength.',
        ],
      ),
      Exercise(
        name: 'Incline Cable Fly',
        sets: '4', reps: '12', rest: '60 sec',
        instructions: [
          'Set an incline bench between two low cable pulleys.',
          'Lie back on the bench and hold a handle in each hand.',
          'Start with arms wide and slightly below chest level to create a stretch.',
          'Bring the handles together above your upper chest in an arc.',
          'Focus on the stretch at the bottom — do not rush through it.',
        ],
      ),
      Exercise(
        name: 'Landmine Press',
        sets: '3', reps: '10', rest: '60 sec',
        instructions: [
          'Place one end of a barbell in a landmine attachment or a corner.',
          'Kneel or stand and hold the other end of the bar at shoulder height.',
          'Press the bar upward and forward in an arc until your arm is extended.',
          'Lower it back to shoulder height with control.',
          'This is easier on the shoulder joint than a standard overhead press.',
        ],
      ),
      Exercise(
        name: 'Plyometric Push-Ups',
        sets: '3', reps: '8', rest: '60 sec',
        instructions: [
          'Start in a standard push-up position.',
          'Lower your chest to the floor as usual.',
          'Press up explosively with enough force to leave the floor.',
          'Land softly with slightly bent elbows to absorb the impact.',
          'Immediately go into the next rep.',
        ],
      ),
    ],
  };

  static const Map<String, List<Exercise>> legs = {
    'Beginner': [
      Exercise(
        name: 'Bodyweight Squats',
        sets: '3', reps: '15', rest: '45 sec',
        instructions: [
          'Stand with feet shoulder-width apart and toes pointed slightly outward.',
          'Keep your chest up and your core braced.',
          'Push your hips back and bend your knees to lower yourself.',
          'Go until your thighs are at least parallel to the floor.',
          'Drive through your heels to return to standing.',
        ],
      ),
      Exercise(
        name: 'Reverse Lunges',
        sets: '3', reps: '10 each', rest: '45 sec',
        instructions: [
          'Stand tall with feet together and hands on your hips.',
          'Step one foot back and lower your back knee toward the floor.',
          'Your front thigh should be parallel to the floor.',
          'Push through your front heel to return to the starting position.',
          'Alternate legs each rep.',
        ],
      ),
      Exercise(
        name: 'Glute Bridges',
        sets: '3', reps: '15', rest: '45 sec',
        instructions: [
          'Lie on your back with knees bent and feet flat on the floor.',
          'Place your arms flat by your sides.',
          'Drive through your heels to lift your hips toward the ceiling.',
          'Squeeze your glutes hard at the top — your body forms a straight line.',
          'Lower your hips slowly back to the floor.',
        ],
      ),
      Exercise(
        name: 'Wall Sit',
        sets: '3', reps: '30 sec', rest: '45 sec',
        instructions: [
          'Stand with your back flat against a wall.',
          'Slide down until your knees are at a 90 degree angle.',
          'Your thighs should be parallel to the floor.',
          'Keep your back flat against the wall and feet flat on the floor.',
          'Hold the position, breathing steadily.',
        ],
      ),
    ],
    'Intermediate': [
      Exercise(
        name: 'Barbell Back Squat',
        sets: '4', reps: '8', rest: '90 sec',
        instructions: [
          'Place a barbell across your upper traps and step back from the rack.',
          'Stand with feet shoulder-width apart, toes slightly out.',
          'Brace your core, take a deep breath, and squat down.',
          'Break parallel — hips crease below the knee.',
          'Drive through your whole foot to return to standing.',
        ],
      ),
      Exercise(
        name: 'Romanian Deadlift',
        sets: '3', reps: '10', rest: '60 sec',
        instructions: [
          'Stand holding a barbell or dumbbells in front of your thighs.',
          'Keep a slight bend in your knees throughout the movement.',
          'Hinge at your hips and lower the weight along your legs.',
          'Feel a stretch in your hamstrings — go until you feel it fully.',
          'Drive your hips forward to return to standing.',
        ],
      ),
      Exercise(
        name: 'Walking Lunges',
        sets: '3', reps: '12 each', rest: '60 sec',
        instructions: [
          'Stand tall with dumbbells at your sides or hands on hips.',
          'Step forward with your right foot and lower your back knee toward the floor.',
          'Push off your right foot and bring your left foot forward into the next lunge.',
          'Keep your torso upright and your front knee tracking over your toes.',
          'Continue alternating legs as you walk forward.',
        ],
      ),
      Exercise(
        name: 'Leg Press',
        sets: '3', reps: '12', rest: '60 sec',
        instructions: [
          'Sit in the leg press machine with your feet shoulder-width apart on the platform.',
          'Release the safety and lower the platform by bending your knees.',
          'Stop just before your lower back lifts off the seat.',
          'Drive the platform back up through your heels.',
          'Do not lock your knees completely at the top.',
        ],
      ),
      Exercise(
        name: 'Leg Curl Machine',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Lie face-down on the leg curl machine and position the pad just above your heels.',
          'Grip the handles for stability.',
          'Curl your legs upward by contracting your hamstrings.',
          'Bring the pad as close to your glutes as possible.',
          'Lower the weight slowly over 2–3 counts.',
        ],
      ),
    ],
    'Advanced': [
      Exercise(
        name: 'Barbell Front Squat',
        sets: '4', reps: '6', rest: '120 sec',
        instructions: [
          'Rest the barbell across your front deltoids with elbows high and parallel to the floor.',
          'Stand with feet shoulder-width apart.',
          'Keep your torso upright as you squat — the front rack demands this.',
          'Squat to full depth, hips below parallel.',
          'Drive up through your whole foot, keeping elbows high throughout.',
        ],
      ),
      Exercise(
        name: 'Bulgarian Split Squat',
        sets: '4', reps: '10 each', rest: '90 sec',
        instructions: [
          'Stand in front of a bench and place your rear foot on it, laces down.',
          'Your front foot should be far enough forward so your shin stays vertical.',
          'Lower your back knee toward the floor by bending your front leg.',
          'Stop when your front thigh is parallel to the floor.',
          'Drive through your front heel to return to the top.',
        ],
      ),
      Exercise(
        name: 'Hack Squat',
        sets: '4', reps: '10', rest: '90 sec',
        instructions: [
          'Step into the hack squat machine and place your shoulders under the pads.',
          'Position your feet shoulder-width apart on the platform.',
          'Release the safety and lower yourself to full depth.',
          'Drive back up through your heels without locking your knees.',
          'Keep your back flat against the pad throughout.',
        ],
      ),
      Exercise(
        name: 'Nordic Hamstring Curl',
        sets: '3', reps: '6', rest: '90 sec',
        instructions: [
          'Kneel on a mat and have a partner hold your ankles firmly down.',
          'Keep your body straight from knees to head.',
          'Slowly lower your torso toward the floor by allowing your knees to extend.',
          'Use your hands to catch yourself at the bottom.',
          'Drive back up using your hamstrings as much as possible.',
        ],
      ),
      Exercise(
        name: 'Sissy Squat',
        sets: '3', reps: '12', rest: '60 sec',
        instructions: [
          'Stand with feet together and hold something for balance if needed.',
          'Rise onto your toes and lean your torso back.',
          'Bend your knees forward as you lower your body.',
          'Your knees travel far past your toes — this is intentional.',
          'Drive back up by extending your knees and returning upright.',
        ],
      ),
      Exercise(
        name: 'Jump Squats',
        sets: '3', reps: '10', rest: '60 sec',
        instructions: [
          'Stand with feet shoulder-width apart.',
          'Perform a squat, lowering until thighs are parallel.',
          'Explode upward, driving through your feet to leave the floor.',
          'Land softly by absorbing into a squat — do not land stiff-legged.',
          'Go immediately into the next rep with control.',
        ],
      ),
    ],
  };

  static const Map<String, List<Exercise>> shoulders = {
    'Beginner': [
      Exercise(
        name: 'Dumbbell Shoulder Press',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Sit or stand holding a dumbbell in each hand at shoulder level.',
          'Keep your core tight and avoid arching your lower back.',
          'Press the dumbbells straight up until your arms are fully extended.',
          'Lower the weights slowly back to shoulder level.',
          'Keep your elbows at roughly 45 to 75 degrees — not fully flared.',
        ],
      ),
      Exercise(
        name: 'Lateral Raises',
        sets: '3', reps: '12', rest: '45 sec',
        instructions: [
          'Stand holding a dumbbell in each hand by your sides.',
          'Keep a slight bend in your elbows throughout.',
          'Raise both arms out to the sides until they are parallel to the floor.',
          'Lead with your elbows — think of pouring water from a jug.',
          'Lower the weights slowly back down.',
        ],
      ),
      Exercise(
        name: 'Front Raises',
        sets: '3', reps: '10', rest: '45 sec',
        instructions: [
          'Stand with a dumbbell in each hand in front of your thighs, palms facing down.',
          'Keep your arms straight with just a slight bend in the elbow.',
          'Raise one or both arms forward until they are parallel to the floor.',
          'Hold briefly at the top.',
          'Lower the weight slowly and with control.',
        ],
      ),
      Exercise(
        name: 'Band Pull-Aparts',
        sets: '3', reps: '15', rest: '30 sec',
        instructions: [
          'Hold a resistance band with both hands in front of you at chest height.',
          'Keep your arms straight and palms facing down.',
          'Pull the band apart by squeezing your shoulder blades together.',
          'Bring the band to your chest, arms fully extended to the sides.',
          'Return slowly to the starting position.',
        ],
      ),
    ],
    'Intermediate': [
      Exercise(
        name: 'Barbell Overhead Press',
        sets: '4', reps: '8', rest: '90 sec',
        instructions: [
          'Stand holding a barbell at shoulder height with an overhand grip.',
          'Brace your core and glutes.',
          'Press the bar directly upward in a straight path.',
          'At the top, your ears should be in front of your arms — push your head through.',
          'Lower the bar back to shoulder height with control.',
        ],
      ),
      Exercise(
        name: 'Arnold Press',
        sets: '3', reps: '10', rest: '60 sec',
        instructions: [
          'Sit holding dumbbells at chest height with palms facing you.',
          'As you press upward, rotate your palms away from you.',
          'Finish with palms facing forward at the top, arms fully extended.',
          'Reverse the rotation as you lower back to the starting position.',
          'The rotation hits all three heads of the deltoid.',
        ],
      ),
      Exercise(
        name: 'Cable Lateral Raise',
        sets: '3', reps: '15', rest: '30 sec',
        instructions: [
          'Stand beside a low cable pulley and grip the handle with the hand furthest from the machine.',
          'Keep a slight bend in your elbow.',
          'Raise your arm out to the side until it is parallel to the floor.',
          'Hold briefly at the top, then lower slowly.',
          'The cable keeps constant tension throughout, unlike a dumbbell.',
        ],
      ),
      Exercise(
        name: 'Face Pulls',
        sets: '3', reps: '15', rest: '30 sec',
        instructions: [
          'Set a cable pulley to around face height with a rope attachment.',
          'Grip the rope with both hands, thumbs pointing back.',
          'Pull the rope toward your face, spreading the ends apart as you pull.',
          'Your hands should finish beside your ears at the end of the rep.',
          'Squeeze your rear delts and external rotators at the peak.',
        ],
      ),
      Exercise(
        name: 'Upright Row',
        sets: '3', reps: '10', rest: '45 sec',
        instructions: [
          'Stand holding a barbell or dumbbells with an overhand grip in front of your thighs.',
          'Use a wider grip to reduce impingement risk.',
          'Pull the weight straight up along your body toward your chin.',
          'Lead with your elbows — they should rise higher than your hands.',
          'Lower the weight slowly back to the start.',
        ],
      ),
    ],
    'Advanced': [
      Exercise(
        name: 'Push Press',
        sets: '4', reps: '6', rest: '120 sec',
        instructions: [
          'Hold a barbell at shoulder height in a rack position.',
          'Dip slightly by bending your knees.',
          'Explosively drive through your legs to initiate the press.',
          'Use the momentum to drive the bar overhead to full extension.',
          'Lower the bar back to your shoulders with control.',
        ],
      ),
      Exercise(
        name: 'Seated DB Press (heavy)',
        sets: '4', reps: '8', rest: '90 sec',
        instructions: [
          'Sit upright on a bench with back support, holding heavy dumbbells at shoulder level.',
          'Keep your core tight and back flat against the pad.',
          'Press both dumbbells straight up until arms are fully extended.',
          'Pause briefly at the top.',
          'Lower slowly back to shoulder level for a full stretch.',
        ],
      ),
      Exercise(
        name: 'Lateral Raise Drop Set',
        sets: '3', reps: '12/10/8', rest: '60 sec',
        instructions: [
          'Start with your heaviest dumbbell and perform 12 lateral raises.',
          'Immediately drop to a lighter weight with no rest.',
          'Perform 10 reps with the medium weight.',
          'Drop to an even lighter weight immediately.',
          'Finish with 8 reps — the burn should be intense.',
        ],
      ),
      Exercise(
        name: 'Behind-the-Neck Press',
        sets: '3', reps: '10', rest: '60 sec',
        instructions: [
          'Only attempt this with adequate shoulder mobility — warm up thoroughly.',
          'Sit with a barbell resting across your upper traps.',
          'Press the bar straight up to full extension.',
          'Lower the bar behind your neck to about ear level.',
          'Press back up — keep the movement controlled and within a pain-free range.',
        ],
      ),
      Exercise(
        name: 'Handstand Hold (wall)',
        sets: '3', reps: '20 sec', rest: '60 sec',
        instructions: [
          'Face the wall and place your hands about 6 inches from the base.',
          'Kick up into a handstand, resting your heels against the wall.',
          'Keep your arms straight and core tight.',
          'Press through your shoulders — do not collapse your elbows.',
          'Hold for the full duration, then lower down with control.',
        ],
      ),
      Exercise(
        name: 'Cable Rear Delt Fly',
        sets: '3', reps: '15', rest: '45 sec',
        instructions: [
          'Set two cables at the highest position and cross the handles.',
          'Hold the left handle in your right hand and vice versa.',
          'Stand in the middle with a slight forward lean.',
          'Pull both handles outward and back in a wide arc.',
          'Squeeze your rear delts and hold for a moment at the peak.',
        ],
      ),
    ],
  };

  static List<Exercise> getExercises(String focus, String level) {
    switch (focus) {
      case 'Abs':       return abs[level] ?? [];
      case 'Arms':      return arms[level] ?? [];
      case 'Chest':     return chest[level] ?? [];
      case 'Legs':      return legs[level] ?? [];
      case 'Shoulders': return shoulders[level] ?? [];
      default:          return [];
    }
  }
}

// ─── Constants ─────────────────────────────────────────────────────────────────

const List<String> kDayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];
const List<String> kDayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const List<String> kFocusOptions = [
  'Abs', 'Arms', 'Chest', 'Legs', 'Shoulders'
];

const List<String> kLevels = ['Beginner', 'Intermediate', 'Advanced'];

const Map<String, Color> kFocusColors = {
  'Abs':       Color(0xFFD85A30),
  'Arms':      Color(0xFF378ADD),
  'Chest':     Color(0xFF2E7D32),
  'Legs':      Color(0xFF6A1B9A),
  'Shoulders': Color(0xFFE65100),
};

const Map<String, IconData> kFocusIcons = {
  'Abs':       Icons.self_improvement,
  'Arms':      Icons.fitness_center,
  'Chest':     Icons.accessibility_new,
  'Legs':      Icons.directions_run,
  'Shoulders': Icons.sports_gymnastics,
};

Color focusColor(String focus) => kFocusColors[focus] ?? Colors.grey;
IconData focusIcon(String focus) => kFocusIcons[focus] ?? Icons.fitness_center;

Color levelColor(String level) {
  switch (level) {
    case 'Beginner':     return const Color(0xFF2E7D32);
    case 'Intermediate': return const Color(0xFF378ADD);
    case 'Advanced':     return const Color(0xFFD85A30);
    default:             return Colors.grey;
  }
}

// ─── kWorkoutDays — shared with dashboard ─────────────────────────────────────

const List<Map<String, dynamic>> kWorkoutDays = [
  {'day': 'Mon', 'focus': 'Abs',       'icon': Icons.self_improvement,  'color': Color(0xFFD85A30)},
  {'day': 'Tue', 'focus': 'Arms',      'icon': Icons.fitness_center,    'color': Color(0xFF378ADD)},
  {'day': 'Wed', 'focus': 'Chest',     'icon': Icons.accessibility_new, 'color': Color(0xFF2E7D32)},
  {'day': 'Thu', 'focus': 'Legs',      'icon': Icons.directions_run,    'color': Color(0xFF6A1B9A)},
  {'day': 'Fri', 'focus': 'Shoulders', 'icon': Icons.sports_gymnastics, 'color': Color(0xFFE65100)},
];

// ─── Main screen ───────────────────────────────────────────────────────────────

class FitnessPlanScreen extends StatefulWidget {
  const FitnessPlanScreen({super.key});

  @override
  State<FitnessPlanScreen> createState() => _FitnessPlanScreenState();
}

class _FitnessPlanScreenState extends State<FitnessPlanScreen>
    with SingleTickerProviderStateMixin {
  late int _selectedDayIndex;
  bool _editMode = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    final weekday = DateTime.now().weekday;
    _selectedDayIndex = weekday - 1;

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _selectDay(int index) {
    setState(() => _selectedDayIndex = index);
    _animController.forward(from: 0);
  }

  // ── Add workout bottom sheet ───────────────────────────────────────────────

  void _showAddWorkoutSheet(int dayIndex) {
    String? selectedFocus;
    String selectedLevel = AppData.fitnessLevel.value ?? 'Beginner';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add workout — ${kDayNames[dayIndex]}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Pick a muscle group and difficulty.',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),

                const Text('Muscle group',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kFocusOptions.map((focus) {
                    final isSelected = selectedFocus == focus;
                    final c = focusColor(focus);
                    return GestureDetector(
                      onTap: () =>
                          setSheetState(() => selectedFocus = focus),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? c.withValues(alpha: 0.12)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? c : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(focusIcon(focus),
                                color: isSelected ? c : Colors.grey,
                                size: 16),
                            const SizedBox(width: 6),
                            Text(focus,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? c
                                        : Colors.black87)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                const Text('Difficulty',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row(
                  children: kLevels.map((lvl) {
                    final isSelected = selectedLevel == lvl;
                    final c = levelColor(lvl);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setSheetState(() => selectedLevel = lvl),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: EdgeInsets.only(
                              right: lvl != kLevels.last ? 8 : 0),
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? c.withValues(alpha: 0.1)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? c : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(lvl,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? c
                                          : Colors.black87)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedFocus == null
                        ? null
                        : () {
                      final block = WorkoutBlock(
                        focus: selectedFocus!,
                        level: selectedLevel,
                        id: '${dayIndex}_${selectedFocus}_${DateTime.now().millisecondsSinceEpoch}',
                      );
                      AppData.addWorkoutBlock(dayIndex, block);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378ADD),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add to plan',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Change difficulty for one block ──────────────────────────────────────

  void _showChangeDifficultySheet(int dayIndex, WorkoutBlock block) {
    String selectedLevel = block.level;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Change difficulty — ${block.focus}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                    'Only this workout block will be affected.',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),
                ...kLevels.map((lvl) {
                  final isSelected = selectedLevel == lvl;
                  final c = levelColor(lvl);
                  return GestureDetector(
                    onTap: () =>
                        setSheetState(() => selectedLevel = lvl),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? c.withValues(alpha: 0.08)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? c : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            lvl == 'Beginner'
                                ? Icons.star_outline
                                : lvl == 'Intermediate'
                                ? Icons.star_half
                                : Icons.star,
                            color: c,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(lvl,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? c
                                      : Colors.black87)),
                          const Spacer(),
                          if (isSelected)
                            Icon(Icons.check_circle,
                                color: c, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AppData.updateWorkoutBlock(
                          dayIndex, block.copyWith(level: selectedLevel));
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF378ADD),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirm',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── Day-level picker — only affects the selected day ──────────────────────

  void _showDayLevelSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LevelPickerSheet(
        current: AppData.fitnessLevel.value,
        title: 'Change level — ${kDayNames[_selectedDayIndex]}',
        subtitle: 'Updates all workouts on ${kDayNames[_selectedDayIndex]} only.',
        onPicked: (level) {
          Navigator.pop(context);
          AppData.applyLevelToDay(_selectedDayIndex, level);
          setState(() {});
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<WeekSchedule>(
      valueListenable: AppData.weekSchedule,
      builder: (context, schedule, _) {
        final dayBlocks = schedule[_selectedDayIndex] ?? [];
        final isRestDay = dayBlocks.isEmpty;
        final isWeekend =
            _selectedDayIndex == 5 || _selectedDayIndex == 6;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Fitness Plan',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28),
            ),
            actions: [
              // Edit toggle
              TextButton.icon(
                onPressed: () =>
                    setState(() => _editMode = !_editMode),
                icon: Icon(
                  _editMode ? Icons.check : Icons.edit,
                  color: const Color(0xFF378ADD),
                  size: 18,
                ),
                label: Text(
                  _editMode ? 'Done' : 'Edit',
                  style: const TextStyle(color: Color(0xFF378ADD)),
                ),
              ),
              // Day-level picker (only changes the selected day)
              TextButton.icon(
                onPressed: _showDayLevelSheet,
                icon: const Icon(Icons.tune,
                    color: Colors.grey, size: 18),
                label: Text(
                  AppData.fitnessLevel.value ?? 'Level',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildDayStrip(schedule),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildDayContent(
                      dayIndex: _selectedDayIndex,
                      blocks: dayBlocks,
                      isRestDay: isRestDay,
                      isWeekend: isWeekend,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Day tab strip ──────────────────────────────────────────────────────────

  Widget _buildDayStrip(WeekSchedule schedule) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 7,
        itemBuilder: (context, index) {
          final isActive = _selectedDayIndex == index;
          final blocks = schedule[index] ?? [];
          final isWeekend = index == 5 || index == 6;
          final hasWorkout = blocks.isNotEmpty;

          final accentColor = hasWorkout
              ? focusColor(blocks.first.focus)
              : Colors.grey.shade300;

          return GestureDetector(
            onTap: () => _selectDay(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? accentColor : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    kDayShort[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isActive ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.7)
                          : hasWorkout
                          ? accentColor
                          : isWeekend
                          ? Colors.grey.shade300
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Day content ────────────────────────────────────────────────────────────

  Widget _buildDayContent({
    required int dayIndex,
    required List<WorkoutBlock> blocks,
    required bool isRestDay,
    required bool isWeekend,
  }) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kDayNames[dayIndex],
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isRestDay
                          ? (isWeekend
                          ? 'Rest day'
                          : 'No workouts — tap + to add one')
                          : '${blocks.length} workout${blocks.length > 1 ? 's' : ''} planned',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showAddWorkoutSheet(dayIndex),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF378ADD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),

        if (isRestDay)
          _buildRestCard(isWeekend: isWeekend)
        else
          ...blocks.map((block) => _buildWorkoutBlock(
            dayIndex: dayIndex,
            block: block,
          )),

        const SizedBox(height: 24),
      ],
    );
  }

  // ── Rest card ──────────────────────────────────────────────────────────────

  Widget _buildRestCard({required bool isWeekend}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            isWeekend ? Icons.weekend : Icons.add_circle_outline,
            color: Colors.grey.shade400,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            isWeekend ? 'Rest & Recover' : 'No workout added',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            isWeekend
                ? 'Weekends are for recovery. Tap + if you want to train anyway.'
                : 'Tap the + button above to add a workout.',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Workout block card ─────────────────────────────────────────────────────

  Widget _buildWorkoutBlock({
    required int dayIndex,
    required WorkoutBlock block,
  }) {
    final color = focusColor(block.focus);
    final exercises = WorkoutLibrary.getExercises(block.focus, block.level);
    final lvlColor = levelColor(block.level);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(18),
        border: _editMode
            ? Border.all(
            color: const Color(0xFFD85A30).withValues(alpha: 0.4),
            width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(focusIcon(block.focus),
                      color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(block.focus,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _editMode
                                ? () => _showChangeDifficultySheet(
                                dayIndex, block)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: lvlColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: _editMode
                                    ? Border.all(
                                    color: lvlColor
                                        .withValues(alpha: 0.4),
                                    width: 1)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(block.level,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: lvlColor,
                                          fontWeight: FontWeight.w600)),
                                  if (_editMode) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.edit,
                                        size: 10, color: lvlColor),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('${exercises.length} exercises',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_editMode)
                  GestureDetector(
                    onTap: () => AppData.removeWorkoutBlock(
                        dayIndex, block.id),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD85A30)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: Color(0xFFD85A30), size: 20),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: Divider(
                color: color.withValues(alpha: 0.2), height: 1),
          ),

          if (!_editMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: exercises
                    .map((ex) => _ExerciseRow(
                  exercise: ex,
                  index: exercises.indexOf(ex),
                  accentColor: color,
                ))
                    .toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.grey.shade400, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tap the level badge to change difficulty · tap 🗑 to remove',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Exercise row ──────────────────────────────────────────────────────────────

class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final Color accentColor;

  const _ExerciseRow({
    required this.exercise,
    required this.index,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:
      Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        dense: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: accentColor.withValues(alpha: 0.12),
          child: Text(
            '${index + 1}',
            style: TextStyle(
                fontSize: 11,
                color: accentColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(exercise.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 5,
            children: [
              _chip('${exercise.sets}×${exercise.reps}', accentColor),
              _chip('Rest ${exercise.rest}', Colors.grey),
            ],
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: exercise.instructions
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(
                            right: 8, top: 1),
                        decoration: BoxDecoration(
                          color: accentColor
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Reusable level picker sheet ───────────────────────────────────────────────

class _LevelPickerSheet extends StatelessWidget {
  final String? current;
  final String title;
  final String subtitle;
  final ValueChanged<String> onPicked;

  const _LevelPickerSheet({
    required this.current,
    required this.title,
    required this.subtitle,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      {'label': 'Beginner',     'icon': Icons.star_outline, 'color': const Color(0xFF2E7D32)},
      {'label': 'Intermediate', 'icon': Icons.star_half,    'color': const Color(0xFF378ADD)},
      {'label': 'Advanced',     'icon': Icons.star,         'color': const Color(0xFFD85A30)},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          ...levels.map((l) {
            final isCurrent = current == l['label'];
            final c = l['color'] as Color;
            return GestureDetector(
              onTap: () => onPicked(l['label'] as String),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? c.withValues(alpha: 0.08)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent ? c : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(l['icon'] as IconData, color: c, size: 22),
                    const SizedBox(width: 12),
                    Text(l['label'] as String,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isCurrent ? c : Colors.black87)),
                    const Spacer(),
                    if (isCurrent)
                      Icon(Icons.check_circle, color: c, size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}