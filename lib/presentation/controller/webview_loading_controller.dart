import 'package:get/get.dart';

class WebViewLoadingController extends GetxController {
  var isLoading = false.obs;

  void setLoading(bool value) {
    isLoading.value = value;
  }
}
