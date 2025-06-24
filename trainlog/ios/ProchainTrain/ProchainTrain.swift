//
//  ProchainTrain.swift
//  ProchainTrain
//
//  Created by Antoine Waes on 18/04/2025.
//

import WidgetKit
import SwiftUI

struct Trip: Codable {
    let id: String
    let departureTime: String
    let departureStation: String
    let arrivalStation: String
    let trainNumber: String?
    let trainType: String?
    let distance: Double?
    let price: Double?
    let departureCityName: String?
    let arrivalCityName: String?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), nextTrips: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = UserDefaults(suiteName: "group.TrainLog.prochainTrain")
        
        var trips: [Trip]?
        if let jsonString = data?.string(forKey: "nextTrips"),
           let jsonData = jsonString.data(using: .utf8) {
            trips = try? JSONDecoder().decode([Trip].self, from: jsonData)
        }
        
        let entry = SimpleEntry(date: Date(), nextTrips: trips)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let data = UserDefaults(suiteName: "group.TrainLog.prochainTrain")
        
        var trips: [Trip]?
        if let jsonString = data?.string(forKey: "nextTrips"),
           let jsonData = jsonString.data(using: .utf8) {
            trips = try? JSONDecoder().decode([Trip].self, from: jsonData)
        }
        
        let entry = SimpleEntry(date: Date(), nextTrips: trips)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let nextTrips: [Trip]?
}

struct ProchainTrainEntryView : View {
    
    // Detect the current Family
    @Environment(\.widgetFamily) var family
    
    
    var entry: Provider.Entry
    
    var nextTrip: Trip? {
        entry.nextTrips?.first
    }
    
    private let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }()
    
    private let outputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM '-' HH:mm"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()

    // Nouvelle fonction pour formater le temps restant
    private func formatTimeRemaining(to departureDate: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: departureDate)
        
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        if days > 0 {
            return days == 1 ? "1 jour" : "\(days) jours"
        } else if hours > 0 {
            return hours == 1 ? "1 heure" : "\(hours) heures"
        } else if minutes > 0 {
            return minutes == 1 ? "1 min" : "\(minutes) mins"
        } else {
            return "Départ imminent"
        }
    }

    var body: some View {
        
        if family == .accessoryCircular {
            VStack(alignment: .center, spacing: 0) {
                if let trip = nextTrip {
                    if let departureDate = inputFormatter.date(from: trip.departureTime) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 15, height: 15)

                            Image(systemName: "train.side.front.car")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 10, height: 10)
                                .foregroundColor(.black) // Couleur inversée
                        }
                        
                        HStack(spacing: 4) {
                            Text(formatTimeRemaining(to: departureDate))
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.top, 4)
                        }
                        // Destination (6 premiers caractères)
                        Text(String(trip.arrivalStation.prefix(6)))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }}
            
        } else {
            // Build Widget for other families - Nouveau design harmonieux
            
            if let trip = nextTrip {
                ZStack {
                    // Arrière-plan avec gradient subtil en vert
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green.opacity(0.1), Color.white]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        // En-tête avec logo et temps restant
                        HStack {
                            Image("SNCF")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 18)
                            
                            Spacer()
                            
                            if let departureDate = inputFormatter.date(from: trip.departureTime) {
                                Text(formatTimeRemaining(to: departureDate))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.green.opacity(0.1))
                                    )
                            }
                        }
                        
                        // Trajet avec ville d'arrivée
                        VStack(alignment: .leading, spacing: 2) {
                            // Ville d'arrivée en plus grand
                            Text(trip.arrivalCityName ?? "")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.green)
                                .lineLimit(1)
                            
                            
                              
                                
                                Text("\(trip.arrivalStation)")
                                    .font(.system(size: 11))
                                .foregroundColor(.primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            
                        }
                        
                        Spacer()
                        
                        // Détails du train
                        HStack(spacing: 8) {
                            // Numéro de train
                            HStack(spacing: 4) {
                                Image(systemName: "train.side.front.car")
                                    .font(.system(size: 10))
                                    .foregroundColor(.green)
                                Text(trip.trainNumber ?? "")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            // Type de train
                            Text(trip.trainType ?? "")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.green)
                                )
                        }
                        
                        // Date et heure de départ
                        if let departureDate = inputFormatter.date(from: trip.departureTime) {
                            Text(outputFormatter.string(from: departureDate))
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                }
            } else {
                // État vide
                VStack(spacing: 8) {
                    Image(systemName: "train.side.front.car")
                        .font(.system(size: 24))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("Aucun voyage prévu")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }}
}

struct ProchainTrain: Widget {
    let kind: String = "ProchainTrain"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ProchainTrainEntryView(entry: entry)
                    .containerBackground(.white, for: .widget)
            } else {
                ProchainTrainEntryView(entry: entry)
                    .padding()
                    .background(Color.white)
            }
        }
        .configurationDisplayName("Prochain Voyage")
        .contentMarginsDisabled() // Here
        .description("Affiche le nombre de jours avant votre prochain départ.")
        .supportedFamilies([
              .systemSmall,
              .accessoryCircular
          ])
    }
}

#Preview(as: .systemSmall) {
    ProchainTrain()
} timeline: {
    SimpleEntry(date: .now, nextTrips: [
        Trip(
            id: "1",
            departureTime: "2025-04-24T14:04:00.000",
            departureStation: "Paris",
            arrivalStation: "Lyon",
            trainNumber: "TGV 6942",
            trainType: "TGV",
            distance: 450,
            price: 65,
            departureCityName: "Paris",
            arrivalCityName: "Lyon"
        )
    ])
    SimpleEntry(date: .now, nextTrips: nil)
}
