
import 'dart:io';
import 'package:aes_crypt/aes_crypt.dart';
class encrypt_decrypt{
int encryptFiles(String key,String loc,List <File> files) {
    var crypt = AesCrypt(key);
    crypt.setOverwriteMode(AesCryptOwMode.rename);
    for (File file  in files) {
      int len=file.path.split('/').length;
      String fileName=file.path.split('/')[len-1];
      String filePath=loc+'/'+fileName+".aes";
      crypt.encryptFileSync(file.path,filePath);
    }
      return 0;
  }
int decryptFiles(String key,String loc,List <File> files) {
  var crypt = AesCrypt(key);
  crypt.setOverwriteMode(AesCryptOwMode.rename);
  for (File file  in files) {
    int len=file.path.split('/').length;
    String fileName=file.path.split('/')[len-1];
    String filePath=loc+'/'+fileName;
    filePath.replaceFirst('.aes','');
    try{
      crypt.decryptFileSync(file.path,filePath);
    }
    on Exception{
      return 1;
    }
  }
  return 0;
}
}