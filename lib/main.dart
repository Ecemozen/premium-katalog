import 'package:flutter/material.dart';
import 'dart:convert'; // JSON işlemleri için

void main() {
  runApp(const AnaUygulama());
}

// --- 1. VERİ MODELİMİZ ---
class Urun {
  final String ad;
  final String fiyat;
  final String aciklama;
  final String gorsel;

  Urun(this.ad, this.fiyat, this.aciklama, this.gorsel);

  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      json['ad'],
      json['fiyat'],
      json['aciklama'],
      json['gorsel'],
    );
  }
}

// --- 2. GLOBAL SEPETİMİZ ---
List<Urun> globalSepet = [];

// --- 3. KÖK UYGULAMA (NAMED ROUTES / ROTA TANIMLAMALARI) ---
class AnaUygulama extends StatelessWidget {
  const AnaUygulama({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Katalog',
      // Uygulama açıldığında başlayacak ilk rota
      initialRoute: '/',
      // Projedeki tüm sayfaların isimlendirilmiş rotaları (Syllabus isterleri için)
      routes: {
        '/': (context) => const AnaSayfa(),
        '/detay': (context) => const UrunDetaySayfasi(),
        '/sepet': (context) => const SepetSayfasi(),
      },
    );
  }
}

// --- 4. ANA SAYFA (ASENKRON JSON OKUMA SİSTEMİ) ---
class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  Future<List<Urun>> jsonDosyasiniOku() async {
    String hamMetin = await DefaultAssetBundle.of(context).loadString('assets/urunler.json');
    List<dynamic> cozulmusJson = jsonDecode(hamMetin);
    return cozulmusJson.map((eleman) => Urun.fromJson(eleman)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Katalog'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Sepet sayfasına isimlendirilmiş rota ile geçiş
              Navigator.pushNamed(context, '/sepet').then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Urun>>(
        future: jsonDosyasiniOku(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final List<Urun> urunler = snapshot.data!;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.network(
                    'https://wantapi.com/assets/banner.png',
                    errorBuilder: (context, error, stackTrace) => const Text('Görsel Yüklenecek', style: TextStyle(color: Colors.red)),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 12, 
                      mainAxisSpacing: 12,  
                      childAspectRatio: 0.80, // GridView kart tabanlı tasarım isteri
                    ),
                    itemCount: urunler.length,
                    itemBuilder: (context, index) {
                      final oAnkiUrun = urunler[index];

                      return Card(
                        elevation: 4,
                        child: InkWell(
                          onTap: () {
                            // --- DEĞİŞİKLİK BURADA: ROUTE ARGUMENTS KULLANIMI ---
                            // Veriyi constructor yerine 'arguments' parametresiyle fırlatıyoruz
                            Navigator.pushNamed(
                              context, 
                              '/detay', 
                              arguments: oAnkiUrun, 
                            ).then((_) => setState(() {}));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    oAnkiUrun.gorsel, 
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  oAnkiUrun.ad, 
                                  textAlign: TextAlign.center, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  oAnkiUrun.fiyat, 
                                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Veri bulunamadı.'));
        },
      ),
    );
  }
}

// --- 5. DETAY SAYFASI (ROUTE ARGUMENTS YAKALAMA) ---
class UrunDetaySayfasi extends StatefulWidget {
  const UrunDetaySayfasi({super.key}); // Constructor'dan 'required' parametre kaldırıldı

  @override
  State<UrunDetaySayfasi> createState() => _UrunDetaySayfasiState();
}

class _UrunDetaySayfasiState extends State<UrunDetaySayfasi> {
  @override
  Widget build(BuildContext context) {
    // --- DEĞİŞİKLİK BURADA: ROUTE ARGUMENTS YAKALAMA ---
    // Yukarıdan pushNamed ile fırlatılan Urun nesnesini burada yakalıyoruz
    final secilenUrun = ModalRoute.of(context)!.settings.arguments as Urun;
    
    bool sepeteEklendi = globalSepet.contains(secilenUrun);

    return Scaffold(
      appBar: AppBar(
        title: Text(secilenUrun.ad),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 180,
                child: Image.asset(
                  secilenUrun.gorsel, 
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(secilenUrun.ad, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(secilenUrun.fiyat, style: const TextStyle(fontSize: 24, color: Colors.green)),
            const SizedBox(height: 20),
            const Text('Açıklama:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(secilenUrun.aciklama, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: sepeteEklendi ? Colors.green : Colors.blueGrey),
                onPressed: () {
                  setState(() {
                    if (sepeteEklendi) {
                      globalSepet.remove(secilenUrun);
                    } else {
                      globalSepet.add(secilenUrun);
                    }
                  });
                },
                child: Text(sepeteEklendi ? 'Sepetten Çıkar' : 'Sepete Ekle', style: const TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 6. SEPET SAYFASI ---
class SepetSayfasi extends StatefulWidget {
  const SepetSayfasi({super.key});

  @override
  State<SepetSayfasi> createState() => _SepetSayfasiState();
}

class _SepetSayfasiState extends State<SepetSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sepetim'), backgroundColor: Colors.blueGrey),
      body: globalSepet.isEmpty
          ? const Center(child: Text('Sepetiniz şu an boş.', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              itemCount: globalSepet.length,
              itemBuilder: (context, index) {
                final urun = globalSepet[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset(urun.gorsel, fit: BoxFit.contain),
                    ),
                    title: Text(urun.ad, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(urun.fiyat, style: const TextStyle(color: Colors.green)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          globalSepet.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}