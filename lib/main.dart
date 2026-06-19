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

// --- 3. KÖK UYGULAMA (PREMIUM GÖRSEL TEMA VE ROTA TANIMLAMALARI) ---
class AnaUygulama extends StatelessWidget {
  const AnaUygulama({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premium Katalog',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Temiz, hafif grimsi arka plan
        primaryColor: const Color(0xFF1E1B4B), // Derin İndigo
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AnaSayfa(),
        '/detay': (context) => const UrunDetaySayfasi(),
        '/sepet': (context) => const SepetSayfasi(),
      },
    );
  }
}

// --- 4. ANA SAYFA (PREMIUM KART VE IZGARA TASARIMI) ---
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
        title: const Text(
          'Premium Store',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1B4B),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, size: 26, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/sepet').then((_) => setState(() {}));
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Urun>>(
        future: jsonDosyasiniOku(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E1B4B)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final List<Urun> urunler = snapshot.data!;

            return Column(
              children: [
                // Tamamen Lokal Asset Sistemine Geçirilmiş Yuvarlatılmış Banner
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/banner.jpg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        color: const Color(0xFFEEF2F6),
                        child: const Center(
                          child: Text('EXCLUSIVE SELECTION', style: TextStyle(color: Color(0xFF1E1B4B), fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 16, 
                      mainAxisSpacing: 16,  
                      childAspectRatio: 0.78, 
                    ),
                    itemCount: urunler.length,
                    itemBuilder: (context, index) {
                      final oAnkiUrun = urunler[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context, 
                                '/detay', 
                                arguments: oAnkiUrun, 
                              ).then((_) => setState(() {}));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Image.asset(
                                        oAnkiUrun.gorsel, 
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    oAnkiUrun.ad, 
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    oAnkiUrun.fiyat, 
                                    style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w800, fontSize: 14) 
                                  ),
                                ],
                              ),
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

// --- 5. DETAY SAYFASI (EKSİKSİZ DÜZELTİLMİŞ SÜRÜM) ---
class UrunDetaySayfasi extends StatefulWidget {
  const UrunDetaySayfasi({super.key});

  @override
  State<UrunDetaySayfasi> createState() => _UrunDetaySayfasiState();
}

class _UrunDetaySayfasiState extends State<UrunDetaySayfasi> {
  @override
  Widget build(BuildContext context) {
    final secilenUrun = ModalRoute.of(context)!.settings.arguments as Urun;
    bool sepeteEklendi = globalSepet.contains(secilenUrun);

    return Scaffold(
      appBar: AppBar(
        title: Text(secilenUrun.ad, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Image.asset(secilenUrun.gorsel, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 24),
            // HATANIN TAMAMEN ÇÖZÜLDÜĞÜ SATIR (CrossAxisAlignment.center yapıldı)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Expanded(
                  child: Text(
                    secilenUrun.ad, 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ),
                Text(
                  secilenUrun.fiyat, 
                  style: const TextStyle(fontSize: 22, color: Color(0xFF4F46E5), fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Açıklama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Text(
              secilenUrun.aciklama, 
              style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
            ),
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sepeteEklendi ? const Color(0xFF10B981) : const Color(0xFF1E1B4B),
                  shape: const StadiumBorder(), 
                  elevation: 2,
                ),
                onPressed: () {
                  setState(() {
                    if (sepeteEklendi) {
                      globalSepet.remove(secilenUrun);
                    } else {
                      globalSepet.add(secilenUrun);
                    }
                  });
                },
                child: Text(
                  sepeteEklendi ? 'Sepetten Çıkar' : 'Sepete Ekle', 
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 6. SEPET SAYFASI (GELİŞMİŞ LİSTE GÖRÜNÜMÜ) ---
class SepetSayfasi extends StatefulWidget {
  const SepetSayfasi({super.key});

  @override
  State<SepetSayfasi> createState() => _SepetSayfasiState();
}

class _SepetSayfasiState extends State<SepetSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepetim', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E1B4B),
        centerTitle: true,
        elevation: 0,
      ),
      body: globalSepet.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Sepetiniz şu an boş.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: globalSepet.length,
              itemBuilder: (context, index) {
                final urun = globalSepet[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(urun.gorsel, fit: BoxFit.contain),
                    ),
                    title: Text(urun.ad, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(urun.fiyat, style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
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