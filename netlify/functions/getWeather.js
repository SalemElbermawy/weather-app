const fetch = require('node-fetch'); // للتأكد من دعم Node

exports.handler = async function(event, context) {
  try {
    const city = event.queryStringParameters.city; // اسم المدينة من request
    const apiKey = "c277de7b55594a17731f1fc905f115ba"; // استبدل بمفتاحك
    const response = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}`);
    
    if (!response.ok) {
      return {
        statusCode: response.status,
        body: JSON.stringify({ error: "Failed to fetch weather data" }),
      };
    }

    const data = await response.json();
    return {
      statusCode: 200,
      body: JSON.stringify(data),
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message }),
    };
  }
};
