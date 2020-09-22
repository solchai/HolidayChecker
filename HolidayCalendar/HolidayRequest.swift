//
//  HolidayRequest.swift
//  HolidayCalendar
//
//  Created by Solomon Chai on 2020-09-07.
//

import Foundation

enum HolidayError: Error {
    case noDataAvailable
    case cantProcessData
}

struct HolidayRequest {
    let resourceURL: URL
    let keyAPI = "cb5a03638a4a17901574b812e20a2fcbd1a14faf"
    
    init(searchText: String) {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy"
        let currentYear = format.string(from: date)
        let countryCode: String
        let inputYear: String
        var searchTextArr: [String]
        if searchText.contains(",") {
            searchTextArr = searchText.components(separatedBy: ",")
            countryCode = searchTextArr[0]
            inputYear = searchTextArr[1]
        } else {
            countryCode = searchText
            inputYear = ""
        }
        
        let resourceString = "https://calendarific.com/api/v2/holidays?api_key=\(keyAPI)&country=\(countryCode)&year=\(inputYear == "" ? currentYear : inputYear)"
        
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        self.resourceURL = resourceURL
    }
    
    func getHolidays(completion: @escaping(Result<[HolidayDetail], HolidayError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: resourceURL) {data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let holidaysResponse = try decoder.decode(HolidayResponse.self, from: jsonData)
                let holidayDetails = holidaysResponse.response.holidays
                completion(.success(holidayDetails))
            } catch {
                completion(.failure(.cantProcessData))
            }
        }
        dataTask.resume()
    }
}
