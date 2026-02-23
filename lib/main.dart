 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/lib/main.dart b/lib/main.dart
new file mode 100644
index 0000000000000000000000000000000000000000..991aad1e1575882bf206747622b9173aaa37c77e
--- /dev/null
+++ b/lib/main.dart
@@ -0,0 +1,407 @@
+import 'dart:math';
+
+import 'package:flutter/material.dart';
+import 'package:google_maps_flutter/google_maps_flutter.dart';
+import 'package:url_launcher/url_launcher.dart';
+
+void main() {
+  runApp(const FamilyPlacesApp());
+}
+
+class FamilyPlacesApp extends StatelessWidget {
+  const FamilyPlacesApp({super.key});
+
+  @override
+  Widget build(BuildContext context) {
+    return MaterialApp(
+      debugShowCheckedModeBanner: false,
+      title: 'Lugares para niños - Washington',
+      theme: ThemeData(
+        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
+        useMaterial3: true,
+      ),
+      home: const PlacesMapScreen(),
+    );
+  }
+}
+
+class Place {
+  const Place({
+    required this.id,
+    required this.name,
+    required this.description,
+    required this.schedule,
+    required this.imageUrl,
+    required this.lat,
+    required this.lng,
+    required this.reviews,
+  });
+
+  final String id;
+  final String name;
+  final String description;
+  final String schedule;
+  final String imageUrl;
+  final double lat;
+  final double lng;
+  final List<Review> reviews;
+
+  double get rating =>
+      reviews.isEmpty ? 0 : reviews.map((r) => r.stars).reduce((a, b) => a + b) / reviews.length;
+}
+
+class Review {
+  const Review({required this.author, required this.comment, required this.stars});
+
+  final String author;
+  final String comment;
+  final int stars;
+}
+
+class PlacesMapScreen extends StatefulWidget {
+  const PlacesMapScreen({super.key});
+
+  @override
+  State<PlacesMapScreen> createState() => _PlacesMapScreenState();
+}
+
+class _PlacesMapScreenState extends State<PlacesMapScreen> {
+  final List<Place> _places = [
+    const Place(
+      id: 'seattle-children-museum',
+      name: 'Seattle Children\'s Museum',
+      description: 'Museo interactivo para niños de 0 a 10 años con actividades educativas.',
+      schedule: 'Lun-Dom: 9:00 AM - 5:00 PM',
+      imageUrl:
+          'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=1200&q=80',
+      lat: 47.6212,
+      lng: -122.3517,
+      reviews: [
+        Review(author: 'Ana', comment: 'Muy limpio y divertido para los peques.', stars: 5),
+        Review(author: 'Jorge', comment: 'Excelente para días de lluvia.', stars: 4),
+      ],
+    ),
+    const Place(
+      id: 'point-defiance-zoo',
+      name: 'Point Defiance Zoo & Aquarium',
+      description: 'Zoológico y acuario con espacios abiertos para toda la familia.',
+      schedule: 'Lun-Dom: 9:30 AM - 4:00 PM',
+      imageUrl:
+          'https://images.unsplash.com/photo-1546182990-dffeafbe841d?auto=format&fit=crop&w=1200&q=80',
+      lat: 47.3054,
+      lng: -122.5167,
+      reviews: [
+        Review(author: 'Carla', comment: 'Los niños amaron los pingüinos.', stars: 5),
+        Review(author: 'Luis', comment: 'Hay buenas áreas de descanso.', stars: 4),
+        Review(author: 'Marta', comment: 'Recomiendo llevar carrito.', stars: 4),
+      ],
+    ),
+    const Place(
+      id: 'spokane-riverfront',
+      name: 'Riverfront Park Spokane',
+      description: 'Parque con áreas de juego, paseo en teleférico y eventos familiares.',
+      schedule: 'Lun-Dom: 6:00 AM - 10:00 PM',
+      imageUrl:
+          'https://images.unsplash.com/photo-1508261305438-4d0f2bff2f02?auto=format&fit=crop&w=1200&q=80',
+      lat: 47.6623,
+      lng: -117.4233,
+      reviews: [
+        Review(author: 'Pilar', comment: 'Perfecto para picnic y correr.', stars: 5),
+      ],
+    ),
+  ];
+
+  final LatLng _userLocation = const LatLng(47.6062, -122.3321);
+  Place? _selectedPlace;
+
+  Set<Marker> get _markers {
+    return {
+      Marker(
+        markerId: const MarkerId('user-location'),
+        position: _userLocation,
+        infoWindow: const InfoWindow(title: 'Tu ubicación (demo)'),
+        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
+      ),
+      ..._places.map(
+        (place) => Marker(
+          markerId: MarkerId(place.id),
+          position: LatLng(place.lat, place.lng),
+          infoWindow: InfoWindow(
+            title: place.name,
+            snippet: 'Horario: ${place.schedule}',
+            onTap: () => _openPlaceDetails(place),
+          ),
+          onTap: () => _openPlaceDetails(place),
+        ),
+      ),
+    };
+  }
+
+  Set<Polyline> get _route {
+    if (_selectedPlace == null) return {};
+
+    final destination = LatLng(_selectedPlace!.lat, _selectedPlace!.lng);
+
+    return {
+      Polyline(
+        polylineId: const PolylineId('route-line'),
+        points: [_userLocation, destination],
+        color: Colors.teal,
+        width: 5,
+      ),
+    };
+  }
+
+  void _openPlaceDetails(Place place) {
+    setState(() {
+      _selectedPlace = place;
+    });
+
+    showModalBottomSheet<void>(
+      context: context,
+      isScrollControlled: true,
+      builder: (_) => PlaceDetailsSheet(
+        place: place,
+        onGetRoute: () => _launchMapsDirections(place),
+      ),
+    );
+  }
+
+  Future<void> _launchMapsDirections(Place place) async {
+    final mapsUrl = Uri.parse(
+      'https://www.google.com/maps/dir/?api=1&origin=${_userLocation.latitude},${_userLocation.longitude}&destination=${place.lat},${place.lng}&travelmode=driving',
+    );
+
+    if (!await launchUrl(mapsUrl, mode: LaunchMode.externalApplication)) {
+      if (!mounted) return;
+      ScaffoldMessenger.of(context).showSnackBar(
+        const SnackBar(content: Text('No se pudo abrir Google Maps.')),
+      );
+    }
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    return Scaffold(
+      appBar: AppBar(
+        title: const Text('Lugares para niños en Washington'),
+      ),
+      body: Stack(
+        children: [
+          GoogleMap(
+            initialCameraPosition: const CameraPosition(
+              target: LatLng(47.6062, -122.3321),
+              zoom: 7,
+            ),
+            markers: _markers,
+            polylines: _route,
+            myLocationEnabled: false,
+            myLocationButtonEnabled: false,
+          ),
+          if (_selectedPlace != null)
+            Positioned(
+              left: 16,
+              right: 16,
+              top: 16,
+              child: Card(
+                child: ListTile(
+                  leading: const Icon(Icons.place),
+                  title: Text(_selectedPlace!.name),
+                  subtitle: Text(
+                    'Ruta mostrada • ${_selectedPlace!.rating.toStringAsFixed(1)} ★',
+                  ),
+                  trailing: IconButton(
+                    icon: const Icon(Icons.clear),
+                    onPressed: () => setState(() => _selectedPlace = null),
+                  ),
+                ),
+              ),
+            ),
+        ],
+      ),
+    );
+  }
+}
+
+class PlaceDetailsSheet extends StatefulWidget {
+  const PlaceDetailsSheet({
+    super.key,
+    required this.place,
+    required this.onGetRoute,
+  });
+
+  final Place place;
+  final VoidCallback onGetRoute;
+
+  @override
+  State<PlaceDetailsSheet> createState() => _PlaceDetailsSheetState();
+}
+
+class _PlaceDetailsSheetState extends State<PlaceDetailsSheet> {
+  final _authorController = TextEditingController();
+  final _commentController = TextEditingController();
+  int _stars = 5;
+  late List<Review> _reviews;
+
+  @override
+  void initState() {
+    super.initState();
+    _reviews = [...widget.place.reviews];
+  }
+
+  @override
+  void dispose() {
+    _authorController.dispose();
+    _commentController.dispose();
+    super.dispose();
+  }
+
+  double get _rating => _reviews.isEmpty
+      ? 0
+      : _reviews.map((r) => r.stars).reduce((a, b) => a + b) / _reviews.length;
+
+  void _submitReview() {
+    if (_authorController.text.trim().isEmpty || _commentController.text.trim().isEmpty) {
+      ScaffoldMessenger.of(context).showSnackBar(
+        const SnackBar(content: Text('Completa nombre y reseña.')),
+      );
+      return;
+    }
+
+    setState(() {
+      _reviews.insert(
+        0,
+        Review(
+          author: _authorController.text.trim(),
+          comment: _commentController.text.trim(),
+          stars: _stars,
+        ),
+      );
+      _authorController.clear();
+      _commentController.clear();
+      _stars = 5;
+    });
+  }
+
+  @override
+  Widget build(BuildContext context) {
+    return DraggableScrollableSheet(
+      expand: false,
+      initialChildSize: 0.85,
+      minChildSize: 0.45,
+      maxChildSize: 0.95,
+      builder: (_, scrollController) {
+        return Padding(
+          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
+          child: ListView(
+            controller: scrollController,
+            children: [
+              ClipRRect(
+                borderRadius: BorderRadius.circular(16),
+                child: AspectRatio(
+                  aspectRatio: 16 / 9,
+                  child: Image.network(
+                    widget.place.imageUrl,
+                    fit: BoxFit.cover,
+                    errorBuilder: (_, __, ___) => const ColoredBox(
+                      color: Colors.black12,
+                      child: Center(child: Icon(Icons.broken_image, size: 50)),
+                    ),
+                  ),
+                ),
+              ),
+              const SizedBox(height: 12),
+              Text(widget.place.name, style: Theme.of(context).textTheme.headlineSmall),
+              const SizedBox(height: 8),
+              Text(widget.place.description),
+              const SizedBox(height: 8),
+              Row(
+                children: [
+                  const Icon(Icons.schedule, size: 18),
+                  const SizedBox(width: 6),
+                  Expanded(child: Text(widget.place.schedule)),
+                ],
+              ),
+              const SizedBox(height: 8),
+              Row(
+                children: [
+                  const Icon(Icons.star, color: Colors.amber),
+                  const SizedBox(width: 6),
+                  Text('${_rating.toStringAsFixed(1)} (${_reviews.length} reseñas)'),
+                  const Spacer(),
+                  FilledButton.icon(
+                    onPressed: widget.onGetRoute,
+                    icon: const Icon(Icons.directions),
+                    label: const Text('Cómo llegar'),
+                  ),
+                ],
+              ),
+              const Divider(height: 24),
+              Text('Agregar reseña', style: Theme.of(context).textTheme.titleMedium),
+              const SizedBox(height: 8),
+              TextField(
+                controller: _authorController,
+                decoration: const InputDecoration(
+                  labelText: 'Tu nombre',
+                  border: OutlineInputBorder(),
+                ),
+              ),
+              const SizedBox(height: 8),
+              TextField(
+                controller: _commentController,
+                maxLines: 3,
+                decoration: const InputDecoration(
+                  labelText: 'Tu reseña',
+                  border: OutlineInputBorder(),
+                ),
+              ),
+              const SizedBox(height: 8),
+              DropdownButtonFormField<int>(
+                initialValue: _stars,
+                decoration: const InputDecoration(
+                  labelText: 'Puntuación',
+                  border: OutlineInputBorder(),
+                ),
+                items: List.generate(
+                  5,
+                  (index) {
+                    final value = index + 1;
+                    return DropdownMenuItem(
+                      value: value,
+                      child: Text('$value estrella${value > 1 ? 's' : ''}'),
+                    );
+                  },
+                ),
+                onChanged: (value) {
+                  setState(() {
+                    _stars = max(1, value ?? 5);
+                  });
+                },
+              ),
+              const SizedBox(height: 8),
+              FilledButton(
+                onPressed: _submitReview,
+                child: const Text('Enviar reseña'),
+              ),
+              const Divider(height: 24),
+              Text('Reseñas', style: Theme.of(context).textTheme.titleMedium),
+              const SizedBox(height: 8),
+              if (_reviews.isEmpty)
+                const Text('Todavía no hay reseñas para este lugar.')
+              else
+                ..._reviews.map(
+                  (review) => Card(
+                    child: ListTile(
+                      title: Text(review.author),
+                      subtitle: Text(review.comment),
+                      trailing: Text('${review.stars} ★'),
+                    ),
+                  ),
+                ),
+            ],
+          ),
+        );
+      },
+    );
+  }
+}
 
EOF
)
