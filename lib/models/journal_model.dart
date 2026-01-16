class JournalModel {
  final int? id;
  final int? userId;
  final String? title;
  final String? content;
  final String? tags;
  final String? createdAt;
  
  // 1. TAMBAHKAN VARIABLE INI
  final bool? isPrivate; 

  JournalModel({
    this.id,
    this.userId,
    this.title,
    this.content,
    this.tags,
    this.createdAt,
    // 2. MASUKKAN KE CONSTRUCTOR
    this.isPrivate, 
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: int.tryParse(json['id'].toString()),
      userId: int.tryParse(json['user_id'].toString()),
      title: json['title'],
      content: json['content'],
      tags: json['tags'],
      createdAt: json['created_at'],
      
      // 3. AMBIL DARI JSON DATABASE
      // Database MySQL biasanya mengembalikan 1 (true) atau 0 (false)
      isPrivate: (json['is_private'].toString() == '1'), 
    );
  }
}