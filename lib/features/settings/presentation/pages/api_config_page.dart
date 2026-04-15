import "package:flutter/material.dart";
import "package:get/get.dart";
import "../../../../core/services/api_config_service.dart";

class ApiConfigPage extends StatefulWidget {
  const ApiConfigPage({super.key});

  @override
  State<ApiConfigPage> createState() => _ApiConfigPageState();
}

class _ApiConfigPageState extends State<ApiConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final ApiConfigService _apiConfigService = Get.find<ApiConfigService>();

  @override
  void initState() {
    super.initState();
    _controller.text = _apiConfigService.baseUrl;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await _apiConfigService.setBaseUrl(_controller.text);
    if (!mounted) return;
    Get.snackbar("Saved", "API base URL updated");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Config")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Backend Base URL",
                  hintText: "http://localhost:5002",
                ),
                validator: (value) {
                  final input = value?.trim() ?? "";
                  if (input.isEmpty) return "Base URL is required";
                  if (!input.startsWith("http://") && !input.startsWith("https://")) {
                    return "URL must start with http:// or https://";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                "Android emulator uses: http://10.0.2.2:5002",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
