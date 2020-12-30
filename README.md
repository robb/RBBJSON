# RBBJSON

<p align="left">
    <img src="https://img.shields.io/badge/Swift_Version-5.2-orange.svg?style=flat&logo=Swift" alt="Swift Version: 5.2" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/SwiftPM-Compatible-darkgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <a href="https://twitter.com/DLX">
        <img src="https://img.shields.io/badge/Twitter-@DLX-blue.svg?style=flat&logo=Twitter" alt="Twitter: @DLX" />
    </a>
</p>

RBBJSON enables flexible JSON traversal at runtime and [JSONPath]-like querying for rapid prototyping.

Use `JSONDecoder` to create an `RBBJSON` struct, then traverse it using [dynamic member lookup][dml]:

```swift
let json = try JSONDecoder().decode(RBBJSON.self, from: data)

json.firstName         // RBBJSON.string("John")
json.lastName          // RBBJSON.string("Appleseed")
json.age               // RBBJSON.number(26)
json.invalidKey        // RBBJSON.null
json.phoneNumbers[0]   // RBBJSON.string("+14086065775")
```

If you want to access a value that coincides with a Swift-defined property, use a `String` subscript instead:

```swift
json.office.map     // Error: Maps to Sequence.map
json.office["map"]  // RBBJSON.string("https://maps.apple.com/?q=IL1")
```

To unbox a JSON value, use one of the failable initializers:

```swift
String(json.firstName) // "John"
String(json.lastName)  // "Appleseed"
String(json.age)       // nil

Int(json.age)          // 26
Double(json.age)       // 26.0
```

You can also make use of a [JSONPath]-inspired Query syntax to find nested data inside a JSON structure.

For example, given:

```json
{ 
  "store": {
    "book": [ 
      { 
        "category": "reference",
        "author": "Nigel Rees",
        "title": "Sayings of the Century",
        "price": 8.95
      },
      { 
        "category": "fiction",
        "author": "Evelyn Waugh",
        "title": "Sword of Honour",
        "price": 12.99
      },
      { 
        "category": "fiction",
        "author": "Herman Melville",
        "title": "Moby Dick",
        "isbn": "0-553-21311-3",
        "price": 8.99
      },
      { 
        "category": "fiction",
        "author": "J. R. R. Tolkien",
        "title": "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        "price": 22.99
      }
    ],
    "bicycle": {
      "color": "red",
      "price": 19.95
    }
  }
}
```

|JSONPath|RBBJSON|Result|
|-|-|-|
|`$.store.book[*].author`|`json.store.book[any: .child].author`|[The authors of all books in the store.](/Tests/RBBJSONTests/READMETests.swift#L46-L51)|
|`$..author`|`json[any: .descendantOrSelf].author`|[All authors.](/Tests/RBBJSONTests/READMETests.swift#L56-L61)|
|`$.store.*`|`json.store[any: .child]`|[All things in the store, a list of books an a red bycicle.](/Tests/RBBJSONTests/READMETests.swift#L66-L99)|
|`$.store..price`|`json.store[any: .descendantOrSelf].price`|[All prices in the store.](/Tests/RBBJSONTests/READMETests.swift#L104-L110)|
|`$..book[2]`|`json[any: .descendantOrSelf].book[2]`|[The second book.](/Tests/RBBJSONTests/READMETests.swift#L115-L123)|
|`$..book[-2]`|`json[any: .descendantOrSelf].book[-2]`|[The second-to-last book.](/Tests/RBBJSONTests/READMETests.swift#L128-L136)|
|`$..book[0,1]`, `$..book[:2]`|`json[any: .descendantOrSelf].book[0, 1])`, `json[any: .descendantOrSelf].book[0...1])`, `json[any: .descendantOrSelf].book[0..<2])`|[The first two books.](/Tests/RBBJSONTests/READMETests.swift#L141-L154)|
|`$..book[?(@.isbn)]`|`json[any: .descendantOrSelf].book[has: \.isbn]`|[All books with an ISBN number.](/Tests/RBBJSONTests/READMETests.swift#L159-L174)|
|`$..book[?(@.price<10)]`|`json.store.book[matches: { $0.price <= 10 }]`|[All books cheaper than `10`.](/Tests/RBBJSONTests/READMETests.swift#L179-L193)|
|`$.store["book", "bicycle"]..["price", "author"]`|`json.store["book", "bicycle"][any: .descendantOrSelf]["price", "author"]`|[The author (where available) and price of every book or bicycle.](/Tests/RBBJSONTests/READMETests.swift#L203-L223)|

Once you query a JSON value using one of the higher order selectors, the resulting type of the expression will be a lazy `RBBJSON.Query`:

```swift
json.store.book[0]["title"]     // RBBJSON.string("Sayings of the Century")
json.store.book[0, 1]["title"]  // RBBJSON.Query
```

Because `RBBJSON.Query` conforms to `Sequence`, you can initialize an `Array` with it to obtain the results or use e.g. `compactMap`:

```swift
String(json.store.book[0].title)                    // "Sayings of the Century"
json.store.book[0, 1].title.compactMap(String.init) // ["Sayings of the Century", "Sword of Honour"]

String(json.store.book[0]["invalid Property"])                    // nil
json.store.book[0, 1]["invalid Property"].compactMap(String.init) // []
```

---



[jsonpath]: https://goessner.net/articles/JsonPath/
[dml]: https://oleb.net/blog/2018/06/dynamic-member-lookup/
