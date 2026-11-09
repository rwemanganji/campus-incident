import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

/// Form to submit a new incident: category, title, description, location, optional photo.
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});
  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  String? _category;
  String? _location;
  File? _photo;
  bool _anonymous = false;
  bool _categoryError = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final x = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1600);
    if (x != null) setState(() => _photo = File(x.path));
  }

  void _photoSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () { Navigator.pop(ctx); _pick(ImageSource.camera); },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () { Navigator.pop(ctx); _pick(ImageSource.gallery); },
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    final formOk = _form.currentState!.validate();
    setState(() => _categoryError = _category == null);
    if (!formOk || _category == null) return;

    final provider = context.read<IncidentProvider>();
    final ok = await provider.submit(
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category!,
      location: _location!,
      anonymous: _anonymous,
      photo: _photo,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(ok ? 'Report submitted' : (provider.error ?? 'Could not submit'))));
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<IncidentProvider>().submitting;
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Select a category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in AppConstants.categories)
                  ChoiceChip(
                    avatar: Icon(AppConstants.categoryIcon(c), size: 18),
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) => setState(() { _category = c; _categoryError = false; }),
                  ),
              ]),
              if (_categoryError)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Please choose a category', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _title,
                maxLength: 80,
                decoration: const InputDecoration(labelText: 'Title', hintText: 'Briefly describe the issue'),
                validator: (v) => Validators.minLength(v, 5, 'Title'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _description,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What happened, when, and what is the impact?',
                  alignLabelWithHint: true,
                ),
                validator: (v) => Validators.minLength(v, 10, 'Description'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on_outlined)),
                items: [for (final l in AppConstants.locations) DropdownMenuItem(value: l, child: Text(l))],
                onChanged: (v) => _location = v,
                validator: (v) => v == null ? 'Please choose a location' : null,
              ),
              const SizedBox(height: 20),
              const Text('Add a photo (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _photoSheet,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _photo == null
                      ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.add_a_photo_outlined),
                          SizedBox(height: 4),
                          Text('Tap to add photo'),
                        ])
                      : Stack(fit: StackFit.expand, children: [
                          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_photo!, fit: BoxFit.cover)),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton.filledTonal(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _photo = null),
                            ),
                          ),
                        ]),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Report anonymously'),
                subtitle: const Text('Other students will not see your name. Staff still can.'),
                value: _anonymous,
                onChanged: (v) => setState(() => _anonymous = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: submitting ? null : _submit,
                  child: submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit Report'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
