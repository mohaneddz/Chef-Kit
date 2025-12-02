abstract class ChefsEvent {}

class LoadChefs extends ChefsEvent {}

class GoToChefsPage extends ChefsEvent {
  final int page;
  GoToChefsPage(this.page);
}
