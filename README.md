# zaincash_flutter
A none offical Zaincash payment gateway integration for flutter

# INSTALL

in your project terminal enter
```
  dart pub add zaincash
```

# USE
First you will need a transaction_id created by using your merchant credentials on backend and then forwarded over to the mobile app, if you do not have merchant credentials please contact the zaincash support to get one

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

# SCREENSHOTS
<p float="left">
<img src="https://github.com/karrarkazuya/zaincash_flutter/blob/main/git_images/1.png" alt="1" height="500">
<img src="https://github.com/karrarkazuya/zaincash_flutter/blob/main/git_images/2.png" alt="1" height="500">
<img src="https://github.com/karrarkazuya/zaincash_flutter/blob/main/git_images/3.png" alt="1" height="500">
<img src="https://github.com/karrarkazuya/zaincash_flutter/blob/main/git_images/4.png" alt="1" height="500">
</p>
