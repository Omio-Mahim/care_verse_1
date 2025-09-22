import '../models/doctor.dart';

List<Doctor> getDoctorsData() {
  return [
    Doctor(
      id: '1',
      name: "Dr. Kaji Md. Nasimuzzaman",
      specialty: "Gynae & Obs",
      consultations: 220,
      years: 15,
      rating: 4.9,
      fee: 1000,
      photo: "assets/images/Dr.-Kaji-Md.-Nasimuzzaman.jpg",
      details: [
        "MBBS, MCPS, DGO, FMAS, DMAS (INDIA)",
        "Advanced Trained on Infertility from India",
        "Infertility, Obstetrics & Gynecology Specialist & Laparoscopic Surgeon",
        "Senior Consultant (Gyne & Obs Dept)",
        "Sylhet MAG Osmani Medical College & Hospital",
      ],
      bio:
          "Dr. Kaji Md. Nasimuzzaman is a renowned infertility, obstetrics, and gynecology specialist and laparoscopic surgeon based in Sylhet, known for his compassionate approach and extensive clinical expertise.",
    ),
    Doctor(
      id: '2',
      name: "Dr. Khursheda Tahmin (Shimu)",
      specialty: "Gynae & Obs",
      consultations: 120,
      years: 10,
      rating: 4.8,
      fee: 800,
      photo: "assets/images/Dr.-Khursheda-Tahmin-Shimu-.jpg",
      details: [
        "MBBS, BCS (Health), MS (OBGYN)",
        "Trained in Female Pelvic Medicine & Pelvic Reconstructive Surgery",
        "Gynecology, Obstetrics Specialist & Surgeon",
        "Fistula Surgeon",
        "Assistant Professor (Gyne & Obs)",
        "Sylhet MAG Osmani Medical College & Hospital",
      ],
      bio:
          "Dr. Khursheda Tahmin (Shimu) is a skilled Gynecology and Obstetrics Specialist & Surgeon in Sylhet, holding MBBS, BCS (Health), and MS (OBGYN) degrees.",
    ),
    Doctor(
      id: '3',
      name: "Prof. Dr. Md. Manajjir Ali",
      specialty: "Child Care",
      consultations: 200,
      years: 12,
      rating: 4.9,
      fee: 600,
      photo: "assets/images/Prof.-Dr.-Md.-Manajjir-Ali.jpg",
      details: [
        "MBBS, FCPS (CHILD), DMEd (UK), FRCP (EDIN, UK)",
        "Newborn & Child Diseases Specialist",
        "Former Professor, Pediatrics",
        "Sylhet MAG Osmani Medical College & Hospital",
      ],
      bio:
          "Prof. Dr. Md. Manajjir Ali is a Child Specialist in Sylhet with extensive experience in pediatric care.",
    ),
    // Add more doctors as needed...
  ];
}
