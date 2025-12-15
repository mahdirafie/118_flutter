class SpaceItem {
  final int sid;
  final String sname;
  final String room;
  final int cid;

  SpaceItem({
    required this.sid,
    required this.sname,
    required this.room,
    required this.cid,
  });

  factory SpaceItem.fromJson(Map<String, dynamic> json) => SpaceItem(
        sid: json['sid'] as int,
        sname: json['sname'] as String,
        room: json['room'] as String,
        cid: json['cid'] as int,
      );

  Map<String, dynamic> toJson() => {
        'sid': sid,
        'sname': sname,
        'room': room,
        'cid': cid,
      };
}
