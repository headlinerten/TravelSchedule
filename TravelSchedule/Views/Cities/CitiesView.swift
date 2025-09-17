import SwiftUI

struct CitiesView: View {
    @StateObject var viewModel = CitiesViewModel()
    @Binding var selectedCity: Cities?
    @Binding var selectedStation: RailwayStations?
    @State private var searchCity = ""
    let isSelectingFrom: Bool
    @Binding var navigationPath: NavigationPath
    
    private var filteredCities: [Cities] {
        searchCity.isEmpty ? viewModel.city : viewModel.city.filter { $0.cityName.lowercased().contains(searchCity.lowercased()) }
    }
    
    var body: some View {
        VStack {
            // Header с кнопкой назад и заголовком
            ZStack {
                HStack {
                    Button(action: {
                        navigationPath.removeLast()
                    }) {
                        Image(systemName: "chevron.left")
                            .frame(width: 17, height: 26)
                            .foregroundStyle(.blackDay)
                    }
                    Spacer()
                }
                Text("Выбор города")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Проверяем состояние загрузки
            if viewModel.isLoading {
                Spacer()
                ProgressView("Загрузка городов...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                Spacer()
            } else if let error = viewModel.error {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Ошибка загрузки")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.blackDay)
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Button(action: {
                        Task {
                            await viewModel.loadCities()
                        }
                    }) {
                        Text("Повторить")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blueUniversal)
                            .cornerRadius(10)
                    }
                }
                Spacer()
            } else {
                // Поисковая строка
                SearchBar(searchText: $searchCity)
                    .padding(.bottom, 16)
                
                // Список городов
                ScrollView {
                    if filteredCities.isEmpty {
                        VStack {
                            Spacer()
                            Text("Город не найден")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.blackDay)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 238)
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                        .padding(.bottom, 200)
                    } else {
                        LazyVStack {
                            ForEach(filteredCities) { city in
                                Button(action: {
                                    selectedCity = city
                                    // Если у города есть станции, переходим к выбору станции
                                    if !city.stations.isEmpty {
                                        navigationPath.append(Destination.stations(city: city, isSelectingFrom: isSelectingFrom))
                                    } else {
                                        // Если станций нет, возвращаемся назад
                                        // (можно показать алерт, что у города нет станций)
                                        navigationPath.removeLast()
                                    }
                                }) {
                                    CityRowView(city: city)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 9, bottom: 4, trailing: 4))
                                        .foregroundStyle(.blackDay)
                                        .listRowSeparator(.hidden)
                                }
                            }
                            .listStyle(.plain)
                            .listRowSeparator(.hidden)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Если города еще не загружены и не идет загрузка, запускаем загрузку
            if viewModel.city.isEmpty && !viewModel.isLoading {
                Task {
                    await viewModel.loadCities()
                }
            }
        }
    }
}

#Preview {
    CitiesView(
        selectedCity: .constant(nil),
        selectedStation: .constant(nil),
        isSelectingFrom: true,
        navigationPath: .constant(NavigationPath())
    )
}
