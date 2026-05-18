class Departments {
  final String name;
  final int id;
  Departments({required this.name, required this.id});
}

class Roles {
  final String name;
  final int id;

  Roles({required this.name, required this.id});
}

class Priorities {
  final String name;
  final int id;
  Priorities({required this.name, required this.id});
}

class Company {
  final String name;
  final int id;

  Company({required this.name, required this.id});
}

final CompanyNames = [
  Company(id: 0, name: 'UM Enterprises'),
  Company(id: 1, name: 'Matrix Pharma'),
];

final roles = [
  Roles(id: 0, name: 'ceo'),
  Roles(id: 1, name: 'manager'),
  Roles(id: 2, name: 'employee'),
];
final priorities = [
  Priorities(name: 'low', id: 0),
  Priorities(name: 'medium', id: 1),
  Priorities(name: 'high', id: 2),
  Priorities(name: 'urgent', id: 3),
];

final List<Departments> departments = [
  Departments(id: 0, name: 'HR'),

  Departments(id: 1, name: 'Admin'),
  Departments(id: 2, name: 'IT'),

  Departments(id: 3, name: 'Procurement'),

  Departments(id: 4, name: 'LA'),

  Departments(id: 5, name: 'Feed'),

  Departments(id: 6, name: 'FM'),

  Departments(id: 7, name: 'Drag'),

  Departments(id: 8, name: 'Finance'),

  Departments(id: 9, name: 'LARA'),

  Departments(id: 10, name: 'LAFM'),

  Departments(id: 11, name: 'LBFM'),

  Departments(id: 12, name: 'FMAS'),

  Departments(id: 13, name: 'FMPS'),

  Departments(id: 14, name: 'FMSG'),
];
