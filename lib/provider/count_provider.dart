import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class CountProvider with ChangeNotifier{

  //---------------------------- Get/Set Url
  String _url = "https://rpms.reena.org/";
  String get url => _url;
  void setUrl(String v){
    _url = v;
    notifyListeners();
  }
  //---------------------------- boolean used for show/hide bottom bar
  bool _convertFlag = false;
  bool get convertFlag => _convertFlag;
  void setFlag(bool v){
    _convertFlag = v;
    notifyListeners();
  }
  //---------------------------- index used for list
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  void setIndex(int v){
    _selectedIndex = v;
    notifyListeners();
  }
  //---------------------------- loading progress indicator
  double _progress = 0;
  double get progress => _progress;
  void setProgress(double v){
    _progress = v;
    notifyListeners();
  }
  //----------------------------
  int _count = 0;
  int get count => _count;
  void setCount(){
    _count++;
    notifyListeners();
  }
//----------------------------
  void initializeAll(){
    _url            = "https://rpms.reena.org/";
    _count          = 0;
    _selectedIndex  = 0;
    _progress       = 0;
    _convertFlag    = false;
    notifyListeners();
  }
//----------------------------
//----------------------------
/*list index function*/
// void onItemTapped(int index) {
//   _selectedIndex = index;
//   setIndex(index);
//
//   if (index == 0) {
//     _url = "${_url}dashboard2";
//   }
//   else if (index == 1) {
//     _url = "${_url}tblorderslist";
//   } else if (index == 2) {
//     _url = "${_url}tblwarrantylist";
//   } else if (index == 3) {
//     //webViewController?.clearCache();
//     webViewController?.reload();
//   }
//   else if (index == 4) {
//     _url = "${_url}logout";
//   }
//   webViewController?.loadUrl( urlRequest: URLRequest(url: WebUri("${_url}")));
//   notifyListeners();
// }
//----------------------------

}