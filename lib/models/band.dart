class Band {
  String id;
  String name;
  int votes;

  Band({required this.id, required this.name, required this.votes});

  // factory Band.fromMap(Map<String, dynamic> obj) {
  //   return Band();
  // }
  factory Band.fromMap(Map<String, dynamic> obj) => Band(
    //id: obj['id'],
    id: obj.containsKey('id') ? obj['id'] : 'no-id',
    //name: obj['name'],
    name: obj.containsKey('name') ? obj['name'] : 'no-name',
    // votes: obj['votes']);
    votes: obj.containsKey('votes') ? obj['votes'] : 'no-votes',
  );
}
