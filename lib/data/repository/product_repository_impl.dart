import '../../domain/repository/product_repository.dart';
import '../../domain/model/product.dart';
import '../data_source/product_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource _dataSource;

  const ProductRepositoryImpl(this._dataSource);

  @override
  Future<List<Product>> getProducts() async {
    return await _dataSource.getProducts();
  }

  @override
  Future<Product?> getProductById(String id) async {
    return await _dataSource.getProductById(id);
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    return await _dataSource.getProductByBarcode(barcode);
  }
}
