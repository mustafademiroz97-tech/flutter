class SensorData {
  // Genel Sistem Verileri
  final double ph;
  final double ec;
  final double waterTemp;
  final double cabinetTemp;
  final double cabinetHumidity;

  // Donanım Durumları
  final bool isPumpActive;
  final bool isFanActive;
  final bool isAcActive; // Klima eklendi

  // Raf Verileri (Listesi)
  final List<ShelfData> shelves;

  SensorData({
    required this.ph,
    required this.ec,
    required this.waterTemp,
    required this.cabinetTemp,
    required this.cabinetHumidity,
    required this.isPumpActive,
    required this.isFanActive,
    required this.isAcActive,
    required this.shelves,
  });

  // Işıkların durumunu Lux değerinden tahmin etme mantığı
  bool get areLightsOn => shelves.any((s) => s.lux > 100);

  factory SensorData.mock() {
    return SensorData(
      ph: 5.8,
      ec: 1.4,
      waterTemp: 20.5,
      cabinetTemp: 24.5,
      cabinetHumidity: 55.0,
      isPumpActive: false, // Pompa şu an duruyor
      isFanActive: true,   // Fan dönüyor
      isAcActive: false,   // Klima kapalı
      shelves: [
        ShelfData(id: 1, temp: 24.0, humidity: 60, lux: 12000, dli: 14.5),
        ShelfData(id: 2, temp: 24.2, humidity: 58, lux: 11500, dli: 13.8),
        ShelfData(id: 3, temp: 23.8, humidity: 62, lux: 12100, dli: 15.0),
        ShelfData(id: 4, temp: 23.5, humidity: 65, lux: 0, dli: 0.0), // Işık kapalı/arızalı örneği
      ],
    );
  }
}

class ShelfData {
  final int id;
  final double temp;
  final double humidity;
  final double lux;
  final double dli; // Daily Light Integral

  ShelfData({
    required this.id,
    required this.temp,
    required this.humidity,
    required this.lux,
    required this.dli,
  });
}