class Member {
  final String id;
  final String name;
  final int assigned;
  final int overdue;
  final int completed;

  Member({
    required this.id,
    required this.name,
    required this.assigned,
    required this.overdue,
    required this.completed,
  });

  factory Member.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Member(
      id: documentId,
      name: data['name'] ?? '',
      assigned: data['assigned'] ?? 0,
      overdue: data['overdue'] ?? 0,
      completed: data['completed'] ?? 0,
    );
  }
}
