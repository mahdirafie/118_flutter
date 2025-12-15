class PostItem {
  final int pid;
  final String pname;
  final String description;
  final int cid;

  PostItem({
    required this.pid,
    required this.pname,
    required this.description,
    required this.cid,
  });

  factory PostItem.fromJson(Map<String, dynamic> json) => PostItem(
        pid: json['pid'] as int,
        pname: json['pname'] as String,
        description: json['description'] as String,
        cid: json['cid'] as int,
      );

  Map<String, dynamic> toJson() => {
        'pid': pid,
        'pname': pname,
        'description': description,
        'cid': cid,
      };
}