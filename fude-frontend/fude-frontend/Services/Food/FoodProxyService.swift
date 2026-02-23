import Foundation

// Text search via your Go backend proxy, which calls USDA FoodData Central.
// Backend must be running (see fude-backend/) for this to work.
// API key is kept server-side — never in the iOS app.

struct FoodProxyService {
    private let client = NetworkClient()

    func search(query: String) async throws -> [FoodItem] {
        var components = URLComponents(
            url: AppConfiguration.backendBaseURL.appendingPathComponent("/api/food/search"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [URLQueryItem(name: "q", value: query)]

        guard let url = components?.url else { throw APIError.invalidURL }

        let response: FoodSearchResponse = try await client.get(url: url)
        return response.foods.map { $0.toFoodItem() }
    }

    func detail(fdcId: String) async throws -> FoodItem {
        let url = AppConfiguration.backendBaseURL
            .appendingPathComponent("/api/food/\(fdcId)")

        let dto: USDAFoodDTO = try await client.get(url: url)
        return dto.toFoodItem()
    }
}

// MARK: - Response DTOs

private struct FoodSearchResponse: Decodable {
    let foods: [USDAFoodDTO]
}

struct USDAFoodDTO: Decodable {
    let fdcId: Int
    let description: String
    let brandOwner: String?
    let brandName: String?
    let foodNutrients: [USDANutrient]
    /// Serving size amount; unit is given by servingSizeUnit (e.g. 28.35 oz, 100 g)
    let servingSize: Double?
    let servingSizeUnit: String?

    func toFoodItem() -> FoodItem {
        let item = FoodItem(
            externalID: String(fdcId),
            source: FoodSource.usda,
            name: description
        )
        item.brand = brandName ?? brandOwner

        // USDA nutrient IDs:
        // 1008 = Energy (kcal), 1003 = Protein, 1005 = Carbohydrate, 1004 = Total Fat
        // 1079 = Fiber, 2000 = Sugars, 1093 = Sodium
        item.caloriesPer100g = nutrientValue(id: 1008) ?? 0
        item.proteinPer100g = nutrientValue(id: 1003) ?? 0
        item.carbohydratesPer100g = nutrientValue(id: 1005) ?? 0
        item.fatPer100g = nutrientValue(id: 1004) ?? 0
        item.fiberPer100g = nutrientValue(id: 1079).map { $0 == 0 ? nil : $0 } ?? nil
        item.sugarPer100g = nutrientValue(id: 2000).map { $0 == 0 ? nil : $0 } ?? nil
        item.sodiumPer100mg = nutrientValue(id: 1093).map { $0 == 0 ? nil : $0 } ?? nil

        // Serving size — convert to grams if the backend provides it
        if let size = servingSize, size > 0 {
            let unit = (servingSizeUnit ?? "g").lowercased()
            switch unit {
            case "oz":
                let grams = size * 28.3495
                item.servingSizeGrams = grams
                item.servingSizeDescription = String(format: "%.0f oz (%.0fg)", size, grams)
            default:
                // Treat g, ml, and unknown units as-is
                item.servingSizeGrams = size
                item.servingSizeDescription = String(format: "%.0f%@", size, servingSizeUnit ?? "g")
            }
        }

        return item
    }

    private func nutrientValue(id: Int) -> Double? {
        foodNutrients.first { $0.nutrientId == id }?.value
    }
}

struct USDANutrient: Decodable {
    let nutrientId: Int
    let value: Double?

    enum CodingKeys: String, CodingKey {
        case nutrientId = "nutrientId"
        case value = "amount"
    }
}
