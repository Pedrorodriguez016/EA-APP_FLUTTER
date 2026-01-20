import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter_translate/flutter_translate.dart';
import '../Services/geocoding_service.dart';

class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Function(double lat, double lon)? onLocationSelected;
  final String? countryCode;

  const AddressAutocompleteField({
    super.key,
    required this.controller,
    this.validator,
    this.onLocationSelected,
    this.countryCode = 'es', // Por defecto España
  });

  @override
  State<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  final GeocodingService _geocodingService = GeocodingService();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<AddressSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  Timer? _debounce;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final query = widget.controller.text.trim();

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      _removeOverlay();
      return;
    }

    // Debounce de 500ms para no hacer demasiadas peticiones
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchAddress(query);
    });
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Pequeño delay para permitir clicks en las sugerencias
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _showSuggestions = false);
          _removeOverlay();
        }
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.length < 3) return; // Mínimo 3 caracteres

    setState(() => _isLoading = true);

    final suggestions = await _geocodingService.searchAddress(
      query,
      countryCode: widget.countryCode,
      limit: 5,
    );

    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
        _showSuggestions = suggestions.isNotEmpty;
      });

      if (_showSuggestions) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.width - 48, // Ancho del campo menos padding
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // Debajo del campo
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.theme.dividerColor, width: 1),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: context.theme.dividerColor),
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  final isValid = suggestion.isValid;

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      _getIconForType(suggestion.type),
                      color: isValid
                          ? context.theme.colorScheme.primary
                          : context.theme.hintColor,
                      size: 20,
                    ),
                    title: Text(
                      suggestion.displayName,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isValid
                            ? context.theme.colorScheme.onSurface
                            : context.theme.hintColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: isValid
                        ? (suggestion.city != null
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        translate('address.complete'),
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(color: Colors.green),
                                      ),
                                    ),
                                  ],
                                )
                              : null)
                        : Row(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                size: 14,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  translate(
                                    'address.incomplete',
                                    args: {
                                      'components': suggestion.missingComponents
                                          .join(", "),
                                    },
                                  ),
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                    trailing: isValid
                        ? Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: context.theme.colorScheme.primary,
                          )
                        : null,
                    onTap: isValid
                        ? () => _selectSuggestion(suggestion)
                        : () => _showInvalidAddressDialog(context, suggestion),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectSuggestion(AddressSuggestion suggestion) {
    widget.controller.text = suggestion.displayName;

    // Notificar las coordenadas seleccionadas
    widget.onLocationSelected?.call(suggestion.lat, suggestion.lon);

    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });

    _removeOverlay();
    _focusNode.unfocus();
  }

  void _showInvalidAddressDialog(
    BuildContext context,
    AddressSuggestion suggestion,
  ) {
    _removeOverlay();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                translate('address.incomplete_title'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate('address.incomplete_info'),
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translate('address.missing_label'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  ...suggestion.missingComponents.map(
                    (component) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(Icons.close, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(component, style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              translate('address.specific_hint'),
              style: TextStyle(fontSize: 13, color: context.theme.hintColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(translate('address.understood')),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'road':
      case 'street':
        return Icons.route_rounded;
      case 'city':
      case 'town':
      case 'village':
        return Icons.location_city_rounded;
      case 'building':
      case 'house':
        return Icons.home_rounded;
      case 'amenity':
        return Icons.place_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: 3,
          style: context.textTheme.bodyLarge,
          validator: widget.validator,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_on_rounded,
              color: context.theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            suffixIcon: _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.theme.colorScheme.primary,
                      ),
                    ),
                  )
                : widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _suggestions = [];
                        _showSuggestions = false;
                      });
                      _removeOverlay();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            hintText: translate('address.write_address'),
            hintStyle: TextStyle(color: context.theme.hintColor),
          ),
        ),
      ),
    );
  }
}
