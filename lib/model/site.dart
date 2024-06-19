class Site {
  String siteId;
  String siteDesc;
  String siteAddress;
  String siteTel;
  Location location;
  String siteCloseTime;
  String siteOpenTime;
  double distanceFromSelected; // Added property for distance
  bool isOpen;

  Site({
    required this.siteId,
    required this.siteDesc,
    required this.siteAddress,
    required this.siteTel,
    required this.location,
    required this.siteCloseTime,
    required this.siteOpenTime,
    this.distanceFromSelected = 0.0,
    this.isOpen = false,
  });

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      siteId: json['site_id'],
      siteDesc: json['site_desc'],
      siteAddress: json['site_address'],
      siteTel: json['site_tel'],
      location: Location.fromJson(json['location']),
      siteCloseTime: json['site_close_time'],
      siteOpenTime: json['site_open_time'],
      distanceFromSelected: 0.0, // Initialize distance with default value
    );
  }
}
class Location {
  String type;
  List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates'].map((x) => x.toDouble())),
    );
  }
}

