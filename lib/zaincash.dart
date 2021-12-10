library zaincash;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';


class ZainCash extends StatefulWidget {
  ZainCash({Key? key, required this.transaction_id, required this.production, required this.close_on_success, required this.close_on_error}) : super(key: key);

  final String transaction_id;
  final bool production;
  final bool close_on_success;
  final bool close_on_error;
  @override
  PaymentDialog createState() => new PaymentDialog();
}


class PaymentDialog extends State<ZainCash> {
bool completed = false;
int currentStep = 1;
var detailsData = {};
var stepOneData = {};

var API = 'api.zaincash.iq';
var hint = '';
var details = Column();
final TextEditingController _phoneController = TextEditingController();
final TextEditingController _pinController = TextEditingController();
final TextEditingController _otpController = TextEditingController();
final listner = new ZaincashService();

@override
  void initState() {
    super.initState();
    this.API = !widget.production ? 'test.zaincash.iq' : 'api.zaincash.iq';
    setLoading();
    getDetails(widget.transaction_id);
  }

@override
  void didUpdateWidget(ZainCash oldWidget) {
    super.didUpdateWidget(oldWidget);
    this.API = !widget.production ? 'test.zaincash.iq' : 'api.zaincash.iq';
    setState(() {
      _otpController.text = '';
      completed = false;
      currentStep = 1;
      hint = '';
      details = Column();
      stepOneData = {};
      setLoading();
      getDetails(widget.transaction_id);
    });
  }


  void getDetails(String transaction_id) {
    httpRequester.get("https://"+this.API+"/transaction/pay?id="+transaction_id).then((data){
        this.detailsData = pageParser().stepOneDetails(data);
        if(detailsData['error'] != null)
          currentStep = 3;
        processSteps();
    });
  }

void processSteps() {
      switch (currentStep) {
        case 1:
          step1();
          break;
        case 2:
          step2();
          break;
        case 3:
          finalStep();
          break;
        default:
      }
}

  /**
   * step one the pin insertion
   */
  step1() {
    setState(() {
      this.details = Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(detailsData['details_1'], 
            textDirection: TextDirection.rtl),
          Text(hint, 
            textDirection: TextDirection.rtl),
          SizedBox(height: 10,),
          Text(detailsData['phone_number'], 
            textDirection: TextDirection.rtl),
          Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: TextFormField(
                  controller: _phoneController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: detailsData['phone_number'].toString(),
                  labelStyle: TextStyle(fontSize: 15),
                  hintTextDirection: TextDirection.rtl,
                  alignLabelWithHint: true
                ),
              ),
              ),
          SizedBox(height: 10,),
            
          Text(detailsData['pin'], 
            textDirection: TextDirection.rtl),
          Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: TextFormField(
                  obscureText: true,
                  controller: _pinController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: detailsData['pin_tip'].toString(),
                  labelStyle: TextStyle(fontSize: 15),
                  hintTextDirection: TextDirection.rtl,
                  alignLabelWithHint: true
                ),
              ),
              ),
        ],);
    });
  }


  /**
   * showing the otp field and the payment details
   */
  step2() {
    setState(() {
      this.details = Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(detailsData['header_2'], 
            textDirection: TextDirection.rtl),
          SizedBox(height: 10,),
          Table(  
            border: TableBorder.all(  
                color: Colors.black,  
                style: BorderStyle.solid,  
                width: 1),  
            children: getTableRows()),
          Text(hint, 
            textDirection: TextDirection.rtl),
          SizedBox(height: 10,),
          Text(detailsData['otp'], 
            textDirection: TextDirection.rtl),
          Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: TextFormField(
                  obscureText: true,
                  controller: _otpController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: detailsData['otp_tip'].toString(),
                  labelStyle: TextStyle(fontSize: 15),
                  hintTextDirection: TextDirection.rtl,
                  alignLabelWithHint: true
                ),
              ),
              ),
        ],);
    });
  }

 /**
  * to assing the rows for the table
  */
 getTableRows() {
  var preparedRows = [
    ['initialAmount',['ستقوم بدفع المبلغ :','برى باره دەدەیت','Item Price']],
    ['totalFees',['مجموع الرسوم :','کرێى سەرجەم','Total Fees']],
    ['dddd',['Discount','Discount','Discount']],
    ['total',['المجموع الكلي :','نرخى سەرجەم','Order Total']],
  ];
  List<TableRow> tableChildren = [];
    for (var item in detailsData['table']) {
      String item1 = item[1];
      String item2 = item[0];
      for (List<dynamic> preparedRow in preparedRows) {
        for (String suggested in preparedRow[1]) {
          if(item1.replaceAll(' ', '') == suggested.replaceAll(' ', '')){
            item2 = stepOneData[preparedRow[0]] != null ? stepOneData[preparedRow[0]].toString() + ' IQD' : '0 IQD';
          }
          if(item2.replaceAll(' ', '') == suggested.replaceAll(' ', '')){
            item1 = stepOneData[preparedRow[0]] != null ? stepOneData[preparedRow[0]].toString() + ' IQD' : '0 IQD';
          }
        }
      }
      tableChildren.add(
        TableRow( children: [
          Column(children:[Text(item1, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 15.0))]),
          Column(children:[Text(item2, textDirection: TextDirection.rtl, style: TextStyle(fontSize: 15.0))]),
        ]));
    }
  return tableChildren;
}

