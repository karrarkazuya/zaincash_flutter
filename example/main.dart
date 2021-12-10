import 'package:flutter/material.dart';
import 'package:zaincash/zaincash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaincash Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Zaincash payment demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _zaincash = Container();
  String paymentState = '';

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    /**
     * to listen for the state of the transaction, it returns a json objects you can fetch like state['success']
     */
    ZaincashService.paymentStateListener.listen((state) {
      setState(() {
        paymentState = state.toString();
      });
    });
  }

  void _triggerPayment() {
    setState(() {
      _zaincash = Container(child: new ZainCash(transaction_id: _controller.text, production: false, close_on_success: true, close_on_error: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _controller,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter the transaction id'
                  ),
                ),
                ),
                SizedBox(height: 20),
                Text('Payment listener state '+paymentState),
              ],
            ),
            _zaincash,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _triggerPayment,
        tooltip: 'Pay',
        child: Icon(Icons.payment),
      ),
    );
  }
}
