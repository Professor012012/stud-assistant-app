class ApplicationModule {
  final String academicLevel;
  final String semester;
  final String moduleCode;
  final String moduleName;

  ApplicationModule({
    required this.academicLevel,
    this.semester = '',
    this.moduleCode = '',
    required this.moduleName,
  });

  Map<String, dynamic> toMap() => {
        'academic_level': academicLevel,
        'semester': semester,
        'module_code': moduleCode,
        'module_name': moduleName,
      };

  factory ApplicationModule.fromMap(Map<String, dynamic> map) {
    return ApplicationModule(
      academicLevel: map['academic_level'] ?? '',
      semester: map['semester'] ?? '',
      moduleCode: map['module_code'] ?? '',
      moduleName: map['module_name'] ?? '',
    );
  }
}

class ApplicationModel {
  final String? id;
  final String studentId;
  final String yearOfStudy;
  final List<ApplicationModule> modules;
  final bool confirmedEligibility;
  final String? transcriptUrl;
  final String? idDocumentUrl;
  final String? proofOfRegistrationUrl;
  final String status;
  final DateTime? createdAt;
  final Map<String, dynamic>? studentProfile;

  ApplicationModel({
    this.id,
    String? studentId,
    String? userId,
    String? yearOfStudy,
    List<ApplicationModule>? modules,
    ApplicationModule? module1,
    ApplicationModule? module2,
    bool? confirmedEligibility,
    bool? eligibilityConfirmed,
    this.transcriptUrl,
    this.idDocumentUrl,
    this.proofOfRegistrationUrl,
    this.status = 'pending',
    this.createdAt,
    this.studentProfile,
  })  : studentId = studentId ?? userId ?? '',
        yearOfStudy = yearOfStudy ?? '',
        modules = modules ??
            [
              if (module1 != null) module1,
              if (module2 != null) module2,
            ],
        confirmedEligibility =
            confirmedEligibility ?? eligibilityConfirmed ?? false;

  String get userId => studentId;
  ApplicationModule get module1 => modules.first;
  ApplicationModule? get module2 => modules.length > 1 ? modules[1] : null;
  bool get eligibilityConfirmed => confirmedEligibility;

  // FIX: removed transcriptUrl, idDocumentUrl, proofOfRegistrationUrl from
  // toMap() — the service uploads files and passes those URLs separately,
  // so including null values here caused them to overwrite the real URLs
  // in the spread inside ApplicationService.submitApplication()
  Map<String, dynamic> toMap() => {
        'student_id': studentId,
        'year_of_study': yearOfStudy,
        'confirmed_eligibility': confirmedEligibility,
        'status': status,
      };

  factory ApplicationModel.fromMap(Map<String, dynamic> map) {
    return ApplicationModel(
      id: map['id'],
      studentId: map['student_id'],
      yearOfStudy: map['year_of_study'],
      modules: (map['application_modules'] as List? ?? [])
          .map((item) =>
              ApplicationModule.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      confirmedEligibility: map['confirmed_eligibility'] ?? false,
      transcriptUrl: map['transcript_url'],
      idDocumentUrl: map['id_document_url'],
      proofOfRegistrationUrl: map['proof_of_registration_url'],
      status: map['status'] ?? 'pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      studentProfile: map['profiles'] != null
          ? Map<String, dynamic>.from(map['profiles'])
          : map['studentProfile'] != null
              ? Map<String, dynamic>.from(map['studentProfile'])
              : null,
    );
  }
}