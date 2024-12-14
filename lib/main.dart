import 'dart:async';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'provider/count_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => CountProvider()),
            //ChangeNotifierProvider(create: (_) => ExampleOneProvider()),
            //ChangeNotifierProvider(create: (_) => FavouriteItemProvider()),
          ],
          child: MaterialApp(
            title: 'RPMS',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            home: MyApp(),
          ))
    //MaterialApp(home: MyApp())
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});


  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true
  );

  PullToRefreshController? pullToRefreshController;
  final urlController = TextEditingController();

  //webViewController?.loadUrl( urlRequest: URLRequest(url: WebUri("${context.read<CountProvider>().url}dashboard2")));
  void _onItemTapped(int index){
    context.read<CountProvider>().setIndex(index);
    String str = "";

    if (index == 0) {
      str = "${context.read<CountProvider>().url}dashboard2";
    }
    else if (index == 1) {
      str = "${context.read<CountProvider>().url}tblorderslist";

    } else if (index == 2) {
      str = "${context.read<CountProvider>().url}tblwarrantylist";

    } else if (index == 3) {
      //webViewController?.clearCache();
      //webViewController?.reload();
      str = "${context.read<CountProvider>().url}logout";
    }
    else if (index == 4) {
      //webViewController?.clearCache();
      webViewController?.reload();
      //str = "${context.read<CountProvider>().url}logout";
    }
    webViewController?.loadUrl( urlRequest: URLRequest(url: WebUri(str)));
  }
  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb ? null : PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    context.read<CountProvider>().setFlag(false) ;
    //webViewController?.clearAllCache();
    InAppWebViewController.clearAllCache();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      /*appBar: AppBar(title: const Text("Reena APP")),*/
      body: SafeArea(
        child: Column(children: <Widget>[
          /*TextField(
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search)
                ),
                controller: urlController,
                keyboardType: TextInputType.url,
                onSubmitted: (value) {
                  var url = WebUri(value);
                  if (url.scheme.isEmpty) {
                    url = WebUri("https://www.google.com/search?q=" + value);
                  }
                  webViewController?.loadUrl(urlRequest: URLRequest(url: url));
                },
              ),*/
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: WebUri(context.read<CountProvider>().url)),
                  initialSettings: settings,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    // setState(() {urlController.text = url.toString();});
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,);
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {

                    var str = url.toString().split('/');
                    pullToRefreshController?.endRefreshing();
                    if(context.read<CountProvider>().progress == 1.0 &&  str[str.length-1] != "login" && str[str.length-1] != "resetpassword"  ){
                      //print("Nasir ${str[str.length-1]}");
                      context.read<CountProvider>().setFlag(true);
                      if(context.read<CountProvider>().selectedIndex != 0 && str[str.length-1] == "dashboard2"  ) {
                        context.read<CountProvider>().setIndex(0);
                      } else if(context.read<CountProvider>().selectedIndex != 1 &&  str[str.length-1] == "tblorderslist"  ) {
                        context.read<CountProvider>().setIndex(1);
                      } else if(context.read<CountProvider>().selectedIndex != 2 &&  str[str.length-1] == "tblwarrantylist"  ) {
                        context.read<CountProvider>().setIndex(2);
                      }
                      //urlController.text = url.toString();

                    }else if(context.read<CountProvider>().progress == 1.0){
                      //e.setFlag(false);
                      //e.setIndex(0);
                      context.read<CountProvider>().initializeAll();
                      //context.read<CountProvider>().initializeAll();
                      //urlController.text = url.toString();
                    }
                  },
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {

                    if (context.read<CountProvider>().progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    context.read<CountProvider>().setProgress(progress / 100);
                    urlController.text = context.read<CountProvider>().url;

                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    urlController.text = context.read<CountProvider>().url;
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    //print(consoleMessage);
                  },
                  onReceivedHttpError: (controller, request, errorResponse) async {
                    // Handle HTTP errors here
                    var isForMainFrame = request.isForMainFrame ?? false;
                    if (!isForMainFrame) {
                      return;
                    }
                    final snackBar = SnackBar(
                      content: Text(
                          'HTTP error for URL: ${request.url} with Status: ${errorResponse.statusCode} ${errorResponse.reasonPhrase ?? ''}'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                ),
                Consumer<CountProvider>(builder: (context, e, child) {
                  return e.progress < 1.0 ? LinearProgressIndicator(value: e.progress, color: Colors.blue,) : Container();
                }),
              ],
            ),
          ),
          /*ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    child: const Icon(Icons.arrow_back),
                    onPressed: () {
                      webViewController?.goBack();
                    },
                  ),
                  ElevatedButton(
                    child: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      webViewController?.goForward();
                    },
                  ),
                  ElevatedButton(
                    child: const Icon(Icons.refresh),
                    onPressed: () {
                      webViewController?.reload();
                    },
                  ),
                ],
              ),*/
        ],
        ),
      ),
      bottomNavigationBar:  Consumer<CountProvider>(builder: (context, e, child) => Offstage(
        offstage: !e.convertFlag,
        child: BottomNavigationBar(
          currentIndex: e.selectedIndex,
          onTap: _onItemTapped,
          elevation: 10,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          selectedItemColor: Colors.blueAccent,
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: const Color(0xFF526480),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_home_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_home_filled),
                label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_list_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_list_filled),
                label: "Orders"),
            BottomNavigationBarItem(
                icon: Icon(FluentSystemIcons.ic_fluent_app_folder_regular),
                activeIcon: Icon(FluentSystemIcons.ic_fluent_app_folder_filled),
                label: "Warranty"),
            BottomNavigationBarItem(
                icon: Icon(Icons.logout),
                activeIcon: Icon(Icons.logout_outlined),
                label: "Logout"),
            /*BottomNavigationBarItem(
                    icon: Icon(Icons.refresh),
                    activeIcon: Icon(Icons.refresh_outlined),
                    label: "Refresh"),
                */
          ],
        ),
      )
      ),
    );
  }
}