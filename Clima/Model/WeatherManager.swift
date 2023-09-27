//
//  WeatherManager.swift
//  Clima
//
//  Created by Fuat Bolat on 3.08.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager : WeatherManager ,weather : WeatherModel)
    func didFailWithError(error : Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=2f97984d6e780cbda5ef473fdce14fbc&units=metric"
    var delegate : WeatherManagerDelegate?
    //sağlıklı bir şekilde url oluşturulur
    func fetchWeather (cityName:String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    func fetchWeather (latitude :CLLocationDegrees ,longitude:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    //url isteği
    func performRequest (with urlString : String){
        //url oluştur
        if let url = URL(string: urlString){
            //URL SESSİON OLUŞUR
            let session = URLSession(configuration: .default)
            //give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if  error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                // temiz datanın geldiği yer
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather : weather)
                    }
                }
                
            }
           
            //start the task
            task.resume()
        }
    }
    //decode adilmemiş veri alınıyor burada decode adiliyor daha sonra weatherdata structuimzin içinde name e gidiyor
    func parseJSON(_ weatherData:Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
           let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            // decode olmuş veriyi alıyorum
           let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            //decode olmuş veriyi weathermodelre gönderiyorum
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
            
            
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }

        
    }
    

        
    
    
}
