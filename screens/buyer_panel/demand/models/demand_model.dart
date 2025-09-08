// lib/screens/buyer_panel/demand/models/demand_model.dart

class DemandModel {
  final String id;
  final String date;
  final String shape;
  final String carat;
  final String color;
  final String clarity;
  final String status;
  final int matches;
  final String? cut;
  final String? polish;
  final String? symmetry;
  final String? fluorescence;
  final String? lab;
  final String? notes;
  final String? budget;
  final String? timeframe;

  DemandModel({
    required this.id,
    required this.date,
    required this.shape,
    required this.carat,
    required this.color,
    required this.clarity,
    required this.status,
    required this.matches,
    this.cut,
    this.polish,
    this.symmetry,
    this.fluorescence,
    this.lab,
    this.notes,
    this.budget,
    this.timeframe,
  });

  factory DemandModel.fromJson(Map<String, dynamic> json) {
    return DemandModel(
      id: json['id'],
      date: json['date'],
      shape: json['shape'],
      carat: json['carat'],
      color: json['color'],
      clarity: json['clarity'],
      status: json['status'],
      matches: json['matches'],
      cut: json['cut'],
      polish: json['polish'],
      symmetry: json['symmetry'],
      fluorescence: json['fluorescence'],
      lab: json['lab'],
      notes: json['notes'],
      budget: json['budget'],
      timeframe: json['timeframe'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'shape': shape,
      'carat': carat,
      'color': color,
      'clarity': clarity,
      'status': status,
      'matches': matches,
      'cut': cut,
      'polish': polish,
      'symmetry': symmetry,
      'fluorescence': fluorescence,
      'lab': lab,
      'notes': notes,
      'budget': budget,
      'timeframe': timeframe,
    };
  }
}
