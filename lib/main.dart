import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:encrypt_files/encrypt_decrypt.dart';

void main() {
  runApp(MaterialApp(
      home:MyHomePage(),
          title:"AES Encryptor-Decryptor",
    debugShowCheckedModeBanner: false,
  )
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List <File> files=[];
  String loc='';
  String selectedOption='';
  bool fileCorrupt=false;
  Directory rootPath=Directory(FolderPicker.ROOTPATH);
  Future<FilePickerResult?> getLocalFiles(String val,BuildContext context) async
  {
    late FilePickerResult? result;
    if (val == 'Decrypt') {
      result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        files = result.paths.map((path) => File(path!)).toList();
        for (File extCheck in files) {
          String ext=extCheck.path;
          ext.replaceFirst(extCheck.path,".aes");
          if (!(extCheck.path.endsWith(".aes"))) {
            await showError(context,"Please select .aes files","Error!");
           fileCorrupt=true;
           break;
          }
          if(!(ext.contains('.'))){
            await showError(context,"File format not supported","Error!");
            fileCorrupt=true;
            break;
          }
        }
      }
    }
      else
        result = await FilePicker.platform.pickFiles(allowMultiple: true);
    return result;
  }
   Future<String> getStorageLoc(BuildContext context) async
  {
    Directory? folder= await FolderPicker.pick(
        allowFolderCreation:true,
        barrierDismissible: false,
        context:context,
        rootDirectory:rootPath,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))));
    return folder!.path;
  }
  Future<void> showMsg (BuildContext context,String err,String msg) async
  {
  await showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context){
    Future.delayed(Duration(seconds:2), () {
      Navigator.of(context).pop(true);
    });
  return AlertDialog(
  title: Text(msg),
  content:Text(err),
  );
  }
  );
}
  Future<void> showError(BuildContext context,String err,String msg) async
  {
     await showDialog(
         context: context,
         barrierDismissible: false,
         builder: (context){
           return AlertDialog(
             title: Text(msg),
             content:Text(err),
             actions:<Widget>[
               TextButton(
                   onPressed:() {
                     Navigator.of(context).pop();
                   },
                   child:Text("OK")),
             ],

           );
         }
           );
  }
  Future<String> getKeys(String act,BuildContext context) async{
    String password='';
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title:Text('Enter '+act+' Key'),
            content:TextField(
              obscureText:true,
              onChanged:(key){
                password=key;
              },
            ),
            actions:<Widget>[
              TextButton(
                  onPressed:() {
                    Navigator.of(context).pop(password);
                  },
                  child:Text("Submit")),
            ],
            // TextField(
            //     obscureText:true,
            // ),
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    //   title:"AES Encryptor-Decryptor",
     return Scaffold(
        appBar:AppBar(
          title:Text("AES Encryptor-Decryptor"),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment:CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height:50),
            Center(
                  child: Container(
                    width:150,
                    height:40,
                    child: ElevatedButton(
                        onPressed: () async{
                          FilePickerResult? filePath= await getLocalFiles('Encrypt',context);
                          if(filePath!= null) {
                            files = filePath.paths.map((path) => File(path!)).toList();
                            String dirPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOCUMENTS);
                            rootPath=Directory(dirPath);
                          }
                          if(files.isNotEmpty)
                            {
                              String key="";
                              key=await getKeys("Encryption",context);
                              if(key!="") {
                                loc=await getStorageLoc(context);
                                if(loc != '')
                                {
                                  await showMsg(context,"Please wait","Wait!");
                                  encrypt_decrypt obj=encrypt_decrypt();
                                  int value=obj.encryptFiles(key, loc, files);
                                  if (value==0) {
                                    showError(
                                        context, "Files encrypted successfully",
                                        "Success!");
                                    files=[];
                                  }
                                }
                              }
                              else{
                                await showError(context,'Invalid Key',"Error!");
                              }

                            }
                        },
                        child: Text('Encrypt Files')),
                  ),
                ),
              SizedBox(height: 10),
              Center(
                child: Container(
                  width:150,
                  height:40,
                  child: ElevatedButton(
                      onPressed: () async{
                        FilePickerResult? filePath= await getLocalFiles('Decrypt',context);
                        if(filePath!= null) {
                          files = filePath.paths.map((path) => File(path!))
                              .toList();
                          String dirPath = await ExternalPath
                              .getExternalStoragePublicDirectory(
                              ExternalPath.DIRECTORY_DOCUMENTS);
                          rootPath = Directory(dirPath);
                        }
                        if(files.isNotEmpty && fileCorrupt!=true)
                        {
                          String key="";
                          key=await getKeys("Decryption",context);
                          if(key!="") {
                            loc=await getStorageLoc(context);
                            if(loc != '')
                            {
                              await showMsg(context,"Please wait","Wait!");
                              encrypt_decrypt obj=encrypt_decrypt();
                              int value=(obj.decryptFiles(key, loc, files));
                              if (value==0) {
                                showError(
                                    context, "Files decrypted successfully",
                                    "Success!");
                                files=[];
                              }
                              else
                                showError(context,"Invalid Key","Error!");
                            }
                          }

                        }
                      },
                      child: Text('Decrypt Files')),
                ),
              ),
            ],
          ),
        ),
      );
  }
}


