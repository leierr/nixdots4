import { Variable } from 'resource:///com/github/Aylur/ags/variable.js';
import Utils from "resource:///com/github/Aylur/ags/utils.js";

// Create a shared weather data variable
const weatherData = new Variable({
  temperature: '',
  weatherIcon: 'unknown'
});

// Function to fetch weather data and update the shared variable
function fetchWeather() {
  Utils.fetch('https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=59.91272&lon=10.74609', {
    headers: { 'User-Agent': 'Lars Smith Eier/1.0 (lars.smith.eier@gmail.com)' }
  })
  .then(response => response.text())
  .then(rawData => {
      try {
          const data = JSON.parse(rawData);
          const weather = data.properties.timeseries[0];
          const temperature = `${Math.round(weather.data.instant.details.air_temperature)}`;
          const weatherIcon = `${App.configDir}/assets/weather/${weather.data.next_1_hours.summary.symbol_code}.svg`;

          weatherData.setValue({ temperature, weatherIcon });
      } catch (error) {
          console.error("Failed to parse JSON:", error);
      }
  })
  .catch(err => {
      console.error("Error fetching weather:", err);
  });
}

// Fetch weather data initially and set an interval to update every hour
fetchWeather();
Utils.interval(3600000, fetchWeather);

// Function to create a weather widget that hooks onto the shared weatherData variable
export default () => Widget.Box({
  class_name: 'topbar_submodules_weather_widget',
  spacing: 0,
  children: [
    Widget.Icon({ icon: weatherData.value.weatherIcon, }),
    Widget.Box({
      spacing: 0,
      children: [
        Widget.Label({ label: weatherData.value.temperature }),
        Widget.Label({ label: "°C", class_name: "topbar_submodules_weather_widget_celsius", }),
      ],
    }),
  ]
}).hook(weatherData, (self) => {
  self.children[1].children[0].label = weatherData.value.temperature
  self.children[0].icon = weatherData.value.weatherIcon
})