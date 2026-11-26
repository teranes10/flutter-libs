import 'package:flutter_test/flutter_test.dart';
import 'package:te_widgets/te_widgets.dart';

/// Live data replacing a client-side list must not move the viewer: same page, same loaded rows, updated content.
void main() {
  List<String> rows(int n, [String tag = '']) => [for (var i = 0; i < n; i++) 'r$i$tag'];

  TListController<String, String> controller(List<String> items) {
    final c = TListController<String, String>(itemKey: (s) => s.replaceAll(RegExp(r'[^r0-9]'), ''), items: items, itemsPerPage: 10);
    addTearDown(c.dispose);
    return c;
  }

  test('replacing the items keeps the current page and shows the new row contents', () {
    final c = controller(rows(35));
    c.handlePageChange(3);
    expect(c.displayItems.first.data, 'r20');

    c.updateItems(rows(35, '!'));
    expect(c.page, 3);
    expect(c.displayItems.first.data, 'r20!');
    expect(c.displayItems, hasLength(10));
  });

  test('a list that shrank under the current page stays on what is now the last page', () {
    final c = controller(rows(35));
    c.handlePageChange(4);
    c.updateItems(rows(18));
    expect(c.page, 2);
    expect(c.displayItems.map((x) => x.data), rows(18).skip(10));

    c.updateItems(const []);
    expect(c.page, 1);
    expect(c.displayItems, isEmpty);
  });

  test('after infinite scroll loaded more, a replace keeps every loaded row', () {
    final c = controller(rows(35));
    c.handleLoadMore();
    c.handleLoadMore();
    expect(c.displayItems, hasLength(30));

    c.updateItems(rows(35, '!'));
    expect(c.displayItems, hasLength(30));
    expect(c.displayItems.last.data, 'r29!');
    expect(c.hasMoreItems, isTrue);
  });

  test('page 1 stays page 1', () {
    final c = controller(rows(35));
    c.updateItems(rows(40));
    expect(c.page, 1);
    expect(c.displayItems.first.data, 'r0');
  });
}
