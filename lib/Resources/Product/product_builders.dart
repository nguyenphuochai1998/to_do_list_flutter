import 'package:flutter/material.dart';
import 'package:to_do_list_flutter/Resources/Product/product_data.dart';



const loadingText = 'LOADING';


deleteProducrtBuidler(fetchState) {
  if (fetchState.loading == true) {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null) {
    return Text(fetchState.response!.name!, textDirection: TextDirection.ltr);
  }

  return MaterialApp(
    home: Scaffold(
      body: ElevatedButton(
        child: Text("Delete", textDirection: TextDirection.ltr),
        onPressed: () => fetchState.fetch(null),
      ),
    ),
  );
}

createProductBuilder(fetchState) {
  if (fetchState.loading == true) {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null) {
    return Text(fetchState.response!.name!, textDirection: TextDirection.ltr);
  }

  return MaterialApp(
    home: Scaffold(
      body: ElevatedButton(
        child: Text("Create product", textDirection: TextDirection.ltr),
        onPressed: () => fetchState.fetch(params),
      ),
    ),
  );
}
