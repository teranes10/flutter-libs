import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TCrudTable<T, F extends TFormBase> extends StatefulWidget {
  final List<TTableHeader<T>> headers;
  final int itemsPerPage;
  final List<int> itemsPerPageOptions;

  final List<T>? items;
  final TLoadListener<T>? onLoad;
  final List<T>? archivedItems;
  final TLoadListener<T>? onArchiveLoad;

  final F? createForm;
  final Future<T?> Function(F)? onAddItem;

  const TCrudTable({
    super.key,
    required this.headers,
    this.itemsPerPage = 5,
    this.itemsPerPageOptions = const [5, 10, 15, 25, 50],
    this.items,
    this.onLoad,
    this.onArchiveLoad,
    this.archivedItems,
    this.createForm,
    this.onAddItem,
  });

  @override
  State<TCrudTable<T, F>> createState() => _TCrudTableState<T, F>();
}

class _TCrudTableState<T, F extends TFormBase> extends State<TCrudTable<T, F>> {
  bool get showCreateForm => widget.createForm != null;
  bool get showArchiveTable => widget.onArchiveLoad != null || widget.archivedItems != null;
  late ValueNotifier<String> searchNotifier;
  late ValueNotifier<String> archiveSearchNotifier;
  final tableController = TPaginationController<T>();
  final archiveTableController = TPaginationController<T>();
  int currentTabIndex = 0;
  bool isArchiveLoaded = false;

  @override
  void initState() {
    super.initState();
    searchNotifier = ValueNotifier('');
    archiveSearchNotifier = ValueNotifier('');
  }

  @override
  void dispose() {
    searchNotifier.dispose();
    archiveSearchNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 25,
      children: [
        _buildTopBar(),
        _buildDataTable(),
      ],
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        spacing: 5,
        runSpacing: 5,
        children: [
          showCreateForm
              ? TButton(
                  type: TButtonType.outline,
                  size: TButtonSize.lg,
                  icon: Icons.add,
                  text: widget.createForm?.formActionName ?? 'Add New Item',
                  color: AppColors.primary,
                  onPressed: (_) => _addNewItem(),
                )
              : const SizedBox.shrink(),
          Wrap(
            spacing: 25,
            runSpacing: 5,
            children: [
              if (showArchiveTable)
                TTabs(
                    inline: true,
                    selectedIndex: currentTabIndex,
                    onTabChanged: (index) {
                      setState(() {
                        currentTabIndex = index;
                      });
                    },
                    tabs: [
                      TTab(text: 'Active'),
                      TTab(text: 'Archive'),
                    ]),
              SizedBox(
                width: 250,
                child: TTextField(
                  placeholder: 'Search',
                  postWidget: Icon(Icons.search_rounded, color: AppColors.grey.shade500),
                  size: TInputSize.sm,
                  valueNotifier: currentTabIndex == 0 ? searchNotifier : archiveSearchNotifier,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (!showArchiveTable) {
      return TDataTable<T>(
        headers: widget.headers,
        items: widget.items,
        onLoad: widget.onLoad,
        searchNotifier: searchNotifier,
        controller: tableController,
      );
    }

    return IndexedStack(
      index: currentTabIndex,
      children: [
        // Active items table
        TDataTable<T>(
          headers: widget.headers,
          items: widget.items,
          onLoad: widget.onLoad,
          searchNotifier: searchNotifier,
          controller: tableController,
        ),
        // Archive items table
        _buildArchiveTable(),
      ],
    );
  }

  Widget _buildArchiveTable() {
    if (currentTabIndex == 0 && !isArchiveLoaded) return SizedBox.shrink();

    isArchiveLoaded = true;
    return TDataTable<T>(
      headers: widget.headers,
      items: widget.archivedItems,
      onLoad: widget.onArchiveLoad,
      searchNotifier: archiveSearchNotifier,
      controller: archiveTableController,
    );
  }

  void _addNewItem() async {
    final value = await TFormService.show(context, widget.createForm!);
    if (value == null || widget.onAddItem == null) return;

    final item = await widget.onAddItem!.call(value);
    if (item == null) return;

    tableController.addItem(item);
  }
}
