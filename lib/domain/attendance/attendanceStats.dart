class Attendancestats {
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final double attendancePercentage;
  final String className;
  final List<bool> attendanceList;

  Attendancestats({
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.className,
    required this.attendancePercentage,
    this.attendanceList = const [],
  });

  factory Attendancestats.fromJson(Map<String, dynamic> json) {
    final statistics = json['statistics'];
    final history = json['history'] as List;
    final className=json['class'];

    // Convert history to list of booleans (true for present, false for absent)
    final attendanceList = history.map((entry) {
      return entry['status'] == 'present';
    }).toList();

    return Attendancestats(
      totalClasses: statistics['totalClasses'],
      presentCount: statistics['presentCount'],
      absentCount: statistics['absentCount'],
      className: className['name'],
      attendancePercentage: statistics['attendancePercentage'].toDouble(),
      attendanceList: attendanceList,
    );
  }
}
