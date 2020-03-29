import 'package:flutter/cupertino.dart';

class ListModel<T> extends ChangeNotifier {
  List<T> _list = [];
  ListModel(this._list);

  List<T> get list => _list;
  set list(List<T> es) {
    this._list = es;
    print('set ===== >   notifyListeners');
    notifyListeners();
  }

  add(T entity) {
    this._list.add(entity);
    print('add ===== >   notifyListeners');
    notifyListeners();
  }

  remove(bool where(T t)) {
    this._list.removeWhere((e) => where(e));
    print('remove ===== >   notifyListeners');
    notifyListeners();
  }

  update(T t, bool where(T t)) {
    try {
      print('update ===== >   notifyListeners');
      int index = _list.indexWhere((e) => where(e));
      _list[index] = t;
      notifyListeners();
    } catch (e) {}
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