/**
 * to send the otp request
 */
processStep1(){
  setState(() {
    if((!_phoneController.text.startsWith('964') || _phoneController.text.length != 13) && _phoneController.text != ''){
      hint = detailsData['phone_number_tip'];
      step1();
    }
    if(_phoneController.text != '' && _pinController.text != ''){
      setLoading();
      httpRequester.post("https://"+this.API+"/transaction/processing", {
        "phonenumber": _phoneController.text,
        "pin": _pinController.text,
        "id": widget.transaction_id
      }).then((data){
        if(!(data is String) && data['success'] != null && data['success'] == 1){
          this.stepOneData = data;
          currentStep = 2;
          processSteps();
        }else{
          ZaincashService.fetch(
            {
              "success": 0,
              "error": !(data is String) && data['error'] != null ? data['error'] : '',
              "id": widget.transaction_id
            }
          );
          this.detailsData = {
            "error": !(data is String) && data['error'] != null ? data['error'] : '',
            "message": "",
          };
          currentStep = 3;
          if(widget.close_on_error){
            setState(() {
              completed = true;
            });
          }else{
            processSteps();
          }
        }
      });
    }
  });
}

/**
 * to submit the otp request
 */
processStep2(){
  setState(() {
    if(_otpController.text != '' && _phoneController.text.length >= 4){
      setLoading();
      httpRequester.post("https://"+this.API+"/transaction/processingOTP?type=MERCHANT_PAYMENT", {
        "phonenumber": _phoneController.text,
        "pin": _pinController.text,
        "otp": _otpController.text,
        "id": widget.transaction_id
      }).then((data){
        if(!(data is String) && data['total'] != null){
          currentStep = 3;
          httpRequester.get(data['url']).then((value){
            ZaincashService.fetch(
              {
                "success": 1,
                "id": widget.transaction_id
              }
            );
          });
          this.detailsData = {
            "error": 'payment was successful, total paid ' + data['total'].toString() + ' IQD',
            "message": "",
          };
          if(widget.close_on_success){
            setState(() {
              completed = true;
            });
          }else{
            processSteps();
          }
        }else{
          httpRequester.get(data['url']).then((value){
            ZaincashService.fetch(
              {
                "success": 0,
                "error": !(data is String) && data['error'] != null ? data['error'] : '',
                "id": widget.transaction_id
              }
            );
          });
          this.detailsData = {
            "error": !(data is String) && data['error'] != null ? data['error'] : '',
            "message": "",
          };
          currentStep = 3;
          if(widget.close_on_error){
            setState(() {
              completed = true;
            });
          }else{
            processSteps();
          }
        }
      });
    }
  });
}

cancelPayment() {
  httpRequester.post("https://"+this.API+"/transaction/cancel", {
        "type": 'MERCHANT_PAYMENT',
        "id": widget.transaction_id
      });
  setState(() {
          currentStep = 3;
          this.detailsData = {};
          completed = true;
        });
        ZaincashService.fetch(
            {
              "success": 0,
              "error": 'canceled',
              "id": widget.transaction_id
            }
          );
}

/**
 * set the loading spinner for fetching data
 */
setLoading(){
  setState(() {
    this.details = Column(children: [
        Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: Colors.teal,
              strokeWidth: 1.5,
            )),
          )
    ]);
  });
}

/**
 * handling the buttons events
 */
paymentButton(){
  switch (currentStep) {
        case 1:
          processStep1();
          break;
        case 2:
          processStep2();
          break;
        case 3:
          setState(() {
            completed = true;
          });
          break;
        default:
      }
}

finalStep() {
  setState(() {
    this.details = Column(children: [
        Text(detailsData['error'], 
          textDirection: TextDirection.rtl),
        SizedBox(height: 10,),
        Text(detailsData['message'], 
          textDirection: TextDirection.rtl),
      ],);
  });
}


@override
  Widget build(BuildContext context) {
    if(completed)
    return Container();
    return AlertDialog(
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: EdgeInsets.all(0),
          content: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
          child: ListBody(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.all(Radius.circular(5))
                ),
              child:Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(detailsData['title'] != null ? detailsData['title'] : 'Zaincash payment', style: TextStyle(fontSize: 16, color: Colors.white)),
                  Container(
                    width: 50,
                    height: 50,
                    child: Image.network('https://api.zaincash.iq/images/zaincashlogo-ar.png'),
                  ),
                ],
              )),
              SizedBox(height: 10,),
              this.details,
            ],
          ),
        ),
        actions: <Widget>[
          if(currentStep != 3)
          TextButton(
            child: Text(detailsData['button'] != null ? detailsData['button'] : currentStep == 3 ? 'Close' : ''),
            onPressed: paymentButton,
          ),
          IconButton(onPressed: cancelPayment, icon: Icon(Icons.close))
        ],
      );
  }

}

