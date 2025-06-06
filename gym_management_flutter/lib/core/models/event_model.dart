// EventRequest model
class EventRequest {
  final String title;
  final String date;
  final String time;
  final String location;
  final String? imageUri;
  final int createdBy;

  EventRequest({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    this.imageUri,
    required this.createdBy,
  });

  factory EventRequest.fromJson(Map<String, dynamic> json) {
    return EventRequest(
      title: json['title'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      location: json['location'] as String,
      imageUri: json['imageUri'] as String?,
      createdBy: json['createdBy'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'imageUri': imageUri,
      'createdBy': createdBy,
    };
  }
}

// EventUpdateRequest model
class EventUpdateRequest {
  final int id;
  final String? title;
  final String? date;
  final String? time;
  final String? location;
  final String? imageUri;

  EventUpdateRequest({
    required this.id,
    this.title,
    this.date,
    this.time,
    this.location,
    this.imageUri,
  });

  factory EventUpdateRequest.fromJson(Map<String, dynamic> json) {
    return EventUpdateRequest(
      id: json['id'] as int,
      title: json['title'] as String?,
      date: json['date'] as String?,
      time: json['time'] as String?,
      location: json['location'] as String?,
      imageUri: json['imageUri'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'imageUri': imageUri,
    };
  }
}

// EventResponse model
class EventResponse {
  final int id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String? imageUri;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  EventResponse({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    this.imageUri,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      location: json['location'] as String,
      imageUri: json['imageUri'] as String?,
      createdBy: json['createdBy'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'imageUri': imageUri,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// EventParticipant model
class EventParticipant {
  final int id;
  final int eventId;
  final int userId;
  final String joinedAt;

  EventParticipant({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.joinedAt,
  });

  factory EventParticipant.fromJson(Map<String, dynamic> json) {
    return EventParticipant(
      id: json['id'] as int,
      eventId: json['eventId'] as int,
      userId: json['userId'] as int,
      joinedAt: json['joinedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'joinedAt': joinedAt,
    };
  }
}