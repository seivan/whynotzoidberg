import PackageDescription

let package = Package(
    name: "whynotzoidberg",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 0),
//        .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 1, minor: 7),
        .Package(url: "https://github.com/vapor/mongo-driver.git", majorVersion: 1)
//        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1, minor:0),




    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Tests",
    ]
)

