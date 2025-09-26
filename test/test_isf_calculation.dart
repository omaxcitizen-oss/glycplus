
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/screens/profile_screen.dart';

void main() {
  group('ISF Calculation', () {
    test('ISF is calculated correctly with the 1800 rule for mg/dL', () {
      const profileScreen = ProfileScreen();
      final profileScreenState = profileScreen.createState();

      // Set the glucose unit to mg/dL
      profileScreenState.setState(() {
        profileScreenState.selectedGlucoseUnit = 'mg/dL';
      });

      // Set basal and bolus doses
      profileScreenState.basalDoseController.text = '20';
      profileScreenState.bolusDoseController.text = '10';

      // Trigger the calculation
      profileScreenState.autoCalculateRatios();

      // Verify the ISF calculation
      // ISF = 1800 / (20 + 10) = 60
      expect(profileScreenState.isfController.text, '60.0');
    });
  });
}
