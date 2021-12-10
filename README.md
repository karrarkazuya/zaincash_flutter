# zaincash_flutter
Zaincash payment gateway integration for flutter


# USE
First you will need a transaction_id created by using your merchant credentials on backend and then forwarded over to the mobile app

Then use zaincash as a widget inside your view
```
  ZainCash(transaction_id: "61b3976de65fb79d1b5ffc3c", production: false, close_on_success: true, close_on_error: true)
```
And you can listen to the state change events using the listener
```
  ZaincashService.paymentStateListener.listen((state) {
      if(state['success'] == 1){
      // TO DO
      }
  });
```
