abstract class ApiEndpoints {
  static const auth = _AuthEndpoints();
  static const admin = _AdminEndpoints();
  static const products = _ProductEndpoints();
  static const banners = _BannerEndpoints();
  static const wishlist = _WishlistEndpoints();
  static const cart = _CartEndpoints();
  static const addresses = _AddressEndpoints();
  static const payments = _PaymentEndpoints();
  static const orders = _OrderEndpoints();
}

class _AuthEndpoints {
  const _AuthEndpoints();

  final String register = "/api/auth/register";
  final String login = "/api/auth/login";
  final String refresh = "/api/auth/refresh";
  final String logout = "/api/auth/logout";
  final String me = "/api/auth/me";
}

class _AdminEndpoints {
  const _AdminEndpoints();

  final String users = "/api/admin/users";

  String userById(String userId) => "/api/admin/users/$userId";

  String updateRole(String userId) => "/api/admin/users/$userId/role";
}

class _ProductEndpoints {
  const _ProductEndpoints();

  final String list = "/api/products";

  String byId(String productId) => "/api/products/$productId";
}

class _BannerEndpoints {
  const _BannerEndpoints();

  final String list = "/api/banners";
}

class _WishlistEndpoints {
  const _WishlistEndpoints();

  final String list = "/api/wishlist";
  final String add = "/api/wishlist";

  String remove(String productId) => "/api/wishlist/$productId";
}

class _CartEndpoints {
  const _CartEndpoints();

  final String get = "/api/cart";
  final String addItem = "/api/cart/items";
  final String clear = "/api/cart/clear";

  String updateItem(String productId) => "/api/cart/items/$productId";
  String removeItem(String productId) => "/api/cart/items/$productId";
}

class _AddressEndpoints {
  const _AddressEndpoints();

  final String list = "/api/addresses";
  final String create = "/api/addresses";

  String update(String id) => "/api/addresses/$id";
  String delete(String id) => "/api/addresses/$id";
}

class _PaymentEndpoints {
  const _PaymentEndpoints();

  final String methods = "/api/payments/methods";
  final String process = "/api/payments/process";
}

class _OrderEndpoints {
  const _OrderEndpoints();

  final String create = "/api/orders";
  final String list = "/api/orders";

  String byId(String id) => "/api/orders/$id";
}
