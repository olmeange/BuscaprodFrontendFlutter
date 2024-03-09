import 'dart:convert';
import 'dart:io';
import 'package:buscaprodmt/src/models/materialsv2_model.dart';
import 'package:buscaprodmt/src/pages/image_details_page.dart';
import 'package:buscaprodmt/src/pages/login_page.dart';
//import 'package:buscaprodmt/src/pages/login_page.dart';
import 'package:buscaprodmt/src/services/api_services.dart';
import 'package:buscaprodmt/src/utils/list_flag_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final _formState = GlobalKey<FormState>();
  final scrollController = ScrollController();
  final FetchItem fetchItem = FetchItem();
  final TextEditingController inputController = TextEditingController();
  String chosenValue = 'Descripción';
  String sharedPrefText = '';
  String inputSearchText = '';
  bool inputDone = false;

  // This holds the posts fetched from the server
  List<Materialsv2> _posts = [];

  // Clase que contiene las banderas para controlar adecuadamente la carga del listview
  final ListFlagsController listFlagsController = ListFlagsController();

  // Declaration for back button system android
  //final _androidAppRetain = const MethodChannel("android_app_retain");

  @override
  void initState() {
    super.initState();
    _loadSavedText().then((tkn) {
      sharedPrefText = tkn;
    });
    scrollController.addListener(() {
      _loadMore(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(() {
      _loadMore(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Platform.isAndroid) {
          MoveToBackground.moveTaskToBack();
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Busca Prod Mercotec',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: SafeArea(
          child: Stack(children: [
            Column(children: [
              searchInput(),
              Expanded(
                  child: Visibility(
                visible: inputDone,
                child: !listFlagsController.isEmpty ? resultList() : notFound(),
              )),
            ]),

            // when the _loadMore function is running
            if (listFlagsController.isLoadMoreRunning ||
                listFlagsController.isFirstLoadRunning)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  // This function will be called when the app launches (see the initState function)
  void _firstLoad(context) async {
    setState(() {
      listFlagsController.page = 1;
      listFlagsController.hasNextPage = true;
      listFlagsController.isFirstLoadRunning = true;
      inputDone = false;
    });

    final Materialsv2Model data =
        await fetchItem.getMaterialsDescriptionCodePerPage(
            listFlagsController.page,
            inputSearchText,
            chosenValue,
            sharedPrefText);

    if (data.statusCode == 1011) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }

    if (data.statusCode == 1013) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Sin Conexión a Internet",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.white,
          ),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ));
    }

    setState(() {
      inputDone = true;
    });

    if (data.materialsv2!.isNotEmpty) {
      setState(() {
        _posts.clear();
        listFlagsController.isEmpty = false;
        _posts = data.materialsv2!;
      });
    } else {
      setState(() {
        listFlagsController.isEmpty = true;
      });
    }

    setState(() {
      listFlagsController.isFirstLoadRunning = false;
    });
  }

  // This function will be triggered whenver the user scroll
  // to near the bottom of the list view
  void _loadMore(context) async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        listFlagsController.isLoadMoreRunning = true;
        listFlagsController.page++;
      });

      final Materialsv2Model data =
          await fetchItem.getMaterialsDescriptionCodePerPage(
              listFlagsController.page,
              inputSearchText,
              chosenValue,
              sharedPrefText);

      if (data.statusCode == 1011) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }

      if (data.statusCode == 1013) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Sin Conexión a Internet",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white,
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blue,
        ));
      }

      if (data.materialsv2!.isNotEmpty) {
        setState(() {
          _posts.addAll(data.materialsv2!);
        });
      }

      if (listFlagsController.page > 1 &&
          data.materialsv2!.isEmpty &&
          data.statusCode != 1013 &&
          data.statusCode == 1004) {
        setState(() {
          listFlagsController.hasNextPage = false;
          listFlagsController.isLoadMoreRunning = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
              "Lista de items completa",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.blue,
          ));
        });
      }

      setState(() {
        listFlagsController.isLoadMoreRunning = false;
      });
    }
  }

  searchInput() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Form(
          key: _formState,
          child: TextFormField(
            controller: inputController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              suffixIcon: PopupMenuButton(
                icon: const Icon(Icons.arrow_drop_down_sharp),
                offset: const Offset(0, 48),
                onSelected: (value) {
                  chosenValue = value.toString();
                  _posts.clear();
                  listFlagsController.page = 1;
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  const PopupMenuItem(
                    value: 'Descripción',
                    child: Text('Descripción'),
                  ),
                  const PopupMenuItem(
                    value: 'Código',
                    child: Text('Código'),
                  )
                ],
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              border: const OutlineInputBorder(),
              hintText: 'Ingrese código o descripción',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            ),
            onFieldSubmitted: (String newValue) {
              if (newValue.isNotEmpty || newValue.trim().isEmpty) {
                inputSearchText = newValue;
                _firstLoad(context);
              }
            },
          ),
        ));
  }

  Widget resultList() {
    return ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.vertical,
        itemCount: _posts.length,
        itemBuilder: (BuildContext context, int i) {
          //print(_posts.length);
          //print(_posts[i].descripcion);
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            leading: InkWell(
              onTap: () {
                detailsPopup(_posts[i].descripcion!, _posts[i].image!,
                    _posts[i].codMaterial!);
              },
              child: AspectRatio(
                aspectRatio: 2,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    child: Image.memory(base64.decode(_posts[i].image!),
                        scale: 1 / 1.2, errorBuilder: (_, __, ___) {
                      return Image.asset('assets/not_found.png',
                          fit: BoxFit.contain);
                    })),
              ),
            ),
            title: Text(_posts[i].descripcion!,
                style: const TextStyle(fontSize: 14)),
            subtitle: Text(_posts[i].codMaterial!),
          );
        });
  }

  void detailsPopup(String name, String img, String sku) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
              padding: const EdgeInsets.all(5.0),
              child: Dialog(
                  surfaceTintColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Container(
                      padding: const EdgeInsets.all(5.0),
                      child: SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "ITEM: $name - CODIGO: $sku",
                                textAlign: TextAlign.center,
                              ),
                              InkWell(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ImageDetailsPage(item: img)));
                                },
                                child: Image.memory(base64.decode(img),
                                    width: 200,
                                    height: 200, errorBuilder: (_, __, ___) {
                                  return Image.asset('assets/not_found.png',
                                      fit: BoxFit.contain,
                                      width: 200,
                                      height: 200);
                                }),
                              ),
                              InkWell(
                                onTap: () async {
                                  // share product to another app
                                  final appDir = await getTemporaryDirectory();
                                  if (img.isNotEmpty) {
                                    Uint8List bytes = base64.decode(img);
                                    File file =
                                        File('${appDir.path}/image.png');
                                    await file.writeAsBytes(bytes);
                                    ShareResult result =
                                        await Share.shareXFiles(
                                            [XFile(file.path)],
                                            text: "ITEM: $name - CODIGO: $sku");
                                    if (result.status ==
                                        ShareResultStatus.success) {
                                      //print(
                                      //    'Success sharing file: ${result.status}');
                                      await file.delete();
                                    }
                                  } else {
                                    final assetImg = await rootBundle
                                        .load('assets/not_found.png');
                                    final buffer = assetImg.buffer;
                                    await Share.shareXFiles([
                                      XFile.fromData(
                                          buffer.asUint8List(
                                              assetImg.offsetInBytes,
                                              assetImg.lengthInBytes),
                                          name: name,
                                          mimeType: 'image/png')
                                    ], text: "$name - CODIGO: $sku");
                                  }
                                },
                                child:
                                    iconBtn(context, Icons.share, Colors.blue),
                              )
                            ]),
                      )))),
        );
      },
    );
  }

  Widget iconBtn(BuildContext context, IconData icon, Color color) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: color,
      child: Icon(
        icon,
        size: 29,
        color: Colors.white,
      ),
    );
  }

  Widget notFound() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      color: Colors.white,
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/not_found.png', height: 120, width: 100),
          const SizedBox(height: 20),
          const Text(
            'No hay datos',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
        ],
      )),
    );
  }

  Future<String> _loadSavedText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('tkn') ?? '';
  }
}
