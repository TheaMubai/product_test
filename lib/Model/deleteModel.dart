class Deletemodel{
  late final int productID;
  late final int index;
  Deletemodel({required this.index,required this.productID});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deletemodel &&
          runtimeType == other.runtimeType &&
          productID == other.productID;

  @override
  int get hashCode => productID.hashCode;
}