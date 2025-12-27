import 'package:get/get.dart';
import '../Models/valoracion.dart';
import '../Services/valoracion_services.dart';
import '../Controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class ValoracionController extends GetxController {
  final ValoracionServices _valoracionServices = Get.put(ValoracionServices());

  var valoraciones = <Valoracion>[].obs;
  var myValoracion = Rxn<Valoracion>();
  var isLoading = false.obs;
  var isSubmitting = false.obs;

  var ratingScore = 0.0.obs;
  final TextEditingController commentController = TextEditingController();

  Future<void> loadRatings(String eventId) async {
    try {
      isLoading.value = true;

      final list = await _valoracionServices.getValoracionesEvento(eventId);
      valoraciones.assignAll(list);

      if (Get.find<AuthController>().isLoggedIn.value) {
        final myRating = await _valoracionServices.getUserValoracion(eventId);
        myValoracion.value = myRating;
        if (myRating != null) {
          ratingScore.value = myRating.puntuacion.toDouble();
          commentController.text = myRating.comentario;
        } else {
          ratingScore.value = 0.0;
          commentController.clear();
        }
      }
    } catch (e) {
      print('Error cargando valoraciones: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitRating(String eventId) async {
    if (ratingScore.value < 1) {
      Get.snackbar(
        'Error',
        'Por favor selecciona una puntuación',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      Valoracion nueva;

      if (myValoracion.value != null) {
        nueva = await _valoracionServices.updateValoracion(
          myValoracion.value!.id,
          ratingScore.value,
          commentController.text,
        );
      } else {
        nueva = await _valoracionServices.createValoracion(
          eventId,
          ratingScore.value,
          commentController.text,
        );
      }

      myValoracion.value = nueva;

      if (valoraciones.any((v) => v.id == nueva.id)) {
        final index = valoraciones.indexWhere((v) => v.id == nueva.id);
        valoraciones[index] = nueva;
      } else {
        valoraciones.add(nueva);
      }

      valoraciones.refresh();

      loadRatings(eventId);

      Get.back();
      Get.snackbar(
        'Éxito',
        'Valoración guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar la valoración: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteRating(String eventId) async {
    if (myValoracion.value == null) return;
    try {
      isSubmitting.value = true;
      await _valoracionServices.deleteValoracion(myValoracion.value!.id);

      myValoracion.value = null;
      ratingScore.value = 0.0;
      commentController.clear();

      await loadRatings(eventId);

      Get.back();
      Get.snackbar(
        'Éxito',
        'Valoración eliminada',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
