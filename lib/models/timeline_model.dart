const String fieldID = "id";
const String fieldTimelineID = "timeline_id";
const String fieldTimelineCaption = "timeline_caption";
const String fieldTimelineImage = "timeline_image";
const String fieldArea = "area";
const String fieldVisibility = "visibility";
const String fieldCompanyID = "company_id";
const String fieldCreatedAt = "created_at";
const String fieldCompanyName = "company_name";
const String fieldCompanyLogo = "company_logo";

class TimelineModel {
  static const String keyTimeline = "timelines";

  final int id;
  final String timelineID;
  final String timelineCaption;
  final String timelineImage;
  final String area;
  final int visibility;
  final String companyID;
  final int createdAt;
  final String companyName;
  final String companyLogo;

  TimelineModel({
    this.id = 0,
    this.timelineID = "",
    this.timelineCaption = "",
    this.timelineImage = "",
    this.area = "",
    this.visibility = 0,
    this.companyID = "",
    this.createdAt = 0,
    this.companyName = "",
    this.companyLogo = "",
  });

  TimelineModel.empty() : this();

  factory TimelineModel.fromJson(Map<String, dynamic> data) => TimelineModel(
    id: data[fieldID] ?? 0,
    timelineID: data[fieldTimelineID] ?? "",
    timelineCaption: data[fieldTimelineCaption] ?? "",
    timelineImage: data[fieldTimelineImage] ?? "",
    area: data[fieldArea] ?? "",
    visibility: data[fieldVisibility] ?? 0,
    companyID: data[fieldCompanyID] ?? "",
    createdAt: data[fieldCreatedAt] != null ? DateTime.tryParse(data[fieldCreatedAt])?.millisecondsSinceEpoch ?? 0 : 0,
    companyName: data[fieldCompanyName] ?? "",
    companyLogo: data[fieldCompanyLogo] ?? "",
  );

  @override
  String toString() =>
      "TimelineModel(id: $id, timelineID: $timelineID, timelineCaption: $timelineCaption, timelineImage: $timelineImage, area: $area, visibility: $visibility, companyID: $companyID, createdAt: $createdAt, companyName: $companyName, companyLogo: $companyLogo)\n";
}
