import UIKit

struct nameStr {
    let name: String
    let age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

var greeting = [
    nameStr(name: "Alex", age: 33),
    nameStr(name: "Rob", age: 22),
    nameStr(name: "Rick", age: 44)
]

for greet in greeting {
    print("\(greet.name)")
}
