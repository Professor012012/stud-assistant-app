class ModulesData {
  static const Map<String, List<String>> modulesByYear = {
    '1st Year': [
      'ITE115C — Information Technology Essentials I',
      'ITM115C — Information Technology Mathematics I',
      'LCS5011 — Academic Literacy and Communication Studies',
      'PIM5011 — Personal Information Management',
      'PSA115C — Problem Solving and Algorithms',
      'SOD115C — Software Development I',
      'INP125C — Internet Programming I',
      'ITE125C — Information Technology Essentials II',
      'ITM125C — Information Technology Mathematics II',
      'LCS5012 — Academic Literacy and Communication Studies II',
      'SOD125C — Software Development II',
    ],
    '2nd Year': [
      'DBS216C — Databases II',
      'GID216C — Graphic Design II',
      'SOD216C — Software Development II A',
      'TPG216C — Technical Programming II A',
      'WEB215C — Web Content Management II',
      'GUD226C — Graphical User Interface Design II',
      'INT226C — Internet Technologies II',
      'SOD226C — Software Development II B',
      'SOE226C — Software Engineering II',
      'TPG226C — Technical Programming II B',
    ],
    '3rd Year': [
      'CMN316C — Communication Networks III',
      'ITS316C — Information Technology and Society I',
      'SOD316C — Software Development III',
      'SOE316C — Software Engineering III',
      'TPG316C — Technical Programming III',
      'ITC327W — Work Integrated Learning in Information Technology',
    ],
  };

  static List<String> get years => modulesByYear.keys.toList();

  static List<String> modulesForYear(String year) =>
      modulesByYear[year] ?? [];
}