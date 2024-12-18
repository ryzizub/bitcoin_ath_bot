import 'package:hive/hive.dart';

class LocalStorageService {
  LocalStorageService();

  Future<void> init() async {
    await BoxCollection.open(
      'Boxes',
      {'price'},
      path: './hive',
    );
  }

  Future<void> saveATH(int price) async {
    final box = await Hive.openBox<int>('price');
    await box.put('ath_price', price);
  }

  Future<int?> getATH() async {
    final box = await Hive.openBox<int>('price');
    return box.get('ath_price');
  }
}
