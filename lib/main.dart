import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/item.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App', //título quando app está minimizado.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, //primarySwatch - paleta de cores
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>(); //Necessário importar do models/item.dart

  HomePage() {
    items = [];

    // items.add(Item(title: "Example 1", done: false));
    // items.add(Item(title: "Example 2", done: true));
    // items.add(Item(title: "Example 3", done: false));
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl =
      TextEditingController(); //controlará a adição do texto, variável adiconada no TextFormField também

  void add() {
    if (newTaskCtrl.text.isEmpty) return; //Verifica se é vazio ou não

    setState(() {
      widget.items.add(Item(title: newTaskCtrl.text, done: false));
      newTaskCtrl.text = ""; //newTaskCtrl.clear() também funcopnar
      save(); //Chama o método que salva os dados
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences //buscará os dados locais
        .getInstance(); //vai aguardar até que o sharedPreferences não estiver pronto
    var data = prefs.getString('data');

    //confirma se não é nulo
    if (data != null) {
      //verifica se a lista é iterável
      Iterable decoded = jsonDecode(data);

      //map irá percorrer todos os dados
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();

      //chamamos um setState para analisar
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    //seta os valores no sahredPreferences
    await prefs.setString('data', jsonEncode(widget.items));
  }

  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //representa uma página, com o appbar e o body
      appBar: AppBar(
        leading: Icon(Icons.assignment), // Menu "hamburguer" lateral esquerdo,
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            //INputDecoration é justamente o texto que aparecerá acima do input
            labelText: "Adicionar Tarefa",
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
        // actions: <Widget>[
        //   //Menu do lado direito
        //   Icon(Icons.plus_one),
        // ],
      ),
      body: ListView.builder(
        itemCount: widget.items.length, //Traz o tamanho (quantidade de items)
        itemBuilder: (BuildContext ctxt, int index) {
          final item = widget.items[index];
          //Pega o contexto e o índice
          return Dismissible(
            key: Key(item.title),
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                //setState pega o true ou false selecionado no front e seta na propriedade do item
                //para modificar estado também existe o block, provider, etc
                setState(() {
                  //só disponível em statefull
                  item.done = value;
                  save();
                });
              },
            ),
            background: Container(
              color: Colors.red.withOpacity(0.6),
              child: Icon(Icons.delete_forever),
              // child: Text("Excluir"),//Pode-se adicionar textos também
            ),

            //função do arrasto e ações:
            onDismissed: (direction) {
              //possibilidade de analisar a direção que foi arrastado:
              // if(direction == DismissDirection.endToStart || startToEnd)
              remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        //Botão para adicionar o texto
        onPressed: add, //Chamando função add - Não vai parenteses '()'
        child: Icon(Icons.add_box),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
