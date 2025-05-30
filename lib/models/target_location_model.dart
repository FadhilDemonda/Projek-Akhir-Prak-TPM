class LokasiTrigger {
  Lokasi? lokasi;

  LokasiTrigger({this.lokasi});

  LokasiTrigger.fromJson(Map<String, dynamic> json) {
    lokasi =
        json['lokasi'] != null ? new Lokasi.fromJson(json['lokasi']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lokasi != null) {
      data['lokasi'] = this.lokasi!.toJson();
    }
    return data;
  }
}

class Lokasi {
  String? nama;
  List<LokasiBising>? lokasiBising;

  Lokasi({this.nama, this.lokasiBising});

  Lokasi.fromJson(Map<String, dynamic> json) {
    nama = json['nama'];
    if (json['lokasi_bising'] != null) {
      lokasiBising = <LokasiBising>[];
      json['lokasi_bising'].forEach((v) {
        lokasiBising!.add(new LokasiBising.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nama'] = this.nama;
    if (this.lokasiBising != null) {
      data['lokasi_bising'] =
          this.lokasiBising!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LokasiBising {
  String? nama;
  String? tingkatKebisinganEstimasi;
  String? keterangan;
  double? longitude;
  double? latitude;
  double? triggerRadiusMeter;

  LokasiBising({
    this.nama,
    this.tingkatKebisinganEstimasi,
    this.keterangan,
    this.longitude,
    this.latitude,
    this.triggerRadiusMeter,
  });

  LokasiBising.fromJson(Map<String, dynamic> json) {
    nama = json['nama'];
    tingkatKebisinganEstimasi = json['tingkat_kebisingan_estimasi'];
    keterangan = json['keterangan'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    triggerRadiusMeter = json['triggerRadiusMeter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nama'] = this.nama;
    data['tingkat_kebisingan_estimasi'] = this.tingkatKebisinganEstimasi;
    data['keterangan'] = this.keterangan;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['triggerRadiusMeter'] = this.triggerRadiusMeter;
    return data;
  }
}

List<LokasiTrigger> triggerListLocation = [
  LokasiTrigger(
    lokasi: Lokasi(
      nama: 'DAOP 6 Yogyakarta',
      lokasiBising: [
        LokasiBising(
          nama: 'LOSD MC',
          tingkatKebisinganEstimasi: 'Tinggi',
          keterangan:
              'Lokasi ini sering digunakan untuk parkir kereta api yang sedang tidak beroperasi.',
          longitude: 110.42275691028573,
          latitude: -7.747996485379148,
          triggerRadiusMeter: 20,
        ),
        LokasiBising(
          nama: 'Depo Kreta Yogyakarta',
          tingkatKebisinganEstimasi: 'Hijau',
          keterangan: '',
          longitude: 110.42275691028573,
          latitude: -7.747996485379148,
          triggerRadiusMeter: 20,
        ),
        LokasiBising(
          nama: 'Depo Kreta maguwo',
          tingkatKebisinganEstimasi: 'Tinggi',
          keterangan: '',
          longitude: 110.4225161,
          latitude: -7.7481928,
          triggerRadiusMeter: 15,
        ),
        LokasiBising(
          nama: 'Depo Kereta Yogyakarta',
          tingkatKebisinganEstimasi: 'Tinggi',
          keterangan: '',
          longitude: 110.36219145203746,
          latitude: -7.789217886322038,
          triggerRadiusMeter: 15,
        ),
        LokasiBising(
          nama: 'Depo Traksi Yogyakarta',
          tingkatKebisinganEstimasi: 'Tinggi',
          keterangan: '',
          longitude: 110.3607883210834,
          latitude: -7.788460708175744,
          triggerRadiusMeter: 20,
        ),
        LokasiBising(
          nama: 'Stabling Area',
          tingkatKebisinganEstimasi: 'Sedang',
          keterangan: 'Ini adalah tempat KAI',
          longitude: 110.3614188,
          latitude: -7.7883374,
          triggerRadiusMeter: 30,
        ),
      ],
    ),
  ),
];
