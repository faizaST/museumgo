class Tiket {
  final String userId;
  final String nama;
  final String tanggal;
  final int jumlah;
  final int total;
  final String buktiUrl;
  final String status;

  Tiket({
    required this.userId,
    required this.nama,
    required this.tanggal,
    required this.jumlah,
    required this.total,
    required this.buktiUrl,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'nama': nama,
    'tanggal': tanggal,
    'jumlah': jumlah,
    'total': total,
    'bukti_url': buktiUrl,
    'status': status,
  };
}
