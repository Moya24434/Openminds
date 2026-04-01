import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/session_model.dart';
import '../../services/admin_service.dart';
import '../../services/user_prefs.dart';
import 'package:geocoding/geocoding.dart';

class EditSessionPage extends StatefulWidget {
  final Session session;

  const EditSessionPage({super.key, required this.session});

  @override
  State<EditSessionPage> createState() => _EditSessionPageState();
}

class _EditSessionPageState extends State<EditSessionPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lieuController;
  final AdminService _adminService = AdminService();

  late String _selectedType;
  DateTime? _selectedDateDebut;
  TimeOfDay? _selectedTimeDebut;
  DateTime? _selectedDateFin; // The API needs DateFin, but SessionModel doesn't have it natively returned by default, we just default to +1h
  TimeOfDay? _selectedTimeFin;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _lieuController = TextEditingController(text: widget.session.adresse);
    _selectedType = widget.session.typeSession;
    _selectedDateDebut = widget.session.dateDebut;
    _selectedDateFin = widget.session.dateFin;
    _selectedTimeDebut = TimeOfDay(hour: widget.session.dateDebut.hour, minute: widget.session.dateDebut.minute);
    _selectedTimeFin = TimeOfDay(hour: widget.session.dateFin.hour, minute: widget.session.dateFin.minute);


    // Default Fin to +2 hour if not available
    final finDate = widget.session.dateFin.add(const Duration(hours: 2));
    _selectedDateFin = finDate;
    _selectedTimeFin = TimeOfDay(hour: finDate.hour, minute: finDate.minute);
  }

  Future<void> _pickDate({required bool isDebut}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isDebut ? _selectedDateDebut : _selectedDateFin) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isDebut) _selectedDateDebut = picked;
        else _selectedDateFin = picked;
      });
    }
  }

  Future<void> _pickTime({required bool isDebut}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isDebut ? _selectedTimeDebut : _selectedTimeFin) ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isDebut) _selectedTimeDebut = picked;
        else _selectedTimeFin = picked;
      });
    }
  }

  Future<void> _submitUpdate() async {
    // 1. Validation du formulaire
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateDebut == null || _selectedTimeDebut == null ||
        _selectedDateFin == null || _selectedTimeFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner les dates et heures"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Récupération de l'ID Admin
    final int? userId = await UserPrefs.getUserId();
    if (userId == null) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Administrateur non identifié"), backgroundColor: Colors.red)
      );
      return;
    }

    // --- ÉTAPE GEOCODING : Mise à jour des coordonnées ---
    double latitude = 0.0;
    double longitude = 0.0;

    if (_selectedType == 'Présentiel') {
      try {
        // On transforme l'adresse (peut-être nouvelle) en coordonnées
        List<Location> locations = await locationFromAddress(_lieuController.text.trim());
        if (locations.isNotEmpty) {
          latitude = locations.first.latitude;
          longitude = locations.first.longitude;
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("📍 Impossible de localiser cette adresse. Vérifiez l'orthographe."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // 3. Formatage des dates
    final dateTimeDebut = DateTime(
        _selectedDateDebut!.year, _selectedDateDebut!.month, _selectedDateDebut!.day,
        _selectedTimeDebut!.hour, _selectedTimeDebut!.minute
    );
    final dateTimeFin = DateTime(
        _selectedDateFin!.year, _selectedDateFin!.month, _selectedDateFin!.day,
        _selectedTimeFin!.hour, _selectedTimeFin!.minute
    );

    final formattedDebut = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeDebut);
    final formattedFin = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeFin);

    // 4. Appel au service de mise à jour (avec les nouveaux paramètres Lat/Lng)
    final success = await _adminService.updateSession(
      userId,
      widget.session.idSession,
      widget.session.formation?.idFormation ?? 0,
      _selectedType,
      _lieuController.text.trim(),
      formattedDebut,
      formattedFin,
      latitude,  // Transmis au service
      longitude, // Transmis au service
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Session modifiée avec succès"), backgroundColor: Colors.green)
      );
      Navigator.pop(context, true); // On renvoie true pour rafraîchir la liste précédente
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la modification"), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFF004AAD)),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Modifier Session", style: TextStyle(color: Color(0xFF004AAD), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Date et Heure (Début)"),
              const SizedBox(height: 8),
              _buildDateTimeRow(date: _selectedDateDebut, time: _selectedTimeDebut, onDate: () => _pickDate(isDebut: true), onTime: () => _pickTime(isDebut: true)),
              const SizedBox(height: 20),

              _buildLabel("Date et Heure (Fin)"),
              const SizedBox(height: 8),
              _buildDateTimeRow(date: _selectedDateFin, time: _selectedTimeFin, onDate: () => _pickDate(isDebut: false), onTime: () => _pickTime(isDebut: false)),
              const SizedBox(height: 20),

              _buildLabel("Type de session"),
              const SizedBox(height: 8),
              Row(
                children: ['Présentiel', 'En ligne'].map((type) {
                  final isSelected = _selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        margin: EdgeInsets.only(right: type == 'Présentiel' ? 5 : 0, left: type == 'En ligne' ? 5 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF004AAD) : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: isSelected ? const Color(0xFF004AAD) : Colors.grey[300]!),
                        ),
                        child: Center(child: Text(type, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _buildLabel("Lieu / Lien"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lieuController,
                validator: (val) => val == null || val.trim().isEmpty ? "Obligatoire" : null,
                decoration: InputDecoration(
                  hintText: "Lieu ou lien Zoom",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _isLoading ? null : _submitUpdate,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SAUVEGARDER", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));

  Widget _buildDateTimeRow({required DateTime? date, required TimeOfDay? time, required VoidCallback onDate, required VoidCallback onTime}) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onDate,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
              child: Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : "Date"),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: onTime,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
              child: Text(time != null ? time.format(context) : "Heure"),
            ),
          ),
        ),
      ],
    );
  }
}
