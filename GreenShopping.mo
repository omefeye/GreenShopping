import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Iter "mo:base/Iter";

actor GreenShoppingAssistant {

  // Ürün Veri Yapısı
  type Product = {
    id: Text;
    name: Text;
    category: Text;
    price: Float;
    ecoRating: Int; // 1-10 arasında puan
  };

  // Kullanıcı Veri Yapısı
  type User = {
    id: Text;
    name: Text;
    email: Text;
    ecoPoints: Int;
  };

  // Alışveriş Sepeti Veri Yapısı
  type Cart = {
    userId: Text;
    products: [Product];
  };

  // Ürün Veritabanı (HashMap kullanarak)
  let products = HashMap.HashMap<Text, Product>(10, Text.equal, Text.hash);
  let users = HashMap.HashMap<Text, User>(10, Text.equal, Text.hash);
  let carts = HashMap.HashMap<Text, Cart>(10, Text.equal, Text.hash);

  // Yeni ürün ekleme fonksiyonu
  public func addProduct(id: Text, name: Text, category: Text, price: Float, ecoRating: Int): async Bool {
    switch (products.get(id)) {
      case null {
        let product: Product = {
          id = id;
          name = name;
          category = category;
          price = price;
          ecoRating = ecoRating;
        };
        products.put(id, product);
        return true;
      };
      case (?_product) { return false; };
    }
  };

  // Ürün okuma fonksiyonu
  public query func getProduct(id: Text): async ?Product {
    return products.get(id);
  };

  // Tüm ürünleri okuma fonksiyonu
  public query func getAllProducts(): async [Product] {
    return Iter.toArray(products.vals());
  };

  // Kullanıcı kaydetme fonksiyonu
  public func registerUser(id: Text, name: Text, email: Text): async Bool {
    switch (users.get(id)) {
      case null {
        let user: User = {
          id = id;
          name = name;
          email = email;
          ecoPoints = 0;
        };
        users.put(id, user);
        return true;
      };
      case (?_user) { return false; };
    }
  };

  // Kullanıcı okuma fonksiyonu
  public query func getUser(id: Text): async ?User {
    return users.get(id);
  };

  // Tüm kullanıcıları okuma fonksiyonu
  public query func getAllUsers(): async [User] {
    return Iter.toArray(users.vals());
  };

  // Sepete ürün ekleme fonksiyonu
  public func addToCart(userId: Text, productId: Text): async Bool {
    switch (users.get(userId)) {
      case null { return false; };
      case (?user) {
        switch (products.get(productId)) {
          case null { return false; };
          case (?product) {
            switch (carts.get(userId)) {
              case null {
                let cart: Cart = {
                  userId = userId;
                  products = [product];
                };
                carts.put(userId, cart);
                return true;
              };
              case (?cart) {
                let updatedCart = {
                  cart with
                  products = Array.append(cart.products, [product]);
                };
                carts.put(userId, updatedCart);
                return true;
              };
            }
          }
        }
      }
    }
  };

  // Sepet okuma fonksiyonu
  public query func getCart(userId: Text): async ?Cart {
    return carts.get(userId);
  };

  //Çevre dostu ürün önerme fonksiyonu
  public query func recommendEcoFriendlyProducts(userId: Text): async [Product] {
    switch (users.get(userId)) {
      case null { return []; };
      case (?user) {
        return Iter.toArray<Product>(
          Iter.filter<Product>(
            products.vals(),
            func(product: Product) : Bool { product.ecoRating >= 8 }
          )
        );
      }
    }
  };
}
