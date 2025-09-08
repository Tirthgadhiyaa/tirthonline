// lib/screens/buyer_panel/saved_search/manager_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../bloc/saved_search_bloc/saved_search_event.dart';
import '../../../bloc/saved_search_bloc/saved_search_state.dart';
import '../../../models/saved_search_model.dart';
import '../../../bloc/saved_search_bloc/saved_search_bloc.dart';
import '../../../services/api/saved_search_service.dart';
import 'saved_search_form_screen.dart';

class SavedSearchManagerScreen extends StatelessWidget {
  static const String routeName = '/saved-searches';
  const SavedSearchManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SavedSearchBloc(SavedSearchService())..add(FetchSavedSearches()),
      child: const _SavedSearchManagerBody(),
    );
  }
}

class _SavedSearchManagerBody extends StatefulWidget {
  const _SavedSearchManagerBody({super.key});

  @override
  State<_SavedSearchManagerBody> createState() =>
      _SavedSearchManagerBodyState();
}

class _SavedSearchManagerBodyState extends State<_SavedSearchManagerBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<SavedSearchModel> _searches = [];
  SavedSearchModel? _selectedSearch;
  bool _isLoading = true;
  bool _isSaving = false;
  final GlobalKey<SavedSearchFormScreenState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedSearchBloc>().add(FetchSavedSearches());
    });
  }

  void _onSearchSelected(SavedSearchModel? search) {
    setState(() {
      _selectedSearch = search;
    });
    // Update the form below
    _formKey.currentState?.setFromModel(search);
  }

  void _onSave() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.isFormValid) return;
    setState(() => _isSaving = true);
    final model = formState.toModel(_selectedSearch);
    if (_selectedSearch == null) {
      context.read<SavedSearchBloc>().add(CreateSavedSearch(model));
    } else {
      context.read<SavedSearchBloc>().add(UpdateSavedSearch(model));
    }
  }

  void _onDelete() {
    if (_selectedSearch != null) {
      context
          .read<SavedSearchBloc>()
          .add(DeleteSavedSearch(_selectedSearch!.id));
      setState(() => _selectedSearch = null);
      _formKey.currentState?.setFromModel(null);
    }
  }

  void _onReset() {
    setState(() => _selectedSearch = null);
    _formKey.currentState?.setFromModel(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: BlocConsumer<SavedSearchBloc, SavedSearchState>(
          listener: (context, state) {
            if (state is SavedSearchLoaded) {
              setState(() {
                _searches = state.searches;
                _isLoading = false;
                if (_selectedSearch != null) {
                  // Refresh selected search from list
                  final updated = _searches.firstWhere(
                    (s) => s.id == _selectedSearch!.id,
                    orElse: () => _selectedSearch!,
                  );
                  _selectedSearch = updated;
                  _formKey.currentState?.setFromModel(updated);
                }
              });
            } else if (state is SavedSearchActionSuccess) {
              setState(() {
                _selectedSearch = null;
                _formKey.currentState?.setFromModel(null);
                _isSaving = false;
              });
              context.read<SavedSearchBloc>().add(FetchSavedSearches());
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                Expanded(
                  child: SavedSearchFormScreen(
                    key: _formKey,
                    initialSearch: _selectedSearch,
                    onCancel: _onReset,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Icon and title
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              FontAwesomeIcons.bookmark,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved Filters',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your saved filters for quick access',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Right: Dropdown and action buttons
          Row(
            children: [
              SizedBox(
                width: 280,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.grey.shade400, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: theme.colorScheme.primary, width: 1.8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          suffixIcon: _selectedSearch != null
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.grey),
                                  tooltip: 'Clear selection',
                                  onPressed: _onReset,
                                )
                              : null,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SavedSearchModel?>(
                            isExpanded: true,
                            value: _selectedSearch,
                            hint: const Text('Select a saved filter'),
                            items: [
                              const DropdownMenuItem<SavedSearchModel?>(
                                value: null,
                                child: Text('+ New Filter'),
                              ),
                              ..._searches.map(
                                  (s) => DropdownMenuItem<SavedSearchModel?>(
                                        value: s,
                                        child: Text(s.name),
                                      )),
                            ],
                            onChanged: _onSearchSelected,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontSize: 16),
                            icon: const Icon(Icons.arrow_drop_down, size: 28),
                            dropdownColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedSearch != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                    onPressed: _onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
