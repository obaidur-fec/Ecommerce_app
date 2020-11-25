class AppProperties {
  static String _baseApiUrl = 'http://10.0.2.2:3000/api/v1';

  static String productUrl = '$_baseApiUrl/products/';

  static String categoryUrl = '$_baseApiUrl/categories/';

  static String searchByCategoryOrNameUrl = '$_baseApiUrl/products/search/';

  static String searchByCategoryUrl = '$_baseApiUrl/products/search/category/';

  static String saveOrderUrl = '$_baseApiUrl/cart/flutter/stripepayment';

  static String payPalRequestUrl = '$_baseApiUrl/cart/braintree/paypalpayment/';

  static String signUpUrl = '$_baseApiUrl/users/signup';

  static String signInUrl = '$_baseApiUrl/users/signin';
}
