import Foundation

// OpenFoodFacts barcode lookup — no API key required, called directly from iOS.
// API docs: https://world.openfoodfacts.org/data
// Endpoint: GET https://world.openfoodfacts.org/api/v2/product/{barcode}.json

struct OpenFoodFactsService {
    private let client = NetworkClient()
    private let baseURL = "https://world.openfoodfacts.org/api/v2/product"

    func lookup(barcode: String) async throws -> FoodItem {
        guard let url = URL(string: "\(baseURL)/\(barcode).json?fields=product_name,brands,nutriments,serving_size,image_url") else {
            throw APIError.invalidURL
        }

        let response: OFFProductResponse = try await client.get(url: url)

        guard response.status == 1, let product = response.product else {
            throw APIError.notFound
        }

        return product.toFoodItem(barcode: barcode)
    }
}

// MARK: - Response DTOs

private struct OFFProductResponse: Decodable {
    let status: Int
    let product: OFFProduct?
}

private struct OFFProduct: Decodable {
    let productName: String?
    let brands: String?
    let servingSize: String?
    let imageURL: String?
    let nutriments: OFFNutriments?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case servingSize = "serving_size"
        case imageURL = "image_url"
        case nutriments
    }

    func toFoodItem(barcode: String) -> FoodItem {
        let item = FoodItem(
            externalID: barcode,
            source: FoodSource.openFoodFacts,
            name: productName ?? "Unknown Product"
        )
        item.brand = brands?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces)
        item.servingSizeDescription = servingSize ?? "100g"
        item.imageURL = imageURL
        item.caloriesPer100g = nutriments?.caloriesPer100g ?? 0
        item.proteinPer100g = nutriments?.proteinsPer100g ?? 0
        item.carbohydratesPer100g = nutriments?.carbohydratesPer100g ?? 0
        item.fatPer100g = nutriments?.fatPer100g ?? 0
        item.fiberPer100g = nutriments?.fiberPer100g
        item.sugarPer100g = nutriments?.sugarsPer100g
        item.sodiumPer100mg = nutriments?.sodiumPer100g.map { $0 * 1000 } // g → mg
        return item
    }
}

private struct OFFNutriments: Decodable {
    let caloriesPer100g: Double?
    let proteinsPer100g: Double?
    let carbohydratesPer100g: Double?
    let fatPer100g: Double?
    let fiberPer100g: Double?
    let sugarsPer100g: Double?
    let sodiumPer100g: Double?

    // Note: OFF uses hyphens in JSON keys (energy-kcal_100g) — must use CodingKeys
    enum CodingKeys: String, CodingKey {
        case caloriesPer100g = "energy-kcal_100g"
        case proteinsPer100g = "proteins_100g"
        case carbohydratesPer100g = "carbohydrates_100g"
        case fatPer100g = "fat_100g"
        case fiberPer100g = "fiber_100g"
        case sugarsPer100g = "sugars_100g"
        case sodiumPer100g = "sodium_100g"
    }
}
