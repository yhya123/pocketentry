import 'package:get/get.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';
import 'package:pocketentry/routes/app_routes.dart';

class PersonSearchController extends GetxController {
  final PersonUseCases _personUseCases = Get.find();

  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final persons = <PersonEntity>[].obs;

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.trim().length < 2) {
      persons.clear();
      return;
    }
    search();
  }

  Future<void> search() async {
    try {
      isLoading.value = true;
      persons.value = await _personUseCases.getAll(query: searchQuery.value);
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void openPerson(PersonEntity person) {
    Get.toNamed(AppRoutes.personDetail, arguments: {'personId': person.id});
  }
}
