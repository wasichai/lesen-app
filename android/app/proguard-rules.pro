# Reglas de R8 para la release. Flutter y los plugins traen las suyas; aquí solo lo propio de la app.
# audio_service y just_audio usan reflexión para el servicio y la sesión multimedia.
-keep class com.ryanheise.** { *; }
# flutter_local_notifications serializa las notificaciones programadas con Gson.
-keep class com.dexterous.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
