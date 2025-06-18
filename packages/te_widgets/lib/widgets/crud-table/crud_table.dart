import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

class TCrudTable<T> extends StatefulWidget {
  final List<TTableHeader<T>> headers;
  final int itemsPerPage;
  final List<int> itemsPerPageOptions;

  final List<T>? items;
  final TLoadListener<T>? onLoad;
  final List<T>? archivedItems;
  final TLoadListener<T>? onArchiveLoad;

  final TFormBase? createForm;

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
  });

  @override
  State<TCrudTable<T>> createState() => _TCrudTableState<T>();
}

class _TCrudTableState<T> extends State<TCrudTable<T>> {
  bool get showCreateForm => widget.createForm != null;
  bool get showArchiveTable => widget.onArchiveLoad != null || widget.archivedItems != null;
  late ValueNotifier<String> searchNotifier;

  @override
  void initState() {
    super.initState();
    searchNotifier = ValueNotifier('');
  }

  @override
  void dispose() {
    searchNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 25,
      children: [
        _buildTopBar(),
        TDataTable<T>(
          headers: widget.headers,
          items: widget.items,
          onLoad: widget.onLoad,
          searchNotifier: searchNotifier,
        ),
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
          if (showCreateForm)
            TButton(
              type: TButtonType.outline,
              size: TButtonSize.lg,
              icon: Icons.add,
              text: 'Add New Item',
              color: AppColors.primary,
              onPressed: (_) => {},
            ),
          SizedBox(width: 1, height: 1),
          Wrap(
            spacing: 25,
            runSpacing: 5,
            children: [
              if (showArchiveTable)
                TTabs(inline: true, tabs: [
                  TTab(text: 'Active'),
                  TTab(text: 'Archive'),
                ]),
              SizedBox(
                  width: 250,
                  child: TTextField(
                    placeholder: 'Search',
                    postWidget: Icon(Icons.search_rounded, color: AppColors.grey.shade500),
                    size: TInputSize.sm,
                    valueNotifier: searchNotifier,
                  )),
            ],
          )
        ],
      ),
    );
  }
}
