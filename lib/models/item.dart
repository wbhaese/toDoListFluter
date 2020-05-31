class Item {
  String title;
  bool done;
  //Construtor da classe
  //This já pega o valor das variáveis
  Item({this.title, this.done});

  //pega os valores do JSON
  Item.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    done = json['done'];
  }

  //Passa os valores para JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['done'] = this.done;

    return data;
  }
}