class ZaincashService {

static StreamController paymentState = new StreamController.broadcast();

static fetch(object) {
    // fetch json from server and then load it to objects
    // emits an event here
    paymentState.add(object); // send an arbitrary event
  }

// for the stream
static Stream get paymentStateListener => paymentState.stream;
}

/**
 * handle the http requests
 */
class httpRequester {
  static Future get(link) async {
    try {
      HttpClient client = new HttpClient();
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      HttpClientRequest request = await client.getUrl(Uri.parse(link));
      HttpClientResponse response = await request.close();
      return await response.transform(utf8.decoder).join();
    } catch (e) {
      return '';
    }
  }


 static Future post(link, input) async {
    try {
      HttpClient client = new HttpClient();
      Map map = input;
      HttpClientRequest request = await client.postUrl(Uri.parse(link));
      request.headers.set('content-type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.headers.set('Connection', 'keep-alive');
      request.add(utf8.encode(json.encode(map)));
      HttpClientResponse response = await request.close();
      String reply = await response.transform(utf8.decoder).join();
      Map<String, dynamic> data = jsonDecode(reply);
      return data;
    } catch (e) {
      return 'no';
    }
  }


}

/*
 * used to parse the details of transaction 
 */
class pageParser {
  stepOneDetails(String text) {
    if(text == '')
      return {'error': 'Connection issue',
            'message': ''};
    if(text.contains('<button')){
      return {
        'pay_by_agent': text.contains('name="email"'),
        'language': text.contains('كيفية التسجيل') ? 'ar' : text.contains('Phone Number') ? 'en' : 'ku',
        'title': getFromTo(text, '<title>', '</title>'),
        'details_1': getFromTo(text, '<p id="AmountWithCharge"', '<p id="AmountWithoutCharge"'),
        'header_1': getFromTo(text, '<div id="step1"', '</h3>'),
        'header_2': getFromTo(text, '<div id="step2"', '</h3>'),
        'phone_number': getFromTo(text, '<!--Phone Number-->', '</label>'),
        'phone_number_tip': getFromTo(text, 'name="phonenumber"', '</div>'),
        'pin': getFromTo(text, '<!--Pin-->', '</label>'),
        'pin_tip': getFromTo(text, 'name="pin"', '</div>'),
        'otp': getFromTo(text, '<div class="otp-container">', '</label>'),
        'otp_tip': getFromTo(text, '<!--otp-->', '</label>'),
        'button': getFromTo(text, '<button', '</button>'), 
        'table': getTable(text), 
        };
    }
    return {'error': getFromTo(text, '<h3>', '</h3>'),
            'message': getFromTo(text, '<h5>', '</h5>')};
  }

  getFromTo(String text, from, to){
      try {
        text =  text.replaceAll(text.substring(0, text.indexOf(from)), '');
        text = text.substring(text.indexOf(from), text.indexOf(to));
        text = clearTags(text);
        return text;
      } catch (e) {
        return e.toString();
      }
  }


  getTable(String text){
      try {
        text =  text.replaceAll(text.substring(0, text.indexOf("<table")), '');
        text = text.substring(text.indexOf("<table"), text.indexOf("</table>"));
        var tabel = [];
        while(text.contains("<tr")){
          tabel.add(getTr(text));
          text = text.replaceAll(text.substring(text.indexOf("<tr"), text.indexOf("</tr>") + "</tr>".length), '');
        }
        return tabel;
      } catch (e) {
        return [];
      }
  }

  getTr(String text){
      try {
        text = text.replaceAll(text.substring(0, text.indexOf("<tr")), '');
        text = text.substring(text.indexOf("<tr"), text.indexOf("</tr>"));
        text = text.replaceAll(text.substring(0, text.indexOf("<td")), '');
        var td1 = text.substring(0, text.indexOf("</td>"));
        text = text.replaceAll(text.substring(0, text.indexOf("</td>") +  "</td>".length), '');
        var td2 = text.substring(text.indexOf("<td"), text.indexOf("</td>"));
        td1 = clearTags(td1);
        td2 = clearTags(td2);
        return [td1, td2];
      } catch (e) {
        return [];
      }
  }


  clearTags(String text) {
    while(text.contains("<") && text.contains(">") && text.indexOf("<") < text.indexOf(">")){
      text = text.replaceAll(text.substring(text.indexOf("<"), text.indexOf(">")+1), '');
    }
    text = text.trim().replaceAll(RegExp(r'(\n){3,}'), "\n\n");
    while(text.startsWith(" "))
      text = text.substring(1, text.length);
    while(text.endsWith(" "))
      text = text.substring(0, text.length - 1);

    if (text.contains(">")) {
      text = "<" + text;
      text = clearTags(text);
    } else if (text.contains("<")) {
      text = text + ">";
      text = clearTags(text);
    }
    return text;
  }
}
