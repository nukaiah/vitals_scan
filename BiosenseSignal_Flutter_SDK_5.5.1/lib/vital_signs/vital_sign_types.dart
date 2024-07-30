abstract class VitalSignTypes {
  static const int pulseRate = 0x1;
  static const int respirationRate = 0x2;
  static const int oxygenSaturation = 0x4;
  static const int sdnn = 0x8;
  static const int stressLevel = 0x10;
  static const int rri = 0x20;
  static const int bloodPressure = 0x40;
  static const int stressIndex = 0x80;
  static const int meanRri = 0x100;
  static const int rmssd = 0x200;
  static const int sd1 = 0x400;
  static const int sd2 = 0x800;
  static const int prq = 0x1000;
  static const int pnsIndex = 0x2000;
  static const int pnsZone = 0x4000;
  static const int snsIndex = 0x8000;
  static const int snsZone = 0x10000;
  static const int wellnessIndex = 0x20000;
  static const int wellnessLevel = 0x40000;
  static const int lfhf = 0x80000;
  static const int hemoglobin = 0x100000;
  static const int hemoglobinA1C = 0x200000;
}
