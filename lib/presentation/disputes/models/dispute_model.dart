class DisputeModel {
  final int id;
  final int ticketId;
  final String ticketNumber;
  final String ticketTitle;
  final String ticketStatus;
  final int raisedById;
  final String raisedByName;
  final String reason;
  final String description;
  final String status;
  final int? assignedReviewerId;
  final String? assignedReviewerName;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final List<DisputeActivityModel> timeline;

  const DisputeModel({
    required this.id,
    required this.ticketId,
    this.ticketNumber = '',
    this.ticketTitle = '',
    this.ticketStatus = '',
    required this.raisedById,
    this.raisedByName = '',
    required this.reason,
    required this.description,
    required this.status,
    this.assignedReviewerId,
    this.assignedReviewerName,
    this.resolutionNotes,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.timeline = const [],
  });

  factory DisputeModel.fromJson(Map<String, dynamic> j) => DisputeModel(
    id: int.tryParse(j['id']?.toString() ?? '') ?? 0,
    ticketId: int.tryParse(j['ticket_id']?.toString() ?? '') ?? 0,
    ticketNumber: j['ticket_number'] ?? '',
    ticketTitle: j['ticket_title'] ?? '',
    ticketStatus: j['ticket_status'] ?? '',
    raisedById: int.tryParse(j['raised_by_id']?.toString() ?? '') ?? 0,
    raisedByName: j['raised_by_name'] ?? '',
    reason: j['reason'] ?? '',
    description: j['description'] ?? '',
    status: j['status'] ?? 'open',
    assignedReviewerId:
        (j['assigned_reviewer_id'] is num)
            ? (j['assigned_reviewer_id'] as num).toInt()
            : int.tryParse(j['assigned_reviewer_id']?.toString() ?? ''),
    assignedReviewerName: j['assigned_reviewer_name'],
    resolutionNotes: j['resolution_notes'],
    createdAt: DateTime.tryParse(
      j['created_at'] ?? DateTime.now().toIso8601String(),
    ) ?? DateTime.now(),
    updatedAt: j['updated_at'] != null
        ? DateTime.tryParse(j['updated_at'])
        : null,
    resolvedAt: j['resolved_at'] != null
        ? DateTime.tryParse(j['resolved_at'])
        : null,
    timeline:
        (j['timeline'] as List<dynamic>?)
            ?.map((e) => DisputeActivityModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );

  bool get isOpen => status == 'open';
  bool get isUnderReview => status == 'under_review';
  bool get isResolved => status == 'resolved';
  bool get isRejected => status == 'rejected';
  bool get isEscalated => status == 'escalated';
  bool get isWithdrawn => status == 'withdrawn';

  bool get isClosedStatus =>
      isResolved || isRejected || isEscalated || isWithdrawn;

  String get reasonLabel => DisputeReasonLabels.labelFor(reason);
  String get statusLabel => DisputeStatusLabels.labelFor(status);
}

class DisputeActivityModel {
  final int id;
  final int disputeId;
  final String action;
  final int actorId;
  final String actorName;
  final String? note;
  final DateTime createdAt;

  const DisputeActivityModel({
    required this.id,
    this.disputeId = 0,
    required this.action,
    required this.actorId,
    this.actorName = '',
    this.note,
    required this.createdAt,
  });

  factory DisputeActivityModel.fromJson(Map<String, dynamic> j) =>
      DisputeActivityModel(
        id: int.tryParse(j['id']?.toString() ?? '') ?? 0,
        disputeId: int.tryParse(j['dispute_id']?.toString() ?? '') ?? 0,
        action: j['action'] ?? '',
        actorId: int.tryParse(j['actor_id']?.toString() ?? '') ?? 0,
        actorName: j['actor_name'] ?? '',
        note: j['note'],
        createdAt: DateTime.tryParse(
          j['created_at'] ?? DateTime.now().toIso8601String(),
        ) ?? DateTime.now(),
      );

  String get actionLabel => DisputeActionLabels.labelFor(action);
}

class DisputeReasonLabels {
  DisputeReasonLabels._();

  static const Map<String, String> _map = {
    'wrong_resolution': 'Wrong Resolution',
    'sla_breach': 'SLA Breach',
    'wrong_assignment': 'Wrong Assignment',
    'quality_issue': 'Quality Issue',
    'other': 'Other',
  };

  static String labelFor(String reason) => _map[reason] ?? reason;

  static String valueFor(String label) {
    final entry = _map.entries.where((e) => e.value == label).toList();
    return entry.isNotEmpty ? entry.first.key : label;
  }

  static List<String> get labels => _map.values.toList();
}

class DisputeStatusLabels {
  DisputeStatusLabels._();

  static const Map<String, String> _map = {
    'open': 'Open',
    'under_review': 'Under Review',
    'resolved': 'Resolved',
    'rejected': 'Rejected',
    'escalated': 'Escalated',
    'withdrawn': 'Withdrawn',
    'disputed': 'Disputed',
  };

  static String labelFor(String status) => _map[status] ?? status;
}

class DisputeActionLabels {
  DisputeActionLabels._();

  static const Map<String, String> _map = {
    'raised': 'Dispute raised',
    'commented': 'Comment',
    'reviewer_assigned': 'Reviewer assigned',
    'status_changed': 'Status changed',
    'resolved': 'Resolved',
    'rejected': 'Rejected',
    'escalated': 'Escalated',
    'withdrawn': 'Withdrawn',
  };

  static String labelFor(String action) => _map[action] ?? action;
}
