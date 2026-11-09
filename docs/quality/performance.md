# Rendimiento

| Riesgo                                         | Medida                                                                                                                          |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Reconstruir el lector con cada evento de audio | Posición y palabra activa por `ValueNotifier`; cada párrafo escucha y se reconstruye solo si es el suyo (prueba que lo cuenta). |
| Buscar la palabra activa                       | Búsqueda binaria sobre tiempos ordenados, `O(log n)`; solo notifica al cambiar de palabra.                                      |
| Documentos largos                              | `ListView.builder` con caché de 1600 px; los párrafos fuera de pantalla no existen.                                             |
| Reiniciar el audio al reconstruir              | El manejador de audio vive fuera del árbol de widgets.                                                                          |
| Desplazamiento automático                      | Solo si la oración sale de la vista y nunca durante 4 s tras desplazar a mano.                                                  |
| Imágenes                                       | Portadas SVG pequeñas, en memoria durante la sesión y en archivo para sin conexión.                                             |
| Red                                            | Lo inmutable se pide una vez; la cola colapsa el progreso (una petición por lectura, no una por oración).                       |
| Batería                                        | Sin tareas en segundo plano salvo el audio; la cola se vacía en momentos concretos y cada minuto solo con la app abierta.       |
| Base local                                     | SQLite en un hilo aparte (`createInBackground`).                                                                                |

**Sin medir todavía en dispositivos reales**: arranque en frío, fotogramas en el lector a 1,5× con resaltado, memoria
con lecturas largas y consumo de batería escuchando 30 minutos con la pantalla bloqueada. Se miden con
`flutter run --profile` y DevTools en un Android de gama media y un iPhone, y el resultado se anota aquí.
