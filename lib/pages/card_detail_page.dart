// Backwards-compatible export for the newer CardDetailPage implementation.
// Some files (and tests) still import `pages/card_detail_page.dart`.
export 'card_detail_page_new.dart';

// This file re-exports the newer implementation so imports referencing
// `pages/card_detail_page.dart` get `CardDetailPage` from
// `card_detail_page_new.dart`.
