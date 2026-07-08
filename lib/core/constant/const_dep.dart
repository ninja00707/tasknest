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

class Statuses {
  final String name;
  final int id;
  Statuses({required this.name, required this.id});
}

final statuses = [
  Statuses(id: 0, name: 'All'),
  Statuses(id: 1, name: 'open'),

  Statuses(id: 2, name: 'in_progress'),

  Statuses(id: 3, name: 'completed'),
  Statuses(id: 4, name: 'closed'),
];
final CompanyNames = [
  Company(id: 0, name: 'UM Enterprises'),
  Company(id: 1, name: 'Matrix Pharma'),
];

final roles = [
  Roles(id: 0, name: 'Director'),
  Roles(id: 1, name: 'manager'),
  Roles(id: 2, name: 'employee'),
  Roles(id: 3, name: 'developer'),
];
final priorities = [
  Priorities(name: 'low', id: 0),
  Priorities(name: 'medium', id: 1),
  Priorities(name: 'high', id: 2),
  Priorities(name: 'urgent', id: 3),
];

final List<Departments> departments = [];

const int roleCEO = 0;
const int roleManager = 1;
const int roleEmployee = 2;
const int roleDeveloper = 3;
